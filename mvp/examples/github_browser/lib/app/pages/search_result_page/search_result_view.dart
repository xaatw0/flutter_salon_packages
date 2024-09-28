import 'package:mvp/mvp.dart';

abstract class SearchResultView implements BaseView {
  Future<void> changeDrawerWithRepository();
}
