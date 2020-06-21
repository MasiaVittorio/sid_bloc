part of bloc_var;

extension BlocVarBuilders<T> on BlocVar<T> {

  Widget buildDistinct(
    ValueBuilder<T> builder,
  ) => build(builder, distinct: true);

  Widget build(
    ValueBuilder<T> builder,
    {bool distinct = false,}
  ) => StreamBuilder<T>(
    stream: distinct ?? false
      ? this.outDistinct
      : this.out,
    initialData: this.value,
    builder: (BuildContext context, AsyncSnapshot<T> snapshot)
      => builder(context,snapshot.data),
  );

  Widget buildChild({
    Widget child,
    @required ChildValueBuilder builder,
    bool distinct = false,
  }) => StreamBuilder<T>(
    stream: distinct ?? false 
      ? this.outDistinct
      : this.out,
    initialData: this.value,
    builder: (BuildContext context, AsyncSnapshot<T> snapshot)
      => builder(context,snapshot.data, child),
  );




}