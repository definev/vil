import 'package:vil/interpreter.dart';
import 'package:vil/token.dart';
import 'package:vil/vil.dart';

class Environment {
  Environment(Map<String, dynamic> values, {Environment? parent})
      : _values = values,
        this.parent = parent;

  final Environment? parent;
  Map<String, dynamic> _values = {};

  Environment clone() {
    return Environment({..._values}, parent: parent);
  }

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
      message: 'Biến "${name.lexeme}" chưa được định nghĩa',
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
      message: 'Biến "${name.lexeme}" chưa được định nghĩa',
    );
  }

  dynamic getAt(Token name, int depth) {
    return ancestor(name, depth)?._values[name.lexeme];
  }

  dynamic assignAt(Token name, int depth, dynamic value) {
    ancestor(name, depth)?._values[name.lexeme] = value;
  }

  Environment? ancestor(Token name, int depth) {
    Environment environment = this;
    for (int i = 0; i < depth; i++) {
      final parent = environment.parent;
      if (parent == null) {
        Vil.error(
          errorIn: 'RESOLVER',
          loc: name.loc,
          message: 'Không tồn tại biến tại cấp độ $depth.',
          errorAt: '"${name.lexeme}"',
        );
        return null;
      }
      environment = parent;
    }
    return environment;
  }
}
