import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class BottomIndexNotifier extends StateNotifier<int> {
  BottomIndexNotifier() : super(0);

  void change(int change) {
    state = change;
  }

  void clean() {
    state = 0;
  }
}

final bottomIndexProvider =
    StateNotifierProvider<BottomIndexNotifier, int>((ref) {
  return BottomIndexNotifier();
});


