import 'package:vil/environment.dart';
import 'package:vil/grammar/statement.dart';
import 'package:vil/interpreter.dart';
import 'package:vil/vil_callable.dart';
import 'package:vil/vil_instance.dart';

class VilFunction implements VilCallable {
  const VilFunction(this.declaration, this.closure);
  final FuncDecl declaration;
  final Environment closure;

  VilFunction bind(VilInstance vilInstance) {
    Environment environment = Environment({}, parent: closure.parent);
    environment.define('self', vilInstance);
    return VilFunction(declaration, environment);
  }

  @override
  int get argsSize => declaration.params.length;

  @override
  dynamic call(Interpreter interpreter, List arguments) {
    Environment functionScope = Environment({}, parent: closure);

    for (int i = 0; i < declaration.params.length; i++) {
      functionScope.define(declaration.params[i].lexeme, arguments[i]);
    }

    try {
      interpreter.executeBlock(declaration.body, functionScope);
    } on ReturnEvent catch (e) {
      return e.value;
    }
  }

  @override
  String toString() => '<hàm "${declaration.name.lexeme}">';
}
