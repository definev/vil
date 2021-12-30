import 'dart:io';

import 'package:vil/interpreter.dart';
import 'package:vil/loc.dart';
import 'package:vil/native_methods.dart';
import 'package:vil/parser.dart';
import 'package:vil/scanner.dart';
import 'package:vil/token.dart';
import 'package:vil/token_type.dart';

class Vil {
  static Interpreter interpreter = Interpreter();
  static NativeMethods native = Console();

  static bool hadError = false;
  static bool hadRuntimeError = false;

  static void run(String source) {
    Scanner scanning = Scanner(source);
    List<Token> tokens = scanning.scan();

    Parser parser = Parser(tokens);
    final statements = parser.parse();
    if (statements != null) {
      interpreter.interpret(statements);
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
    required Loc loc,
    required String message,
    String? errorAt,
  }) {
    print('|$errorIn| [$loc]: Lỗi $errorAt: $message');
    hadError = true;
  }

  static void parserError(Token token, String message) {
    if (token.type == TokenType.eof) {
      error(
        errorIn: 'PARSER',
        loc: token.loc,
        message: message,
        errorAt: ' ở cuối file',
      );
    } else {
      error(
        errorIn: 'PARSER',
        loc: token.loc,
        message: message,
        errorAt: ' tại "${token.lexeme}"',
      );
    }
  }

  static void runtimeError(RuntimeError error) {
    Vil.error(
      errorIn: 'INTERPRETER',
      loc: error.token.loc,
      message: error.message,
    );
    hadRuntimeError = true;
  }
}

void main() {
  Vil.runFile(
      '/Users/daiduong/Desktop/Project/Github Project/vil/vil/test/testcase/for_loop.vil');
}
