import 'package:flutter/material.dart';
import '../../../domain/entities/git_repository_data.dart';
import '../../../domain/string_resources.dart';
import '../../widgets/molecules/owner_clip.dart';
import '../../widgets/molecules/repository_detail_column.dart';

class GitRepositoryDataDrawer extends StatelessWidget {
  const GitRepositoryDataDrawer(
    this.repositoryData, {
    super.key,
  });

  final GitRepositoryData repositoryData;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(repositoryData.repositoryName.value),
        if (repositoryData.ownerIconUrl.value?.isNotEmpty ?? false)
          OwnerClip(repositoryData.ownerIconUrl),
        Text(repositoryData.repositoryHtmlUrl.value),
        const SizedBox(height: 32),
        RepositoryDetailColumn(
          StringResources.kStar,
          repositoryData.countStar.value,
        ),
        const SizedBox(height: 16),
        RepositoryDetailColumn(
          StringResources.kWatchers,
          repositoryData.countWatcher.value,
        ),
        const SizedBox(height: 16),
        RepositoryDetailColumn(
          StringResources.kForks,
          repositoryData.countFork.value,
        ),
        const SizedBox(height: 16),
        RepositoryDetailColumn(
          StringResources.kIssues,
          repositoryData.countIssue.value,
        ),
      ],
    );
  }
}
