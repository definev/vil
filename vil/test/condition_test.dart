import 'package:test/test.dart';
import 'package:vil/vil.dart';

import 'native_methods_mock.dart';
import 'package:path/path.dart' as Path;

void main() {
  group('Condition statement and ternary expression', () {
    test('Câu lệnh nếu - hoặc', () {
      setupMockVil();
      final path = '${Path.current}/test/testcase/if_statement.vil';
      Vil.runFile(path);

      expect((Vil.native as TestingNative).content, 'Đã kiểm tra\n');
    });

    test('Toán tử điều kiện ba ngôi', () {
      setupMockVil();
      final path = '${Path.current}/test/testcase/ternary.vil';
      Vil.runFile(path);

      expect((Vil.native as TestingNative).content, '1\n');
    });
  });
}
