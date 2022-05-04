//import { createHash } from 'crypto'

class ADNLAddress {
  late List<int> _publicKey;

  ADNLAddress(List<int> publicKey) {
    _publicKey = publicKey;

    var value = ADNLAddress._isBytes(publicKey) ? publicKey : publicKey;

    if (ADNLAddress._isBytes(value)) {
      _publicKey = value;
    } else if (ADNLAddress._isHex(value)) {
      //_publicKey = new Uint8Array(Buffer.from(value as string, 'hex'))
    } else if (ADNLAddress._isBase64(value)) {
      //_publicKey = new Uint8Array(Buffer.from(value as string, 'base64'))
    }

    /* if (this._publicKey.length !== 32) {
            throw new Error('ADNLAddress: Bad peer public key. Must contain 32 bytes.')
        } */
  }

  List<int> publicKey() {
    return _publicKey;
  }

  List<int> hash() {
    /* const hash = createHash('sha256')
        const typeEd25519 = new Uint8Array([ 0xc6, 0xb4, 0x13, 0x48 ])

        hash.update(typeEd25519)
        hash.update(this._publicKey)

        return new Uint8Array(hash.digest()) */

    return _publicKey; //AITANA
  }

  static bool _isBytes(data) {
    //return ArrayBuffer.isView(data);

    return false; //AITANA
  }

  static bool _isHex(data) {
    //const re = /^[a-fA-F0-9]+$/

    //return typeof data === 'string' && re.test(data)

    return false; //AITANA
  }

  static bool _isBase64(data) {
    // eslint-disable-next-line no-useless-escape
    //const re = /^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=)?$/
    //return typeof data === 'string' && re.test(data)

    return false;
  }
}
