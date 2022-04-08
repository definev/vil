// ignore_for_file: unused_element

import 'package:annotations/annotations.dart';
import 'package:vil/grammar/expression.dart';
import 'package:vil/token.dart';

part 'statement.g.dart';

@Ast([
  'Print           : Expression expression',
  'Expr            : Expression expression',
  'VariableDecl    : Token name, Expression? initializer',
  'FuncDecl        : Token name, List<Token> params, List<Statement> body',
  'ClassDecl       : Token name, List<FuncDecl> methods',
  'Block           : List<Statement> statements',
  'IfStatement     : Expression condition, Statement thenStatement, Statement? elseStatement',
  'WhileLoop       : Expression condition, Statement body',
  'BreakStatement  : ',
  'ReturnStatement : Token keyword, Expression? value',
])
class _Statement {}
