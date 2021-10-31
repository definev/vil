import 'package:annotations/annotations.dart';
import 'package:vil/token.dart';

part 'expression.g.dart';

@Ast([
  "Binary   : Expression left, Token operator, Expression right",
  "Grouping : Expression expression",
  "Literal  : dynamic value",
  "Unary    : Token operator, Expression right"
])
class _Expression {}
