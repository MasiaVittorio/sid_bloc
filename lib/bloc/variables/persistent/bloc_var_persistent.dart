import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sid_bloc/persistence/shared_db.dart';
// import 'package:sid_bloc/persistence_hive/persistence.dart';

import '../../bloc.dart';

import 'dart:convert';


class PersistentVar<T> extends BlocVar<T>{

  PersistentVar({
    @required this.initVal,
    @required this.key,   
    this.fromJson,
    this.toJson, 
    BlocVar<Map<String,bool>> readCount,
    this.readCallback,
    void Function(T) onChanged,
    bool Function(T, T) equals,
    T Function(T) copier,
    this.verboseRead = false,
    // this.hiveOverSqflite = false,
  }):super(initVal, onChanged: onChanged, equals: equals, copier: copier){

    if(readCount != null){
      readCount.value[this.key] = false;
      readCount.refresh();
    }
    this._read().then((_){
      if(this.verboseRead == true) 
        print("after reading $key");

      this.reading = false;
      if(readCount != null){
        readCount.value[this.key] = true;
        readCount.refresh();
      }
      if(this.verboseRead == true) 
        print("read callback != null? ${readCallback != null}");

      this.readCallback?.call(this.value);
    });
  }
  T initVal;

  final String key;
  bool reading = true;

  void Function(T value) readCallback;

  final T Function(dynamic json) fromJson;
  final FutureOr<dynamic> Function(T element) toJson;

  final bool verboseRead;
  // final bool hiveOverSqflite;

  @override
  void set(newVal, {bool withoutWriting = false}){
    super.set(newVal);
    if(!withoutWriting) 
      this._write();
  }

  @override
  bool setDistinct(newVal, {bool withoutWriting = false}){
    bool result = super.setDistinct(newVal);
    if(!withoutWriting) 
      this._write();
    return result;
  }

  @override
  void refresh(){
    super.refresh();
    this._write();
  }

  @override
  void edit(void Function(T) editor){
    super.edit(editor);
    this._write();
  }


  Future<void> _read() async {

    if(this.verboseRead == true) 
      print("reading $key");
    dynamic instance;

    // if(hiveOverSqflite)
    //   instance = await SharedBox.getInstance();
    // else 
    //   instance = await SharedDb.getInstance();
    instance = await SharedDb.getInstance();

    final String jsonString = await instance.getString(this.key) ?? '';


    if(jsonString == ''){
      if(this.verboseRead == true) 
        print("jsonString was empty or null");
        return;
    }
    if(this.verboseRead == true) 
      print("read $T 1 string $jsonString");

    dynamic jsonObject;
    bool error = false;
    try{
       jsonObject = jsonDecode(jsonString);
    } catch(e) {
      error = true;
    }

    if(this.verboseRead == true) 
      print("read $T 2 error: $error");
    if (error) 
      return;

    dynamic result = this.fromJson?.call(jsonObject) ?? jsonObject;

    if(this.verboseRead == true) 
      print("read $T 3 result $result");

    if(result is T) /// if T is a nullable type, then "null is T" is true :D
      this.set(result, withoutWriting: true);
    else 
      print('read error $T');
  }

  void _write() async {
    dynamic instance;

    // if(hiveOverSqflite)
    //   instance = await SharedBox.getInstance();
    // else 
    //   instance = await SharedDb.getInstance();
    instance = await SharedDb.getInstance();

    String jsonString = jsonEncode(
      await this.toJson?.call(this.value) ?? this.value
    );
    
    instance.setString(this.key, jsonString);
  }
}
