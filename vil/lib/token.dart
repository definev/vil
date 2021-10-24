import 'package:vil/token_type.dart';

class Token {
  final TokenType type;
  final int line;
  final int col;
  final String lexeme;
  final dynamic literal;

  const Token({
    required this.type,
    required this.line,
    required this.col,
    required this.lexeme,
    required this.literal,
  });

  @override
  String toString() {
    return "[$line, $col]: $type | lexeme: $lexeme | literal: $literal";
  }
}
