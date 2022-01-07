// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statement.dart';

// **************************************************************************
// AstGenerator
// **************************************************************************

abstract class StatementVisitor<T> {
  T visitPrint(Print print);
  T visitExpr(Expr expr);
  T visitVariableDecl(VariableDecl variableDecl);
  T visitFuncDecl(FuncDecl funcDecl);
  T visitBlock(Block block);
  T visitIfStatement(IfStatement ifStatement);
  T visitWhileLoop(WhileLoop whileLoop);
  T visitBreakStatement(BreakStatement breakStatement);
  T visitReturnStatement(ReturnStatement returnStatement);
}

abstract class Statement {
  const Statement();
  T accept<T>(StatementVisitor<T> visitor);
}

class Print extends Statement {
  final Expression expression;
  const Print(
    this.expression,
  );
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitPrint(this);
  }
}

class Expr extends Statement {
  final Expression expression;
  const Expr(
    this.expression,
  );
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitExpr(this);
  }
}

class VariableDecl extends Statement {
  final Token name;
  final Expression? value;
  const VariableDecl(
    this.name,
    this.value,
  );
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitVariableDecl(this);
  }
}

class FuncDecl extends Statement {
  final Token name;
  final List<Token> params;
  final List<Statement> body;
  const FuncDecl(
    this.name,
    this.params,
    this.body,
  );
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitFuncDecl(this);
  }
}

class Block extends Statement {
  final List<Statement> statements;
  const Block(
    this.statements,
  );
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitBlock(this);
  }
}

class IfStatement extends Statement {
  final Expression condition;
  final Statement thenStatement;
  final Statement? elseStatement;
  const IfStatement(
    this.condition,
    this.thenStatement,
    this.elseStatement,
  );
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitIfStatement(this);
  }
}

class WhileLoop extends Statement {
  final Expression condition;
  final Statement body;
  const WhileLoop(
    this.condition,
    this.body,
  );
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitWhileLoop(this);
  }
}

class BreakStatement extends Statement {
  const BreakStatement();
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitBreakStatement(this);
  }
}

class ReturnStatement extends Statement {
  final Token keyword;
  final Expression? value;
  const ReturnStatement(
    this.keyword,
    this.value,
  );
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitReturnStatement(this);
  }
}
