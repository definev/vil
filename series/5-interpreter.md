Có nhiều cách để chuyển code của một ngôn ngữ cho máy tính thực thi, nó có thể là biên dịch code đó sang ngôn ngữ máy để thực thi, hoặc chuyển code đó sang một ngôn ngữ bậc cao khác, và cũng có thể là chuyển nó sang dạng bytecode và đưa vào máy ảo để chạy. Tuy nhiên, đối với trình thông dịch đầu tiên của chúng ta, chúng ta sẽ đi theo con đường đơn giản nhất, ngắn nhất là thực thi chính cây cú pháp.

Hiện tại, trình phân tích cú pháp chỉ hỗ trợ các biểu thức. Để thực thi được code, chúng ta cần đánh giá biểu thức đó và trả về giá trị của nó. Với mỗi loại biểu thức đã thực hiện - literal, binary, ... chúng ta cần một đoạn code tương ứng giúp đánh giá nhánh đó và tạo ra kết quả tương ứng. Để giải quyết vấn đề này chúng ta cần trả lời hai câu hỏi:
- Loại giá trị nào chúng ta sẽ trả về?
- Làm thế nào để tổ chức code?

# Giá trị trả về
Trong ViL, giá trị được chứa trong biểu thức `literal`, tính toán qua các biểu thức như `binary`, `unary` và lưu lại kết quả trong một biến nào đó. Người dùng sẽ tiếp xúc với cái gọi là đối tượng của ViL nhưng ở phía sau tất cả được thực thi ở ngôn ngữ mà trình thông dịch của chúng ta được viết ở đây là Dart. Điều đó có nghĩa là kết nối hai kiểu ngôn ngữ: kiểu động của ViL và kiểu tĩnh của Dart. Biến trong ViL không cố định kiểu dữ liệu, nó có thể là số trong thời điểm này nhưng ta hoàn toàn gán được một giá trị logic lúc sau ngay trong runtime. Rất may mắn, tuy Dart là kiểu tĩnh nhưng nó vẫn có kiểu dữ liệu `dynamic` cái mà có thể lưu bất cứ kiểu dữ liệu nào trong các thời điểm khác nhau ở runtime.

Ở những vị trí trong trình thông dịch mà cần lưu trữ giá trị ViL, chúng ta có thể sử dụng kiểu dynamic. Dart đã cung cấp sẵn các các kiểu nguyên thủy tương tự như ViL vì vậy chúng ta có thể sử dụng các kiểu dữ liệu đó cho các kiểu dữ liệu built-in của ViL, ta có bảng đối sánh sau:

|Kiểu dữ liệu của ViL|Kiểu dữ liêu trong Dart|
|-|-|
|bất kì|dynamic|
|rỗng|null|
|số|double|
|chuỗi|String|
|logic|bool|

Để kiểm tra kiểu dữ liệu thật sự mà `dynamic` lưu, dart cung cấp sẵn từ khóa `is` để kiểu tra kiểu dữ liệu đó là số, chuỗi hay logic. Nói cách khác, Dart VM cung cấp đầy đủ mọi thứ để chúng ta xây dựng các kiểu built-in trong ViL. Ngoài ra chúng ta cần phải quản lí bộ nhớ tuy nhiên máy ảo của dart có garbage collector và nó làm rất tốt việc giải phóng bộ nhớ.

# Đánh giá biểu thức
Bạn còn nhớ bảng này chứ? Chúng ta sẽ triển khai phương thức cho `interpret()` cho biểu thức thông qua Visitor patterm mà mình đã giới thiệu ở bài viết trước.

![image.png](https://images.viblo.asia/4e4c7568-0f9e-4f41-a37c-583ff353a39a.png)

 Thực chất trình thông dịch của chúng ta không khác so với `AstPrinter` mà ở bài viết trước chúng ta triển khai, `AstPrinter` sẽ "nén" các biểu thức lại thành một chuỗi còn Interpreter sẽ đánh giá và đưa giá trí trị của biểu thức. Bắt đầu với lớp `Interpreter`:

Source: `lib/interpreter.dart`, Tạo file  `lib/interpreter.dart` 
```dart
import 'package:vil/grammar/expression.dart';

class Interpreter implements ExpressionVisitor<dynamic> {
  @override
  dynamic visitBinary(Binary binary) {
    // TODO: implement visitBinary
    throw UnimplementedError();
  }

  @override
  dynamic visitGrouping(Grouping grouping) {
    // TODO: implement visitGrouping
    throw UnimplementedError();
  }

  @override
  dynamic visitLiteral(Literal literal) {
    // TODO: implement visitLiteral
    throw UnimplementedError();
  }

  @override
  dynamic visitUnary(Unary unary) {
    // TODO: implement visitUnary
    throw UnimplementedError();
  }
}
```

## Literal

Chúng ta bắt đầu triển khai từ biểu thức dễ nhất là `literal`, việc cần làm là lấy ra giá trị lưu trong biểu thức.

Source: `lib/interpreter.dart`, hàm `visitLiteral`
```dart
@override
dynamic visitLiteral(Literal literal) {
  return literal.value;
}
```

## Grouping

Tiếp theo là `grouping`, chúng ta lấy biểu thức trong ngoặc và đánh giá nó.

Source: `lib/interpreter.dart`, hàm `visitGrouping`
```dart
@override
dynamic visitGrouping(Grouping grouping) {
  return _evaluate(grouping.expression);
}
```

Hàm đánh giá biểu thức truyền `Interpreter` them visitor patterm mình đã triển khai để đánh giá biểu thức.

Source: `lib/interpreter.dart`, Đứng trước hàm `visitBinary`
```dart
dynamic _evaluate(Expression expression) {
  return expression.accept(this);
}
```

## Unary
Giống như biểu thức nhóm, biểu thức một ngôi có một biểu thức con duy nhất mà chúng ta phải đánh giá trước. Sự khác biệt là sau biểu thức một ngôi con ta cần thực hiện thêm một chút xử lí sau đó.

Source: `lib/interpreter.dart`, hàm `visitUnary`
```dart
@override
dynamic visitUnary(Unary unary) {
  final right = _evaluate(unary.right);
  switch (unary.operator.type) {
    case TokenType.minus:
      return -right;
    case TokenType.bang:
      return !_isTruthy(right);
    default:
      return null;
  }
}
```

Đầu tiên, chúng ta đánh giá biểu thức con. Sau đó, áp dụng chính toán tử một ngôi phía trước cho giá trị vừa đánh giá được. Có hai biểu thức một ngôi khác nhau là `-` và `!`, được xác định qua TokenType.

Toán tử `-` có tác dụng đổi dấu kiểu dữ liệu số, với kiểu dữ liệu động hiện tại dart cho phép ta để dấu `-` đằng trước mà không báo lỗi tuy nhiên bạn có thể nghĩ nếu đó không phải kiểu số thì sao, chúng ta sẽ xử lí vấn đề đó ở phần tiếp theo sau. Toán tử `!` bằng với đảo logic.

### Truthness và falsiness
Hàm `_isTruthy` giúp kiểm tra giá trị đó có "truthy" hay không, một giá trị được coi là truthy có hai trường hợp, một nó là giá trị `true` hai nếu nó không phải kiểu logic thì nó sẽ kiểm tra xem giá trị đó có null hay không.

Source: `lib/interpreter.dart`, hàm `_isTruthy`
```dart
bool _isTruthy(dynamic value) {
  if (value is bool) return value;
  return value != null;
}
```

## Binary
Biểu thức `binary` là biểu thức thông dụng nhất và cũng là biểu thức phức tạp nhất, tuy nhiên đừng sợ nó cũng đơn giản vì dart đã lo hết các phần khó cho chúng ta rồi. Bắt đầu với các toán tử tính toán.

Source: `lib/interpreter.dart`, hàm `visitBinary`
```dart
@override
dynamic visitBinary(Binary binary) {
  final left = _evaluate(binary.left);
  final right = _evaluate(binary.right);

  switch (binary.operator.type) {
    case TokenType.minus:
      return left - right;
    case TokenType.plus:
      return left + right;
    case TokenType.star:
      return left * right;
    case TokenType.slash:
      return left / right;
    default:
      return null;
  }
}
```

Tương tự vậy với phép so sánh độ lớn và phép so sánh bình đẳng.

Source: `lib/interpreter.dart`, trong hàm `visitBinary`
```dart
case TokenType.equalEqual:
  return left == right;
case TokenType.bangEqual:
  return left != right;
case TokenType.greater:
  return left > right;
case TokenType.greaterEqual:
  return left >= right;
case TokenType.less:
  return left < right;
case TokenType.lessEqual:
  return left <= right;
```

Tuy nhiên ta cũng không thể phó mặc dart xử lí hộ tất cả các lỗi về kiểu, những lỗi này xảy ra ở runtime, chúng ta cần một cơ chế để bắt lỗi và đưa nó ra cho lập trình viên sửa lỗi.
# Xử lí lỗi runtime
Cảm giác thật nguy hiểm khi để kệ giá trị của biến là `dynamic` khi chúng ta biết chắc chắn nó phải là số hoặc chuỗi. Mặc dù mã của người dùng ngôn ngữ có sai sót, nhưng nếu chúng ta muốn tạo ra một ngôn ngữ có thể sử dụng được, chúng ta có trách nhiệm xử lý lỗi đó một cách khéo léo.

Ở bài trước chúng ta đã xử lí lỗi cú pháp và lỗi đánh máy, những lỗi này được xử lí trước khi chạy những dòng code, đảm bảo tính đúng của đoạn code được nhập vào, lỗi runtime lại khác nó xảy ra trong lúc thực thi chương trình. 

Đầu tiên định nghĩa lỗi `RuntimeError`

Source: `lib/interpreter.dart`, Bên dưới lớp `Interpreter`
```dart
class RuntimeError {
  final String message;
  final Token token;

  RuntimeError({
    required this.message,
    required this.token,
  });

  @override
  String toString() => '$message';
}
```

## Phát hiện lỗi
Một trong số các lỗi cơ bản là sai kiểu, chúng ta cầm một hàm để kiểm tra kiểu hiện tại của biến đó có phải số hay chuỗi hay không và ném lại một RuntimeError nếu bị lỗi.

Source: `lib/interpreter.dart`, Bên dưới hàm `_isTruthy`
```dart
void _checkIsNumber(List<dynamic> values, Token token) {
  for (var value in values) {
    if (value is! num) {
      throw RuntimeError(
          token: token, message: 'Sai kiểu dữ liệu, cần kiểu số.');
    }
  }
}
```

Sau khi đã có hàm kiểm tra chúng ta thêm nó vào `unary` để chắc chắn rằng giá trị nhận vào là số.

Source: `lib/interpreter.dart`, Sửa lại hàm `visitUnary`
```dart
case TokenType.minus:
  _checkIsNumber([right], unary.operator);
  return -right;
```

Tương tự với `binary`, trong ViL chỉ có số mới thực hiện được các phép so sánh:

Source: `lib/interpreter.dart`, Sửa lại hàm `visitBinary`

- Phép trừ
```dart
case TokenType.minus:
  _checkIsNumber([left, right], binary.operator);
  return left - right;
```
- Phép nhân
```dart
case TokenType.star:
  _checkIsNumber([left, right], binary.operator);
  return left * right;
```
- Phép chia
```dart
case TokenType.slash:
  _checkIsNumber([left, right], binary.operator);
  return left / right;
```
- Lớn hơn
```dart
case TokenType.greater:
  _checkIsNumber([left, right], binary.operator);
  return left > right;
```
- Lớn hơn hoặc bằng
```dart
case TokenType.greaterEqual:
  _checkIsNumber([left, right], binary.operator);
  return left >= right;
```
- Nhỏ hơn
```dart
case TokenType.less:
  _checkIsNumber([left, right], binary.operator);
  return left < right;
```
- Nhỏ hơn hoặc bằng
```dart
case TokenType.less:
  _checkIsNumber([left, right], binary.operator);
  return left <= right;
```

Phép cộng hơi đặc biệt hơn một chút, ViL cho phép cộng giữa số với số, chuỗi với chuỗi hoặc số với chuỗi, ngoài ra nếu không rơi vào các trường hợp này thì trả về một RuntimeError.

Source: `lib/interpreter.dart`, Sửa lại hàm `visitBinary`
```dart
case TokenType.plus:
  if (left is num && right is num) return left + right;
  if (left is String && right is String) return left + right;
  if (left is String && right is num) return left + right.toString();
  if (left is num && right is String) return left.toString() + right;
  throw RuntimeError(
    token: binary.operator,
    message: 'Sai kiểu dữ liệu, chỉ có thể cộng hai kiểu số hoặc chuỗi.',
  );
```

# Đóng gói trình thông dịch
Chúng ta tổng kết lại trình thông dịch với một hàm public `interpret` để bắt đầu trình thông dịch.

Source: `lib/interpreter.dart`, Sửa lại hàm `visitBinary`
```dart
void interpret(Expression expression) {
  try {
    final value = _evaluate(expression);
    print(_stringify(value));
  } on RuntimeError catch (error) {
    Vil.runtimeError(error);
  }
}
```

Nó nhận vào kết quả phân tích cú pháp của Parser và đánh giá giá trị qua hàm `_evaluate`, gọi hàm `_stringify` để in ra màn hình, bắt lỗi runtime và log nó ra cho lập trình viên sửa lỗi.

Hàm `_stringify` để chuyển đổi tên của các kiểu trong dart sang ViL.

Source: `lib/interpreter.dart`, Sau hàm `interpret`
```dart
String _stringify(dynamic value) {
  if (value == null) return 'rỗng';

  if (value is double) {
    final text = value.toString();
    if (text.endsWith('.0')) {
      return text.substring(0, text.length - 2);
    }
    return text;
  }

  if (value is bool) return value ? 'đúng' : 'sai';

  return value.toString();
}
```

Hàm in lỗi giống với hàm in lỗi của Parser.

Source: `lib/vil.dart`, Dưới hàm `parserError`
```dart
static void runtimeError(RuntimeError error) {
  Vil.error(
    errorIn: 'INTERPRETER',
    line: error.token.line,
    col: error.token.col,
    message: error.message,
  );
  hadRuntimeError = true;
}
```

Chúng ta có một cờ hiệu nhỏ `hadRuntimeError` để đánh dấu dừng chương trình lại nếu gặp lỗi runtime.

Source: `lib/vil.dart`
```dart
class Vil {
  static bool hadError = false;
  static bool hadRuntimeError = false; // Thêm dòng này
  ...
  
  static void runFile(String fileSource) {
    File file = File(fileSource);
    String source = file.readAsStringSync();
    run(source);
    if (hadError) exit(65);
    if (hadRuntimeError) exit(70); // Thoát chương trình nếu gặp cờ lỗi runtime
  }
```

## Chạy trình thông dịch
Giờ việc của chúng ta là thêm lớp `Interpreter` vào lớp chính `Vil`, gọi hàm `interpret` với kết quả của `Parser`.

```dart
class Vil {
  static Interpreter interpreter = Interpreter(); // Thêm trình thông dịch

  static bool hadError = false;
  static bool hadRuntimeError = false;

  static void run(String source) {
    Scanner scanning = Scanner(source);
    List<Token> tokens = scanning.scan();

    Parser parser = Parser(tokens);
    Expression? expression = parser.parse();
    if (expression != null) {
      interpreter.interpret(expression); // Gọi hàm thực thi
    }
  }
 
  ...
}
```

Hãy chạy thử một phép toán, giờ đây ViL đã có chức năng như một chiếc máy tính cơ bản thật thụ, khung xương của ngôn ngữ đã hoàn thành: Scanning, Parser, Interpreter các bước đã được triển khai. Ở những bài viết sau chúng ta sẽ thêm phần cơ và da thịt cho ViL, biến nó trở thành một ngôn ngữ đầy mạnh mẽ. 

![image.png](https://images.viblo.asia/a1406199-09aa-4ef0-9523-2f202269c206.png)

# Mã nguồn
Bạn có thể theo dõi mã nguồn từng bài viết tại đây. Đừng ngại để lại cho mình một sao nhé 😍

ViL : https://github.com/definev/vil