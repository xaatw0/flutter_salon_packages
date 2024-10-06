import 'package:flutter/material.dart';
import 'package:github_browser/app/pages/search_page/search_view.dart';
import 'package:github_browser/app/pages/search_result_page/search_result_page.dart';
import 'package:github_browser/app/widgets/templates/day_night_template.dart';
import 'package:github_browser/domain/entities/search_result_model.dart';
import 'package:mvp/mvp.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../domain/repositories/git_repository.dart';
import 'search_model_with_view.dart';

class SearchPresenter {
  final SearchView _view;
  final _delegate =
      PresenterDelegate<SearchModelWithView>(const SearchModelWithView(
    '',
    SortMethod.bestMatch,
    false,
  ));

  SearchModelWithView get _model => _delegate.model;

  SearchPresenter(this._view);

  bool get isSearchingForRepository => _model.isSearchingForRepository;

  /// 画面が縦向きか判断する(true:縦向き false:横向き)
  bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  /// キーボードが表示されているか取得する(true:表示 false:非表示)
  bool isKeyboardShown(BuildContext context) =>
      0.0 < MediaQuery.of(context).viewInsets.bottom;

  /// キーワードが入力されているか取得する(true:入力あり false:入力なし)
  bool get isKeywordAvailable => _model.searchWord.isNotEmpty;

  bool get isDarkMode => false;

  void changeSearchWord(String word) =>
      _delegate.refresh(_view, _model.copyWith(searchWord: word));

  void Function()? onSearch(BuildContext context) =>
      _model.isSearchingForRepository ? null : () => _onSearch(context);

  Future<void> onSubmitted(BuildContext context) => _onSearch(context);

  Future<void> _onSearch(BuildContext context) async {
    _delegate.refresh(_view, _model.copyWith(isSearchingForRepository: true));

    final repositories = await _model.searchRepositories();
    final searchResultModel = SearchResultModel(
        searchModel: _model, currentPage: 1, repositoryData: repositories);
    _delegate.refresh(_view, _model.copyWith(isSearchingForRepository: false));

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return DayNightTemplate(
              title:
                  '${AppLocalizations.of(context).searchResult} [${_model.searchWord}]',
              child: SearchResultPage(searchResultModel),
            );
          },
        ),
      );
    }
  }

  void onSelectSortMethod(BuildContext context) async {
    final newMethod = await _view.selectSortMethod();
    if (newMethod != null) {
      _delegate.refresh(_view, _model.copyWith(selectedSortMethod: newMethod));
    }
  }
}
