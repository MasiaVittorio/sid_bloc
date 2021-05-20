import 'package:sid_bloc/persistence/shared_db.dart';

import 'bloc.dart';
import 'variables/persistent/bloc_var_persistent.dart';

import 'bloc_set.dart';

// import 'dart:io';

import 'dart:convert';

// import 'package:path_provider/path_provider.dart';



class PersistentSet<T> extends BlocSet<T> {

  PersistentSet({
    required this.initList,
    required this.key,   
    required this.fromJson,
    required this.toJson,   
    BlocVar<Map<String,bool>>? readCount,
    // this.hiveOverSqflite = false,
  }) : super(initList) {
    if(
      this.key.substring(
        this.key.length-4, this.key.length
      ) == '.txt'
    ){
      this.key = this.key.substring(
        0, this.key.length - 4
      );
    }
    this.persistentIndex = PersistentVar<int>(
      key: this.key+'index',
      toJson: (int i) => i,
      fromJson: (dynamic jsi) => jsi,
      readCount: readCount,
      initVal: 0,
      readCallback: (int i)=> this.choose(i),
    );
    if(readCount != null){
      readCount.value[this.key] = false;
      readCount.refresh();
    }
    this._read().then((d){
      if(readCount != null){
        readCount.value[this.key] = true;
        readCount.refresh();
      }
    });
  }

  late PersistentVar<int> persistentIndex;
  List<T> initList;

  String key;
  //wether to use Hive for persistence or sqflite
  // final bool hiveOverSqflite;

  final List<T> Function(dynamic json) fromJson;
  final dynamic Function(List<T> listOfElements) toJson;

  @override
  void dispose(){
    this.persistentIndex.dispose();
    super.dispose();
  }

  @override
  void refresh(){
    super.refresh();
    this.persistentIndex.refresh();
    this._write();
  }

  @override
  void choose(int i, {bool withoutWriting = false}){
    if(!this.checkIndex(i)) return;
    this.persistentIndex.set(i);
    super.choose(i);
    if(withoutWriting == false)
      this._write();
  }

  @override
  void next(){
    int newIndex = ( this.index + 1 ) % this.list.length;
    this.persistentIndex.set(newIndex);
    this.choose(newIndex);
  }

  @override
  void previous(){
    if(this.index == 0) {
      this.persistentIndex.set(this.list.length -1);
      this.choose(this.list.length -1);
    }
    else {
      this.persistentIndex.set(this.index -1);
      this.choose(this.index -1);
    }
  }

  @override
  void chooseElement(T el){
    if(this.list.contains(el) == false) this.list.add(el);
    this.persistentIndex.set(this.list.indexOf(el));
    this.choose(this.list.indexOf(el));
  }


  Future _read() async {
  
    dynamic instance;

    // if(hiveOverSqflite)
    //   instance = await SharedBox.getInstance();
    // else 
    //   instance = await SharedDb.getInstance();
    instance = await SharedDb.getInstance();

    final String jsonString = await instance.getString(this.key) ?? '';

    if(jsonString == '') {
      return;
    }
    dynamic jsonObject;
    bool error = false;
    try{
      jsonObject = jsonDecode(jsonString);
    } catch(e) {
      error = true;
    }
    if (error) return;
    dynamic result;
    error = false;
    try{
      result = this.fromJson(jsonObject);
    } catch(e) {
      error = true;
    }
    if (error) return;
    
    if(result is List<T>) {
      this.list = result;
      this.choose(this.persistentIndex.value, withoutWriting: true);
      return;
    }
    else {
      this._write();
      print('read error $T: we have $result, type ${result.runtimeType}');
    }
    return;
  }

  void _write() async {
    dynamic instance;

    // if(hiveOverSqflite)
    //   instance = await SharedBox.getInstance();
    // else 
    //   instance = await SharedDb.getInstance();
    instance = await SharedDb.getInstance();

    String jsonString = jsonEncode(
      this.toJson(this.list)
    );
    
    instance.setString(this.key, jsonString);
  }



}

