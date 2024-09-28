import 'package:github_browser/app/pages/search_result_page/search_result_view.dart';
import 'package:github_browser/domain/entities/git_repository_data.dart';
import 'package:mvp/mvp.dart';

import '../../../domain/entities/search_result_model.dart';

class SearchResultPresenter extends BasePresenter<SearchResultModel> {
  final SearchResultView view;

  SearchResultPresenter(this.view, SearchResultModel model) : super(model);

  void onRepositoryTapped(GitRepositoryData? selectedRepository) {
    refresh(view, model.copyWith(selectedRepository: selectedRepository));
    view.changeDrawerWithRepository();
  }

  bool onGitListScrolled(double end) {
    final isScrollToEnd = end == 0;
    if (isScrollToEnd) {
      refresh(view, model.copyWith(isLoadingForRepository: true));
      model.loadNewData().then((newModel) {
        refresh(view, newModel.copyWith(isLoadingForRepository: false));
      }).onError((e, st) {
        refresh(view, model.copyWith(isLoadingForRepository: false));
      });
    }
    return isScrollToEnd;
  }
}
