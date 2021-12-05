import 'package:test/test.dart';
import 'package:vil/vil.dart';

import 'native_methods_mock.dart';
import 'package:path/path.dart' as Path;

void main() {
  setupMockVil();

  test('primary "đúng" | "sai" | "rỗng" | số | chuỗi', () {
    final path = '${Path.current}/test/testcase/primary_type.vil';
    Vil.runFile(path);
    expect(
      (Vil.native as TestingNative).content,
      '''1\nhello\nđúng\nsai\n''',
    );
  });
}
