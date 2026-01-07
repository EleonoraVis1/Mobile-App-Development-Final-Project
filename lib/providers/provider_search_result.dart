import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class SearchResultNotifier extends StateNotifier<String> {
  SearchResultNotifier() : super('');

  void addResult(String result) {
    state = result;
  }
  void clean() {
    state = '';
  }
}

final searchResultProvider =
    StateNotifierProvider<SearchResultNotifier, String>((ref) {
  return SearchResultNotifier();
});


