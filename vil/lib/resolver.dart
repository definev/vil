import 'package:vil/grammar/expression.dart';
import 'package:vil/grammar/statement.dart';
import 'package:vil/interpreter.dart';
import 'package:vil/loc.dart';
import 'package:vil/token.dart';
import 'package:vil/token_type.dart';
import 'package:vil/vil.dart';

enum FunctionType {
  none,
  function,
  method,
}

enum ClassType {
  none,
  klass,
}

enum _VariableState {
  declare,
  define,
  read,
}

enum _VariableKind {
  variable,
  function,
  method,
  native,
  klass,
}

class _VariableResolver {
  final Token name;
  final _VariableState state;
  final _VariableKind kind;

  _VariableResolver(
    this.name,
    this.state,
    this.kind,
  );
}

class Resolver with ExpressionVisitor<void>, StatementVisitor<void> {
  Resolver(this._interpreter);

  final Interpreter _interpreter;
  late final List<Map<String, _VariableResolver>> _scopes = [
    <String, _VariableResolver>{
      'clock': _VariableResolver(
        Token(
          lexeme: 'clock',
          type: TokenType.identifier,
          loc: Loc(0, 0),
          literal: null,
        ),
        _VariableState.read,
        _VariableKind.native,
      ),
      'exit': _VariableResolver(
        Token(
          lexeme: 'exit',
          type: TokenType.identifier,
          loc: Loc(0, 0),
          literal: null,
        ),
        _VariableState.read,
        _VariableKind.native,
      ),
      ...Map.fromEntries(
        _interpreter.selfDefinedFunctions.map(
          (function) => MapEntry(
            function,
            _VariableResolver(
              Token(
                lexeme: function,
                type: TokenType.identifier,
                loc: Loc(0, 0),
                literal: null,
              ),
              _VariableState.read,
              _VariableKind.native,
            ),
          ),
        ),
      ),
    },
  
  ];
  FunctionType _currentFunction = FunctionType.none;
  ClassType _classType = ClassType.none;

  void resolve(List<Statement> statements) {
    _resolveStatements(statements);
  }

  @override
  void visitAssign(Assign assign) {
    _resolveExpression(assign.value);
    _resolveLocal(assign, assign.name, false, kind: _VariableKind.variable);
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
        final _variableKind = () {
          switch (variable.kind) {
            case _VariableKind.function:
              return 'Hàm';
            case _VariableKind.klass:
              return 'Lớp';
            case _VariableKind.method:
              return 'Phương thức';
            case _VariableKind.variable:
              return 'Biến';
            case _VariableKind.native:
              return 'Hàm nội bộ';
          }
        }();
        Vil.error(
          errorIn: 'RESOLVER',
          loc: variable.name.loc,
          message:
              '$_variableKind "${variable.name.lexeme}" không được sử dụng',
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
    _declare(funcDecl.name, kind: _VariableKind.function);
    _define(funcDecl.name, kind: _VariableKind.function);
    _resolveFunction(
      funcDecl,
      FunctionType.function,
      ClassType.none,
      kind: _VariableKind.function,
    );
  }

  @override
  void visitClassDecl(ClassDecl classDecl) {
    _declare(classDecl.name, kind: _VariableKind.klass);
    _define(classDecl.name, kind: _VariableKind.klass);

    _beginScope();
    _classType = ClassType.klass;
    _scopes.last['self'] = _VariableResolver(
      classDecl.name,
      _VariableState.read,
      _VariableKind.method,
    );
    for (final method in classDecl.methods) {
      _resolveFunction(
        method,
        FunctionType.function,
        ClassType.klass,
        kind: _VariableKind.method,
      );
    }
    _endScope();
    _classType = ClassType.none;
  }

  void _resolveFunction(
    FuncDecl funcDecl,
    FunctionType type,
    ClassType classType, {
    required _VariableKind kind,
  }) {
    var enclosingFunction = _currentFunction;
    var enclosingClass = _classType;
    _currentFunction = type;
    _classType = classType;
    _beginScope();
    for (var param in funcDecl.params) {
      _declare(param, kind: kind);
      _define(param, kind: kind);
    }
    _resolveStatements(funcDecl.body);
    _endScope();
    _currentFunction = enclosingFunction;
    _classType = enclosingClass;
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
    _resolveLocal(variable, variable.name, true, kind: _VariableKind.variable);
  }

  void _resolveLocal(
    Expression expression,
    Token name,
    bool isRead, {
    required _VariableKind kind,
  }) {
    for (int i = _scopes.length - 1; i >= 0; i--) {
      if (_scopes[i].containsKey(name.lexeme)) {
        _interpreter.resolve(expression, _scopes.length - 1 - i);
        if (isRead) {
          _scopes[i][name.lexeme] =
              _VariableResolver(name, _VariableState.read, kind);
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
    _declare(variableDecl.name, kind: _VariableKind.variable);
    if (variableDecl.initializer != null) {
      _resolveExpression(variableDecl.initializer!);
    }
    _define(variableDecl.name, kind: _VariableKind.variable);
  }

  void _declare(Token token, {required _VariableKind kind}) {
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
        _VariableResolver(token, _VariableState.declare, kind);
  }

  void _define(Token token, {required _VariableKind kind}) {
    if (_scopes.isEmpty) return;
    _scopes.last[token.lexeme] =
        _VariableResolver(token, _VariableState.define, kind);
  }

  @override
  void visitWhileLoop(WhileLoop whileLoop) {
    _resolveExpression(whileLoop.condition);
    _resolveStatement(whileLoop.body);
  }

  @override
  void visitGet(Get get) {
    _resolveExpression(get.object);
  }

  @override
  void visitSet(Set set) {
    _resolveExpression(set.object);
    _resolveExpression(set.value);
  }

  @override
  void visitSelf(Self self) {
    if (_classType == ClassType.none) {
      Vil.error(
        errorIn: 'RESOLVER',
        loc: self.keyword.loc,
        message: 'Không thể truy cập đối tượng self ngoài lớp',
        errorAt: '"self"',
      );
    }
    _resolveLocal(self, self.keyword, true, kind: _VariableKind.method);
  }
}
