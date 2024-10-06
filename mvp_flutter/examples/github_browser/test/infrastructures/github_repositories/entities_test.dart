import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:github_browser/infrastructures/github_repositories/entities.dart';

void main() {
  const jsonPath =
      'test/infrastructures/github_repositories/entities_test.json';

  const fullJsonPath =
      'test/infrastructures/github_repositories/entities_test_full.json';

  test('Json file', () {
    expect(File(jsonPath).existsSync(), true);
    expect(File(fullJsonPath).existsSync(), true);
  });

  final json = File(jsonPath).readAsStringSync();
  final result = GitHubResponse.fromJson(jsonDecode(json));

  test('GitHubResponse', () {
    expect(result.totalCount, 455887);
    expect(result.incompleteResults, false);
    expect(result.items.length, 2);
  });

  test('Item', () {
    final item = result.items[0];

    expect(item.id, 31792824);
    expect(item.nodeId, 'MDEwOlJlcG9zaXRvcnkzMTc5MjgyNA==');
    expect(item.name, 'flutter');
    expect(item.fullName, 'flutter/flutter');
    expect(item.isPrivate, false);
    expect(item.htmlUrl, 'https://github.com/flutter/flutter');
    expect(item.description,
        'Flutter makes it easy and fast to build beautiful apps for mobile and beyond');
    expect(item.fork, false);
    expect(item.url, 'https://api.github.com/repos/flutter/flutter');
    expect(item.forksUrl, 'https://api.github.com/repos/flutter/flutter/forks');
    expect(item.keysUrl,
        'https://api.github.com/repos/flutter/flutter/keys{/key_id}');
    expect(item.collaboratorsUrl,
        'https://api.github.com/repos/flutter/flutter/collaborators{/collaborator}');
    expect(item.teamsUrl, 'https://api.github.com/repos/flutter/flutter/teams');
    expect(item.hooksUrl, 'https://api.github.com/repos/flutter/flutter/hooks');
    expect(item.issueEventsUrl,
        'https://api.github.com/repos/flutter/flutter/issues/events{/number}');
    expect(
        item.eventsUrl, 'https://api.github.com/repos/flutter/flutter/events');
    expect(item.assigneesUrl,
        'https://api.github.com/repos/flutter/flutter/assignees{/user}');
    expect(item.branchesUrl,
        'https://api.github.com/repos/flutter/flutter/branches{/branch}');
    expect(item.tagsUrl, 'https://api.github.com/repos/flutter/flutter/tags');
    expect(item.createdAt, DateTime.parse('2015-03-06T22:54:58Z'));
    expect(item.updatedAt, DateTime.parse('2022-12-06T23:38:33Z'));
    expect(item.pushedAt, DateTime.parse('2022-12-06T23:30:19Z'));
    expect(item.gitUrl, 'git://github.com/flutter/flutter.git');
    expect(item.sshUrl, 'git@github.com:flutter/flutter.git');
    expect(item.cloneUrl, 'https://github.com/flutter/flutter.git');
    expect(item.svnUrl, 'https://github.com/flutter/flutter');
    expect(item.homepage, 'https://flutter.dev');
    expect(item.size, 228817);
    expect(item.stargazersCount, 146985);
    expect(item.watchersCount, 146985);
    expect(item.language, 'Dart');
    expect(item.hasIssues, true);
    expect(item.hasProjects, true);
    expect(item.hasDownloads, true);
    expect(item.hasWiki, true);
    expect(item.hasPages, false);
    expect(item.hasDiscussions, false);
    expect(item.forksCount, 23912);
    expect(item.allowForking, true);
    expect(item.isTemplate, false);
    expect(item.webCommitSignoffRequired, false);
    expect(item.topics, [
      'android',
      'app-framework',
      'cross-platform',
      'dart',
      'dart-platform',
      'desktop',
      'flutter',
      'flutter-package',
      'fuchsia',
      'ios',
      'linux-desktop',
      'macos',
      'material-design',
      'mobile',
      'mobile-development',
      'skia',
      'web',
      'web-framework',
      'windows'
    ]);
    expect(item.visibility, 'public');
    expect(item.openIssuesCount, 11313);
    expect(item.defaultBranch, 'master');
    expect(item.score, 1.0);
  });

  test('Owner', () {
    final owner = result.items[0].owner;

    expect(owner.login, 'flutter');
    expect(owner.id, 14101776);
    expect(owner.nodeId, 'MDEyOk9yZ2FuaXphdGlvbjE0MTAxNzc2');
    expect(owner.avatarUrl,
        'https://avatars.githubusercontent.com/u/14101776?v=4');
    expect(owner.gravatarId, '');
    expect(owner.url, 'https://api.github.com/users/flutter');
    expect(owner.htmlUrl, 'https://github.com/flutter');
    expect(
        owner.followersUrl, 'https://api.github.com/users/flutter/followers');
    expect(owner.followingUrl,
        'https://api.github.com/users/flutter/following{/other_user}');
    expect(
        owner.gistsUrl, 'https://api.github.com/users/flutter/gists{/gist_id}');
    expect(owner.starredUrl,
        'https://api.github.com/users/flutter/starred{/owner}{/repo}');
    expect(owner.subscriptionsUrl,
        'https://api.github.com/users/flutter/subscriptions');
    expect(owner.organizationsUrl, 'https://api.github.com/users/flutter/orgs');
    expect(owner.reposUrl, 'https://api.github.com/users/flutter/repos');
    expect(owner.eventsUrl,
        'https://api.github.com/users/flutter/events{/privacy}');
    expect(owner.receivedEventsUrl,
        'https://api.github.com/users/flutter/received_events');
    expect(owner.type, 'Organization');
    expect(owner.siteAdmin, false);
  });

  test('Licence', () {
    final license = result.items[0].license;

    expect(license.key, 'bsd-3-clause');
    expect(license.name, 'BSD 3-Clause "New" or "Revised" License');
    expect(license.spdxId, 'BSD-3-Clause');
    expect(license.url, 'https://api.github.com/licenses/bsd-3-clause');
    expect(license.nodeId, 'MDc6TGljZW5zZTU=');
  });

  test('full data', () {
    final json = File(fullJsonPath).readAsStringSync();
    final result = GitHubResponse.fromJson(jsonDecode(json));
    expect(result.totalCount, 743181);
  });
}
