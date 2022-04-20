library farton_pkg;

import 'package:flutter/foundation.dart';

import './utiles.dart';
import './shard_prefix.dart';

/* enum Types {
  ordinary,
  prunedBranch,
  libraryReference,
  merkleProof,
  merkleUpdate
}
enum Flavors { builder, slice, continuation }

class SmartContract {
  String _address = "";
  String _code = "";

  SmartContract(String direccion, String codigo) {
    _address = direccion;
    _code = codigo;

    debugPrint(_address + _code);
  }
}

class Cell {} */

class Block {}

class Blockchain {
  final List<Block> _listaBlocks = {} as List<Block>;

  Blockchain() {
    debugPrint(_listaBlocks.length.toString());
  }
}

class Masterchain extends Blockchain {
  static int id = 0;
  static int nextWorkchainId = 0;

  Workchain getNewWorkchain() {
    nextWorkchainId++;
    return Workchain(nextWorkchainId);
  }
}

class Shardchain extends Blockchain {
  int _id = 0; //Uint32
  final shardPrefix _prefix = shardPrefix(); //Uint8Array

  Shardchain(int id) {
    if (Utiles.isUint32(id)) {
      _id = id;
    } else {
      throw Exception("id must be a uint32");
    }

    debugPrint(
        _listaBlocks.length.toString() + _id.toString() + _prefix.toString());
  }
}

class Workchain {
  final List<Shardchain> _shardchains = {} as List<Shardchain>;
  int _id = 0; //Uint32
  static int nextShadchainId = 0;

  Workchain(int id) {
    if (Utiles.isUint32(id)) {
      _id = id;
    } else {
      throw Exception("id must be a uint32");
    }

    debugPrint(_shardchains.length.toString() + _id.toString());
  }

  Shardchain getNewShardchain() {
    nextShadchainId++;
    return Shardchain(nextShadchainId);
  }
}
