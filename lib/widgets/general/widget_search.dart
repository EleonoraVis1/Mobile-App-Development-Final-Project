import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserSearch extends ConsumerStatefulWidget {
  const UserSearch({Key? key, required this.usernames}) : super(key: key);
  final usernames;

  @override
  ConsumerState<UserSearch> createState() => _UserSearchState();
}

class _UserSearchState extends ConsumerState<UserSearch> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        actions: [
          
        ],
      ),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate<String> {
  final List<String> usernames;

  CustomSearchDelegate({required this.usernames});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = '',
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, ''),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final matchQuery = usernames
        .where((username) => username.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildList(matchQuery, context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {

    if (query.isEmpty) {
      return const Center(
        child: Text(
          'Start typing to search...',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final matchQuery = usernames
        .where((username) => username.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildList(matchQuery, context);
  }

  Widget _buildList(List<String> results, BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return ListTile(
          title: Text(result),
          onTap: () {
            close(context, result);
          },
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
        );
      },
    );
  }
}
