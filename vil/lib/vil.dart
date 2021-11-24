import 'dart:io';

import 'package:vil/grammar/expression.dart';
import 'package:vil/interpreter.dart';
import 'package:vil/parser.dart';
import 'package:vil/scanner.dart';
import 'package:vil/token.dart';
import 'package:vil/token_type.dart';

class Vil {
  static Interpreter interpreter = Interpreter();

  static bool hadError = false;
  static bool hadRuntimeError = false;

  static void run(String source) {
    Scanner scanning = Scanner(source);
    List<Token> tokens = scanning.scan();

    Parser parser = Parser(tokens);
    Expression? expression = parser.parse();
    if (expression != null) {
      interpreter.interpret(expression);
    }
  }

  static void runFile(String fileSource) {
    File file = File(fileSource);
    String source = file.readAsStringSync();
    run(source);
    if (hadError) exit(65);
    if (hadRuntimeError) exit(70);
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

  static void parserError(Token token, String message) {
    if (token.type == TokenType.eof) {
      error(
        errorIn: 'PARSER',
        line: token.line,
        col: token.col,
        message: message,
        errorAt: ' ở cuối file',
      );
    } else {
      error(
        errorIn: 'PARSER',
        line: token.line,
        col: token.col,
        message: message,
        errorAt: ' tại "${token.lexeme}"',
      );
    }
  }

  static void runtimeError(RuntimeError error) {
    Vil.error(
      errorIn: 'INTERPRETER',
      line: error.token.line,
      col: error.token.col,
      message: error.message,
    );
    hadRuntimeError = true;
  }
}

void main() {
  Vil.runPrompt();
}
