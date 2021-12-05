// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expression.dart';

// **************************************************************************
// AstGenerator
// **************************************************************************

abstract class ExpressionVisitor<T> {
  T visitBinary(Binary binary);
  T visitGrouping(Grouping grouping);
  T visitLiteral(Literal literal);
  T visitUnary(Unary unary);
  T visitVariable(Variable variable);
  T visitAssign(Assign assign);
}

abstract class Expression {
  T accept<T>(ExpressionVisitor<T> visitor);
}

class Binary extends Expression {
  final Expression left;
  final Token operator;
  final Expression right;
  Binary(
    this.left,
    this.operator,
    this.right,
  );
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitBinary(this);
  }
}

class Grouping extends Expression {
  final Expression expression;
  Grouping(
    this.expression,
  );
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitGrouping(this);
  }
}

class Literal extends Expression {
  final dynamic value;
  Literal(
    this.value,
  );
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitLiteral(this);
  }
}

class Unary extends Expression {
  final Token operator;
  final Expression right;
  Unary(
    this.operator,
    this.right,
  );
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitUnary(this);
  }
}

class Variable extends Expression {
  final Token name;
  Variable(
    this.name,
  );
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitVariable(this);
  }
}

class Assign extends Expression {
  final Token name;
  final Expression value;
  Assign(
    this.name,
    this.value,
  );
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitAssign(this);
  }
}
