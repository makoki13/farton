import 'dart:typed_data';

class ShardPrefix {
  final _data = BytesBuilder(); //Uint8Array
  shardPrefix() {
    _data.add([0,0,0,0,0,0,0,0]);
  }
}