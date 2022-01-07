import 'package:test/test.dart';
import 'package:vil/vil.dart';

import 'native_methods_mock.dart';
import 'package:path/path.dart' as Path;

void main() {
  group('Function test', () {
    test('Function with no return', () {
      setupMockVil();
      final path = '${Path.current}/test/testcase/no_return_function.vil';
      Vil.runFile(path);

      expect((Vil.native as TestingNative).content, 'Chào Definev!\n');
    });
    test('Fibonacci', () {
      setupMockVil();
      final path = '${Path.current}/test/testcase/fibonacci.vil';
      Vil.runFile(path);

      expect(
          (Vil.native as TestingNative).content, '1\n1\n2\n3\n5\n8\n13\n21\n');
    });
    test('Shadowing function', () {
      setupMockVil();
      final path = '${Path.current}/test/testcase/shadowing_function.vil';
      Vil.runFile(path);

      expect((Vil.native as TestingNative).content, '1\n2\n');
    });
  });
}
