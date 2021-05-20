import 'dart:convert';

import 'package:sid_bloc/persistence/persistence.dart';

class SharedVar<T>{
  final String key;
  T _value;
  final dynamic Function(T) toJson;
  final T Function(dynamic) fromJson; 

  SharedVar(this.key, this._value, {
    required this.toJson,
    required this.fromJson,
  }){
    this._read();
  }

  set value(T value) {
    this._write();
    this._value = value;
  }

  T get value => this._value;

  void _write() async {
    final SharedDb? instance = await SharedDb.getInstance();
    if(instance == null) return;

    instance.setString(this.key, jsonEncode(this.toJson(this._value)));
  }

  void _read() async {
    final SharedDb? instance = await SharedDb.getInstance();
    if(instance == null) return;

    String? string = await instance.getString(this.key);

    if(string != null)
      try {
        this._value = this.fromJson(jsonDecode(string));        
      } catch (e) {
        print("error calling from string");
      }
  }
}