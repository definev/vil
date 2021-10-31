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
    List<String> astName =
        rawAstList.map((e) => e.split(":")[0].trim()).toList();
    List<String> astArgument =
        rawAstList.map((e) => e.split(":")[1].trim()).toList();

    StringBuffer writer = StringBuffer();

    writer.writeln('abstract class $baseClassName {}');

    for (int i = 0; i < astName.length; i++) {
      writer.writeln('class ${astName[i]} extends $baseClassName {');
      List<String> argument =
          astArgument[i].split(",").map((e) => e.trim()).toList();
      for (int j = 0; j < argument.length; j++) {
        writer.writeln('final ${argument[j]};');
      }

      final argumentName = argument.map((e) => e.split(" ")[1].trim()).toList();
      writer.writeln('${astName[i]}(');
      for (int j = 0; j < argumentName.length; j++) {
        writer.writeln('this.${argumentName[j]},');
      }
      writer.writeln(');');
      writer.writeln('}');
    }

    return writer.toString();
  }
}
