import 'package:test/test.dart';
import 'package:vil/vil.dart';

import 'native_methods_mock.dart';
import 'package:path/path.dart' as Path;

void main() {
  setupMockVil();

  test('block of code nested', () {
    final path = '${Path.current}/test/testcase/block_nested.vil';
    Vil.runFile(path);
    expect(
      (Vil.native as TestingNative).content,
      ''' Scope: 3  Scope: 2  Scope: 2 \n Scope: 1  Scope: 2  Scope: 2 \n Scope: 1  Scope: 1  Scope: 1 \n''',
    );
  });
}
