import 'package:vil/environment.dart';
import 'package:vil/grammar/expression.dart';
import 'package:vil/grammar/statement.dart';
import 'package:vil/token.dart';
import 'package:vil/token_type.dart';
import 'package:vil/vil.dart';

class Interpreter
    implements ExpressionVisitor<dynamic>, StatementVisitor<void> {
  Environment _environment = Environment();

  void interpret(List<Statement> statements) {
    try {
      for (final statement in statements) {
        _execute(statement);
      }
    } on RuntimeError catch (error) {
      Vil.runtimeError(error);
    }
  }

  void _execute(Statement statement) {
    statement.accept(this);
  }

  String _stringify(dynamic value) {
    if (value == null) return 'rỗng';

    if (value is double) {
      final text = value.toString();
      if (text.endsWith('.0')) {
        return text.substring(0, text.length - 2);
      }
      return text;
    }

    if (value is bool) return value ? 'đúng' : 'sai';

    return value.toString();
  }

  dynamic _evaluate(Expression expression) {
    return expression.accept(this);
  }

  bool _isTruthy(dynamic value) {
    if (value is bool) return value;
    return value != null;
  }

  void _checkIsNumber(List<dynamic> values, Token token) {
    for (var value in values) {
      if (value is! num) {
        throw RuntimeError(
            token: token, message: 'Sai kiểu dữ liệu, cần kiểu số.');
      }
    }
  }

  // EXPRESSION VISITOR
  @override
  dynamic visitBinary(Binary binary) {
    final left = _evaluate(binary.left);
    final right = _evaluate(binary.right);

    switch (binary.operator.type) {
      case TokenType.minus:
        _checkIsNumber([left, right], binary.operator);
        return left - right;
      case TokenType.plus:
        if (left is num && right is num) return left + right;
        if (left is String && right is String) return left + right;
        if (left is String && right is num) return left + right.toString();
        if (left is num && right is String) return left.toString() + right;
        throw RuntimeError(
          token: binary.operator,
          message: 'Sai kiểu dữ liệu, chỉ có thể cộng hai kiểu số hoặc chuỗi.',
        );
      case TokenType.star:
        _checkIsNumber([left, right], binary.operator);
        return left * right;
      case TokenType.slash:
        return left / right;
      case TokenType.equalEqual:
        return left == right;
      case TokenType.bangEqual:
        return left != right;
      case TokenType.greater:
        return left > right;
      case TokenType.greaterEqual:
        _checkIsNumber([left, right], binary.operator);
        return left >= right;
      case TokenType.lessEqual:
        _checkIsNumber([left, right], binary.operator);
        return left <= right;
      default:
        return null;
    }
  }

  @override
  dynamic visitGrouping(Grouping grouping) {
    return _evaluate(grouping.expression);
  }

  @override
  dynamic visitLiteral(Literal literal) {
    return literal.value;
  }

  @override
  dynamic visitUnary(Unary unary) {
    final right = _evaluate(unary.right);
    switch (unary.operator.type) {
      case TokenType.minus:
        _checkIsNumber([right], unary.operator);
        return -right;
      case TokenType.bang:
        return !_isTruthy(right);
      default:
        return null;
    }
  }

  @override
  dynamic visitVariable(Variable variable) {
    return _environment.get(variable.name);
  }

  @override
  dynamic visitAssign(Assign assign) {
    final value = _evaluate(assign.value);
    _environment.assign(assign.name, value);
    return value;
  }

  // STATEMENT VISITOR
  @override
  void visitExpr(Expr exprStmt) {}

  @override
  void visitPrint(Print printStmt) {
    final value = _evaluate(printStmt.expression);
    print(_stringify(value));
  }

  @override
  void visitVariableDecl(VariableDecl variableDeclStmt) {
    dynamic value = null;
    if (variableDeclStmt.value != null) {
      value = _evaluate(variableDeclStmt.value!);
    }
    _environment.define(variableDeclStmt.name.lexeme, value);
  }

  @override
  void visitBlock(Block block) {
    Environment blockEnv = Environment(_environment);
    _environment = blockEnv;

    for (final statement in block.statements) {
      _execute(statement);
    }

    _environment = _environment.parent!;
  }
}

class RuntimeError {
  final String message;
  final Token token;

  RuntimeError({
    required this.message,
    required this.token,
  });

  @override
  String toString() => '$message';
}
