import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';

import 'bloc.dart';

import 'package:sid_utils/sid_utils.dart';

class BlocSet<T> {
  BlocSet(this.list) {
    assert(list != null);
    assert(list.length != 0);
    this.index = 0;
    this.variable = BlocVar<T>(this.list[this.index]);
  }

  List<T> list;
  int index;
  BlocVar<T> variable;

  Type get type => T;

  bool checkIndex(int i) => checkIndexOfList(i, this.list);

  void choose(int i){
    if (!this.checkIndex(i)){
      print('error choose index $i in lenght ${this.list.length}');
      return;
    }
    this.index = i+0;
    this.variable.set(this.list[this.index]);
  }
  void next(){
    int newIndex = ( this.index + 1 ) % this.list.length;
    this.choose(newIndex);
  }
  void previous(){
    if(this.index == 0) this.choose(this.list.length -1);      
    else this.choose(this.index -1);
  }
  void chooseElement(T el){
    if(this.list.contains(el) == false) this.list.add(el);
    this.choose(this.list.indexOf(el));
  }


  void dispose() {
    this.variable.dispose();
  }


  /// if you ever modify [value] without using the [set()] method, MAKE SURE you call [refresh()] 
  /// to keep the value of this instance of [BlocVar] in sync with its stream
  void refresh() => this.variable.refresh();

  Widget build(
    ValueBuilder<T> builder,
  {
    distinct = false,
  }){
    return this.variable.build(
      builder,
      distinct: distinct,
    );
  }

  void correlate<A>(BlocVar<A> a, T map(A av)){
    a.out.map(map).distinct().listen(this.chooseElement);
  }
  void correlateIndex<A>(BlocVar<A> a, int map(A av)){
    a.out.map(map).distinct().listen(this.choose);
  }

  void correlateLatest2<A,B>(
    BlocVar<A> a,
    BlocVar<B> b,
    T map(
      A av, B bv,
    )
  ){
    Observable.combineLatest2(
      a.out, 
      b.out, 
      map
    )
    .distinct()
    .listen(this.chooseElement);
    // a.refresh();
    // b.refresh();
  }
  void correlateLatest3<A,B,C>(
    BlocVar<A> a,
    BlocVar<B> b,
    BlocVar<C> c,
    T map(
      A av, B bv, C cv
    )
  ){

    Observable.combineLatest3(
      a.out, 
      b.out, 
      c.out, 
      map
    )
    .distinct()
    .listen(this.chooseElement);
    // a.refresh();
    // b.refresh();
    // c.refresh();
  }
  void correlateLatest4<A,B,C,D>(
    BlocVar<A> a,
    BlocVar<B> b,
    BlocVar<C> c,
    BlocVar<D> d,
    T map(
      A av, B bv, C cv, D dv
    )
  ){

    Observable.combineLatest4(
      a.out, 
      b.out, 
      c.out, 
      d.out, 
      map
    )
    .distinct()
    .listen(this.chooseElement);
    // a.refresh();
    // b.refresh();
    // c.refresh();
    // d.refresh();
  }
  void correlateLatest5<A,B,C,D,E>(
    BlocVar<A> a,
    BlocVar<B> b,
    BlocVar<C> c,
    BlocVar<D> d,
    BlocVar<E> e,
    T map(
      A av, B bv, C cv, D dv, E ev
    )
  ){

    Observable.combineLatest5(
      a.out, 
      b.out, 
      c.out, 
      d.out, 
      e.out, 
      map
    )
    .distinct()
    .listen(this.chooseElement);
    // a.refresh();
    // b.refresh();
    // c.refresh();
    // d.refresh();
    // e.refresh();
  }
  void correlateLatest6<A,B,C,D,E,F>(
    BlocVar<A> a,
    BlocVar<B> b,
    BlocVar<C> c,
    BlocVar<D> d,
    BlocVar<E> e,
    BlocVar<F> f,
    T map(
      A av, B bv, C cv, D dv, E ev, F fv
    )
  ){

    Observable.combineLatest6(
      a.out, 
      b.out, 
      c.out, 
      d.out, 
      e.out, 
      f.out, 
      map
    )
    .distinct()
    .listen(this.chooseElement);
  }
  void correlateLatest7<A,B,C,D,E,F,G>(
    BlocVar<A> a,
    BlocVar<B> b,
    BlocVar<C> c,
    BlocVar<D> d,
    BlocVar<E> e,
    BlocVar<F> f,
    BlocVar<G> g,
    T map(
      A av, B bv, C cv, D dv, E ev, F fv, G gv
    )
  ){
    Observable.combineLatest7(
      a.out, 
      b.out, 
      c.out, 
      d.out, 
      e.out, 
      f.out, 
      g.out, 
      (aa, bb, cc, dd, ee, ff, gg){
        return map(aa, bb, cc, dd, ee, ff, gg);
      }
    )
    .distinct()
    .listen(this.chooseElement);
  }
  void correlateLatest8<A,B,C,D,E,F,G,H>(
    BlocVar<A> a,
    BlocVar<B> b,
    BlocVar<C> c,
    BlocVar<D> d,
    BlocVar<E> e,
    BlocVar<F> f,
    BlocVar<G> g,
    BlocVar<H> h,
    T map(
      A av, B bv, C cv, D dv, E ev, F fv, G gv, H hv,
    )
  ){
    Observable.combineLatest8(
      a.out, 
      b.out, 
      c.out, 
      d.out, 
      e.out, 
      f.out, 
      g.out, 
      h.out, 
      (aa, bb, cc, dd, ee, ff, gg, hh){
        return map(aa, bb, cc, dd, ee, ff, gg, hh);
      }
    )
    .distinct()
    .listen(this.chooseElement);
  }
  void correlateLatest9<A,B,C,D,E,F,G,H,I>(
    BlocVar<A> a,
    BlocVar<B> b,
    BlocVar<C> c,
    BlocVar<D> d,
    BlocVar<E> e,
    BlocVar<F> f,
    BlocVar<G> g,
    BlocVar<H> h,
    BlocVar<I> i,
    T map(
      A av, B bv, C cv, D dv, E ev, F fv, G gv, H hv, I iv,
    )
  ){
    Observable.combineLatest9(
      a.out, 
      b.out, 
      c.out, 
      d.out, 
      e.out, 
      f.out, 
      g.out, 
      h.out, 
      i.out, 
      (aa, bb, cc, dd, ee, ff, gg, hh, ii){
        return map(aa, bb, cc, dd, ee, ff, gg, hh, ii);
      }
    )
    .distinct()
    .listen(this.chooseElement);
  }


  static BlocSet<T> fromCorrelate<T,A>(BlocVar<A> bvA,T map(A a)) {
    BlocSet<T> newBS = BlocSet<T>([map(bvA.value)]);
    newBS.correlate(bvA, map);
    return newBS;
  }
  static BlocSet<T> fromCorrelateLatest2<T,A,B>(
    BlocVar<A> bvA,
    BlocVar<B> bvB,
    T map(A a, B b),
  ){
    BlocSet<T> newBS = BlocSet<T>([map(
      bvA.value,
      bvB.value,
    )]);
    newBS.correlateLatest2<A,B>(
      bvA,
      bvB,
      map
    );
    return newBS;
  }
  static BlocSet<T> fromCorrelateLatest3<T,A,B,C>(
    BlocVar<A> bvA,
    BlocVar<B> bvB,
    BlocVar<C> bvC,
    T map(A a, B b, C c),
  ){
    BlocSet<T> newBS = BlocSet<T>([map(
      bvA.value,
      bvB.value,
      bvC.value,
    )]);
    newBS.correlateLatest3<A,B,C>(
      bvA,
      bvB,
      bvC,
      map
    );
    return newBS;
  }
  static BlocSet<T> fromCorrelateLatest4<T,A,B,C,D>(
    BlocVar<A> bvA,
    BlocVar<B> bvB,
    BlocVar<C> bvC,
    BlocVar<D> bvD,
    T map(A a, B b, C c, D d),
  ){
    BlocSet<T> newBS = BlocSet<T>([map(
      bvA.value,
      bvB.value,
      bvC.value,
      bvD.value,
    )]);
    newBS.correlateLatest4<A,B,C,D>(
      bvA,
      bvB,
      bvC,
      bvD,
      map
    );
    return newBS;
  }
  static BlocSet<T> fromCorrelateLatest5<T,A,B,C,D,E>(
    BlocVar<A> bvA,
    BlocVar<B> bvB,
    BlocVar<C> bvC,
    BlocVar<D> bvD,
    BlocVar<E> bvE,
    T map(A a, B b, C c, D d, E e,),
  ){
    BlocSet<T> newBS = BlocSet<T>([map(
      bvA.value,
      bvB.value,
      bvC.value,
      bvD.value,
      bvE.value,
    )]);
    newBS.correlateLatest5<A,B,C,D,E>(
      bvA,
      bvB,
      bvC,
      bvD,
      bvE,
      map
    );
    return newBS;
  }
  static BlocSet<T> fromCorrelateLatest6<T,A,B,C,D,E,F>(
    BlocVar<A> bvA,
    BlocVar<B> bvB,
    BlocVar<C> bvC,
    BlocVar<D> bvD,
    BlocVar<E> bvE,
    BlocVar<F> bvF,
    T map(A a, B b, C c, D d, E e, F f),
  ){
    BlocSet<T> newBS = BlocSet<T>([map(
      bvA.value,
      bvB.value,
      bvC.value,
      bvD.value,
      bvE.value,
      bvF.value,
    )]);
    newBS.correlateLatest6<A,B,C,D,E,F>(
      bvA,
      bvB,
      bvC,
      bvD,
      bvE,
      bvF,
      map
    );
    return newBS;
  }
  static BlocSet<T> fromCorrelateLatest7<T,A,B,C,D,E,F,G>(
    BlocVar<A> bvA,
    BlocVar<B> bvB,
    BlocVar<C> bvC,
    BlocVar<D> bvD,
    BlocVar<E> bvE,
    BlocVar<F> bvF,
    BlocVar<G> bvG,
    T map(A a, B b, C c, D d, E e, F f, G g),
  ){
    BlocSet<T> newBS = BlocSet<T>([map(
      bvA.value,
      bvB.value,
      bvC.value,
      bvD.value,
      bvE.value,
      bvF.value,
      bvG.value,
    )]);
    newBS.correlateLatest7<A,B,C,D,E,F,G>(
      bvA,
      bvB,
      bvC,
      bvD,
      bvE,
      bvF,
      bvG,
      map
    );
    return newBS;
  }
  static BlocSet<T> fromCorrelateLatest8<T,A,B,C,D,E,F,G,H>(
    BlocVar<A> bvA,
    BlocVar<B> bvB,
    BlocVar<C> bvC,
    BlocVar<D> bvD,
    BlocVar<E> bvE,
    BlocVar<F> bvF,
    BlocVar<G> bvG,
    BlocVar<H> bvH,
    T map(A a, B b, C c, D d, E e, F f, G g, H h),
  ){
    BlocSet<T> newBS = BlocSet<T>([map(
      bvA.value,
      bvB.value,
      bvC.value,
      bvD.value,
      bvE.value,
      bvF.value,
      bvG.value,
      bvH.value,
    )]);
    newBS.correlateLatest8<A,B,C,D,E,F,G,H>(
      bvA,
      bvB,
      bvC,
      bvD,
      bvE,
      bvF,
      bvG,
      bvH,
      map
    );
    return newBS;
  }
  static BlocSet<T> fromCorrelateLatest9<T,A,B,C,D,E,F,G,H, I>(
    BlocVar<A> bvA,
    BlocVar<B> bvB,
    BlocVar<C> bvC,
    BlocVar<D> bvD,
    BlocVar<E> bvE,
    BlocVar<F> bvF,
    BlocVar<G> bvG,
    BlocVar<H> bvH,
    BlocVar<I> bvI,
    T map(A a, B b, C c, D d, E e, F f, G g, H h, I i),
  ){
    BlocSet<T> newBS = BlocSet<T>([map(
      bvA.value,
      bvB.value,
      bvC.value,
      bvD.value,
      bvE.value,
      bvF.value,
      bvG.value,
      bvH.value,
      bvI.value,
    )]);
    newBS.correlateLatest9<A,B,C,D,E,F,G,H,I>(
      bvA,
      bvB,
      bvC,
      bvD,
      bvE,
      bvF,
      bvG,
      bvH,
      bvI,
      map
    );
    return newBS;
  }
}

