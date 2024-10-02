class Counter {
  const Counter(this.counter);
  final int counter;

  Counter increase() {
    return Counter(counter + 1);
  }

  Counter decrease() {
    return Counter(counter - 1);
  }

  Counter reset() {
    return const Counter(0);
  }
}
