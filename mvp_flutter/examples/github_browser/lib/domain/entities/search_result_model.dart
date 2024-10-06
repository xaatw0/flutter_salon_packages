import 'package:github_browser/domain/entities/search_model.dart';

import 'git_repository_data.dart';

class SearchResultModel {
  const SearchResultModel({
    required this.searchModel,
    required this.currentPage,
    required this.repositoryData,
    this.selectedRepository,
  });

  final SearchModel searchModel;
  final List<GitRepositoryData> repositoryData;
  final int currentPage;
  final GitRepositoryData? selectedRepository;

  Future<SearchResultModel> loadNewData() async {
    final nextPage = currentPage + 1;
    final newRepositories =
        await searchModel.searchRepositories(page: nextPage);
    return SearchResultModel(
      searchModel: searchModel,
      currentPage: nextPage,
      repositoryData: [...repositoryData, ...newRepositories],
      selectedRepository: selectedRepository,
    );
  }
}
