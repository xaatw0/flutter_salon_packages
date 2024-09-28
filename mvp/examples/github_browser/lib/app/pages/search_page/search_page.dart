import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:github_browser/app/pages/search_page/search_presenter.dart';
import 'package:github_browser/app/pages/search_page/search_view.dart';
import 'package:github_browser/app/pages/search_page/visible_widget_logic.dart';
import 'package:github_browser/domain/repositories/git_repository.dart';

import '../../widgets/atoms/cancel_tab_key.dart';
import '../../widgets/molecules/search_text_field.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// 検索用のトップページのView
class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.presenter});

  static const path = '/';
  final SearchPresenter? presenter;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> implements SearchView {
  late final SearchPresenter presenter =
      widget.presenter ?? SearchPresenter(this);

  @override
  Widget build(BuildContext context) {
    // 画面が横向きの場合、キーボードと入力欄が被る可能性が高い。
    // そのため、横向きでキーボード表示時は、アイコンを消して、Padding を小さくする
    final visibleWidgetLogic = VisibleWidgetLogic(
      isWeb: kIsWeb,
      isPortrait: presenter.isPortrait(context),
      isKeyboardShown: presenter.isKeyboardShown(context),
      isTextInputted: presenter.isKeywordAvailable,
    );
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 検索のキーワード入力
          Semantics(
            container: true,
            label: AppLocalizations.of(context).searchExplain,
            child: CancelTabKey(
              child: SearchTextField(
                controller: kIsWeb ? KanjiTextEditingController() : null,
                onChangeKeyword: presenter.changeSearchWord,
                onSubmitted: (_) => presenter.onSubmitted(context),
                onSelectSortMethod: () => presenter.onSelectSortMethod(context),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 検索ボタン
          // アプリでは、キーボードが非表示でキーワードが入力済みの時のみ表示される

          Visibility(
            visible: visibleWidgetLogic.isButtonVisible,
            child: Semantics(
              container: true,
              label: AppLocalizations.of(context).search,
              child: OutlinedButton(
                onPressed: presenter.onSearch(context),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _searchButton(
                      context, presenter.model.isSearchingForRepository),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchButton(BuildContext context, bool isLoading) {
    return isLoading
        ? const SizedBox(
            height: 16, width: 16, child: CircularProgressIndicator())
        : Text(
            AppLocalizations.of(context).search,
            style: Theme.of(context).textTheme.titleMedium!.merge(
                  TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
          );
  }

  @override
  Future<SortMethod?> selectSortMethod() async {
    return showDialog<SortMethod>(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(AppLocalizations.of(context).sortOptions),
            children: SortMethod.values
                .map(
                  (method) => SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, method),
                    child: Text(method.title),
                  ),
                )
                .toList(),
          );
        });
  }
}
