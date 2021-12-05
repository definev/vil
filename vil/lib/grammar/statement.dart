// ignore_for_file: unused_element

import 'package:annotations/annotations.dart';
import 'package:vil/grammar/expression.dart';
import 'package:vil/token.dart';

part 'statement.g.dart';

@Ast([
  'Print        : Expression expression',
  'Expr         : Expression expression',
  'VariableDecl : Token name, Expression? value',
  'Block        : List<Statement> statements',
])
class _Statement {}
