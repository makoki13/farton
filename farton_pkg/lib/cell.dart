import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';

class Cell {
  late int _descriptor1; //Byte
  late int _descriptor2; //Byte
  late List<int> _data; //Uint8Array
  late List<int> _references; //Uint8Array

  Cell(int descriptor1, int descriptor2, List<int> data, List<int> references) {
    _descriptor1 = descriptor1;
    _descriptor2 = descriptor2;
    _data = data;
    _references = references;

    debugPrint(_data.length.toString() + _references.length.toString());
  }

  String sha256() {
    return sha1.convert([_descriptor1, _descriptor2]).toString();
    //_descriptor1.toString() + _descriptor2.toString() + _data.toString() + _references.toString()
  }
}
