import 'package:vil/interpreter.dart';
import 'package:vil/vil_callable.dart';

class ClockFunction implements VilCallable {
  @override
  int get argsSize => 0;

  @override
  call(Interpreter interpreter, List arguments) {
    return DateTime.now().millisecondsSinceEpoch;
  }

  @override
  String toString() {
    return '<native \'clock\'>';
  }
}
