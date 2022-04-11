import 'package:vil/environment.dart';
import 'package:vil/grammar/expression.dart';
import 'package:vil/grammar/statement.dart';
import 'package:vil/native_functions/clock_function.dart';
import 'package:vil/native_functions/exit_function.dart';
import 'package:vil/token.dart';
import 'package:vil/token_type.dart';
import 'package:vil/vil.dart';
import 'package:vil/vil_callable.dart';
import 'package:vil/vil_class.dart';
import 'package:vil/vil_function.dart';
import 'package:vil/vil_instance.dart';

class Interpreter
    implements ExpressionVisitor<dynamic>, StatementVisitor<void> {
  Interpreter({Map<String, dynamic>? globals}) {
    this.globals = Environment({
      'exit': ExitFunction(),
      'clock': ClockFunction(),
      if (globals != null) ...globals,
    });
    if (globals != null) selfDefinedFunctions.addAll(globals.keys);

    _environment = Environment({}, parent: this.globals);
  }

  late final Environment globals;
  final List<String> selfDefinedFunctions = [];
  late Environment _environment;
  Environment get environment => _environment;
  Map<Expression, int> _locals = {};

  void interpret(List<Statement> statements) {
    try {
      for (final statement in statements) {
        _execute(statement);
      }
    } on RuntimeError catch (error) {
      Vil.runtimeError(error);
    }
  }

  void resolve(Expression expression, int depth) {
    _locals[expression] = depth;
  }

  void _execute(Statement statement) {
    statement.accept(this);
  }

  void executeBlock(List<Statement> statements, Environment childScope) {
    _environment = childScope.clone();

    try {
      for (final statement in statements) {
        _execute(statement);
      }
    } finally {
      _environment = childScope.parent!;
    }
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

  dynamic _lookUpVariable(Token name, Expression expression) {
    int? depth = _locals[expression];
    if (depth == null) {
      return globals.get(name);
    } else {
      return _environment.getAt(name, depth);
    }
  }

  // EXPRESSION VISITOR
  @override
  dynamic visitPostfix(Postfix postfix) {
    final left = _evaluate(postfix.left);
    switch (postfix.operator.type) {
      case TokenType.plusPlus:
        _checkIsNumber([left], postfix.operator);
        if (postfix.left is Variable) {
          _environment.assign(
            (postfix.left as Variable).name,
            left + 1,
          );
          return left + 1;
        }
        break;
      case TokenType.minusMinus:
        _checkIsNumber([left], postfix.operator);
        if (postfix.left is Variable) {
          _environment.assign(
            (postfix.left as Variable).name,
            left - 1,
          );
          return left - 1;
        }
        break;
      default:
        throw RuntimeError(
          message: 'Điều này không thể xảy ra.',
          token: postfix.operator,
        );
    }
  }

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
      case TokenType.less:
        return left < right;
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
      case TokenType.plusPlus:
        _checkIsNumber([right], unary.operator);
        if (unary.right is Variable) {
          _environment.assign((unary.right as Variable).name, right + 1);
        }
        return right;
      case TokenType.minusMinus:
        _checkIsNumber([right], unary.operator);
        if (unary.right is Variable) {
          _environment.assign((unary.right as Variable).name, right - 1);
        }
        return right;
      default:
        return null;
    }
  }

  @override
  dynamic visitVariable(Variable variable) {
    return _lookUpVariable(variable.name, variable);
  }

  @override
  dynamic visitAssign(Assign assign) {
    final value = _evaluate(assign.value);
    final depth = _locals[assign];
    if (depth == null) {
      globals.assign(assign.name, value);
    } else {
      _environment.assignAt(assign.name, depth, value);
    }
    return value;
  }

  @override
  dynamic visitTernary(Ternary ternary) {
    final condition = _evaluate(ternary.condition);

    if (_isTruthy(condition)) {
      return _evaluate(ternary.thenBranch);
    } else {
      return _evaluate(ternary.elseBranch);
    }
  }

  @override
  dynamic visitLogical(Logical logical) {
    final left = _evaluate(logical.left);
    final right = _evaluate(logical.right);

    switch (logical.operator.type) {
      case TokenType.kOr:
        return _isTruthy(left) || _isTruthy(right);
      case TokenType.kAnd:
        return _isTruthy(left) && _isTruthy(right);
      default:
        throw RuntimeError(
          message: 'Điều này không thể xảy ra.',
          token: logical.operator,
        );
    }
  }

  @override
  dynamic visitCall(Call call) {
    Environment outerEnvironment = _environment;
    var callee = _evaluate(call.callee);
    if (callee is! VilCallable) {
      throw RuntimeError(
        message: 'Chỉ có thể thực thi trong hàm hoặc lớp.',
        token: call.paren,
      );
    }

    List<dynamic> arguments =
        call.arguments.map((arg) => _evaluate(arg)).toList();

    if (callee.argsSize != arguments.length) {
      throw RuntimeError(
        message:
            'Truyền sai số lượng tham số. Cần ${callee.argsSize} tham số nhưng nhận được ${arguments.length} tham số.',
        token: call.paren,
      );
    }

    final value = callee.call(this, arguments);
    _environment = outerEnvironment;
    return value;
  }

  @override
  dynamic visitGet(Get get) {
    final object = _evaluate(get.object);
    if (object is VilInstance) {
      return object.get(get.name);
    }

    throw RuntimeError(
      message: 'Không thể truy vấn đối tượng.',
      token: get.name,
    );
  }

  // STATEMENT VISITOR
  @override
  void visitExpr(Expr exprStmt) {
    _evaluate(exprStmt.expression);
  }

  @override
  void visitPrint(Print printStmt) {
    final value = _evaluate(printStmt.expression);
    Vil.native.out(_stringify(value));
  }

  @override
  void visitVariableDecl(VariableDecl variableDeclStmt) {
    dynamic value = null;
    if (variableDeclStmt.initializer != null) {
      value = _evaluate(variableDeclStmt.initializer!);
    }
    _environment.define(variableDeclStmt.name.lexeme, value);
  }

  @override
  void visitFuncDecl(FuncDecl funcDecl) {
    _environment.define(
      funcDecl.name.lexeme,
      VilFunction(funcDecl, _environment),
    );
  }

  @override
  void visitClassDecl(ClassDecl classDecl) {
    _environment.define(classDecl.name.lexeme, null);

    Map<String, VilFunction> methods = {};
    for (final method in classDecl.methods) {
      methods[method.name.lexeme] = VilFunction(method, _environment);
    }

    VilClass vilClass = VilClass(classDecl.name.lexeme, methods);
    _environment.assign(classDecl.name, vilClass);
  }

  @override
  void visitBlock(Block block) {
    executeBlock(
      block.statements,
      Environment({}, parent: _environment),
    );
  }

  @override
  void visitIfStatement(IfStatement ifStatement) {
    final condition = _evaluate(ifStatement.condition);

    if (_isTruthy(condition)) {
      _execute(ifStatement.thenStatement);
    } else {
      if (ifStatement.elseStatement != null) {
        _execute(ifStatement.elseStatement!);
      }
    }
  }

  @override
  void visitWhileLoop(WhileLoop whileLoop) {
    while (_isTruthy(_evaluate(whileLoop.condition))) {
      try {
        _execute(whileLoop.body);
      } on BreakEvent catch (_) {
        break;
      }
    }
  }

  @override
  void visitBreakStatement(BreakStatement breakStatement) {
    throw BreakEvent();
  }

  @override
  void visitReturnStatement(ReturnStatement returnStatement) {
    dynamic value;
    if (returnStatement.value != null) {
      value = _evaluate(returnStatement.value!);
    }
    throw ReturnEvent(value);
  }

  @override
  dynamic visitSet(Set set) {
    var object = _evaluate(set.object);

    if (object is! VilInstance) {
      throw RuntimeError(
        message: 'Chỉ có thể thực thi trong hàm hoặc lớp.',
        token: set.name,
      );
    }
    var value = _evaluate(set.value);
    object.set(set.name, value);
  }

  @override
  dynamic visitSelf(Self self) {
    return _lookUpVariable(self.keyword, self);
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

class BreakEvent {}

class ReturnEvent {
  final dynamic value;

  ReturnEvent(this.value);
}
