class BlocEvent<T>{
  BlocEvent(this.event,{this.data});
  T event;
  dynamic data;
}
