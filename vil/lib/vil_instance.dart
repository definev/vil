import 'package:vil/interpreter.dart';
import 'package:vil/token.dart';
import 'package:vil/vil_class.dart';

class VilInstance {
  final VilClass klass;

  VilInstance(this.klass);

  Map<String, dynamic> _fields = {};

  dynamic get(Token name) {
    if (_fields.containsKey(name.lexeme)) {
      return _fields[name.lexeme];
    }

    var method = klass.findMethod(name.lexeme);
    if (method != null) return method.bind(this);

    throw RuntimeError(
      message:
          'Không tìm thấy thuộc tính "${name.lexeme}" trong lớp "${klass.name}".',
      token: name,
    );
  }

  void set(Token name, dynamic value) {
    _fields[name.lexeme] = value;
  }

  @override
  String toString() => '<đối tượng "${klass.name}">';
}
