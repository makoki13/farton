/* import EventEmitter from 'events'
import { Socket as SocketTCP } from 'net'
import {
    Socket as SocketUDP,
    createSocket
} from 'dgram'
import {
    createCipheriv,
    createDecipheriv,
    Cipher,
    Decipher
} from 'crypto'
import {
    ADNLPacket,
    PACKET_MIN_SIZE
} from './packet'
import { ADNLAESParams } from './params'
import { ADNLAddress } from './address'
import { ADNLKeys } from './keys'

 */

enum ADNLClientState {
    connecting,
    open,
    closing,
    closed
}

abstract class ADNLClientOptions {
    Set<String> type = <String>{'tcp4','udp4'};
}

abstract class ADNLSockets {
    Set<String> type = <String>{'SocketTCP','SocketUDP'};
}

abstract class InterfaceADNLClient {
    /* emit(event: 'connect'): boolean
    emit(event: 'ready'): boolean
    emit(event: 'close'): boolean
    emit(event: 'data', data: Buffer): boolean
    emit(event: 'error', error: Error): boolean

    on(event: 'connect', listener: () => void): this
    on(event: 'ready', listener: () => void): this
    on(event: 'close', listener: () => void): this
    on(event: 'data', listener: (data: Buffer) => void): this
    on(event: 'error', listener: (error: Error, close: boolean) => void): this

    once(event: 'connect', listener: () => void): this
    once(event: 'ready', listener: () => void): this
    once(event: 'close', listener: () => void): this
    once(event: 'data', listener: (data: Buffer) => void): this
    once(event: 'error', listener: (error: Error, close: boolean) => void): this */
}

class EventEmitter {
    /* emit(event: string, ...args: any[]): boolean
    emit(event: symbol, ...args: any[]): boolean */
}

class ADNLClient extends EventEmitter {
    String _host;
    int _port;
    ADNLSockets _socket;



    private buffer: Buffer

    private address: ADNLAddress

    private params: ADNLAESParams

    private keys: ADNLKeys

    private cipher: Cipher

    private decipher: Decipher

    private _state = ADNLClientState.CLOSED

    ADNLClient (host: string, port: number, peerPublicKey: Uint8Array | string, options?: ADNLClientOptions) {
        super()

        const { type = 'tcp4' } = options || {}

        this.host = host
        this.port = port
        this.address = new ADNLAddress(peerPublicKey)

        if (type === 'tcp4') {
            this.socket = new SocketTCP()
                .on('connect', this.onConnect.bind(this))
                .on('ready', this.handshake.bind(this))
                .on('close', this.onClose.bind(this))
                .on('data', this.onData.bind(this))
                .on('error', this.onError.bind(this))
        } else if (type === 'udp4') {
            this.socket = createSocket(type)
                .on('connect', () => {
                    this.onConnect()
                    this.handshake()
                })
                .on('close', this.onClose.bind(this))
                .on('message', this.onData.bind(this))
                .on('error', this.onError.bind(this))
        } else {
            throw new Error('ADNLClient: Type must be "tcp4" or "udp4"')
        }
    }

    public get state (): ADNLClientState {
        return this._state
    }

    public connect (): void {
        if (this.state !== ADNLClientState.CLOSED) {
            return undefined
        }

        const { host, port } = this

        this.keys = new ADNLKeys(this.address.publicKey)
        this.params = new ADNLAESParams()
        this.cipher = createCipheriv('aes-256-ctr', this.params.txKey, this.params.txNonce)
        this.decipher = createDecipheriv('aes-256-ctr', this.params.rxKey, this.params.rxNonce)
        this.buffer = Buffer.from([])
        this._state = ADNLClientState.CONNECTING

        this.socket.connect(port, host)
    }

    public end (): void {
        if (this.state === ADNLClientState.CLOSING || this.state === ADNLClientState.CLOSED) {
            return undefined
        }

        this.socket instanceof SocketTCP
            ? this.socket.end()
            : this.socket.disconnect()
    }

    public write (data: Buffer): void {
        const packet = new ADNLPacket(data)
        const encrypted = this.encrypt(packet.data)

        this.socket instanceof SocketTCP
            ? this.socket.write(encrypted)
            : this.socket.send(encrypted)
    }

    private onConnect () {
        this.emit('connect')
    }

    private onReady (): void {
        this._state = ADNLClientState.OPEN
        this.emit('ready')
    }

    private onClose (): void {
        this._state = ADNLClientState.CLOSED
        this.emit('close')
    }

    private onData (data: Buffer): void {
        this.buffer = Buffer.concat([ this.buffer, this.decrypt(data) ])

        while (this.buffer.byteLength >= PACKET_MIN_SIZE) {
            const packet = ADNLPacket.parse(this.buffer)

            if (packet === null) {
                break
            }

            this.buffer = this.buffer.slice(packet.length, this.buffer.byteLength)

            if (this.state === ADNLClientState.CONNECTING) {
                packet.payload.length !== 0
                    ? this.onError(new Error('ADNLClient: Bad handshake.'), true)
                    : this.onReady()

                break
            }

            this.emit('data', packet.payload)
        }
    }

    private onError (error: Error, close = false): void {
        if (close) {
            this.socket instanceof SocketTCP
                ? this.socket.end()
                : this.socket.disconnect()
        }

        this.emit('error', error)
    }

    private handshake (): void {
        const key = Buffer.concat([ this.keys.shared.slice(0, 16), this.params.hash.slice(16, 32) ])
        const nonce = Buffer.concat([ this.params.hash.slice(0, 4), this.keys.shared.slice(20, 32) ])
        const cipher = createCipheriv('aes-256-ctr', key, nonce)
        const payload = Buffer.concat([ cipher.update(this.params.bytes), cipher.final() ])
        const packet = Buffer.concat([ this.address.hash, this.keys.public, this.params.hash, payload ])

        this.socket instanceof SocketTCP
            ? this.socket.write(packet)
            : this.socket.send(packet)
    }

    private encrypt (data: Buffer): Buffer {
        return Buffer.concat([ this.cipher.update(data) ])
    }

    private decrypt (data: Buffer): Buffer {
        return Buffer.concat([ this.decipher.update(data) ])
    }
}
