import 'package:sid_bloc/persistence/sid_cache.dart';


///class for saving up to a certain amount of data to disk
///it is extremely basic and not very efficient but easy to use
///so you should use it ONLY if you must save a small amount of data
///and you're fine with having it read all the saved data at boot 
class SidCacheMap<T>{
  Map<String, List<T>> _map;
  int get length => this._map.length;

  final int maxCapacity;
  final String prefixKey;
  final T Function(dynamic json) fromJson;
  final dynamic Function(T element) toJson;

  late Map<String,SidCache<T>> _caches;

  SidCacheMap({
    required this.prefixKey,
    Map<String,List<T>>? initialMap,
    this.maxCapacity = 20,
    required this.fromJson,
    required this.toJson,
  }): 
    _map = initialMap ?? <String,List<T>>{}
  {
    this._caches = <String, SidCache<T>>{
      for(String key in this._map.keys)
        key : SidCache<T>(
          key: this.prefixKey + key,
          initialElements: this._map[key],
          toJson: this.toJson,
          fromJson: this.fromJson,
          maxCapacity: this.maxCapacity,
        ),
    };
  }

  List<T> read(String key) => <T>[
    if(_map[key] != null)
      ...this._map[key]!
  ];

  List<T> readAll()
    => <T>[
      for(List<T> l in _map.values)
        ...l,
    ];

  bool containsKey(String key)
    => this._map.containsKey(key);

  void add(String key, T object){
    if(_map.containsKey(key))
      this._map[key]?.add(object);
    else
      this._map[key] = <T>[object];

    if(_caches.containsKey(key))
      this._caches[this.prefixKey + key]?.add(object);
    else
      this._caches[this.prefixKey + key] = SidCache<T>(
        initialElements: <T>[object],
        key: this.prefixKey + key,
        maxCapacity: maxCapacity,
        toJson: toJson,
        fromJson: fromJson,
      );
  }

  void addAll(String key, List<T> objects){
    if(_map.containsKey(key))
      this._map[key]?.addAll(objects);
    else
      this._map[key] = objects;

    if(_caches.containsKey(key))
      this._caches[key]?.addAll(objects);
    else
      this._caches[key] = SidCache<T>(
        initialElements: objects,
        key: this.prefixKey + key,
        maxCapacity: maxCapacity,
        toJson: toJson,
        fromJson: fromJson,
      );
  }

  void removeName(String key) async {
    this._caches[key]?.dispose();
    this._caches.remove(key);
    this._map.remove(key);
  }

  void rename(String oldKey, String newKey){
    List<T> objects = this._map[oldKey] ?? <T>[];
    this.removeName(oldKey);
    this.addAll(newKey, objects);
  }

}