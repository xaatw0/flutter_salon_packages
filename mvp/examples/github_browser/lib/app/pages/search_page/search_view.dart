import 'package:mvp/mvp.dart';

import '../../../domain/repositories/git_repository.dart';

abstract class SearchView implements BaseView {
  Future<SortMethod?> selectSortMethod();
}
