import 'package:github_browser/app/pages/search_result_page/search_result_model_with_view.dart';
import 'package:github_browser/app/pages/search_result_page/search_result_view.dart';
import 'package:github_browser/domain/entities/git_repository_data.dart';
import 'package:mvp_flutter/mvp_flutter.dart';

import '../../../domain/entities/search_result_model.dart';

class SearchResultPresenter {
  SearchResultPresenter(
    this._view,
    SearchResultModel searchResultModel,
  ) : _delegate = PresenterDelegate<SearchResultModelWithView>(
          SearchResultModelWithView(
            searchModel: searchResultModel.searchModel,
            currentPage: searchResultModel.currentPage,
            repositoryData: searchResultModel.repositoryData,
          ),
        );

  SearchResultModelWithView get _model => _delegate.model;

  final SearchResultView _view;

  final PresenterDelegate<SearchResultModelWithView> _delegate;

  List<GitRepositoryData> get repositoryData => _model.repositoryData;

  bool get isLoadingForRepository => _model.isLoadingForRepository;

  String get searchWord => _model.searchModel.searchWord;

  GitRepositoryData? get selectedRepository => _model.selectedRepository;

  void onRepositoryTapped(GitRepositoryData? selectedRepository) {
    _delegate.refresh(
        _view, _model.copyWith(selectedRepository: selectedRepository));
    _view.changeDrawerWithRepository();
  }

  bool onGitListScrolled(double end) {
    final isScrollToEnd = end == 0;
    if (isScrollToEnd) {
      _executeWhenScrollReachedEnd();
    }
    return isScrollToEnd;
  }

  void _executeWhenScrollReachedEnd() {
    _delegate.refresh(_view, _model.copyWith(isLoadingForRepository: true));
    _model.loadNewData().then((newDataModel) {
      final newModel = _model.copyWith(
          repositoryData: newDataModel.repositoryData,
          isLoadingForRepository: false);
      _delegate.refresh(_view, newModel);
    }).onError((e, st) {
      _delegate.refresh(_view, _model.copyWith(isLoadingForRepository: false));
    });
  }
}
