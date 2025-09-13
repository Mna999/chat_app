import 'package:flutter_riverpod/flutter_riverpod.dart';

final lastActiveProvider = StateNotifierProvider<LastActiveNotifier, DateTime>(
  (ref) => LastActiveNotifier(),
);

class LastActiveNotifier extends StateNotifier<DateTime> {
  LastActiveNotifier() : super(DateTime.now());

  void setDate(DateTime date) {
    state = date;
  }
}
