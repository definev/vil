import 'interpreter.dart';

abstract class VilCallable {
  int get argsSize;

  dynamic call(Interpreter interpreter, List<dynamic> arguments);
}
