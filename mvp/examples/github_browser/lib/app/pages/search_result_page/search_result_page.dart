import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:github_browser/app/pages/search_result_page/search_result_presenter.dart';
import 'package:github_browser/app/pages/search_result_page/search_result_view.dart';
import 'package:github_browser/domain/entities/git_repository_data.dart';
import 'package:modeless_drawer/modeless_drawer.dart';

import '../../../domain/entities/search_result_model.dart';
import '../../widgets/atoms/not_found_result.dart';
import '../../widgets/organisms/search_result_list_view.dart';
import 'git_repository_data_drawer.dart';

/// 検索結果を表示するためのページのView
class SearchResultPage extends StatefulWidget {
  const SearchResultPage(
    this.searchResultModel, {
    super.key,
    this.presenter,
  });

  final SearchResultModel searchResultModel;
  final SearchResultPresenter? presenter;

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage>
    implements SearchResultView {
  late final presenter =
      widget.presenter ?? SearchResultPresenter(this, widget.searchResultModel);

  final _kerDrawer = GlobalKey<ModelessDrawerState<GitRepositoryData>>();

  @override
  Widget build(BuildContext context) {
    final data = presenter.model.repositoryData;

    return Scaffold(
      appBar: AppBar(
          title: Text(
              '${AppLocalizations.of(context).searchResult} [${widget.searchResultModel.searchModel.searchWord}]')),
      body: Stack(
        children: [
          NotificationListener<ScrollEndNotification>(
            onNotification: (ScrollEndNotification notification) =>
                presenter.onGitListScrolled(notification.metrics.extentAfter),
            child: data.isEmpty
                ? const NotFoundResult()
                : SearchResultListView(
                    data: data,
                    onTapped: (context, repository) =>
                        presenter.onRepositoryTapped(repository),
                    isLoading: presenter.model.isLoadingForRepository,
                  ),
          ),
          ModelessDrawer<GitRepositoryData>(
            key: _kerDrawer,
            builder: (BuildContext context, GitRepositoryData? selectedValue) =>
                GitRepositoryDataDrawer(
              presenter.model.selectedRepository ??
                  presenter.model.repositoryData.first,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Future<void> changeDrawerWithRepository() {
    final state = _kerDrawer.currentState;
    if (state == null) {
      return Future.value();
    }

    return presenter.model.selectedRepository == null
        ? state.close()
        : state.open();
  }
}
