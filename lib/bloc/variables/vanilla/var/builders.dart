part of bloc_var;

extension BlocVarBuilders<T> on BlocVar<T> {

  Widget buildDistinct(
    ValueBuilder<T?> builder,
  ) => build(builder, distinct: true);

  Widget build(
    ValueBuilder<T> builder,
    {bool distinct = false,}
  ) => StreamBuilder<T>(
    stream: distinct
      ? this.outDistinct
      : this.out,
    initialData: this.value,
    builder: (BuildContext context, AsyncSnapshot<T> snapshot)
      => builder(context, snapshot.data as T),
      // data can be null but it will only be null when value is really null
  );

  Widget buildChild({
    Widget? child,
    required ChildValueBuilder<T> builder,
    bool distinct = false,
  }) => StreamBuilder<T>(
    stream: distinct 
      ? this.outDistinct
      : this.out,
    initialData: this.value,
    builder: (BuildContext context, AsyncSnapshot<T> snapshot)
      => builder(context, snapshot.data as T, child),
  );




}