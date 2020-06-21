part of bloc_var;


extension<T> on BlocVar<T> {

  void listenToObservable(Observable<T> observable, bool distinct){
    this._subscription?.cancel();

    if(distinct ?? BlocVar._defDistinct){
      this._subscription = observable
          .distinct(this.equals)
          .listen(this.set);
    } else {
      this._subscription = observable
          .listen(this.set);
    }
  }

  void correlate<A>({
    @required BlocVar<A> from, 
    @required T Function(A) map,
    bool distinct = BlocVar._defDistinct,
  }) => listenToObservable(from.out.map(map), distinct);

  void correlateLatest2<A,B>({
    @required BlocVar<A> fromA,
    @required BlocVar<B> fromB,
    @required T Function(A,B) map,
    bool distinct = BlocVar._defDistinct,
  }) => listenToObservable(
    Observable.combineLatest2<A,B,T>(
      fromA.out, fromB.out, map
    ), 
    distinct,
  );

  void correlateLatest3<A,B,C>({
    @required BlocVar<A> fromA,
    @required BlocVar<B> fromB,
    @required BlocVar<C> fromC,
    @required T Function(A,B,C) map,
    bool distinct = BlocVar._defDistinct,
  }) => listenToObservable(
    Observable.combineLatest3<A,B,C,T>(
      fromA.out, fromB.out, fromC.out, map
    ), 
    distinct,
  );

  void correlateLatest4<A,B,C,D>({
    @required BlocVar<A> fromA,
    @required BlocVar<B> fromB,
    @required BlocVar<C> fromC,
    @required BlocVar<D> fromD,
    @required T Function(A,B,C,D) map,
    bool distinct = BlocVar._defDistinct,
  }) => listenToObservable(
    Observable.combineLatest4<A,B,C,D,T>(
      fromA.out, fromB.out, fromC.out, fromD.out, map,
    ),
    distinct,
  );

  void correlateLatest5<A,B,C,D,E>({
    @required BlocVar<A> fromA,
    @required BlocVar<B> fromB,
    @required BlocVar<C> fromC,
    @required BlocVar<D> fromD,
    @required BlocVar<E> fromE,
    @required T Function(A,B,C,D,E) map,
    bool distinct = BlocVar._defDistinct,
  }) => listenToObservable(
    Observable.combineLatest5<A,B,C,D,E,T>(
      fromA.out, fromB.out, fromC.out, fromD.out, fromE.out, map,
    ),
    distinct,
  );

  void correlateLatest6<A,B,C,D,E,F>({
    @required BlocVar<A> fromA,
    @required BlocVar<B> fromB,
    @required BlocVar<C> fromC,
    @required BlocVar<D> fromD,
    @required BlocVar<E> fromE,
    @required BlocVar<F> fromF,
    @required T Function(A,B,C,D,E,F) map,
    bool distinct = BlocVar._defDistinct,
  }) => listenToObservable(
    Observable.combineLatest6<A,B,C,D,E,F,T>(
      fromA.out, fromB.out, fromC.out, fromD.out, fromE.out, fromF.out, map,
    ),
    distinct,
  );

  void correlateLatest7<A,B,C,D,E,F,G>({
    @required BlocVar<A> fromA,
    @required BlocVar<B> fromB,
    @required BlocVar<C> fromC,
    @required BlocVar<D> fromD,
    @required BlocVar<E> fromE,
    @required BlocVar<F> fromF,
    @required BlocVar<G> fromG,
    @required T Function(A,B,C,D,E,F,G) map,
    bool distinct = BlocVar._defDistinct,
  }) => listenToObservable(
    Observable.combineLatest7<A,B,C,D,E,F,G,T>(
      fromA.out, fromB.out, fromC.out, fromD.out, fromE.out, fromF.out, fromG.out, map,
    ),
    distinct,
  );

  void correlateLatest8<A,B,C,D,E,F,G,H>({
    @required BlocVar<A> fromA,
    @required BlocVar<B> fromB,
    @required BlocVar<C> fromC,
    @required BlocVar<D> fromD,
    @required BlocVar<E> fromE,
    @required BlocVar<F> fromF,
    @required BlocVar<G> fromG,
    @required BlocVar<H> fromH,
    @required T Function(A,B,C,D,E,F,G,H) map,
    bool distinct = BlocVar._defDistinct,
  }) => listenToObservable(
    Observable.combineLatest8<A,B,C,D,E,F,G,H,T>(
      fromA.out, fromB.out, fromC.out, fromD.out, fromE.out, fromF.out, fromG.out, fromH.out, map,
    ),
    distinct,
  );

  void correlateLatest9<A,B,C,D,E,F,G,H,I>({
    @required BlocVar<A> fromA,
    @required BlocVar<B> fromB,
    @required BlocVar<C> fromC,
    @required BlocVar<D> fromD,
    @required BlocVar<E> fromE,
    @required BlocVar<F> fromF,
    @required BlocVar<G> fromG,
    @required BlocVar<H> fromH,
    @required BlocVar<I> fromI,
    @required T Function(A,B,C,D,E,F,G,H,I) map,
    bool distinct = BlocVar._defDistinct,
  }) => listenToObservable(
    Observable.combineLatest9<A,B,C,D,E,F,G,H,I,T>(
      fromA.out, fromB.out, fromC.out, fromD.out, fromE.out, fromF.out, fromG.out, fromH.out, fromI.out, map,
    ),
    distinct,
  );



}
