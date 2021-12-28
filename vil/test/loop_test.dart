import 'package:test/test.dart';
import 'package:vil/vil.dart';

import 'native_methods_mock.dart';
import 'package:path/path.dart' as Path;

void main() {
  group('Loop test', () {
    test('While loop', () {
      setupMockVil();
      final path = '${Path.current}/test/testcase/while_loop.vil';
      Vil.runFile(path);

      expect((Vil.native as TestingNative).content, '0\n1\n2\n3\n4\n');
    });
  });
}
