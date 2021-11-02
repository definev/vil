import 'dart:io';

import 'package:vil/ast_printer.dart';
import 'package:vil/grammar/expression.dart';
import 'package:vil/scanner.dart';
import 'package:vil/token.dart';
import 'package:vil/token_type.dart';

class Vil {
  static bool hadError = false;

  static void run(String source) {
    Scanner scanning = Scanner(source);
    List<Token> tokens = scanning.scan();
    for (final token in tokens) {
      print(token);
    }
  }

  static void runFile(String fileSource) {
    File file = File(fileSource);
    String source = file.readAsStringSync();
    run(source);
    if (hadError) exit(65);
  }

  static void runPrompt() {
    while (true) {
      stdout.write("> ");
      String? line = stdin.readLineSync();
      if (line != null) {
        run(line);
        hadError = false;
      }
    }
  }

  static void error({
    required String errorIn,
    required int line,
    required int col,
    required String message,
    String? errorAt,
  }) {
    print('|$errorIn| [$line, $col]: Lỗi $errorAt: $message');
    hadError = true;
  }
}

void main() {
  // -123 * (45.67)
  final expression = Binary(
    Unary(
        Token(
            line: 1, col: 1, lexeme: '-', literal: null, type: TokenType.minus),
        Literal(123)),
    Token(col: 6, line: 1, lexeme: '*', literal: null, type: TokenType.star),
    Grouping(Literal(45.67)),
  );

  print(AstPrinter().print(expression));
}
