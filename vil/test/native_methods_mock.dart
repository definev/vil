import 'package:vil/native_methods.dart';
import 'package:vil/vil.dart';

class TestingNative implements NativeMethods {
  String content = '';
  String errorContent = '';

  @override
  void out(dynamic value) {
    content += value.toString() + '\n';
  }

  @override
  void error(dynamic value) {
    errorContent += value.toString() + '\n';
  }
}

void setupMockVil() {
  final native = TestingNative();
  Vil.native = native;
}
