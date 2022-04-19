library farton;

import 'package:flutter/foundation.dart';

enum Types {
  ordinary,
  pruned_branch,
  library_reference,
  merkle_proof,
  merkle_update
}
enum Flavors { builder, slice, continuation }

class SmartContract {
  String _address = "";
  String _code = "";

  SmartContract(String direccion, String codigo) {
    _address = direccion;
    _code = codigo;

    debugPrint(_address, _code);
  }
}

class Cell {}
