import 'package:vil/interpreter.dart';
import 'package:vil/token.dart';

class Environment {
  Environment([this.parent = null]);

  final Environment? parent;
  Map<String, dynamic> _values = {};

  void define(String name, dynamic value) {
    _values[name] = value;
  }

  dynamic get(Token name) {
    if (_values.containsKey(name.lexeme)) {
      return _values[name.lexeme];
    }

    if (parent != null) return parent!.get(name);

    throw RuntimeError(
      token: name,
      message: 'Biến "${name.lexeme}" chưa được định nghĩa.',
    );
  }

  void assign(Token name, dynamic value) {
    if (_values.containsKey(name.lexeme)) {
      _values[name.lexeme] = value;
      return;
    }

    if (parent != null) {
      parent!.assign(name, value);
      return;
    }

    throw RuntimeError(
      token: name,
      message: 'Biến "${name.lexeme}" chưa được định nghĩa.',
    );
  }
}
