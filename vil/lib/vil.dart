import 'dart:io';

import 'package:vil/scanning.dart';
import 'package:vil/token.dart';

class Vil {
  static void run(String source) {
    Scanning scanning = Scanning(source);
    List<Token> tokens = scanning.scan();
    for (final token in tokens) {
      print(token);
    }
  }

  static void runFile(String fileSource) {
    File file = File(fileSource);
    String source = file.readAsStringSync();
    run(source);
  }

  static void runPrompt() {
    while (true) {
      stdout.write("> ");
      String? line = stdin.readLineSync();
      if (line != null) {
        run(line);
      }
    }
  }
}

void main() {
  Vil.runPrompt();
}
