import 'package:vil/grammar/expression.dart';
import 'package:vil/grammar/statement.dart';
import 'package:vil/token.dart';
import 'package:vil/token_type.dart';
import 'package:vil/vil.dart';

class Parser {
  Parser(this._tokens);

  final List<Token> _tokens;
  int _current = 0;

  List<Statement>? parse() {
    try {
      List<Statement> statements = [];
      while (!_isAtEnd) {
        statements.add(_declaration());
      }

      return statements;
    } on ParserError catch (_) {
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
    Vil.parserError(token, message);
    return ParserError();
  }

  // DECLARATION SECTION
  Statement _declaration() {
    if (_match([TokenType.kTao])) {
      return _variableDeclaration();
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

  // STATEMENT SECTION
  Statement _statement() {
    if (_match([TokenType.kXuat])) {
      return _printStatement();
    }
    if (_match([TokenType.leftBrace])) {
      return _blockStatement();
    }

    return _expressionStatement();
  }

  Statement _blockStatement() {
    final statements = <Statement>[];

    while (!_check(TokenType.rightBrace) && !_isAtEnd) {
      statements.add(_declaration());
    }
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

  // EXPRESSION SECTION
  Expression _expression() {
    return _assignment();
  }

  Expression _assignment() {
    final expression = _equality();

    if (_match([TokenType.equal])) {
      final equals = _previous();
      final value = _assignment();

      if (expression is Variable) {
        return Assign(expression.name, value);
      }

      _error(equals, 'Không thể gán giá trị nếu không đó không là biến.');
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
    if (_match([TokenType.bang, TokenType.minus])) {
      final operator = _previous();
      final right = _unary();

      return Unary(operator, right);
    }

    return _primary();
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
}

class ParserError {}
