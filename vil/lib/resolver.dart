import 'package:vil/grammar/expression.dart';
import 'package:vil/grammar/statement.dart';
import 'package:vil/interpreter.dart';
import 'package:vil/token.dart';
import 'package:vil/vil.dart';

enum FunctionType {
  none,
  function,
}

enum _VariableState {
  declare,
  define,
  read,
}

class _VariableResolver {
  final Token name;
  final _VariableState state;

  _VariableResolver(this.name, this.state);
}

class Resolver with ExpressionVisitor<void>, StatementVisitor<void> {
  Resolver(this._interpreter);

  final Interpreter _interpreter;
  final List<Map<String, _VariableResolver>> _scopes = [];
  FunctionType _currentFunction = FunctionType.none;

  void resolve(List<Statement> statements) {
    _beginScope();
    _resolveStatements(statements);
    _endScope();
  }

  @override
  void visitAssign(Assign assign) {
    _resolveExpression(assign.value);
    _resolveLocal(assign, assign.name, false);
  }

  @override
  void visitBinary(Binary binary) {
    _resolveExpression(binary.left);
    _resolveExpression(binary.right);
  }

  @override
  void visitBlock(Block block) {
    _beginScope();
    _resolveStatements(block.statements);
    _endScope();
  }

  void _beginScope() {
    _scopes.add({});
  }

  void _resolveStatements(List<Statement> statements) {
    for (final statement in statements) {
      _resolveStatement(statement);
    }
  }

  void _resolveStatement(Statement statement) {
    statement.accept(this);
  }

  void _resolveExpression(Expression expression) {
    expression.accept(this);
  }

  void _endScope() {
    final scope = _scopes.removeLast();
    for (final variable in scope.values) {
      if (variable.state == _VariableState.define) {
        Vil.error(
          errorIn: 'RESOLVER',
          loc: variable.name.loc,
          message: 'Biến "${variable.name.lexeme}" không được sử dụng',
        );
      }
    }
  }

  @override
  void visitBreakStatement(BreakStatement breakStatement) {}

  @override
  void visitCall(Call call) {
    _resolveExpression(call.callee);
    for (var argument in call.arguments) {
      _resolveExpression(argument);
    }
  }

  @override
  void visitExpr(Expr expr) {
    _resolveExpression(expr.expression);
  }

  @override
  void visitFuncDecl(FuncDecl funcDecl) {
    _declare(funcDecl.name);
    _define(funcDecl.name);
    _resolveFunction(funcDecl, FunctionType.function);
  }

  void _resolveFunction(FuncDecl funcDecl, FunctionType type) {
    var enclosingFunction = _currentFunction;
    _currentFunction = type;
    _beginScope();
    for (var param in funcDecl.params) {
      _declare(param);
      _define(param);
    }
    _resolveStatements(funcDecl.body);
    _endScope();
    _currentFunction = enclosingFunction;
  }

  @override
  void visitGrouping(Grouping grouping) {
    _resolveExpression(grouping.expression);
  }

  @override
  void visitIfStatement(IfStatement ifStatement) {
    _resolveExpression(ifStatement.condition);
    _resolveStatement(ifStatement.thenStatement);
    if (ifStatement.elseStatement != null) {
      _resolveStatement(ifStatement.elseStatement!);
    }
  }

  @override
  void visitLiteral(Literal literal) {}

  @override
  void visitLogical(Logical logical) {
    _resolveExpression(logical.left);
    _resolveExpression(logical.right);
  }

  @override
  void visitPostfix(Postfix postfix) {
    _resolveExpression(postfix.left);
  }

  @override
  void visitPrint(Print print) {
    _resolveExpression(print.expression);
  }

  @override
  void visitReturnStatement(ReturnStatement returnStatement) {
    if (_currentFunction == FunctionType.none) {
      Vil.error(
        errorIn: 'RESOLVER',
        loc: returnStatement.keyword.loc,
        message: 'Không thể trả về khi không có hàm',
        errorAt: returnStatement.keyword.lexeme,
      );
    }
    final value = returnStatement.value;
    if (value == null) return;
    _resolveExpression(value);
  }

  @override
  void visitTernary(Ternary ternary) {
    _resolveExpression(ternary.condition);
    _resolveExpression(ternary.thenBranch);
    _resolveExpression(ternary.elseBranch);
  }

  @override
  void visitUnary(Unary unary) {
    _resolveExpression(unary.right);
  }

  @override
  void visitVariable(Variable variable) {
    if (_scopes.isNotEmpty && _scopes.last[variable.name.lexeme] == false) {
      Vil.error(
        errorIn: 'RESOLVER',
        loc: variable.name.loc,
        message: 'biến chưa được khởi tạo.',
        errorAt: '"${variable.name.lexeme}"',
      );
    }
    _resolveLocal(variable, variable.name, true);
  }

  void _resolveLocal(Expression expression, Token name, bool isRead) {
    for (int i = _scopes.length - 1; i >= 0; i--) {
      if (_scopes[i].containsKey(name.lexeme)) {
        _interpreter.resolve(expression, _scopes.length - 1 - i);
        if (isRead) {
          _scopes[i][name.lexeme] =
              _VariableResolver(name, _VariableState.read);
        }
        return;
      }
    }
    Vil.error(
      errorIn: 'RESOLVER',
      loc: name.loc,
      message: 'Biến "${name.lexeme}" chưa được khởi tạo',
      errorAt: '"${name.lexeme}"',
    );
  }

  @override
  void visitVariableDecl(VariableDecl variableDecl) {
    _declare(variableDecl.name);
    if (variableDecl.initializer != null) {
      _resolveExpression(variableDecl.initializer!);
    }
    _define(variableDecl.name);
  }

  void _declare(Token token) {
    if (_scopes.isEmpty) return;

    if (_scopes.last.containsKey(token.lexeme)) {
      Vil.error(
        errorIn: 'RESOLVER',
        loc: token.loc,
        message: 'Biến đã tồn tại',
        errorAt: '"${token.lexeme}"',
      );
      return;
    }

    _scopes.last[token.lexeme] =
        _VariableResolver(token, _VariableState.declare);
  }

  void _define(Token token) {
    if (_scopes.isEmpty) return;
    _scopes.last[token.lexeme] =
        _VariableResolver(token, _VariableState.define);
  }

  @override
  void visitWhileLoop(WhileLoop whileLoop) {
    _resolveExpression(whileLoop.condition);
    _resolveStatement(whileLoop.body);
  }
}
