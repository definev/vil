import 'dart:io';

import 'package:vil/scanner.dart';
import 'package:vil/token.dart';

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
  Vil.runPrompt();
}
