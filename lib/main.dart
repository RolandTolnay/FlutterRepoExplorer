import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'dart:async';
import 'dart:convert';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Repo Explorer",
      theme: new ThemeData(primaryColor: Colors.blue.shade900),
      home: new RepoScreen(),
    );
  }
}

class RepoScreen extends StatefulWidget {
  @override
  _RepoScreenState createState() => new _RepoScreenState();
}

class _RepoScreenState extends State<RepoScreen> {
  var _repos = <Repository>[];
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData("calendar");
  }

  /// Load repositories asynchronously for the given search term
  _loadData(String searchTerm) async {
    final fetcher = new GitHubFetcher.dartRepos();
    setState(() {
      _isLoading = true;
    });

    final result = await fetcher.searchFor(searchTerm);
    setState(() {
      _repos = result;
      _isLoading = false;
    });
  }

  // Main build method for the widget
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Repo Explorer"),
        ),
        body: new Container(
          child: new Column(
            children: <Widget>[
              _searchField(),
              new Expanded(
                  child: _isLoading ? _loadingIndicator() : _repoList())
            ],
          ),
        ));
  }

  /// Text input for entering search term
  Widget _searchField() {
    // TODO: Implement search TextField
    return new Container();
  }

  /// Loading indicator displayed while fetching results
  Widget _loadingIndicator() {
    return new Center(child: new CircularProgressIndicator());
  }

  /// List showing fetched repositories
  Widget _repoList() {
    // TODO: Implement repository list
    return new Container();
  }
}

class Repository {
  final String name;
  final String url;
  final String description;

  final String authorName;
  final String authorAvatarUrl;
  final int stars;

  Repository.fromJSON(Map jsonData)
      : name = jsonData['name'],
        url = jsonData['html_url'],
        description = jsonData['description'],
        authorName = jsonData['owner']['login'],
        authorAvatarUrl = jsonData['owner']['avatar_url'],
        stars = jsonData['stargazers_count'];
}

class GitHubFetcher {
  final String apiUrl;
  final String language;

  GitHubFetcher.dartRepos()
      : apiUrl = 'https://api.github.com/search/repositories',
        language = 'dart';

  /// Asynchronously searches the apiUrl for the search term in the given language
  Future<List<Repository>> searchFor(String searchTerm) async {
    if (searchTerm == null || searchTerm == "") {
      return new List();
    }

    final url = '$apiUrl?q=$searchTerm+language:$language&sort=stars';
    http.Response response = await http.get(url);
    Map data = JSON.decode(response.body);

    List<Repository> repositories = new List();
    final items = data['items'];
    if (items != null) {
      for (var jsonRepo in items) {
        final parsed = new Repository.fromJSON(jsonRepo);
        repositories.add(parsed);
      }
    }
    return repositories;
  }
}

class RepositoryListItem extends StatelessWidget {
  final Repository repository;
  RepositoryListItem(this.repository);

  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      // TODO: Implement ListItem
    );
  }

  /// Navigates to the detail screen of the repository
  _navigateToRepoDetailScreen(BuildContext context) {
    // TODO: Implement navigation
  }
}

class RepositoryDetailScreen extends StatelessWidget {
  final Repository repository;
  RepositoryDetailScreen(this.repository);

  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text("Repository Details")),
      body: new Container(
        child: new Padding(
          padding: const EdgeInsets.all(32.0),
          child: new Column(
            children: <Widget>[
              new Text("${repository.name}", style: _biggerFont),
              new Container(height: 16.0),
              new Text("${repository.description}"),
              new Container(height: 16.0),
              new RaisedButton(
                child: new Text("Open"),
                onPressed: () {
                  _openUrl(repository.url);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
