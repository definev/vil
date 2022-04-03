import 'dart:core';

abstract class NativeMethods {
  void out(dynamic value);
  void error(dynamic value);
}

class Console extends NativeMethods {
  void out(dynamic value) {
    print(value);
  }

  void error(dynamic value) {
    print(value);
  }
}
