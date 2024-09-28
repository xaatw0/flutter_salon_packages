import 'package:flutter/material.dart';
import 'package:github_browser/app/pages/search_page/search_view.dart';
import 'package:github_browser/app/pages/search_result_page/search_result_page.dart';
import 'package:github_browser/domain/entities/search_model.dart';
import 'package:github_browser/domain/entities/search_result_model.dart';
import 'package:mvp/mvp.dart';

import '../../../domain/repositories/git_repository.dart';

class SearchPresenter extends BasePresenter<SearchModel> {
  final SearchView view;
  SearchPresenter(this.view)
      : super(const SearchModel('', SortMethod.bestMatch));

  /// 画面が縦向きか判断する(true:縦向き false:横向き)
  bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  /// キーボードが表示されているか取得する(true:表示 false:非表示)
  bool isKeyboardShown(BuildContext context) =>
      0.0 < MediaQuery.of(context).viewInsets.bottom;

  /// キーワードが入力されているか取得する(true:入力あり false:入力なし)
  bool get isKeywordAvailable => model.searchWord.isNotEmpty;

  bool get isDarkMode => false;

  void changeSearchWord(String word) =>
      refresh(view, model.copyWith(searchWord: word));

  void Function()? onSearch(BuildContext context) =>
      model.isSearchingForRepository ? null : () => _onSearch(context);

  Future<void> onSubmitted(BuildContext context) => _onSearch(context);

  Future<void> _onSearch(BuildContext context) async {
    refresh(view, model.copyWith(isLoading: true));

    final repositories = await model.searchRepositories();
    final searchResultModel = SearchResultModel(
        searchModel: model, currentPage: 1, repositoryData: repositories);
    refresh(view, model.copyWith(isLoading: false));

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return SearchResultPage(searchResultModel);
          },
        ),
      );
    }
  }

  void onSelectSortMethod(BuildContext context) async {
    final newMethod = await view.selectSortMethod();
    if (newMethod != null) {
      refresh(view, model.copyWith(selectedSortMethod: newMethod));
    }
  }
}
