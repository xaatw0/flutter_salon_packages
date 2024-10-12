class AbstractValueObject<T> {
  final T _value;
  const AbstractValueObject(this._value);

  T call() => _value;

  T toJson() => this();
}
