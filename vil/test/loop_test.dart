import 'package:test/test.dart';
import 'package:vil/vil.dart';
import 'package:vil/vil_error.dart';

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
    test('For loop', () {
      setupMockVil();
      final path = '${Path.current}/test/testcase/for_loop.vil';
      Vil.runFile(path);

      expect((Vil.native as TestingNative).content, '0\n1\n2\n3\n4\n');
    });

    test('For loop with break', () {
      setupMockVil();
      final path = '${Path.current}/test/testcase/for_loop_with_break.vil';
      Vil.runFile(path);

      expect((Vil.native as TestingNative).content, '0\n1\n2\n3\n4\n');
    });

    test('For loop no paren', () {
      setupMockVil();
      final path = '${Path.current}/test/testcase/for_loop_no_paren.vil';
      Vil.runFile(path);

      expect((Vil.native as TestingNative).content, '0\n1\n2\n3\n4\n');
    });

    test('For loop error', () {
      setupMockVil();
      final path = '${Path.current}/test/testcase/for_loop_error.vil';

      try {
        Vil.runFile(path);
      } on VilCompileError catch (_) {
        expect(
          (Vil.native as TestingNative).errorContent,
          '|PARSER| [1, 14]: Lỗi tại "{": Thiếu dấu ")" sau vòng lặp.\n',
        );
      }
    });
  });
}
