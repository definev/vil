import 'package:vil/grammar/expression.dart';

class AstPrinter implements ExpressionVisitor<String> {
  String print(Expression expression) {
    return expression.accept(this);
  }

  @override
  String visitBinary(Binary expr) {
    return parenthesize(expr.operator.lexeme, [expr.left, expr.right]);
  }

  @override
  String visitGrouping(Grouping expr) {
    return parenthesize("group", [expr.expression]);
  }

  @override
  String visitLiteral(Literal expr) {
    if (expr.value == null) return "rỗng";
    return expr.value.toString();
  }

  @override
  String visitUnary(Unary expr) {
    return parenthesize(expr.operator.lexeme, [expr.right]);
  }

  String parenthesize(String name, List<Expression> exprs) {
    StringBuffer writer = StringBuffer();

    writer.write("($name");
    for (final expr in exprs) {
      writer.write(" ");
      writer.write(expr.accept(this));
    }
    writer.write(")");

    return writer.toString();
  }
}
