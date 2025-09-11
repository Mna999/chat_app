import 'package:flutter_riverpod/flutter_riverpod.dart';

final textProvider = StateNotifierProvider<TextNotifier, String>(
  (ref) => TextNotifier(),
);

class TextNotifier extends StateNotifier<String> {
  TextNotifier() : super('');

  void setText(String text) {
    state = text;
  }
}
