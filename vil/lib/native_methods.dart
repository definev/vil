import 'dart:core';

abstract class NativeMethods {
  void out(dynamic value);
}

class Console extends NativeMethods {
  void out(dynamic value) {
    print(value);
  }
}
