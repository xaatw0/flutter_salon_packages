import 'package:github_browser/domain/entities/search_result_model.dart';

import '../../../domain/entities/git_repository_data.dart';
import '../../../domain/entities/search_model.dart';

class SearchResultModelWithView extends SearchResultModel {
  const SearchResultModelWithView({
    required super.searchModel,
    required super.currentPage,
    required super.repositoryData,
    super.selectedRepository,
    this.isLoadingForRepository = false,
  });

  final bool isLoadingForRepository;

  SearchResultModelWithView copyWith({
    SearchModel? searchModel,
    List<GitRepositoryData>? repositoryData,
    int? currentPage,
    GitRepositoryData? selectedRepository,
    bool? isLoadingForRepository,
  }) {
    return SearchResultModelWithView(
      searchModel: searchModel ?? this.searchModel,
      currentPage: currentPage ?? this.currentPage,
      repositoryData: repositoryData ?? this.repositoryData,
      selectedRepository: selectedRepository ?? this.selectedRepository,
      isLoadingForRepository:
          isLoadingForRepository ?? this.isLoadingForRepository,
    );
  }
}
