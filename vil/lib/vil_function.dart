import 'package:vil/environment.dart';
import 'package:vil/grammar/statement.dart';
import 'package:vil/interpreter.dart';
import 'package:vil/vil_callable.dart';

class VilFunction implements VilCallable {
  const VilFunction(this.declaration, this.closure);
  final FuncDecl declaration;
  final Environment closure;

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
  String toString() => '<fn "${declaration.name.lexeme}">';
}
