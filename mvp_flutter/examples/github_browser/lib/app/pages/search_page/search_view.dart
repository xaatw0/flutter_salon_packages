import 'package:mvp_flutter/mvp_flutter.dart';

import '../../../domain/repositories/git_repository.dart';

abstract class SearchView implements BaseView {
  Future<SortMethod?> selectSortMethod();
}
