import 'package:flutter/material.dart';
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
  late final _presenter =
      widget.presenter ?? SearchResultPresenter(this, widget.searchResultModel);

  final _kerDrawer = GlobalKey<ModelessDrawerState<GitRepositoryData>>();

  @override
  Widget build(BuildContext context) {
    final data = _presenter.repositoryData;

    return Stack(
      children: [
        NotificationListener<ScrollEndNotification>(
          onNotification: (ScrollEndNotification notification) =>
              _presenter.onGitListScrolled(notification.metrics.extentAfter),
          child: data.isEmpty
              ? const NotFoundResult()
              : SearchResultListView(
                  data: data,
                  onTapped: (context, repository) =>
                      _presenter.onRepositoryTapped(repository),
                  isLoading: _presenter.isLoadingForRepository,
                ),
        ),
        ModelessDrawer<GitRepositoryData>(
          key: _kerDrawer,
          builder: (BuildContext context, GitRepositoryData? selectedValue) =>
              GitRepositoryDataDrawer(
            _presenter.selectedRepository ?? GitRepositoryData.empty,
          ),
        ),
      ],
    );
  }

  @override
  Future<void> changeDrawerWithRepository() {
    final state = _kerDrawer.currentState;
    if (state == null) {
      return Future.value();
    }

    return _presenter.selectedRepository == null ? state.close() : state.open();
  }
}
