import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:generators/src/ast_generator.dart';

Builder generateAst(BuilderOptions options) =>
    // SharedPartBuilder là một builder được sử dụng để tạo ra một file cùng cấp với file chứa annotation
    SharedPartBuilder([AstGenerator()], 'ast');
