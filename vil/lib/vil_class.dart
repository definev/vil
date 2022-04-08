import 'package:vil/interpreter.dart';
import 'package:vil/vil_callable.dart';
import 'package:vil/vil_function.dart';
import 'package:vil/vil_instance.dart';

class VilClass implements VilCallable {
  VilClass(this.name, this.methods);

  final String name;
  final Map<String, VilFunction> methods;

  VilFunction? findMethod(String function) {
    if (methods.containsKey(function)) {
      return methods[function];
    }

    return null;
  }

  @override
  int get argsSize => 0;

  @override
  dynamic call(Interpreter interpreter, List arguments) {
    VilInstance instance = VilInstance(this);
    return instance;
  }

  @override
  String toString() => '<lớp "$name">';
}
