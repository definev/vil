import 'package:vil/loc.dart';
import 'package:vil/token.dart';
import 'package:vil/token_type.dart';
import 'package:vil/vil.dart';

/// Scanning là quá trình chuyển từ văn bản sang token giúp trình thông dịch
/// hiểu được các bước tiếp theo.
///
/// Bước Scanning còn có một cái tên nghe sang chảnh hơn hẳn là Lexer
///
/// Token là đối tương đại diện cho các từ khóa, kí hiệu, giá trị nguyên thủy
/// của biến.
class Scanner {
  Scanner(this.source);

  final String source;

  List<Token> _tokens = [];
  int _startPosition = 0;
  int _currentPosition = 0;

  Loc _loc = Loc(1, 1);

  Map<String, TokenType> _keywords = {
    "khi": TokenType.kKhi,
    "lặp": TokenType.kLap,
    "tạo": TokenType.kTao,
    "xuất": TokenType.kXuat,
    "đúng": TokenType.kDung,
    "sai": TokenType.kSai,
    "nếu": TokenType.kNeu,
    "hoặc": TokenType.kHoac,
    "lớp": TokenType.kLop,
    "hàm": TokenType.kHam,
    "rỗng": TokenType.kRong,
    "cha": TokenType.kCha,
    "self": TokenType.kSelf,
    "trả": TokenType.kTra,
    "thoát": TokenType.kThoat,
    "&&": TokenType.kAnd,
    "||": TokenType.kOr,
  };

  bool get _isAtEnd => _currentPosition >= source.length;

  void error(String message) {
    Vil.error(errorIn: 'SCANNER', loc: _loc, message: message);
  }

  String _autoIncrementPeek() {
    _loc = _loc.next;
    return source[_currentPosition++];
  }

  String _peek() => _isAtEnd ? '' : source[_currentPosition];

  String? _peekNext() {
    if (_currentPosition + 1 > source.length) return null;
    return source[_currentPosition + 1];
  }

  void _addToken(TokenType type, {dynamic literal}) {
    _tokens.add(
      Token(
        type: type,
        loc: Loc(
          _loc.x - (_currentPosition - _startPosition - 1),
          _loc.y,
        ),
        lexeme: source.substring(_startPosition, _currentPosition),
        literal: literal,
      ),
    );
  }

  bool _isNumber(String number) => RegExp(r'\d').hasMatch(number);

  bool _isAlphabet(String source) =>
      RegExp(r'[a-zA-Z\u00C0-\u024F\u1E00-\u1EFF_]').hasMatch(source);

  bool _isNumberAlphabet(String source) =>
      _isNumber(source) || _isAlphabet(source);

  bool _match(String current) {
    if (_peek() == current) {
      _currentPosition++;
      return true;
    }
    return false;
  }

  void _addStringToken() {
    while (!_isAtEnd && !_match('"')) {
      _autoIncrementPeek();
    }

    if (_isAtEnd) error('Đã đến cuối file, phân tích chuỗi thất bại.');

    _addToken(
      TokenType.kChuoi,
      literal: source.substring(_startPosition + 1, _currentPosition - 1),
    );
  }

  void _addNumberToken() {
    while (!_isAtEnd && _isNumber(_peek())) {
      _autoIncrementPeek();
    }
    if (_isAtEnd) error('Đã đến cuối file, phân tích số thất bại.');

    if (_peek() == "." && (_peekNext() != null && _isNumber(_peekNext()!))) {
      _autoIncrementPeek();
      while (_isNumber(_peek())) {
        _autoIncrementPeek();
      }
    }

    _addToken(
      TokenType.kSo,
      literal: double.parse(
        source.substring(_startPosition, _currentPosition),
      ),
    );
  }

  void _identifier() {
    while (!_isAtEnd && _isNumberAlphabet(_peek())) {
      _autoIncrementPeek();
    }

    if (_isAtEnd) error('Đã đến cuối file, phân tích tên biến thất bại.');

    if (_keywords[source.substring(_startPosition, _currentPosition)] != null) {
      _addToken(_keywords[source.substring(_startPosition, _currentPosition)]!);
    } else {
      _addToken(TokenType.identifier);
    }
  }

  List<Token> scan() {
    while (!_isAtEnd) {
      _startPosition = _currentPosition;
      _scanToken();
    }

    _addToken(TokenType.eof);
    return _tokens;
  }

  void _scanToken() {
    String current = _autoIncrementPeek();

    switch (current) {
      case '{':
        _addToken(TokenType.leftBrace);
        break;
      case '}':
        _addToken(TokenType.rightBrace);
        break;
      case '(':
        _addToken(TokenType.leftParen);
        break;
      case ')':
        _addToken(TokenType.rightParen);
        break;
      case ',':
        _addToken(TokenType.comma);
        break;
      case '.':
        _addToken(TokenType.dot);
        break;
      case '-':
        if (_peek() == '-') {
          _autoIncrementPeek();
          _addToken(TokenType.minusMinus);
          return;
        }
        _addToken(TokenType.minus);
        break;
      case '+':
        if (_peek() == '+') {
          _autoIncrementPeek();
          _addToken(TokenType.plusPlus);
          return;
        }
        _addToken(TokenType.plus);
        break;
      case ';':
        _addToken(TokenType.semicolon);
        break;
      case '/':
        _addToken(TokenType.slash);
        break;
      case '*':
        _addToken(TokenType.star);
        break;
      case '?':
        _addToken(TokenType.question);
        break;
      case ':':
        _addToken(TokenType.colon);
        break;
      case '!':
        if (_peek() == '=') {
          _autoIncrementPeek();
          _addToken(TokenType.bangEqual);
          return;
        }
        _addToken(TokenType.bang);
        break;
      case '=':
        if (_peek() == '=') {
          _autoIncrementPeek();
          _addToken(TokenType.equalEqual);
          return;
        }
        _addToken(TokenType.equal);
        break;
      case '>':
        if (_peek() == '=') {
          _autoIncrementPeek();
          _addToken(TokenType.greaterEqual);
          return;
        }
        _addToken(TokenType.greater);
        break;
      case '<':
        if (_peek() == '=') {
          _autoIncrementPeek();
          _addToken(TokenType.lessEqual);
          return;
        }
        _addToken(TokenType.less);
        break;
      case '"':
        _addStringToken();
        break;
      case ' ':
        break;
      case '\n':
        _loc = _loc.down;
        break;
      case '\t':
        _loc = _loc.next;
        break;
      case '\r':
        break;
      default:
        if (_isNumber(current)) {
          _addNumberToken();
        } else if (_isAlphabet(current)) {
          _identifier();
        }
    }
  }
}

class ScanningError {
  final String message;

  ScanningError(this.message);
}
