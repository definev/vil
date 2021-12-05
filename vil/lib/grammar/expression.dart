import 'package:annotations/annotations.dart';
import 'package:vil/token.dart';

part 'expression.g.dart';

@Ast([
  "Binary   : Expression left, Token operator, Expression right",
  "Grouping : Expression expression",
  "Literal  : dynamic value",
  "Unary    : Token operator, Expression right",
  "Variable : Token name",
  "Assign   : Token name, Expression value"
])
// ignore: unused_element
class _Expression {}
