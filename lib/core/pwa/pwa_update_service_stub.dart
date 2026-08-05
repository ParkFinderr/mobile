import 'dart:async';

class PwaUpdateService {
  static final PwaUpdateService instance = PwaUpdateService._();
  PwaUpdateService._();

  Stream<void> get onUpdateReady => const Stream.empty();

  void init() {}
  void checkForUpdate() {}
  void performUpdate() {}
}
