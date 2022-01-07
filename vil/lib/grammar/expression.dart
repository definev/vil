import 'package:annotations/annotations.dart';
import 'package:vil/token.dart';

part 'expression.g.dart';

@Ast([
  "Binary   : Expression left, Token operator, Expression right",
  "Grouping : Expression expression",
  "Literal  : dynamic value",
  "Unary    : Token operator, Expression right",
  "Postfix   : Expression left, Token operator",
  "Variable : Token name",
  "Ternary  : Expression condition, Expression thenExpression, Expression elseExpression",
  "Assign   : Token name, Expression value",
  "Logical  : Expression left, Token operator, Expression right",
  "Call     : Expression callee, Token paren, List<Expression> arguments",
])
// ignore: unused_element
class _Expression {}
