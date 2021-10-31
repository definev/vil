// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expression.dart';

// **************************************************************************
// AstGenerator
// **************************************************************************

abstract class Expression {}

class Binary extends Expression {
  final Expression left;
  final Token operator;
  final Expression right;
  Binary(
    this.left,
    this.operator,
    this.right,
  );
}

class Grouping extends Expression {
  final Expression expression;
  Grouping(
    this.expression,
  );
}

class Literal extends Expression {
  final dynamic value;
  Literal(
    this.value,
  );
}

class Unary extends Expression {
  final Token operator;
  final Expression right;
  Unary(
    this.operator,
    this.right,
  );
}
