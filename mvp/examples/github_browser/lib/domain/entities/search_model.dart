import 'package:github_browser/domain/entities/git_repository_data.dart';
import 'package:github_browser/domain/service_locator.dart';

import '../repositories/git_repository.dart';

class SearchModel {
  const SearchModel(
    this.searchWord,
    this.selectedSortMethod, {
    this.isSearchingForRepository = false,
  });

  final String searchWord;
  final SortMethod selectedSortMethod;
  final bool isSearchingForRepository;

  Future<List<GitRepositoryData>> searchRepositories({int? page}) {
    final gitRepository = ServiceLocator.instance.gitRepository;

    return gitRepository.search(
      searchWord,
      sortMethod: selectedSortMethod,
      page: page ?? gitRepository.getFirstPageIndex(),
    );
  }

  SearchModel copyWith({
    String? searchWord,
    SortMethod? selectedSortMethod,
    bool? isLoading,
  }) {
    return SearchModel(
      searchWord ?? this.searchWord,
      selectedSortMethod ?? this.selectedSortMethod,
      isSearchingForRepository: isLoading ?? this.isSearchingForRepository,
    );
  }
}
