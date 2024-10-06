import 'package:mvp_flutter/mvp_flutter.dart';

abstract class SearchResultView implements BaseView {
  Future<void> changeDrawerWithRepository();
}
