library bloc_var;

import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../persistent/bloc_var_persistent.dart';

part 'builders.dart';
part 'correlators.dart';



typedef ValueBuilder<T> = Widget Function(
  BuildContext context, 
  T val, 
);
typedef ChildValueBuilder<T> = Widget Function(
  BuildContext context, 
  T? val, 
  Widget? child,
);

class BlocVar<T> {

  static const bool _defaultDistinct = false;

  BlocVar(
    T val, 
    {
      this.onChanged, 
      this.equals,
      this.copier,
    }
  ): 
    value = copier?.call(val) ?? val,
    behavior = BehaviorSubject<T>.seeded(copier?.call(val) ?? val);

  T value;

  final BehaviorSubject<T> behavior;
  final bool Function(T, T)? equals; 
  //to allow for behavior.value to not be updated if we update value (happens when value is a map or list, so unmodifiable)
  //we need to copy value for behavior seed and adds
  final T Function(T)? copier;
  ///WARNING: if the value of this bloc var is null, the static build2 (or more) method will not update because 
  ///rxdart thinks that sending a null value is not sending anything GODDAMN 

  final void Function(T)? onChanged;
  ///the subscription that correlate this var to others: 
  /// only one subscription at a time should be used!
  StreamSubscription? _subscription;

  static BlocVar<T> modal<T>({
    required T initVal,
    String? key,   
    T Function(dynamic)? fromJson,
    dynamic Function(T)? toJson, 
    BlocVar<Map<String,bool>>? readCount,
    void Function(T)? readCallback,
    void Function(T)? onChanged,
    bool Function(T, T)? equals,
    T Function(T)? copier,
    bool verboseRead = false,
  }) => key != null ? PersistentVar<T>(
    initVal: initVal,
    key: key,
    fromJson: fromJson,
    toJson: toJson,
    readCallback: readCallback,
    readCount: readCount,
    copier: copier,
    equals: equals,
    onChanged: onChanged,
    verboseRead: verboseRead,
  ) : BlocVar<T>(
    initVal,
    copier: copier,
    equals: equals,
    onChanged: onChanged,
  );

  Type get type => T;
  Stream<T> get out => this.behavior.stream;
  Stream<T> get outDistinct => this.out.distinct(this.equals);
  Stream<T> outModal(bool distinct) => distinct ? this.outDistinct : this.out;

  T get copied => this.copier?.call(this.value) ?? this.value;


  void dispose() {
    behavior.close();
    _subscription?.cancel();
  }

  void notify() => this.onChanged?.call(this.value);

  void set(T newVal){
    this.value = this.copier?.call(newVal) ?? newVal;
    behavior.add(this.value);
    this.notify();
  }

  /// if you ever modify [value] without using the [set()] method, MAKE SURE you call [refresh()] 
  /// to keep the value of this instance of [BlocVar] in sync with its stream
  void refresh() {
    this.notify();
    behavior.add(this.copied);
  } 

  void edit(Function(T) editor){
    editor(this.value);
    this.refresh();
  }

  bool setDistinct(T newVal){
    bool _ret = false;

    if(this.equals != null){
      try {
        bool _eq = this.equals!(this.value, newVal);
        if(_eq) _ret = true;
      } catch (e) {
        _ret = true;
      }
    } else if(newVal == this.value){
      _ret = true;
    }

    if(_ret) return false;

    this.set(newVal);
    return true;
  }

  void refreshDistinct(){
    bool _ret = false;

    if(this.equals != null){
      try {
        bool _eq = this.equals!(this.value, this.behavior.value);
        if(_eq) _ret = true;
      } catch (e) {
        _ret = true;
      }
    } else if(this.behavior.value == this.value){
      _ret = true;
    }

    if(_ret) return;
    this.refresh();
  }


  static BlocVar fromCorrelate<T,A>({
    required BlocVar<A> from,
    required T Function(A) map, 
    bool Function(T,T)? equals,
    void Function(T)? onChanged,
    T Function(T)? copier,
    bool distinct = _defaultDistinct,
  }) => BlocVar<T>(
    map(from.value), 
    onChanged: onChanged, equals: equals, copier: copier
  )..correlate(
    from: from, 
    map: map,
    distinct: distinct,
  );

  static BlocVar<T> fromCorrelateLatest2<T,A,B>(
    BlocVar<A> fromA, BlocVar<B> fromB, {
    required T Function(A,B) map, 
    bool Function(T,T)? equals,
    void Function(T)? onChanged,
    T Function(T)? copier,
    bool distinct = _defaultDistinct,
  }) => BlocVar<T>(
    map(fromA.value, fromB.value), 
    onChanged: onChanged, equals: equals, copier: copier
  )..correlateLatest2(
    fromA: fromA, fromB: fromB, 
    map: map,
    distinct: distinct,
  );
  
  static BlocVar<T> fromCorrelateLatest3<T,A,B,C>(
    BlocVar<A> fromA, BlocVar<B> fromB, BlocVar<C> fromC, {
    required T Function(A,B,C) map, 
    bool Function(T,T)? equals,
    void Function(T)? onChanged,
    T Function(T)? copier,
    bool distinct = _defaultDistinct,
  }) => BlocVar<T>(
    map(fromA.value, fromB.value, fromC.value), 
    onChanged: onChanged, equals: equals, copier: copier
  )..correlateLatest3(
    fromA: fromA, fromB: fromB, fromC: fromC, 
    map: map,
    distinct: distinct,
  );

  static BlocVar<T> fromCorrelateLatest4<T,A,B,C,D>(
    BlocVar<A> fromA, BlocVar<B> fromB, BlocVar<C> fromC,
    BlocVar<D> fromD, {
    required T Function(A,B,C,D) map, 
    bool Function(T,T)? equals,
    void Function(T)? onChanged,
    T Function(T)? copier,
    bool distinct = _defaultDistinct,
  }) => BlocVar<T>(
    map(fromA.value, fromB.value, fromC.value, fromD.value), 
    onChanged: onChanged, equals: equals, copier: copier
  )..correlateLatest4(
    fromA: fromA, fromB: fromB, fromC: fromC, fromD: fromD, 
    map: map,
    distinct: distinct,
  );

  static BlocVar<T> fromCorrelateLatest5<T,A,B,C,D,E>(
    BlocVar<A> fromA, BlocVar<B> fromB, BlocVar<C> fromC,
    BlocVar<D> fromD, BlocVar<E> fromE, {
    required T Function(A,B,C,D,E) map, 
    bool Function(T,T)? equals,
    void Function(T)? onChanged,
    T Function(T)? copier,
    bool distinct = _defaultDistinct,
  }) => BlocVar<T>(
    map(fromA.value, fromB.value, fromC.value, 
        fromD.value, fromE.value), 
    onChanged: onChanged, equals: equals, copier: copier
  )..correlateLatest5(
    fromA: fromA, fromB: fromB, fromC: 
    fromC, fromD: fromD, fromE: fromE,
    map: map,
    distinct: distinct,
  );

  static BlocVar<T> fromCorrelateLatest6<T,A,B,C,D,E,F>(
    BlocVar<A> fromA, BlocVar<B> fromB, BlocVar<C> fromC,
    BlocVar<D> fromD, BlocVar<E> fromE, BlocVar<F> fromF, {
    required T Function(A,B,C,D,E,F) map, 
    bool Function(T,T)? equals,
    void Function(T)? onChanged,
    T Function(T)? copier,
    bool distinct = _defaultDistinct,
  }) => BlocVar<T>(
    map(fromA.value, fromB.value, fromC.value, 
        fromD.value, fromE.value, fromF.value), 
    onChanged: onChanged, equals: equals, copier: copier
  )..correlateLatest6(
    fromA: fromA, fromB: fromB, fromC: fromC, 
    fromD: fromD, fromE: fromE, fromF: fromF,
    map: map,
    distinct: distinct,
  );

  static BlocVar<T> fromCorrelateLatest7<T,A,B,C,D,E,F,G>(
    BlocVar<A> fromA, BlocVar<B> fromB, BlocVar<C> fromC,
    BlocVar<D> fromD, BlocVar<E> fromE, BlocVar<F> fromF, 
    BlocVar<G> fromG, {
    required T Function(A,B,C,D,E,F,G) map, 
    bool Function(T,T)? equals,
    void Function(T)? onChanged,
    T Function(T)? copier,
    bool distinct = _defaultDistinct,
  }) => BlocVar<T>(
    map(fromA.value, fromB.value, fromC.value, fromD.value, 
        fromE.value, fromF.value, fromG.value), 
    onChanged: onChanged, equals: equals, copier: copier
  )..correlateLatest7(
    fromA: fromA, fromB: fromB, fromC: fromC, fromD: fromD, 
    fromE: fromE, fromF: fromF, fromG: fromG,
    map: map,
    distinct: distinct,
  );

  static BlocVar<T> fromCorrelateLatest8<T,A,B,C,D,E,F,G,H>(
    BlocVar<A> fromA, BlocVar<B> fromB, BlocVar<C> fromC,
    BlocVar<D> fromD, BlocVar<E> fromE, BlocVar<F> fromF, 
    BlocVar<G> fromG, BlocVar<H> fromH, {
    required T Function(A,B,C,D,E,F,G,H) map, 
    bool Function(T,T)? equals,
    void Function(T)? onChanged,
    T Function(T)? copier,
    bool distinct = _defaultDistinct,
  }) => BlocVar<T>(
    map(fromA.value, fromB.value, fromC.value, fromD.value, 
        fromE.value, fromF.value, fromG.value, fromH.value), 
    onChanged: onChanged, equals: equals, copier: copier
  )..correlateLatest8(
    fromA: fromA, fromB: fromB, fromC: fromC, fromD: fromD, 
    fromE: fromE, fromF: fromF, fromG: fromG, fromH: fromH,
    map: map,
    distinct: distinct,
  );

  static BlocVar<T> fromCorrelateLatest9<T,A,B,C,D,E,F,G,H,I>(
    BlocVar<A> fromA, BlocVar<B> fromB, BlocVar<C> fromC,
    BlocVar<D> fromD, BlocVar<E> fromE, BlocVar<F> fromF, 
    BlocVar<G> fromG, BlocVar<H> fromH, BlocVar<I> fromI,{
    required T Function(A,B,C,D,E,F,G,H,I) map, 
    bool Function(T,T)? equals,
    void Function(T)? onChanged,
    T Function(T)? copier,
    bool distinct = _defaultDistinct,
  }) => BlocVar<T>(
    map(fromA.value, fromB.value, fromC.value, fromD.value, fromE.value, 
        fromF.value, fromG.value, fromH.value, fromI.value), 
    onChanged: onChanged, equals: equals, copier: copier
  )..correlateLatest9(
    fromA: fromA, fromB: fromB, fromC: fromC, fromD: fromD, fromE: fromE, 
    fromF: fromF, fromG: fromG, fromH: fromH, fromI: fromI,
    map: map,
    distinct: distinct,
  );





  static Widget build2<A,B>(
    BlocVar<A> fromA, BlocVar<B> fromB, {
    required Widget Function(BuildContext,A?,B?) builder,
    bool distinct = false,
  }) => StreamBuilder<Map<String,dynamic>>(
    stream: CombineLatestStream.combine2(
      fromA.outModal(distinct), fromB.outModal(distinct), 
      (A av, B bv,) => {
        'a': av, 'b': bv,
      },
    ),
    initialData: {
      'a': fromA.value, 'b': fromB.value,
    },
    builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> s)
      => builder(
        context,
        s.data!['a'], s.data!['b'],
      ),
  );

  static Widget build3<A,B,C>(
    BlocVar<A> fromA, BlocVar<B> fromB, BlocVar<C> fromC, {
    required Widget Function(BuildContext,A?,B?,C?) builder,
    bool distinct = false,
  }) => StreamBuilder<Map<String,dynamic>>(
    stream: CombineLatestStream.combine3(
      fromA.outModal(distinct), fromB.outModal(distinct), 
      fromC.outModal(distinct), 
      (A av, B bv, C cv) => {
        'a': av, 'b': bv, 'c': cv,
      },
    ),
    initialData: {
      'a': fromA.value, 'b': fromB.value, 'c': fromC.value,
    },
    builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> s)
      => builder(
        context,
        s.data!['a'], s.data!['b'], s.data!['c'],
      ),
  );

  static Widget build4<A,B,C,D>(
    BlocVar<A> fromA, BlocVar<B> fromB, BlocVar<C> fromC, BlocVar<D> fromD, {
    required Widget Function(BuildContext,A?,B?,C?,D?) builder,
    bool distinct = false,
  }) => StreamBuilder<Map<String,dynamic>>(
    stream: CombineLatestStream.combine4(
      fromA.outModal(distinct), fromB.outModal(distinct), 
      fromC.outModal(distinct), fromD.outModal(distinct), 
      (A av, B bv, C cv, D dv) => <String,dynamic>{
        'a': av, 'b': bv, 'c': cv, 'd': dv,
      },
    ),
    initialData: <String,dynamic>{
      'a': fromA.value, 'b': fromB.value, 'c': fromC.value, 'd': fromD.value,
    },
    builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> s)
      => builder(
        context,
        s.data!['a'], s.data!['b'], s.data!['c'], s.data!['d'],
      ),
  );

  static Widget build5<A,B,C,D,E>(
    BlocVar<A> fromA, BlocVar<B> fromB, BlocVar<C> fromC, 
    BlocVar<D> fromD, BlocVar<E> fromE, {
    required Widget Function(BuildContext,A?,B?,C?,D?,E?) builder,
    bool distinct = false,
  }) => StreamBuilder<Map<String,dynamic>>(
    stream: CombineLatestStream.combine5(
      fromA.outModal(distinct), fromB.outModal(distinct), 
      fromC.outModal(distinct), fromD.outModal(distinct), 
      fromE.outModal(distinct), 
      (A av, B bv, C cv, D dv, E ev) => <String,dynamic>{
        'a': av, 'b': bv, 'c': cv, 
        'd': dv, 'e': ev,
      },
    ),
    initialData: <String,dynamic>{
      'a': fromA.value, 'b': fromB.value, 'c': fromC.value, 
      'd': fromD.value, 'e': fromE.value,
    },
    builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> s)
      => builder(
        context,
        s.data!['a'], s.data!['b'], s.data!['c'], 
        s.data!['d'], s.data!['e'],
      ),
  );

  static Widget build6<A,B,C,D,E,F>(
    BlocVar<A> fromA, BlocVar<B> fromB, BlocVar<C> fromC, 
    BlocVar<D> fromD, BlocVar<E> fromE, BlocVar<F> fromF, {
    required Widget Function(BuildContext,A?,B?,C?,D?,E?,F?) builder,
    bool distinct = false,
  }) => StreamBuilder<Map<String,dynamic>>(
    stream: CombineLatestStream.combine6(
      fromA.outModal(distinct), fromB.outModal(distinct), 
      fromC.outModal(distinct), fromD.outModal(distinct), 
      fromE.outModal(distinct), fromF.outModal(distinct), 
      (A av, B bv, C cv, D dv, E ev, F fv) => <String,dynamic>{
        'a': av, 'b': bv, 'c': cv, 
        'd': dv, 'e': ev, 'f': fv,
      },
    ),
    initialData: <String,dynamic>{
      'a': fromA.value, 'b': fromB.value, 'c': fromC.value, 
      'd': fromD.value, 'e': fromE.value, 'f': fromF.value,
    },
    builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> s)
      => builder(
        context,
        s.data!['a'], s.data!['b'], s.data!['c'], 
        s.data!['d'], s.data!['e'], s.data!['f'],
      ),
  );

  static Widget build7<A,B,C,D,E,F,G>(
    BlocVar<A> fromA, BlocVar<B> fromB, BlocVar<C> fromC, BlocVar<D> fromD, 
    BlocVar<E> fromE, BlocVar<F> fromF, BlocVar<G> fromG, {
    required Widget Function(BuildContext,A?,B?,C?,D?,E?,F?,G?) builder,
    bool distinct = false,
  }) => StreamBuilder<Map<String,dynamic>>(
    stream: CombineLatestStream.combine7(
      fromA.outModal(distinct), fromB.outModal(distinct), fromC.outModal(distinct), 
      fromD.outModal(distinct), fromE.outModal(distinct), fromF.outModal(distinct), 
      fromG.outModal(distinct), 
      (A av, B bv, C cv, D dv, E ev, F fv, G gv) => <String,dynamic>{
        'a': av, 'b': bv, 'c': cv, 'd': dv, 
        'e': ev, 'f': fv, 'g': gv,
      },
    ),
    initialData: <String,dynamic>{
      'a': fromA.value, 'b': fromB.value, 'c': fromC.value, 'd': fromD.value, 
      'e': fromE.value, 'f': fromF.value, 'g': fromG.value,
    },
    builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> s)
      => builder(
        context,
        s.data!['a'], s.data!['b'], s.data!['c'], s.data!['d'], 
        s.data!['e'], s.data!['f'], s.data!['g'],
      ),
  );

  static Widget build8<A,B,C,D,E,F,G,H>(
    BlocVar<A> fromA, BlocVar<B> fromB, BlocVar<C> fromC, 
    BlocVar<D> fromD, BlocVar<E> fromE, BlocVar<F> fromF,
    BlocVar<G> fromG, BlocVar<H> fromH, {
    required Widget Function(BuildContext,A?,B?,C?,D?,E?,F?,G?,H?) builder,
    bool distinct = false,
  }) => StreamBuilder<Map<String,dynamic>>(
    stream: CombineLatestStream.combine8(
      fromA.outModal(distinct), fromB.outModal(distinct), fromC.outModal(distinct), 
      fromD.outModal(distinct), fromE.outModal(distinct), fromF.outModal(distinct), 
      fromG.outModal(distinct), fromH.outModal(distinct),
      (A av, B bv, C cv, D dv, E ev, F fv, G gv, H hv) => <String,dynamic>{
        'a': av, 'b': bv, 'c': cv, 'd': dv, 
        'e': ev, 'f': fv, 'g': gv, 'h': hv,
      },
    ),
    initialData: <String,dynamic>{
      'a': fromA.value, 'b': fromB.value, 'c': fromC.value, 'd': fromD.value, 
      'e': fromE.value, 'f': fromF.value, 'g': fromG.value, 'h': fromH.value,
    },
    builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> s)
      => builder(
        context,
        s.data!['a'], s.data!['b'], s.data!['c'], s.data!['d'], 
        s.data!['e'], s.data!['f'], s.data!['g'], s.data!['h'],
      ),
  );

  static Widget build9<A,B,C,D,E,F,G,H,I>(
    BlocVar<A> fromA, BlocVar<B> fromB, BlocVar<C> fromC, 
    BlocVar<D> fromD, BlocVar<E> fromE, BlocVar<F> fromF,
    BlocVar<G> fromG, BlocVar<H> fromH, BlocVar<I> fromI, {
    required Widget Function(BuildContext,A?,B?,C?,D?,E?,F?,G?,H?,I?) builder,
    bool distinct = false,
  }) => StreamBuilder<Map<String,dynamic>>(
    stream: CombineLatestStream.combine9(
      fromA.outModal(distinct), fromB.outModal(distinct), fromC.outModal(distinct), 
      fromD.outModal(distinct), fromE.outModal(distinct), fromF.outModal(distinct), 
      fromG.outModal(distinct), fromH.outModal(distinct), fromI.outModal(distinct),
      (A av, B bv, C cv, D dv, E ev, F fv, G gv, H hv, I iv) => <String,dynamic>{
        'a': av, 'b': bv, 'c': cv, 
        'd': dv, 'e': ev, 'f': fv, 
        'g': gv, 'h': hv, 'i': iv,
      },
    ),
    initialData: <String,dynamic>{
      'a': fromA.value, 'b': fromB.value, 'c': fromC.value, 
      'd': fromD.value, 'e': fromE.value, 'f': fromF.value, 
      'g': fromG.value, 'h': fromH.value, 'i': fromI.value,
    },
    builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> s)
      => builder(
        context,
        s.data!['a'], s.data!['b'], s.data!['c'], 
        s.data!['d'], s.data!['e'], s.data!['f'], 
        s.data!['g'], s.data!['h'], s.data!['i'],
      ),
  );



}
