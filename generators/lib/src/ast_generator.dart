import 'package:build/src/builder/build_step.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:annotations/annotations.dart';

class AstGenerator extends GeneratorForAnnotation<Ast> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    /// Tiền xử lí, lấy ra các tên của class
    /// và lấy ra dữ liệu thô mà chúng ta nhập vào qua AST

    /// Tên class cần gen
    final baseClassName = element.displayName.substring(1);

    /// Annotation nhập vào trong trường hợp này chắc chắn AST là annotation đầu tiên và duy nhất
    /// nên ta lấy annotation đầu tiên
    final ast = element.metadata.first;

    /// Bóc ra dữ liệu thô của `rawASTList` list này trả về dạng List<DartObject>
    final rawRawAstList =
        ast.computeConstantValue()!.getField('rawASTList')!.toListValue()!;

    /// Chuyển từ kiểu List<DartObject> => List<String> ban đầu
    final rawAstList = rawRawAstList.map((e) => e.toStringValue()!).toList();

    /// Tách thành hai mảng tên và biến riêng
    List<String> astName = [];
    List<String> astArgument = [];

    for (final astClass in rawAstList) {
      final args = astClass.split(':');
      astName.add(args[0].trim());
      astArgument.add(args[1].trim());
    }

    StringBuffer writer = StringBuffer();

    _visitorGenerator(baseClassName, astName, writer);

    writer.writeln('abstract class $baseClassName {');
    writer.writeln('const $baseClassName();');
    writer.writeln('T accept<T>(${baseClassName}Visitor<T> visitor);');
    writer.writeln('}');

    for (int i = 0; i < astName.length; i++) {
      writer.writeln('class ${astName[i]} extends $baseClassName {');
      if (astArgument[i].isNotEmpty) {
        List<String> argument =
            astArgument[i].split(",").map((e) => e.trim()).toList();
        for (int j = 0; j < argument.length; j++) {
          writer.writeln('final ${argument[j]};');
        }

        final argumentName =
            argument.map((e) => e.split(" ")[1].trim()).toList();
        writer.writeln('const ${astName[i]}(');
        for (int j = 0; j < argumentName.length; j++) {
          writer.writeln('this.${argumentName[j]},');
        }
        writer.writeln(');');
      } else {
        writer.writeln('const ${astName[i]}();');
      }

      writer.writeln('T accept<T>(${baseClassName}Visitor<T> visitor) {');
      writer.writeln('return visitor.visit${astName[i]}(this);');
      writer.writeln('}');

      writer.writeln('}');
    }

    return writer.toString();
  }

  void _visitorGenerator(
      String baseClassName, List<String> astName, StringBuffer writer) {
    writer.writeln('abstract class ${baseClassName}Visitor<T> {');

    for (final name in astName) {
      writer.writeln(
          'T visit$name($name ${name[0].toLowerCase() + name.substring(1)});');
    }

    writer.writeln('}');
  }
}
