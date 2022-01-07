import 'dart:io';

import 'package:vil/interpreter.dart';
import 'package:vil/vil_callable.dart';

class ExitFunction implements VilCallable {
  @override
  int get argsSize => 1;

  @override
  call(Interpreter interpreter, List arguments) {
    if (arguments[0] is num) {
      exit(arguments[0].toInt());
    } else {
      print('Lỗi tham số cần phải là số nguyên.');
    }
  }

  @override
  String toString() => '<native "exit">';
}
