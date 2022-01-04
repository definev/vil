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
  T visitPostfix(Postfix postfix);
  T visitVariable(Variable variable);
  T visitTernary(Ternary ternary);
  T visitAssign(Assign assign);
  T visitLogical(Logical logical);
}

abstract class Expression {
  const Expression();
  T accept<T>(ExpressionVisitor<T> visitor);
}

class Binary extends Expression {
  final Expression left;
  final Token operator;
  final Expression right;
  const Binary(
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
  const Grouping(
    this.expression,
  );
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitGrouping(this);
  }
}

class Literal extends Expression {
  final dynamic value;
  const Literal(
    this.value,
  );
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitLiteral(this);
  }
}

class Unary extends Expression {
  final Token operator;
  final Expression right;
  const Unary(
    this.operator,
    this.right,
  );
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitUnary(this);
  }
}

class Postfix extends Expression {
  final Expression left;
  final Token operator;
  const Postfix(
    this.left,
    this.operator,
  );
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitPostfix(this);
  }
}

class Variable extends Expression {
  final Token name;
  const Variable(
    this.name,
  );
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitVariable(this);
  }
}

class Ternary extends Expression {
  final Expression condition;
  final Expression thenExpression;
  final Expression elseExpression;
  const Ternary(
    this.condition,
    this.thenExpression,
    this.elseExpression,
  );
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitTernary(this);
  }
}

class Assign extends Expression {
  final Token name;
  final Expression value;
  const Assign(
    this.name,
    this.value,
  );
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitAssign(this);
  }
}

class Logical extends Expression {
  final Expression left;
  final Token operator;
  final Expression right;
  const Logical(
    this.left,
    this.operator,
    this.right,
  );
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitLogical(this);
  }
}
