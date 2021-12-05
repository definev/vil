// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statement.dart';

// **************************************************************************
// AstGenerator
// **************************************************************************

abstract class StatementVisitor<T> {
  T visitPrint(Print print);
  T visitExpr(Expr expr);
  T visitVariableDecl(VariableDecl variableDecl);
  T visitBlock(Block block);
}

abstract class Statement {
  T accept<T>(StatementVisitor<T> visitor);
}

class Print extends Statement {
  final Expression expression;
  Print(
    this.expression,
  );
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitPrint(this);
  }
}

class Expr extends Statement {
  final Expression expression;
  Expr(
    this.expression,
  );
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitExpr(this);
  }
}

class VariableDecl extends Statement {
  final Token name;
  final Expression? value;
  VariableDecl(
    this.name,
    this.value,
  );
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitVariableDecl(this);
  }
}

class Block extends Statement {
  final List<Statement> statements;
  Block(
    this.statements,
  );
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitBlock(this);
  }
}
