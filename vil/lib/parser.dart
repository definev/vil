import 'package:vil/grammar/expression.dart';
import 'package:vil/grammar/statement.dart';
import 'package:vil/token.dart';
import 'package:vil/token_type.dart';
import 'package:vil/vil.dart';

class Parser {
  Parser(this._tokens);

  final List<Token> _tokens;
  int _current = 0;

  int _loopScope = 0;

  List<Statement>? parse() {
    try {
      List<Statement> statements = [];
      while (!_isAtEnd) {
        statements.add(_declaration());
      }

      return statements;
    } on ParserError catch (err) {
      err.show();
      return null;
    }
  }

  /// Kiểm tra đã đến cuối chuỗi Token chưa
  bool get _isAtEnd => _peek().type == TokenType.eof;

  /// Truy xuất phần tử hiện tại
  Token _peek() {
    return _tokens[_current];
  }

  /// Truy xuất phần tử hiện tại và tăng [_current] thêm một
  Token _skip() {
    final token = _peek();
    _current++;
    return token;
  }

  /// Truy xuất phần tử phía trước
  Token _previous() {
    return _tokens[_current - 1];
  }

  /// Kiểm tra tính Token hiện tại có phải là [type] không
  bool _check(TokenType type) {
    if (!_isAtEnd && _peek().type == type) {
      return true;
    }

    return false;
  }

  // Kiểm tra tính Token hiện tại có phải là một trong số TokenType truyền vào hay không
  bool _match(List<TokenType> types) {
    for (final type in types) {
      if (_check(type)) {
        _skip();
        return true;
      }
    }

    return false;
  }

  Token _consume(TokenType type, String message) {
    if (_check(type)) return _skip();
    throw _error(_peek(), message);
  }

  ParserError _error(Token token, String message) {
    throw ParserError(
      token: token,
      message: message,
    );
  }

  // DECLARATION SECTION
  Statement _declaration() {
    if (_match([TokenType.kTao])) {
      return _variableDeclaration();
    }
    if (_match([TokenType.kHam])) {
      return _function('hàm');
    }

    return _statement();
  }

  Statement _variableDeclaration() {
    final token = _consume(TokenType.identifier, 'Cần định nghĩa tên biến.');

    Expression? initializer;
    if (_match([TokenType.equal])) {
      initializer = _expression();
    }

    _consume(TokenType.semicolon, 'Thiếu dấu ";" sau câu lệnh.');
    return VariableDecl(token, initializer);
  }

  Statement _function(String functionType) {
    final name = _consume(TokenType.identifier, 'Cần tên $functionType.');
    List<Token> params = [];
    List<Statement> body = [];

    _consume(TokenType.leftParen, 'Thiếu dấu "(" sau tên $functionType.');

    if (!_check(TokenType.rightParen)) {
      do {
        if (params.length >= 255) {
          _error(_peek(), 'Không thể chứa nhiều hơn 255 tham số.');
        }
        params.add(_consume(TokenType.identifier, 'Tham số cần là tên biến.'));
      } while (_match([TokenType.comma]));
    }
    _consume(TokenType.rightParen, 'Thiếu dấu ")" sau tên $functionType.');

    _consume(TokenType.leftBrace, 'Thiếu dấu "{" trước khối lệnh.');
    body = _block();
    _consume(TokenType.rightBrace, 'Thiếu dấu "}" sau khối lệnh.');

    return FuncDecl(name, params, body);
  }

  // STATEMENT SECTION
  Statement _statement() {
    if (_match([TokenType.kXuat])) {
      return _printStatement();
    }
    if (_match([TokenType.leftBrace])) {
      return _blockStatement();
    }
    if (_match([TokenType.kNeu])) {
      return _ifStatement();
    }
    if (_match([TokenType.kKhi])) {
      return _whileStatement();
    }
    if (_match([TokenType.kLap])) {
      return _forStatement();
    }
    if (_match([TokenType.kThoat])) {
      return _breakStatement();
    }
    if (_match([TokenType.kTra])) {
      return _returnStatement();
    }

    return _expressionStatement();
  }

  Statement _returnStatement() {
    Token keyword = _previous();
    Expression? expression;
    if (!_match([TokenType.semicolon])) {
      expression = _expression();
    }

    _consume(TokenType.semicolon, 'Thiếu dấu ";".');

    return ReturnStatement(keyword, expression);
  }

  Statement _breakStatement() {
    if (_loopScope == 0) {
      throw _error(_previous(),
          'Không được dùng câu lệnh "thoát" trong chương trình chính.');
    }
    _consume(TokenType.semicolon, 'Thiếu dấu ";" sau câu lệnh "thoát".');
    return BreakStatement();
  }

  Statement _forStatement() {
    try {
      _loopScope++;
      _consume(TokenType.leftParen, 'Thiếu dấu "(" đằng sau từ khóa "lặp".');
      Statement? initializer;
      if (!_check(TokenType.semicolon)) {
        if (_match([TokenType.kTao])) {
          initializer = _variableDeclaration();
        } else {
          initializer = _expressionStatement();
        }
      }
      Expression? condition;
      if (!_check(TokenType.semicolon)) {
        condition = _expression();
      }

      _consume(TokenType.semicolon, 'Thiếu dấu ";" trong vòng lặp.');
      Expression? increment;
      if (!_check(TokenType.semicolon)) {
        increment = _expression();
      }

      _consume(TokenType.rightParen, 'Thiếu dấu ")" sau điều kiện lặp.');
      Statement body = _statement();

      if (increment != null) {
        body = Block([body, Expr(increment)]);
      }
      if (condition == null) {
        condition = Literal(true);
      }
      if (initializer != null) {
        return Block([
          initializer,
          WhileLoop(condition, body),
        ]);
      }

      return WhileLoop(condition, body);
    } finally {
      _loopScope--;
    }
  }

  Statement _whileStatement() {
    try {
      _loopScope++;
      _consume(TokenType.leftParen, 'Thiếu dấu "(" sau từ khóa "lặp".');
      final condition = _expression();
      _consume(TokenType.rightParen, 'Thiếu dấu ")" sau điều kiện lặp.');
      final body = _statement();
      return WhileLoop(condition, body);
    } finally {
      _loopScope--;
    }
  }

  Statement _ifStatement() {
    final condition = _expression();
    final thenStatement = _statement();
    Statement? elseStatement;
    if (_match([TokenType.kHoac])) {
      elseStatement = _statement();
    }
    return IfStatement(condition, thenStatement, elseStatement);
  }

  Statement _blockStatement() {
    final statements = _block();
    _consume(TokenType.rightBrace, 'Thiếu dấu "}" sau khối lệnh.');

    return Block(statements);
  }

  Statement _printStatement() {
    final expression = _expression();
    _consume(
        TokenType.semicolon, 'Thiếu dấu ";" sau câu lệnh xuất ra màn hình.');

    return Print(expression);
  }

  Statement _expressionStatement() {
    final expression = _expression();
    _consume(TokenType.semicolon, 'Thiếu dấu ";" sau câu lệnh.');

    return Expr(expression);
  }

  List<Statement> _block() {
    final statements = <Statement>[];

    while (!_check(TokenType.rightBrace) && !_isAtEnd) {
      statements.add(_declaration());
    }
    return statements;
  }

  // EXPRESSION SECTION
  Expression _expression() {
    return _assignment();
  }

  Expression _assignment() {
    final expression = _ternary();

    if (_match([TokenType.equal])) {
      final equals = _previous();
      final value = _assignment();

      if (expression is Variable) {
        return Assign(expression.name, value);
      }

      throw _error(equals, 'Không thể gán giá trị nếu không đó không là biến.');
    }

    return expression;
  }

  Expression _ternary() {
    Expression expression = _or();

    if (_match([TokenType.question])) {
      final thenExpression = _ternary();
      _consume(TokenType.colon, 'Toán tử ba ngôi phải có dấu ":".');
      final elseExpression = _ternary();
      expression = Ternary(expression, thenExpression, elseExpression);
    }

    return expression;
  }

  Expression _or() {
    Expression left = _and();

    while (_match([TokenType.kOr])) {
      final operator = _previous();
      final right = _and();

      left = Logical(left, operator, right);
    }

    return left;
  }

  Expression _and() {
    Expression left = _postfix();

    while (_match([TokenType.kAnd])) {
      final operator = _previous();
      final right = _postfix();

      left = Logical(left, operator, right);
    }

    return left;
  }

  Expression _postfix() {
    var expression = _equality();

    if (_match([TokenType.minusMinus, TokenType.plusPlus])) {
      final operator = _previous();
      expression = Postfix(expression, operator);
    }

    return expression;
  }

  Expression _equality() {
    var expression = _comparison();

    while (_match([TokenType.equalEqual, TokenType.bangEqual])) {
      final operator = _previous();
      final right = _comparison();

      expression = Binary(expression, operator, right);
    }

    return expression;
  }

  Expression _comparison() {
    var expression = _term();

    while (_match([
      TokenType.greater,
      TokenType.greaterEqual,
      TokenType.less,
      TokenType.lessEqual,
    ])) {
      final operator = _previous();
      final right = _term();

      expression = Binary(expression, operator, right);
    }

    return expression;
  }

  Expression _term() {
    var expression = _factor();

    while (_match([TokenType.plus, TokenType.minus])) {
      final operator = _previous();
      final right = _factor();

      expression = Binary(expression, operator, right);
    }

    return expression;
  }

  Expression _factor() {
    var expression = _unary();

    while (_match([TokenType.star, TokenType.slash])) {
      final operator = _previous();
      final right = _unary();

      expression = Binary(expression, operator, right);
    }

    return expression;
  }

  Expression _unary() {
    if (_match([
      TokenType.bang,
      TokenType.minus,
      TokenType.minusMinus,
      TokenType.plusPlus,
    ])) {
      final operator = _previous();
      final right = _unary();

      return Unary(operator, right);
    }

    return _call();
  }

  Expression _call() {
    var expression = _primary();

    while (true) {
      if (_match([TokenType.leftParen])) {
        expression = _finishCall(expression);
      } else {
        break;
      }
    }

    return expression;
  }

  Expression _primary() {
    if (_match([TokenType.kSo, TokenType.kChuoi])) {
      return Literal(_previous().literal);
    }
    if (_match([TokenType.kDung])) {
      return Literal(true);
    }
    if (_match([TokenType.kSai])) {
      return Literal(false);
    }
    if (_match([TokenType.kRong])) {
      return Literal(null);
    }
    if (_match([TokenType.leftParen])) {
      final expression = _expression();
      _consume(TokenType.rightParen, 'Thiếu ")" sau biểu thức.');
      return Grouping(expression);
    }
    if (_match([TokenType.identifier])) {
      return Variable(_previous());
    }

    throw _error(_peek(), 'Token chưa có trong bảng quy tắc.');
  }

  Expression _finishCall(Expression callee) {
    List<Expression> arguments = [];
    if (!_check(TokenType.rightParen)) {
      do {
        if (arguments.length >= 255) {
          throw _error(_previous(), 'Không thể chứa nhiều hơn 255 tham số.');
        }
        arguments.add(_expression());
      } while (_match([TokenType.comma]));
    }

    final paren = _consume(TokenType.rightParen, 'Thiếu ")" sau tham số.');

    return Call(callee, paren, arguments);
  }
}

class ParserError {
  final String message;
  final Token token;

  const ParserError({
    required this.message,
    required this.token,
  });

  void show() => Vil.parserError(token, message);
}
