import 'dart:convert';

import 'package:sid_bloc/persistence/persistence.dart';
import 'package:flutter/material.dart';

class CachedVar<T>{
  final String key;
  T privateValue;
  final dynamic Function(T) toJson;
  final T Function(dynamic) fromJson; 

  CachedVar(this.key, this.privateValue, {
    @required this.toJson,
    @required this.fromJson,
  }){
    this._read();
  }

  set value(T newVal) {
    this._write();
    this.privateValue = newVal;
  }

  T get value => this.privateValue;

  void forceWrite() => _write();
  void _write() async {
    final instance = await CachedDb.getInstance();
    instance.setString(this.key, jsonEncode(this.toJson(this.privateValue)));
  }

  void _read() async {
    final instance = await CachedDb.getInstance();
    String string = await instance.getString(this.key);

    if(string != null)
      try {
        this.privateValue = this.fromJson(jsonDecode(string));        
      } catch (e) {
        print("error calling from string");
      }
  }
}