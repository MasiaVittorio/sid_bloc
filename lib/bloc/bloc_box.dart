import 'dart:convert';

import 'package:sid_bloc/persistence/persistence.dart';
import 'bloc.dart';

import 'package:flutter/material.dart';
import 'package:sid_utils/sid_utils.dart';

class BlocBox<T> extends BlocVar<List<T>> {

  //=======================================================
  // Constructor
  BlocBox(List<T> _content, {
    @required this.key,
    @required this.itemToJson,
    @required this.jsonToItem,
    void Function(List<T>) onChanged,
    this.readCallback, 
    bool Function(List<T>, List<T>) equals,
  }): super(
    _content,
    onChanged: onChanged,
    copier: (list) => <T>[for(final e in list) e],
    equals: equals,
  )
  {
    this._read().then((ok){
      // this._reread();
      this.reading = false;
      readCallback?.call(this.value);
    });
  }

  //=======================================================
  // Values

  final String key;
  final T Function(dynamic) jsonToItem;
  final dynamic Function(T) itemToJson;

  bool reading = true;
  void Function(List<T>) readCallback;

  //=======================================================
  // Getters
  Type get type => T;
  String get lenghtKey => this.key + "_lenght";
  String indexKey(int index) => this.key + "_$index";

  //=======================================================
  // Methods
  @override
  void set(List<T> newVal, {bool withoutWriting = false}){
    super.set(newVal);
    if(withoutWriting == false){
      this._write();
    }
  }
  @override
  bool setDistinct(newVal, {bool withoutWriting = false}){
    bool result = super.setDistinct(newVal);
    if(withoutWriting == false){
      this._write();
    } 
    return result;
  }

  void setIndex(int index, T newItem, {bool withoutWriting = false}){
    if(!this.value.checkIndex(index)) return;

    super.set(<T>[for(int i = 0; i < this.value.length; ++i)
      if(i == index) newItem
      else this.value[i],
    ]);
    if(withoutWriting == false){
      this._write(index: index);
    }
  }

  void add(T newItem, {bool withoutWriting = false}){
    super.set([...this.value, newItem]);
    if(withoutWriting == false){
      this._write(index: this.value.length -1);
    }
  }

  void removeAt(int index){
    this.value.removeAt(index);
    super.refresh(); 
    this._delete(index);
  }

  void removeLast(){
    this.removeAt(this.value.length -1);
  }

  @override
  void refresh({int index}){
    super.refresh();
    this._write(index: index);
  }

  //=======================================================
  // Persistence
  Future<bool> _read() async {
  
    final instance = await SharedDb.getInstance();

    final String lenghtString = await instance.getString(this.lenghtKey);
    if(lenghtString == null) return false; // not wrote anything yet

    int lenghtFromDisk; 
    bool error = false;
    try{
      lenghtFromDisk = jsonDecode(lenghtString);
    } catch(e) {
      error = true;
      print("unexpected error during lenght decoding of $key: error = $e");
    }
    if(error) return false;
    if(lenghtFromDisk == 0) return false;

    List<T> _content = <T>[];

    for(int i = 0; i < lenghtFromDisk; ++i){
      String itemString = await instance.getString(this.indexKey(i));
      if(itemString == null) continue;
      T item; 
      bool error = false;
      try{
        item = this.jsonToItem(jsonDecode(itemString));
      } catch(e) {
        error = true;
        print("unexpected error during item number $i decoding of $key: error = $e");
      }
      if(error) continue;

      _content.add(item);
    }

    if(_content.length != lenghtFromDisk){
      instance.setString(lenghtKey, jsonEncode(_content.length));
    }

    this.set(_content);

    return true;
  }

  // void _reread() async {

  //   final instance = await SharedDb.getInstance();
  //   final String jsonString = await instance.getString(this.key) ?? '';

  //   if(jsonString == '') {
  //     return;
  //   }
  //   dynamic jsonObject;
  //   bool error = false;
  //   try{
  //     jsonObject = jsonDecode(jsonString);
  //   } catch(e) {
  //     error = true;
  //   }
  //   if (error) return;
  //   dynamic result;
  //   error = false;
  //   try{
  //     result = <T>[for(final encoded in jsonObject as List)
  //       this.jsonToItem(encoded),
  //     ];
  //   } catch(e) {
  //     error = true;
  //   }
  //   if (error) return;
    
  //   this.set(result);
  // } 

  void _write({int index}) async {

    final instance = await SharedDb.getInstance();

    instance.setString(lenghtKey, jsonEncode(this.value.length));

    if(index == null){
      for(int i = 0; i < this.value.length; ++i){
        instance.setString(indexKey(i), jsonEncode(this.itemToJson(this.value[i])));
      }
    } else {
      if(!this.value.checkIndex(index)) return;
      instance.setString(indexKey(index), jsonEncode(this.itemToJson(this.value[index])));
    }

  }

  void _delete(int index) async {
    final instance = await SharedDb.getInstance();

    instance.deleteByKey(indexKey(index));
  }



}

