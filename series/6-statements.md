Trình thông dịch mà chúng ta đã cùng tạo ra ở bài trước trông không giống việc lập trình lắm mà giống như một cái máy tính cơ bản đưa phép tính vào và nó trả ra kết quả. Lập trình theo mình là xây dựng cả một cấu trúc dựa trên các thành phần nhỏ. Chúng ta hiện không thể làm điều đó vì không có cách nào để gán một cái tên bất kì cho biến hay hàm nào đó. Chúng ta không thể tạo nên chương trình hoàn chỉnh nếu không có cách nào để tham chiếu giá trị qua tên biến hay tên hàm.

Để thực hiện điều này, trình thông dịch phải có cơ chế lưu lại trạng thái nội bộ của nó, mục tiêu của bài viết này không chỉ khiến nó thực hiện lệnh được mà còn có thể *ghi nhớ*.

![image.png](https://images.viblo.asia/e1556974-5ca8-4429-86c4-b6a1276c05a5.png)

Trong bài viết này chúng ta sẽ làm điều đó. Định nghĩa câu lệnh xuất ra màn hình `in` và câu lệnh khai báo biến `tạo`.Chúng ta sẽ thêm các biểu thức để truy cập và gán cho các biến. Cuối cùng chúng ta sẽ triển khai trạng thái trong phạm vi cục bộ.

# Câu lệnh (statements)
Chúng ta sẽ mở rộng bộ quy tắc của ViL với một loại quy tắc mới - statements, chúng không khác biệt quá nhiều với expression. Bắt đầu với 2 loại statements:
- Câu lệnh biểu thức ***expression statements***: Vẫn là một biểu thức chung nhưng ta ngăn cách nó bằng dấu `;` ở cuối, tránh các side-effect giữa 2 biểu thức khác nhau nhưng đặt cạnh nhau gây hiểu lầm. Bạn có thể không nhận thấy chúng, nhưng bạn vẫn sử dụng chúng mọi lúc trong C, Java và các ngôn ngữ khác. Bất cứ khi nào bạn thấy một hàm hoặc lệnh gọi phương thức được theo sau bởi dấu `;`, bạn đang khai báo một câu lệnh biểu thức.
- Câu lệnh xuất ra màn hình ***print statements***: đánh giá một biểu thức và hiển thị kết quả ra màn hình cho người dùng. hơi kì lạ khi để phương thức in là một câu lệnh riêng thay vì một hàm gọi, tuy nhiên để thực hiện chức năng hàm cho ngôn ngữ chúng ta cần rất nhiều thứ để triển khai mà mình sẽ đánh đổi điều đó để chúng ta có thứ gì đó để nghịch ngợm với ViL trong lúc nó chưa hoàn thiện.

Một quy tắc mới được thêm vào vậy nên chúng ta có một bảng quy tắc mới, với việc thêm statement cuối cùng ta đã phân tích toàn bộ mã của ViL chứ không chỉ một biểu thức đơn giản. Bộ quy tắc mới như sau:
```js
program               => statement* EOF ;

statement             => expressionStatement
                      | printStatement ;

expressionStatement   => expression ";" ;
printStatement        => "xuất" expression ";" ;
```

Quy tắc mới đầu tiên `program` đại diện cho cả chương trình với tập hợp các câu lệnh liên tiếp và kết thúc khi chúng ta đến cuối file. Hiện tại chúng ta có hai loại câu lệnh như đã nói bên trên, bây giờ bước tiếp theo là chuyển từ các quy tắc sang cây cú pháp và thực thi nó.


## Cây cú pháp của câu lệnh
* Chúng ta không thể sử dụng lại lớp đại diện cây cú pháp của biểu thức (expresssion) để biểu diễn câu lệnh, như trong bảng quy tắc phép cộng câu lệnh hay trừ là vô lí. Điều đó dẫn dến việc ta cần phải tạo một base class mới cho câu lệnh. Nhưng đừng lo, nó không khác biểu thức là mấy, ta chỉ cần định nghĩa cú pháp và phần code sẽ do code gen đảm nhiệm.

Source: `lib/grammar/statement.dart`
```dart
import 'package:annotations/annotations.dart';
import 'package:vil/grammar/expression.dart';

part 'statement.g.dart';

@Ast([
  'PrintStmt : Expression expression',
  'ExprStmt  : Expression expression',
])
class _Statement {}
```

Và chạy lệnh `dart run build_runner build`, kết quả ta gen được file `statement.g.dart` như sau:
```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statement.dart';

// **************************************************************************
// AstGenerator
// **************************************************************************

abstract class StatementVisitor<T> {
  T visitPrintStmt(PrintStmt printStmt);
  T visitExprStmt(ExprStmt exprStmt);
}

abstract class Statement {
  T accept<T>(StatementVisitor<T> visitor);
}

class PrintStmt extends Statement {
  final Expression expression;
  PrintStmt(
    this.expression,
  );
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitPrintStmt(this);
  }
}

class ExprStmt extends Statement {
  final Expression expression;
  ExprStmt(
    this.expression,
  );
  T accept<T>(StatementVisitor<T> visitor) {
    return visitor.visitExprStmt(this);
  }
}
```

## Phân tích câu lệnh
Hàm `parse` trong lớp Parser giờ đây sẽ không còn trả về `Expression` nữa mà là một loạt các `Statement`:

Source: `lib/parser.dart`, Sửa đổi hàm `parse`
```dart
List<Statement>? parse() {
  try {
    List<Statement> statements = [];
    while (!_isAtEnd) {
      statements.add(_statement());
    }

    return statements;
  } on ParserError catch (_) {
    return null;
  }
}
```

Đừng quên import `Statement` nhé:

```dart
import 'package:vil/grammar/statement.dart';
```

Hàm `parse` khá dễ dàng chuyển từ bộ quy tắc `program` sang. Thu thập tất cả các câu lệnh cho đến khi đến cuối file.

### Câu lệnh chung
Hàm `_statement` giống như hàm `_expression` nó "gói" chung lại tất cả các câu lệnh tuy nhiên hơi khác một chút các câu lệnh có mức độ ưu tiên ngang bằng nhau nên chúng cùng xuất hiện ở trong hàm `_statement` còn biểu thức phải có sự ưu tiên trước sau nên nó chỉ gói lại biểu thức mức độ ưu tiên thấp nhất.

Source: `lib/parser.dart`
```dart
Statement _statement() {
  if (_match([TokenType.kXuat])) {
    return _printStatement();
  }

  return _expressionStatement();
}
```

### Câu lệnh xuất
Hàm tạo câu lệnh xuất ra màn hình cứ áp dụng công thức mà làm là xong :D
```dart
Statement _printStatement() {
  final expression = _expression();
  _consume(
      TokenType.semicolon, 'Thiếu dấu ";" sau câu lệnh xuất ra màn hình.');

  return Print(expression);
}
```

### Câu lệnh biểu thức
Như công thức 😉

```dart
Statement _expressionStatement() {
  final expression = _expression();
  _consume(TokenType.semicolon, 'Thiếu dấu ";" sau câu lệnh.');

  return Expr(expression);
}
```

## Thực thi câu lệnh
Trình phân tích cú pháp của chúng ta hiện có thể tạo ra các cây cú pháp câu lệnh, vì vậy bước tiếp theo và cuối cùng là diễn giải chúng. Giống như trong các biểu thức, chúng ta sử dụng visitor patterm, và với một base class mới ta cũng phải có một Visitor riêng của nó `StatementVisitor` để thực thi.

Source: `lib/interpreter.dart`
```dart
class Interpreter
    implements ExpressionVisitor<dynamic>, StatementVisitor<void> {
...


  @override
  void visitExpr(Expr exprStmt) {
    // TODO: implement visitExpr
  }

  @override
  void visitPrint(Print printStmt) {
    // TODO: implement visitPrint
  }
}
```

Câu lệnh không trả về gì cả mà nó chỉ thực thi nên generic type của nó là void.

### Thực thi câu lệnh xuất
Về câu lệnh xuất ra màn hình chỉ đơn giản là đánh giá biểu thức bên trong và qua hàm `print` của dart xuất ra màn hình, vậy là hoàn thành. để chắc chắn ta đưa giá trị vào hàm `_stringify` để xử lí sang chuôĩ tương ứng giá trị.

```dart
@override
void visitPrint(Print printStmt) {
  final value = _evaluate(printStmt.expression);
  print(_stringify(value));
}
```

Đầu vào của `Interpreter` đã thay đổi nó là một `List<Statement>` thay vì `Expression` khi trước, sửa lại hàm `interpret` một chút:

Source: `lib/interpreter.dart`
```dart
void interpret(List<Statement> statements) {
  try {
    for (final statement in statements) {
      _execute(statement);
    }
  } on RuntimeError catch (error) {
    Vil.runtimeError(error);
  }
}
```

Hàm `_execute` truyền `Interpreter` vào `statement` để tự đánh giá.

Source: `lib/interpreter.dart`, bên dưới `interpret`
```dart
void _execute(Statement statement) {
  statement.accept(this);
}
```

Sửa lại hàm `run` trong lớp gốc `Vil`.

Source: `lib/vil.dart`, hàm `run`
```dart
static void run(String source) {
  Scanner scanning = Scanner(source);
  List<Token> tokens = scanning.scan();

  Parser parser = Parser(tokens);
  final statements = parser.parse();
  if (statements != null) {
    interpreter.interpret(statements);
  }
}
```

Tuyệt! Chúng ta đã có khả năng thực hiện được lệnh xuất ra màn hình.
```js
.../crafting-interpreters/vil/vil$ dart run lib/vil.dart
lib/vil.dart: Warning: Interpreting this as package URI, 'package:vil/vil.dart'.
> xuất "Chào thế giới";
Chào thế giới
> xuất 3 * 4 + 5; 
17
> xuất đúng;
đúng
> xuất rỗng;
rỗng
```

Nó gần giống như một chương trình thực sự! Đừng quên dấu `;` của bạn nhé 😅

# Biến toàn cục
Bây giờ chúng ta đã có các câu lệnh, chúng ta có thể bắt đầu làm việc về trạng thái của chương trình. Trước khi đi vào tất cả sự phức tạp về trạng thái cục bộ, chúng ta hãy bắt đầu với loại lưu biến đơn giản nhất - biến toàn cục. Chúng ta cần hai cú pháp mơi để thực hiện điều này.
1. Cú pháp **khai báo** và **khởi tạo** biến. Câu lệnh này thực hiện hai việc khởi tạo biến tên `hoa`, sau đó gán giá trị `"cúc dại"` cho nó.
```dart
tạo hoa = "cúc dại";
```
2. Sau khi thực hiện thành công câu lệnh trên, truy cập vào tên biến `hoa` lấy giá trị `"cúc dại"` ra và xuất ra màn hình.
```dart
xuất hoa; // cúc dại
```

Sau đó, chúng tôi sẽ thêm phép gán và khối lệnh, nhưng hiện tại như vậy là đủ để triển khai.

## Cú pháp tạo biến
Như bên trên chúng ta đã định nghĩa nó sẽ có dạng
```dart
tạo hoa = "cúc dại";
```
Quy tắc tương đương như sau
```js
variableDecl => "tạo" IDENTIFIER ("=" expression)? ";" ;
```


Quy tắc mới của chúng ta như sau:
```js
program        => statement* EOF ;

statement      => expressionStatement
               |  printStatement
               |  variableDecl ;
```

Nhưng để thuận tiện về việc định nghĩa các quy tắc mới về khai báo hàm, khai báo lớp ở trong các bài viết sau chúng ta sẽ tách câu lệnh tạo biến ra một lớp trừu tượng khác `declaration`, bản chất nó vẫn là `statement` nhưng với độ ưu tiên thấp hơn một chút.

```js
program        => declaration* EOF ;

declaration    => variableDecl
               |  statement ; 

statement      => expressionStatement
               |  printStatement ;
```

Chúng ta cần phải xác định định danh `IDENTIFIER` một cái tên đại diện cho giá trị nào đó, để truy cập biến ta có biểu thức `primary` mới như sau.
```dart
primary        => số | chuỗi
               |  "đúng" | "sai" | "rỗng"
               |  "(" expression ")"
               |  IDENTIFIER ;
```

Chúng ta đã làm rõ bộ quy tắc cần thiết, bây giờ triển khai phần code thôi, định nghĩa lớp `VariableDeclaration` mới nhận vào token `name` tên của biến và `value` giá trị khởi tạo của biến đó có thể có hoặc không.

Source: `lib/grammar/statement.dart`, bên trên `_Statement`
```dart
@Ast([
  'Print        : Expression expression',
  'Expr         : Expression expression',
  'VariableDecl : Token name, Expression? value',
])
```

Chúng ta cũng cần thêm một biểu thức để lưu trữ tên biến.

Source: `lib/grammar/expression.dart`, bên trên `_Expression`
```dart
@Ast([
  "Binary   : Expression left, Token operator, Expression right",
  "Grouping : Expression expression",
  "Literal  : dynamic value",
  "Unary    : Token operator, Expression right",
  "Variable : Token name"
])
```

Chạy lệnh `dart run build_runner build` là xong.
### Phân tích cú pháp phép tạo biến
Bây giờ quy tắc đầu tiên là `_declaration` nên chúng ta cần chỉnh sửa một chút ở hàm `parse` trong  `Parser`

Source: `lib/parser.dart`, hàm `parse`
```dart
List<Statement>? parse() {
  try {
    List<Statement> statements = [];
    while (!_isAtEnd) {
      statements.add(_declaration()); // Thay đổi từ `_statement` => `_declaration`
    }

    return statements;
  } on ParserError catch (_) {
    return null;
  }
}
```

Chúng ta có một hàm mới như sau:
```dart
Statement _declaration() {
  if (_match([TokenType.kTao])) {
    return _variableDeclaration();
  }

  return _statement();
}

Statement _variableDeclaration() {
  final token = _consume(TokenType.identifier, 'Cần định nghĩa tên biến.');

  Expression? initializer;
  if (_match([TokenType.equal])) {
    initializer = _expression();
  }

  _consume(TokenType.semicolon, 'Thiếu dấu ";" sau câu lệnh.');
  return VariableDecl(token, initializer);
}
```

Thêm một dòng để phân tích biểu thức `Variable` mới ở hàm `_primary`

```dart
Expression _primary() {
  
  ...
  
  if (_match([TokenType.identifier])) {
    return Variable(_previous());
  }

  throw _error(_peek(), 'Token chưa có trong bảng quy tắc.');
}
```

Tất cả việc này cung cấp cho chúng ta phần phân tích hoạt động để khai báo và sử dụng các biến. Tất cả những gì còn lại là đưa kết quả vào trình thông dịch. Trước khi đạt được điều đó, chúng ta cần nói về nơi các biến "sống" trong bộ nhớ.

# Môi trường lưu trữ
Các ràng buộc liên kết các biến với giá trị cần được lưu trữ ở đâu đó. Kể từ khi người Lisp phát minh ra dấu ngoặc đơn, cấu trúc dữ liệu này đã được gọi là **môi trường**.

Source: `https://craftinginterpreters.com`
![image.png](https://images.viblo.asia/e72107c2-f8d8-4029-a108-e4f37903a1b1.png)

Nó có thể hiểu đơn giản là một `Map` với key là tên định danh của biến đó và value là giá trị của nó, chúng ta có thể khai báo trực tiếp theo dạng map vào trình thông dịch nhưng vì tính đóng gói ta sẽ đưa nó vào một lớp mới `Environment` để tiện triển khai.

Source: `lib/environment.dart`, tạo file và tạo lớp `Environment`
```dart
import 'package:vil/interpreter.dart';
import 'package:vil/token.dart';

class Environment {
  Map<String, dynamic> _values = {};
}
```

Chúng ta sử dụng `String` thay vì `Token` vì `Token` vì `Token` chứa cả **vị trí** của tên biến, chúng ta không cần đến điều đó nên thay vì thế sử dụng luôn tên biến để làm key.

Môi trường cần hai phương thức để **khai báo** và **truy cập** biến như sau.

Source: `lib/environment.dart`, phương thức khai báo biến (`define`)
```dart
void define(String name, dynamic value) {
  _values[name] = value;
}
```

Không hẳn là cố ý, nhưng chúng ta đã đưa ra một sự lựa chọn trong cách cách tiếp cận biến. Khi ta thêm key vào map `_values` và không kiểm tra xem nó đã có sẵn hay chưa. Điều đó có nghĩa là chương trình này hoạt động, nó không phân biệt rõ ràng biến đã được khởi tạo hay chưa mà chỉ thay đổi giá trị của biến.
```js
tạo a = "before";
xuất a; // "before".
tạo a = "after";
xuất a; // "after".
```


Source: `lib/environment.dart`, phương thức truy cập biến (`define`)
```dart
dynamic get(Token name) {
  if (_values.containsKey(name.lexeme)) {
    return _values[name.lexeme];
  }
  
  throw RuntimeError(
    token: name,
    message: 'Biến "${name.lexeme}" chưa được định nghĩa.',
  );
}
```

Khi truy cập nếu không tồn tại chúng ta ném trả lại một lỗi runtime.

## Triển khai biến toàn cục
Tạo một instance của `Environment` trong lớp `Interpreter`

Source: `lib/interpreter.dart`
```dart
class Interpreter
    implements ExpressionVisitor<dynamic>, StatementVisitor<void> {
  Environment _environment = Environment();

  ...
}
```

Chúng ta lưu trữ biến trong môi trường đến khi nào mà `Interpreter` vẫn tồn tại và đang chạy. 

Ở bên trên chúng ta định nghĩa hai cú pháp mới: biểu thức `Variable` và câu lệnh `VariableDecl`, bây giờ hãy xử lí nó.

Source: `lib/interpreter.dart`, hàm xử lí `visitVariableDecl`
```dart
@override
void visitVariableDecl(VariableDecl variableDeclStmt) {
  dynamic value = null;
  if (variableDeclStmt.value != null) {
    value = _evaluate(variableDeclStmt.value!);
  }
  _environment.define(variableDeclStmt.name.lexeme, value);
}
```

Source: `lib/interpreter.dart`, hàm xử lí `visitVariable`
```dart
@override
dynamic visitVariable(Variable variable) {
  return _environment.get(variable.name);
}
```

Bây giờ chúng ta hoàn toàn có thể chạy câu lệnh sau
```js
tạo a = 1;
tạo b = 2;
xuất a + b;
```

Với một chút code về phần `Environment` ngôn ngữ chúng ta đã có thể **nhớ** được dữ liệu.

# Phép gán
Chúng ta đã có thể tạo được biến, điều tiếp theo là thay đổi biến đó theo ý muốn của mình. cú pháp mới của chúng ta như sau.

```js
expression => assignment ;
assignment => IDENTIFIER "=" expression ";"
           |  equality ;
```

Quy trình thêm một cú pháp mới rất đơn giản như mọi lần trước.

Source: `lib/grammar/expression.dart`
```dart
@Ast([
  "Binary   : Expression left, Token operator, Expression right",
  "Grouping : Expression expression",
  "Literal  : dynamic value",
  "Unary    : Token operator, Expression right",
  "Variable : Token name",
  "Assign   : Token name, Expression value" // Thêm dòng này
])
```

## Cú pháp phép gán
Tiếp tục thay đổi `Parser` theo quy tắc mới.

Source: `lib/parser.dart`
```dart
Expression _expression() {
  return _assignment();
}
```

Source: `lib/parser.dart`, hàm `_assignment` 
```dart
Expression _assignment() {
  final expression = _equality();

  if (_match([TokenType.equal])) {
    final equals = _previous();
    final value = _assignment();

    if (expression is Variable) {
      return Assign(expression.name, value);
    }

    _error(equals, 'Không thể gán giá trị nếu không đó không là biến.');
  }

  return expression;
}
```

## Thực thi phép gán

Triển khai visitor cho phép gán trong `Interpreter`.

Source: `lib/interpreter.dart`, hàm `visitAssign`
```dart
@override
dynamic visitAssign(Assign assign) {
  final value = _evaluate(assign.value);
  _environment.assign(assign.name, value);
  return value;
}
```

Thêm phương thức gán trong `Environment`

Source: `lib/environment.dart`
```dart
void assign(Token name, dynamic value) {
  if (_values.containsKey(name.lexeme)) {
    _values[name.lexeme] = value;
    return;
  }

  throw RuntimeError(
    token: name,
    message: 'Biến "${name.lexeme}" chưa được định nghĩa.',
  );
}
```

Xong !!! Chúng ta đã hoàn thành phép gán cho biến toàn cục, phần tiếp theo cùng thực hiện phạm vi hẹp hơn của biến khi nó ở trong một scope nhỏ hơn như ở trong hàm hay một câu lệnh điều kiện.

# Phạm vi
**Phạm vi** xác định một khu vực nơi tên ánh xạ tới một giá trị nhất định. Nhiều phạm vi cho phép **cùng một tên** để chỉ những thứ khác nhau trong các **ngữ cảnh khác nhau**. Ví dụ như:
```js
{
  tạo a = "first";
  xuất a; // "first".
}

{
  tạo a = "second";
  xuất a; // "second".
}
```

Đoạn code trên chứa hai khối code khác nhau cùng định nghĩa biến `a` nhưng ánh xạ đến các giá trị khác nhau.

![image.png](https://images.viblo.asia/4466f6b1-a77b-4f9d-9959-964aa6daf3e8.png)

Biến được tạo chỉ truy cập được trong phạm vi của nó. sau khi ra khỏi scope, biến sẽ được giải phóng bộ nhớ.
```dart
{
  tạo a = "in block";
}
xuất a; // Lỗi biến a đã bị hủy.
```

## Sự lồng nhau của khối lệnh

Sẽ thế nào nếu ta gọi hàm xuất trong một khối riêng như thế này?
```js
tạo globalScope = "Bên ngoài";

{
  tạo local = "Bên trong";
  {
      xuất global + local;
  }
}
```

ViL tìm kiếm hai biến `globalScope` và `localScope` trong scope hiện tại nhưng không có, tiếp theo nó sẽ tìm kiếm ở phạm vi rộng hơn, scope bao ngoài nó. A !!! tìm thấy biến `localScope` rồi, lấy giá trị của nó và tiếp tục tìm biến `globalScope` nhưng trong scope này vẫn không có, tiếp tục tìm rộng ra scope lớn hơn ta thấy `globalScope` đã được khai báo lấy giá trị và xuất phép cộng chuỗi ra màn hình.

Để thực hiện được hành vi này sửa lớp `Environment` thêm cho nó một môi trường "cha" bao quanh môi trường hiện tại.

Source: `lib/environment.dart`
```dart
class Environment {
  Environment([this.parent = null]);

  final Environment? parent;
  ...
}
```

Hàm truy cập và hàm gán chúng ta sửa lại kiểm tra biến cần truy cập hoặc chỉnh sửa cả ở trong môi trường `parent`

Source: `lib/environment.dart`, hàm `get`
```dart
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
```

## Cú pháp và thực thi khối lệnh
Với lớp `Environment` mới chúng ta hoàn toàn có thể triển khai khối lệnh. Quy tắc như sau:
```js
statement => printStatement
          |  expressionStatement
          |  block ;

block     => "{" declaration* "}" ;
```

Khai báo quy tắc mới và chạy `dart run build_runner build`

Source: `lib/grammar/expression.dart`
```dart
@Ast([
  'Print        : Expression expression',
  'Expr         : Expression expression',
  'VariableDecl : Token name, Expression? value',
  'Block        : List<Statement> statements',
])
```

Thay đổi `Parser`, bắt cú pháp của khai báo khối lệnh.

Source: `lib/parser.dart`
```dart
Statement _statement() {
  if (_match([TokenType.kXuat])) {
    return _printStatement();
  }
  if (_match([TokenType.leftBrace])) {
    return _blockStatement();
  }

  return _expressionStatement();
}

Statement _blockStatement() {
  final statements = <Statement>[];

  while (!_check(TokenType.rightBrace) && !_isAtEnd) {
    statements.add(_declaration());
  }
  _consume(TokenType.rightBrace, 'Thiếu dấu "}" sau khối lệnh.');

  return Block(statements);
}
```

Cuối cùng là thực thi khối code triển khai visitor của khối lệnh.

Source: `lib/interpreter.dart`
```dart
@override
void visitBlock(Block block) {
  Environment blockEnv = Environment(_environment);
  _environment = blockEnv;

  for (final statement in block.statements) {
    _execute(statement);
  }

  _environment = _environment.parent!;
}
```

HOÀN THÀNH!!! Hãy thử ngay đoạn code sau nếu bạn thực hiện đúng như mình sẽ có kết quả như bên dưới:
```js
{
  tạo a = " Scope: 1 ";
  tạo b = " Scope: 1 ";
  tạo c = " Scope: 1 ";
  {
      tạo b = " Scope: 2 ";
      tạo c = " Scope: 2 ";
      {
          tạo a = " Scope: 3 ";
          xuất a + b + c;
      }
      xuất a + b + c;
  }
  xuất a + b + c;
}
```
Kết quả
```dart
 Scope: 3  Scope: 2  Scope: 2 
 Scope: 1  Scope: 2  Scope: 2 
 Scope: 1  Scope: 1  Scope: 1 
```

# Tổng kết
Bài viết này chúng ta đã thực hiên được 3 thứ:
- Ngôn ngữ ViL đã lưu trữ được trạng thái
- Tạo ra biến và truy cập cũng như sửa giá trị của nó được
- Định nghĩa phạm vi truy cập của biến, tiền đề để thực hiện các câu lệnh điều kiện và vòng lặp, thứ mà chúng ta triển khai ở bài viết sau

# Mã nguồn
Bạn có thể theo dõi mã nguồn từng bài viết tại đây. Đừng ngại để lại cho mình một sao nhé 😍

ViL : https://github.com/definev/vil