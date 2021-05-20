part of bloc_var;


extension<T> on BlocVar<T> {

  void listenToStream(Stream<T> stream, bool distinct){
    this._subscription?.cancel();

    if(distinct ?? BlocVar._defaultDistinct){
      this._subscription = stream
          .distinct(this.equals)
          .listen(this.set);
    } else {
      this._subscription = stream
          .listen(this.set);
    }
  }

  void correlate<A>({
    @required BlocVar<A> from, 
    @required T Function(A) map,
    bool distinct = BlocVar._defaultDistinct,
  }) => listenToStream(from.out.map(map), distinct);

  void correlateLatest2<A,B>({
    @required BlocVar<A> fromA,
    @required BlocVar<B> fromB,
    @required T Function(A,B) map,
    bool distinct = BlocVar._defaultDistinct,
  }) => listenToStream(
    CombineLatestStream.combine2<A,B,T>(
      fromA.out, fromB.out, map
    ), 
    distinct,
  );

  void correlateLatest3<A,B,C>({
    @required BlocVar<A> fromA,
    @required BlocVar<B> fromB,
    @required BlocVar<C> fromC,
    @required T Function(A,B,C) map,
    bool distinct = BlocVar._defaultDistinct,
  }) => listenToStream(
    CombineLatestStream.combine3<A,B,C,T>(
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
    bool distinct = BlocVar._defaultDistinct,
  }) => listenToStream(
    CombineLatestStream.combine4<A,B,C,D,T>(
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
    bool distinct = BlocVar._defaultDistinct,
  }) => listenToStream(
    CombineLatestStream.combine5<A,B,C,D,E,T>(
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
    bool distinct = BlocVar._defaultDistinct,
  }) => listenToStream(
    CombineLatestStream.combine6<A,B,C,D,E,F,T>(
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
    bool distinct = BlocVar._defaultDistinct,
  }) => listenToStream(
    CombineLatestStream.combine7<A,B,C,D,E,F,G,T>(
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
    bool distinct = BlocVar._defaultDistinct,
  }) => listenToStream(
    CombineLatestStream.combine8<A,B,C,D,E,F,G,H,T>(
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
    bool distinct = BlocVar._defaultDistinct,
  }) => listenToStream(
    CombineLatestStream.combine9<A,B,C,D,E,F,G,H,I,T>(
      fromA.out, fromB.out, fromC.out, fromD.out, fromE.out, fromF.out, fromG.out, fromH.out, fromI.out, map,
    ),
    distinct,
  );



}
