import 'package:flutter_riverpod/flutter_riverpod.dart';

final loadingAuthProvider = StateNotifierProvider<LoadingAuthNotifier, bool>(
  (ref) => LoadingAuthNotifier(),
);

class LoadingAuthNotifier extends StateNotifier<bool> {
  LoadingAuthNotifier() : super(false);

  void set() {
    state = true;
  }

  void reset() {
    state = false;
  }
}
