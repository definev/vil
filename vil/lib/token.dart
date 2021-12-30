import 'package:vil/loc.dart';
import 'package:vil/token_type.dart';

class Token {
  final TokenType type;
  final Loc loc;
  final String lexeme;
  final dynamic literal;

  const Token({
    required this.type,
    required this.loc,
    required this.lexeme,
    required this.literal,
  });

  @override
  String toString() {
    return "[$loc]: $type | lexeme: $lexeme | literal: $literal";
  }
}
