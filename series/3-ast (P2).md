# Làm việc với cây cú pháp
Ở phần trước, chúng ta đã định nghĩa được 4 biểu thức: **Literal**, **Grouping**, **Binary**, **Unary**.

Mặc dù chúng ta chưa làm ra nó, hãy xem xét trình thông dịch sẽ làm gì với các cây cú pháp. Mỗi loại biểu thức trong ViL hoạt động khác nhau trong runtime. Điều đó có nghĩa là mỗi loại biểu thức cần một đoạn mã khác nhau để xử lí biểu thức. Với token, chúng ta có thể chỉ cần TokenType để phân biệt. Nhưng chúng ta không có enum “type” cho cây cú pháp, mà chỉ có một lớp riêng biệt cho mỗi biểu thức.

Chúng ta có thể viết một chuỗi if-else dài xét từng loại:
```dart
if (expr is Binary) {
  // xử lí binary
} else if (expr is Grouping) {
  // xử lí grouping
} else // ...
```
Nhưng loại kiểm tra như vậy rất chậm, phụ thuộc vào thứ tự sắp xếp if-else, đây không phải phương án tốt.

Chúng ta có một nhóm các lớp và chúng ta cần liên kết một phần hành vi với mỗi lớp. Giải pháp tự nhiên trong một ngôn ngữ hướng đối tượng như Dart là đưa các hành vi đó vào các phương thức trên chính các lớp. Chúng ta có thể thêm một phương thức trừu tượng interpret() trên lớp Expression mà sau đó mỗi lớp con sẽ triển khai nó.

# Vấn đề của việc triển khai phương thức trừu tượng
Vấn đề này về cơ bản nó có vẻ vẫn như vấn đề của cách triển khai trước. Chúng ta có một số loại và một số phương thức như “thông dịch”. Đối với từng cặp biểu thức và phương thức, chúng ta cần có một cách triển khai cụ thể. Ở đây ví dụ bảng sau:

![image.png](https://images.viblo.asia/c96b6a96-be39-42c4-848a-13cd611daba4.png)

Source: *craftinginterpreters.com*

Mỗi hàng là biểu thức còn mỗi cột là phương thức cần triển khai. Với mỗi ô là phương thức thực hiện của từng biểu thức với từng hoạt động.

## Cách tiếp cận với lớp
Với Dart - một ngôn ngữ hướng đối tượng một lớp tương ứng với một hàng. Một khi thêm một biểu thức mới tương ứng với việc thêm một hàng nữa trong bảng tra cứu. 

![image.png](https://images.viblo.asia/93ee639e-4dba-4939-90ee-4349b595ad08.png)

Source: *craftinginterpreters.com*

Điều này giúp chúng ta mở rộng theo hàng một cách dễ dàng chỉ bằng việc thêm một lớp mới. Nhưng mở rộng theo cột, lại khó, khi có một phương thức mới được thêm vào, ta lại phải vào từng class thêm phương thức mới.

## Cách tiếp cận với functional
Cách này giống như cách tiếp cận if-else phần trên từng phương thức. Điều này thêm một phương thức mới thật dễ dàng chỉ cần định nghĩa một hàm mới if-else từng loại biểu thức.

![image.png](https://images.viblo.asia/0883b29d-a166-4500-8fa0-a9028b4ac872.png)

Nhưng ngược lại, việc thêm một biểu thức mới rất khó. Bạn phải quay lại và thêm một lớp mới cho tất cả các hàm trong tất cả các phương thức hiện có.

Cả hai cách đều có khuyết điểm riêng, với ViL ta có thể sử dụng triển khai theo kiểu lớp vì số biểu thức nhiều hơn số phương thức cần thực hiện. Nhưng chúng ta có thể làm tốt hơn nữa với Visitor pattern giải quyết nhược điểm của hai cách tiếp cận trên.

# Visitor pattern
Visitor pattern giống như cách tiếp cận "functional" trong hướng đối tượng vậy. Cơ bản ta có một lớp trừu tượng **Visitor** giống như người vận chuyển chứa bản mẫu của mã xử lí khi đi qua biểu thức, và khi có một phương thức mới cần triển khai ta triển khai **Vistor** của phương thứ đó. Bây giờ, mỗi lớp biểu thức không còn phải triển khai trực tiếp phương thức mà triển khai phương thức `accept` và truyền một **Visitor** và trả về mã xử lí của biểu thức đó trong **Visitor** vừa truyền.

Hãy lấy một ví dụ nhỏ sau. Ta có hai lớp `Car` và `Bike` triển khai lớp cha là `Vehicle`. 
```dart
abstract class Vehicle {}

class Car implements Vehicle {}

class Bike implements Vehicle {}
```

Ta thêm `VehicleVisitor` giúp định nghĩa phương thức khi đi qua từng loại xe.
```dart
abstract class VehicleVisitor {
    void visitCar(Car car);
    void visitBike(Bike bike);
} 
```

Ok bây giờ thêm phương thức `accept` trong lớp trừu tượng `Vehicle` mỗi khi vistor đi qua ta sẽ gọi nó.
```dart
abstract class Vehicle {
    void accept(VehicleVisitor visitor);
}

class Car implements Vehicle {
    void accept(VehicleVisitor visitor) {
        visitor.visitCar(this);
    }
}

class Bike implements Vehicle {
    void accept(VehicleVisitor visitor) {
        visitor.visitBike(this);
    }
}
```

Bây giờ với mỗi phương thức chúng ta sẽ triển khai `VehicleVisitor` là đã xong.

# Code gen Visitor cho biểu thức
Được rồi, hãy đưa nó vào các lớp biểu thức của chúng ta. Chúng ta cũng sẽ tinh chỉnh ví dụ mẫu một chút, muốn phương thức `accept` trả lại một giá trị nào đó. Giá trị đó tùy theo từng Visitor nên mình sẽ sử dụng kiểu generic trong dart để định kiểu cho giá trị trả về.

Source: `ast_generator.dart`
```dart
...
class AstGenerator extends GeneratorForAnnotation<Ast> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
        ...
        StringBuffer writer = StringBuffer();

        _visitorGenerator(baseClassName, astName, writer);
        ...
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
```

Định nghĩa phương thức `accept` sử dụng kiểu generic:

Source: `ast_generator.dart`
```dart
    ...
    _visitorGenerator(baseClassName, astName, writer);

    writer.writeln('abstract class $baseClassName {');

    writer.writeln('T accept<T>(${baseClassName}Visitor<T> visitor);');

    writer.writeln('}');
    ...
```

Triển khai trong biểu thức chính

Source: `ast_generator.dart`
```dart
class AstGenerator extends GeneratorForAnnotation<Ast> {
  @override
  String generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
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

      writer.writeln('T accept<T>(${baseClassName}Visitor<T> visitor) {');
      writer.writeln('return visitor.visit${astName[i]}(this);');
      writer.writeln('}');

      writer.writeln('}');
    }

    return writer.toString();
  }
}
```

Vào project gôc ViL và chạy lệnh:
```bash
dart run build_runner build --delete-conflicting-outputs
```

# Visitor in cây cú pháp
Khi chúng ta gỡ lỗi trình phân tích cú pháp và trình thông dịch của mình, sẽ hữu ích khi xem cây cú pháp đã phân tích cú pháp và đảm bảo rằng nó có cấu trúc mà chúng ta mong đợi. Ta có thể kiểm tra nó trong trình debug, nhưng đó có lẽ là việc làm hơi không "pro" lắm.

Thay vì thế hãy thực hiện một máy in cây cú pháp khi mục tiêu là tạo ra một chuỗi văn bản có cú pháp hợp lệ trong ngôn ngữ nguồn.
Biểu thức `-123 * (45.67)` có dạng cây như sau:
![image.png](https://images.viblo.asia/59ea9682-8145-479a-bd7d-1cb3a5129c61.png)

Và máy in của chúng ta biểu diễn như sau:
```
(* (- 123) (group 45.67))
```

Không được đẹp lắm nhưng nó cũng thể hiện được sự lồng nhau và các nhóm trong biểu thức. Triển khai điều này, tạo file `vil/liv/ast_printer.dart` như sau:
```dart
import 'package:vil/grammar/expression.dart';

class AstPrinter implements ExpressionVisitor<String> {
  String print(Expression expression) {
    return expression.accept(this);
  }

  @override
  String visitBinary(Binary binary) {
    // TODO: implement visitBinary
    throw UnimplementedError();
  }

  @override
  String visitGrouping(Grouping grouping) {
    // TODO: implement visitGrouping
    throw UnimplementedError();
  }

  @override
  String visitLiteral(Literal literal) {
    // TODO: implement visitLiteral
    throw UnimplementedError();
  }

  @override
  String visitUnary(Unary unary) {
    // TODO: implement visitUnary
    throw UnimplementedError();
  }
}
```

Triển khai 4 phương thức cho 4 loại biểu thức.
```dart
  @override
  String visitBinary(Binary expr) {
    return parenthesize(expr.operator.lexeme, [expr.left, expr.right]);
  }

  @override
  String visitGrouping(Grouping expr) {
    return parenthesize("group", [expr.expression]);
  }

  @override
  String visitLiteral(Literal expr) {
    if (expr.value == null) return "rỗng";
    return expr.value.toString();
  }

  @override
  String visitUnary(Unary expr) {
    return parenthesize(expr.operator.lexeme, [expr.right]);
  }
```

Các biểu thức Literal rất dễ dàng — chúng chuyển đổi giá trị thành một chuỗi với một chút kiểm tra để xử lí kiểu null trong dart chuyển sang kiểu "rỗng" của ViL. Các biểu thức khác có biểu thức con, vì vậy chúng sử dụng phương thức trợ giúp trong `parenthesize` này:

Source: `vil/liv/ast_printer.dart`, dưới hàm `visitUnary`
```dart
...
String parenthesize(String name, List<Expression> exprs) {
    StringBuffer writer = StringBuffer();

    writer.write("($name");
    for (final expr in exprs) {
      writer.write(" ");
      writer.write(expr.accept(this));
    }
    writer.write(")");

    return writer.toString();
}
```

Vậy là xong, giờ thử chạy nó trong hàm `main` ở file `vil/lib/vil.dart`:

Source: `vil.dart`
```dart
void main() {
  // -123 * (45.67)
  final expression = Binary(
    Unary(
        Token(
            line: 1, col: 1, lexeme: '-', literal: null, type: TokenType.minus),
        Literal(123)),
    Token(col: 6, line: 1, lexeme: '*', literal: null, type: TokenType.star),
    Grouping(Literal(45.67)),
  );

  // (* (- 123) (group 45.67))
  print(AstPrinter().print(expression));
}
```

Nếu bạn làm đúng máy in của chúng ta sẽ trả ra như này `(* (- 123) (group 45.67))`

Vậy là đã hoàn thành, ở các bài viết sau chúng ta không sử dụng lại **AstPrinter** bạn có thể xóa nó đi hoặc comment lại. Hoặc nếu bạn muốn phát triển song song cả máy in AST của chúng ta thì có thể giữ lại và phát triển nó. Đây chỉ là một ví dụ cho cách triển khai **Vistor**.