import 'package:mvp_flutter/mvp_flutter.dart';

abstract class CounterView implements BaseView {
  Future<bool?> askReset();
}
