import 'dart:convert';

import 'package:sid_bloc/persistence/persistence.dart';
import 'bloc.dart';

import 'package:flutter/material.dart';

class BlocMap<S,T> extends BlocVar<Map<S,T>> {

  //=======================================================
  // Constructor
  BlocMap(Map<S,T> _content, {
    @required this.key,
    this.itemToJson,
    this.jsonToItem,
    this.keyToJson,
    this.jsonToKey,
    void Function(Map<S,T>) onChanged,
    this.readCallback, 
  }): super(
    _content,
    onChanged: onChanged,
    copier: (map) => <S,T>{for(final entry in map.entries) entry.key : entry.value},
    equals: (m1, m2){
      for(final k in {...(m1.keys), ...(m2.keys)}){
        if(m1[k] != m2[k]) return false;
      }
      return true;
    },
  )
  { 
    if(itemToJson == null) itemToJson = (T a) => a; 
    if(keyToJson == null) keyToJson = (S a) => a; 
    if(jsonToItem == null) jsonToItem = (dynamic a) => a; 
    if(jsonToKey == null) jsonToKey = (dynamic a) => a; 

    this._read().then((ok){
      // this._reread();
      this.reading = false;
      readCallback?.call(this.value);
    });
  }

  //=======================================================
  // Values

  final String key;
  T Function(dynamic) jsonToItem;
  dynamic Function(T) itemToJson;
  S Function(dynamic) jsonToKey;
  dynamic Function(S) keyToJson;

  bool reading = true;
  void Function(Map<S,T>) readCallback;

  //=======================================================
  // Getters
  Type get type => T;

  String get allKeysKey => this.key + "_keys";
  List<dynamic> get allEncodedKeys => <dynamic>[for(final S key in this.value.keys) this.encodedKey(key)];

  String singleKey(S key) => this.key + "_" + jsonEncode(this.encodedKey(key));

  dynamic encodedKey(S key) => this.keyToJson?.call(key) ?? key;
  dynamic encodedItem(T item) => this.itemToJson?.call(item) ?? item;

  //=======================================================
  // Methods
  @override
  void set(Map<S,T> newVal, {bool withoutWriting = false}){
    super.set(newVal);
    if(withoutWriting == false){
      this._write();
    }
  }

  @override
  bool setDistinct(Map<S,T> newVal, {bool withoutWriting = false}){
    bool result = super.setDistinct(newVal);
    if(withoutWriting == false){
      this._write();
    } 
    return result;
  }

  void setKey(S key, T newItem, {bool withoutWriting = false}){

    this.value[key] = newItem;
    this.refresh();
    if(withoutWriting == false){
      this._write(keyToWrite: key);
    }
  }

  void removeKey(S key){
    this.value.remove(key);
    super.refresh(); 
    this._deleteFromDisk(key);
  }

  void removeAll(){
    final Set<S> _keysToBeDeleted = <S>{...this.value.keys};
    this.value = <S,T>{};
    super.refresh(); 

    for(final _keyToBeDeleted in _keysToBeDeleted){
      this._deleteFromDisk(_keyToBeDeleted);
    }
  }

  @override
  void refresh({S key}){
    super.refresh();
    this._write(keyToWrite: key);
  }

  //=======================================================
  // Persistence
  Future<bool> _read() async {
  
    final _instance = await SharedDb.getInstance();

    final String _allKeysString = await _instance.getString(this.allKeysKey);
    if(_allKeysString == null) return false; // not wrote anything yet

    List<dynamic> _allEncodedKeysFromDisk; 
    bool _error = false;
    try{
      _allEncodedKeysFromDisk = jsonDecode(_allKeysString);
    } catch(e) {
      _error = true;
      print("unexpected error during allkeys decoding of $key: error = $e");
    }
    if(_error) return false;
    if(_allEncodedKeysFromDisk.isEmpty) return false;

    List<S> _allDecodedKeysFromDisk;
    _error = false;
    try {
      _allDecodedKeysFromDisk = <S>[
        for(final encodedKey in _allEncodedKeysFromDisk)
          this.jsonToKey?.call(encodedKey) ?? encodedKey,
      ];
    } catch (e) {
      _error = true;
      print("unexpected error during allkeys second decoding of $key: error = $e");
    }
    if(_error) return false;
    if(_allDecodedKeysFromDisk == null) return false;
    if(_allDecodedKeysFromDisk.isEmpty) return false;

    Map<S,T> _contentFromDisk = <S,T>{};

    for(final _decodedKey in _allDecodedKeysFromDisk){
      final String _itemString = await _instance.getString(this.singleKey(_decodedKey));
      if(_itemString == null) continue;
      T _item; 
      _error = false;
      try{
        final jsonItem = jsonDecode(_itemString);
        _item = this.jsonToItem?.call(jsonItem) ?? jsonItem;
      } catch(e) {
        _error = true;
        print("unexpected error during item key: ${this.encodedKey(_decodedKey)} decoding of ${this.key}: error = $e");
      }
      if(_error) continue;
      _contentFromDisk[_decodedKey] = _item;
    }

    if(_contentFromDisk.length != _allEncodedKeysFromDisk.length){
      _instance.setString(allKeysKey, jsonEncode(<dynamic>[for(final k in _contentFromDisk.keys) this.keyToJson?.call(k) ?? k]));
    }

    this.set(_contentFromDisk);

    return true;
  }


  void _write({S keyToWrite}) async {

    final instance = await SharedDb.getInstance();

    instance.setString(this.allKeysKey, jsonEncode(this.allEncodedKeys));

    if(keyToWrite == null || this.value[keyToWrite] == null){
      for(final entry in this.value.entries){
        instance.setString(singleKey(entry.key), jsonEncode(this.encodedItem(entry.value)));
      }
    } else {
      instance.setString(singleKey(keyToWrite), jsonEncode(this.encodedItem(this.value[keyToWrite])));
    }

  }

  void _deleteFromDisk(S key) async {
    final instance = await SharedDb.getInstance();

    instance.deleteByKey(singleKey(key));
  }



}

