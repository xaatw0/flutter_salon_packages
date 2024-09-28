import 'package:github_browser/domain/entities/search_model.dart';

import 'git_repository_data.dart';

class SearchResultModel {
  const SearchResultModel({
    required this.searchModel,
    required this.currentPage,
    required this.repositoryData,
    this.selectedRepository,
    this.isLoadingForRepository = false,
  });

  final SearchModel searchModel;
  final List<GitRepositoryData> repositoryData;
  final int currentPage;
  final GitRepositoryData? selectedRepository;
  final bool isLoadingForRepository;

  SearchResultModel copyWith({
    SearchModel? searchModel,
    List<GitRepositoryData>? repositoryData,
    int? currentPage,
    GitRepositoryData? selectedRepository,
    bool? isLoadingForRepository,
  }) {
    return SearchResultModel(
      searchModel: searchModel ?? this.searchModel,
      currentPage: currentPage ?? this.currentPage,
      repositoryData: repositoryData ?? this.repositoryData,
      selectedRepository: selectedRepository ?? this.selectedRepository,
      isLoadingForRepository:
          isLoadingForRepository ?? this.isLoadingForRepository,
    );
  }

  Future<SearchResultModel> loadNewData() async {
    final nextPage = currentPage + 1;
    final newRepositories =
        await searchModel.searchRepositories(page: nextPage);
    return copyWith(
      currentPage: nextPage,
      repositoryData: [...repositoryData, ...newRepositories],
    );
  }
}
