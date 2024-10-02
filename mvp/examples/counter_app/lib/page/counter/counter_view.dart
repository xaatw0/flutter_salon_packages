import 'package:mvp/mvp.dart';

abstract class CounterView implements BaseView {
  Future<bool?> askReset();
}