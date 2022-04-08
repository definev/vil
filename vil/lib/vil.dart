import 'dart:io';

import 'package:vil/interpreter.dart';
import 'package:vil/loc.dart';
import 'package:vil/native_methods.dart';
import 'package:vil/parser.dart';
import 'package:vil/resolver.dart';
import 'package:vil/scanner.dart';
import 'package:vil/token.dart';
import 'package:vil/token_type.dart';
import 'package:vil/vil_error.dart';

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
    if (statements == null) return;

    Resolver resolver = Resolver(interpreter);
    resolver.resolve(statements);
    if (hadError) return;
    interpreter.interpret(statements);
  }

  static void runFile(String fileSource) {
    File file = File(fileSource);
    String source = file.readAsStringSync();
    run(source);
    if (hadError) throw VilCompileError();
    if (hadRuntimeError) throw VilRuntimeError();
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
    native.error(
        '|$errorIn| [$loc]:${errorAt != null ? " Lỗi $errorAt: " : " "}$message');
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
        errorAt: 'tại "${token.lexeme}"',
      );
    }
  }

  static void runtimeError(RuntimeError error) {
    Vil.error(
      errorIn: 'INTERPRETER',
      loc: error.token.loc,
      message: error.message,
      errorAt: 'tại "${error.token.lexeme}"',
    );
    hadRuntimeError = true;
  }
}

void main() {
  Vil.run('''
lớp Bim {
  beep() {
    in self;
  }

  bop(message) {
    in message;
  }
}

hàm outsource() {
  in "OUT SOURCE!!!";
}

tạo bim = Bim();
''');
}
