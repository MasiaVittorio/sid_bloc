import 'dart:convert';

import 'dart:async';
import 'package:sid_bloc/persistence/cached_db.dart';


///class for saving up to a certain amount of data to disk
///it is extremely basic and not very efficient but easy to use
///so you should use it ONLY if you must save a small amount of data
///and you're fine with having it read all the saved data at boot 
class SidCache<T>{
  List<T> elements;
  int get length => this.elements.length;

  final String key;
  final int maxCapacity;
  final T Function(dynamic json) fromJson;
  final dynamic Function(T element) toJson;

  SidCache({
    required this.key,
    List<T>? initialElements,
    this.maxCapacity = 20,
    required this.fromJson,
    required this.toJson,
  }): 
    assert(key != ""),
    elements = initialElements ?? <T>[]
  {
    this._read();
  }

  Future _read() async {
    CachedDb instance = await (CachedDb.getInstance() as FutureOr<CachedDb>);
    String jsonString = await instance.getString(this.key) ?? '';

    if(jsonString == '')
      return;

    dynamic jsonObject;

    bool error = false;
    try{
       jsonObject = jsonDecode(jsonString);
    } catch(e) {
      error = true;
    }
    if (error) return;

    if(jsonObject is List<String>) 
      this.elements = [

        for(String s in jsonObject)
          this.fromJson(s),

      ]..where((t) => t is T);
  }

  void _write() async {
    CachedDb instance = await (CachedDb.getInstance() as FutureOr<CachedDb>);

    String s = jsonEncode(<String>[
      for(T t in this.elements)
        jsonEncode(this.toJson(t))
    ]);

    instance.setString(key, s);
  }

  void _add(T object){
    while(this.length > this.maxCapacity)
      this.elements.removeAt(0);
    this.elements.add(object);
  }

  void add(T object){
    this._add(object);
    this._write();
  }

  void addAll(List<T> objects){
    for(T object in objects)
      this._add(object);
    this._write();
  }

  void dispose() async {
    CachedDb instance = await (CachedDb.getInstance() as FutureOr<CachedDb>);
    instance.deleteByKey(this.key);
  }

}