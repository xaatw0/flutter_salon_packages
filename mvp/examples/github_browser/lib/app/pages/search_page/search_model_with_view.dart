import 'package:github_browser/domain/entities/search_model.dart';
import 'package:github_browser/domain/repositories/git_repository.dart';

class SearchModelWithView extends SearchModel {
  const SearchModelWithView(
    super.searchWord,
    super.selectedSortMethod,
    this.isSearchingForRepository,
  );

  final bool isSearchingForRepository;

  SearchModelWithView copyWith({
    String? searchWord,
    SortMethod? selectedSortMethod,
    bool? isSearchingForRepository,
  }) {
    return SearchModelWithView(
      searchWord ?? this.searchWord,
      selectedSortMethod ?? this.selectedSortMethod,
      isSearchingForRepository ?? this.isSearchingForRepository,
    );
  }
}
