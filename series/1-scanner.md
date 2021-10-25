# Cài đặt Dart SDK
Trước khi vào phần Scanning, nếu chưa cài Dart hãy thực hiện theo hướng dẫn tại đây. https://dart.dev/get-dart

Sau khi tải theo hướng dẫn mở terminal và nhập, nếu thành công sẽ trả ra giống như này.
```bash
dart --version 
Dart SDK version: 2.14.4 (stable) 
```

## Setup project
Tạo thư mục `vil`, sau đó tạo file config `pubspec.yaml`:
```yaml
name: vil

environment:
    sdk: ">=2.14.0 <3.0.0"
```

Tạo thư mục `lib` trong đây sẽ chứa code của chúng ta. Sau khi hoàn thành ta sẽ được cấu trúc đơn giản như này là đã xong.
```
vil
|--lib
|pubspec.yaml
```

# Bộ khung của trình thông dịch
Trước khi triển khai tính năng, chúng ta cần tạo nên bộ khung của trình thông dịch. Bắt đầu từ class `Vil`.

Source: `lib/vil.dart`
```dart
class Vil {
  static void run(String source) {}

  static void runFile(String url) {}

  static void runPrompt() {}
}
```
ViL là ngôn ngữ kịch bản đương nhiên sẽ hỗ trợ chạy trực tiếp từ mã. ViL hỗ trợ thêm 2 kiểu chạy, chạy từ file và chạy trực tiếp trên command-line.
## Chạy qua file
Với Dart, chúng ta đọc file dễ dàng với phương thức `readAsStringSync()`.

Source: `lib/vil.dart`
```dart
import "dart:io";

...
static void runFile(String fileSource) {
    File file = File(fileSource);
    String source = file.readAsStringSync();
    run(source);
}
...
```
## Chạy qua command-line
Chúng ta đặt một vòng lặp vô hạn, đọc từng dòng lệnh được nhập trên command-line và chạy qua phương thức `run`.

Source: `lib/vil.dart`
```dart
  ...
static void runPrompt() {
    while (true) {
        stdout.write("> ");
        String? line = stdin.readLineSync();
        
        if (line != null) run(line);
    }
}
  ...
```

## Chạy qua mã nguồn
Hiện tại bộ khung của chúng ta chưa có gì để xử lí. Phương thức `run` đơn giản chỉ in ra mã nguồn mà nó nhận vào.

Source: `lib/vil.dart`
``` dart
...
class Vil {
 static void run(String source) {
    print(source);
  }
...
```

## Xử lí lỗi
Trong lúc viết code lỗi là một điều tất yếu không tránh khỏi, bây giờ chúng ta cần một cơ chế bắt lỗi đủ đơn giản để thực hiện mà vẫn cung cấp đầy đủ thông tin cần thiết để sửa lỗi đó. Bắt đầu bằng việc thêm một biến `hadError` giữ trạng thái lỗi của chương trình.
 Source: `lib/vil.dart`
 ```dart
 class Vil {
    static bool hadError = false;
    ...
}
 ```

Giờ ta thêm phương thức `error` với 5 biến số chứ thông tin chính để có thể sửa lỗi đó.
- `line`: Dòng xảy ra lỗi
- `col`: Cột xảy ra lỗi.
- `errorIn`: Xác định lỗi xảy ra trong quá trình nào.
- `errorAt`: Xác định kí tự bị lỗi, đôi khi không cần cung cấp vì có thể là lỗi logic không phải lỗi cú pháp.

Kết hợp lại ta được.

Source: `lib/vil.dart`, ở trong class `Vil` ta thêm:
```dart
static void error({
    required String errorIn,
    required int line,
    required int col,
    required String message,
    String? errorAt,
}) {
    print('|$errorIn| [$line, $col]: Lỗi $errorAt: $message');
    hadError = true;
}
```

Ok vậy là đã tạm xong phần xương của ngôn ngữ, chúng ta chuẩn bị đến phần sụn, giúp chuyển từ mã nguồn sang các Token mà trình thông dịch của chúng ta hiểu được - **Scanner**.

# Scanning là gì?
Scanning - hay còn có một tên gọi khác nghe sang chảnh hơn là Lexer, là bước đầu tiên trong cuộc hành trình của chúng ta.
Scanning giúp phân tích từ code sang token chuẩn bị bước tiếp theo.

# Token
### Lexeme
Đây là một dòng lệnh ViL.
```js
xuất "Hello world!";
```
Đoạn mã sau khi qua bước Scanning, ta lọc ra được các lexeme:
- `xuất` `"Hello world!"` `;`

Lexeme có thể dịch nôm na ra là cụm từ có nghĩa. 
Lexeme ở trong Token, từ `xuất` nếu đứng riêng lẻ từng kí tự `x`, `u`, `ấ`, `t` sẽ không có nghĩa nhưng khi kết hợp lại ta lại được một cụm có nghĩa và tạo ra một token.

### Token type
Token type giúp phân loại token, giúp trình phân tích cú pháp (**Parser**) mà trong bài sau chúng ta sẽ thực hiện hiểu được "Ô đây là token `>` phải gom nó vào phép so sách thôi ..." 

Trình phân tích cú pháp có thể phân loại mã thông báo từ lexeme thô bằng cách so sánh các chuỗi, nhưng điều đó chậm và hơi "xấu". Thay vào đó, tại thời điểm chúng ta nhận ra lexeme, chúng ta cũng nhớ nó đại diện cho loại lexeme nào. Chúng tôi có một loại khác nhau cho mỗi từ khóa, toán tử, bit dấu câu và loại chữ.

Tạo file `token_type.dart` trong thư mục `lib`.

Source: `lib/token_type.dart`
```dart
enum TokenType {
  // kí tự
  /* { */          leftBrace,
  /* ( */          leftParen,
  /* } */          rightBrace,
  /* ) */          rightParen,
  /* , */          comma,
  /* . */          dot,
  /* - -- */       minus, minusMinus,
  /* + ++ */       plus, plusPlus,
  /* ; */          semicolon, 
  /* / */          slash,
  /* * */          star,
  /* ? */          question,
  /* : */          colon,
  /* && */         kAnd,
  /* || */         kOr,

  // so sánh
  /* ! != */       bang, bangEqual,
  /* = == */       equal, equalEqual,
  /* > >= */       greater, greaterEqual,
  /* < <= */       less, lessEqual,

  // Từ khóa
  /* while */      kKhi, 
  /* for */        kLap, 
  /* var */        kTao, 
  /* print */      kXuat, 
  /* true */       kDung, 
  /* false */      kSai, 
  /* if */         kNeu, 
  /* else */       kHoac,
  /* class */      kLop, 
  /* fun */        kHam, 
  /* null */       kRong, 
  /* super */      kCha,
  /* this */       kThis,
  /* return */     kReturn,
  /* string */     kChuoi,
  /* number */     kSo, 

  // Tên biến / tên class / tên hàm
  /* identifier */ identifier,

  // Kết thúc mã
  eof,
}
```

### Giá trị của token (Literal)
Với hai Token đặc biệt như `kChuoi` và `kSo` chúng ta thu thập giá trị của chúng ngay tại bước `scanner` và đến công đoạn chạy mã sẽ lấy giá trị ra sử dụng ngay được.

### Tổng kết lại Token
Cùng với ba thông tin trên và vị trí hàng cột, ta tạo ra một class tổng hợp lại gọi là `Token`.

Tạo file `token.dart` tại thư mục `lib`.

Source: `lib/token.dart`
```dart
import 'package:vil/token_type.dart';

class Token {
  final TokenType type;
  final int line;
  final int col;
  final String lexeme;
  final dynamic literal;

  const Token({
    required this.type,
    required this.line,
    required this.col,
    required this.lexeme,
    required this.literal,
  });

  @override
  String toString() {
    return "[$line, $col]: $type | lexeme: $lexeme | literal: $literal";
  }
}
```

## Class Scanner
Khởi tạo class `Scanner`. Tạo file `scanner.dart` trong thư mục `lib`

Source: `lib/scanner.dart`
```dart
class Scanner {
    Scanner(this.source);
    final String source;
}
```

### Triển khai Scanner
Cách tiếp cận của chúng ta là sẽ chạy từ đầu đến cuối của mã nguồn, xem xét từng kí tự tại vị trí xét và thêm từng token tương ứng với loại kí tự đó. 

> Trong dart, đặt dấu `_` ở đầu tên biến là khai báo biến đó với scope là private

Trước khi thực hiện ta cần thêm hai biến `_line` và `_col` để lưu giữ vị trí dòng cột của mã.

Source: `lib/scanner.dart`
```dart
class Scanner {
  ...
    // Mảng token
    List<Token> _tokens = [];
    // Vị trí bắt đầu
    int _startPosition = 0;
    // Vị trí hiện tại
    int _currentPosition = 0;

    int _col = 1;
    int _line = 1;
}
```

Bắt đầu với một vòng lặp và lặp đến khi tới kí tự cuối cùng.

Source: `lib/scanner.dart`
```dart
class Scanner {
    ...
    List<Token> scan() {
        while (!_isAtEnd) {
            _startPosition = _currentPosition;
            _scanToken();
        }
        
        return _tokens;
    }
    
    ...
}
```

Để kiểm tra đã đến cuối ta kiểm tra vị trí hiện tại.

Source: `lib/scanner.dart`
```dart
bool get _isAtEnd => _currentPosition >= source.length;
```

### Kiểm tra kí tự
Việc đầu tiên là lấy kí tự hiện tại là gì.

Source: `lib/scanner.dart`
```dart
String _autoIncrementPeek() {
    _col++;
    return source[_currentPosition++];
}

void _scanToken() {
    String current = _autoIncrementPeek();
}
```

Hàm `_autoIncrementPeek` lấy kí tự hiện tại là di chuyển đến vị trí tiếp theo đồng thời tăng vị trí cột thêm một đơn vị.

#### Thêm token
Hàm thêm Token.

Source: `lib/scanner.dart`
```dart
void _addToken(TokenType type, {dynamic literal}) {
    _tokens.add(
        Token(
            type: type,
            col: _col - (_currentPosition - _startPosition - 1),
            line: _line,
            lexeme: source.substring(_startPosition, _currentPosition),
            literal: literal,
        ),
    );
}
```

#### Token đơn kí tự
Token đơn kí tự là các dấu, toán tử, như trên file `token_type.dart` đã phân loại. Với loại kí tự này ta chỉ cần xét kí tự đó có phải kí tự hiện tại hay không.

Source: `lib/scanner.dart`, hàm `_scanToken`
```dart
String current = _autoIncrementPeek();

switch (current) {
    case '{':
        _addToken(TokenType.leftBrace);
        break;
    case '}':
        _addToken(TokenType.rightBrace);
        break;
    case '(':
        _addToken(TokenType.leftParen);
        break;
    case ')':
        _addToken(TokenType.rightParen);
        break;
    case ',':
        _addToken(TokenType.comma);
        break;
    case '.':
        _addToken(TokenType.dot);
        break;
    ...
    default:
}
```

Tương tự như vậy với bạn làm tương tự với các token đơn kí tự khác như:  `-`, `+`, `;`, `/`, `*`, `?`, `:`.

#### Token hai kí tự
Với hai token có chung tiền tố ví dụ như `-` và `--`, kiểm tra tiếp kí tự tiếp theo.

Source: `lib/scanner.dart`, hàm `_scanToken`
```dart
    case '-':
        if (_peek() == '-') {
        _autoIncrementPeek();
        _addToken(TokenType.minusMinus);
        return;
        }
        _addToken(TokenType.minus);
        break;
```

Hàm `_peek` có nhiệm vụ tương tự như hàm `_autoIncrementPeek` nhưng nó không thay đổi vị trí hiện tại mà chỉ lấy ra giá trị hiện tại. 

Source: `lib/scanner.dart`
```dart
String _autoIncrementPeek() {...}

String _peek() => source[_currentPosition];
```

Bạn hãy tự thực hiện tương tự với các cặp token so sánh nhé.

#### Token chuỗi
Token chuỗi bắt đầu bằng dấu `"` và kết thúc bằng nó.

Để kiểm tra kí tự có đúng không ta sử dụng hàm `_match`.

Source: `lib/scannner.dart`, sau hàm `_peek`
```dart
bool _match(String current) {
    if (_peek() == current) {
        _currentPosition++; // Đúng coi như đã kiểm tra kí tự này chuyển đến vị trí tiếp theo
        return true;
    }
    return false;
}
```

Source: `lib/scannner.dart`
```dart
void _addStringToken() {
    while (!_isAtEnd && !_match('"')) {
        _autoIncrementPeek();
    }

    if (_isAtEnd) error('Đã đến cuối file, phân tích chuỗi thất bại.');
    
    _addToken(
        TokenType.kChuoi,
        literal: source.substring(_startPosition + 1, _currentPosition - 1),
    );
}

void _scanToken() {
...
case '"':
    _addStringToken();
    break;
...
```

Đến đây chúng ta đã sử dụng cơ chế báo lỗi của ViL nếu phân tích chuỗi thất bại. Hàm `error` như sau.

Source: `lib/scannner.dart`
```dart
void error(String message) {
    Vil.error(errorIn: 'SCANNER', line: _line, col: _col, message: message);
}
```

Với gía trị chuỗi ta bỏ hai dấu ngoặc, cắt mã gốc tại vị đầu + 1 và vị trí hiện tại trừ 1. Chúng ta đã phân tích được token chuỗi, Hooray!!!

#### Kí tự đặc biệt
Với kí tự ví dụ như xuống dòng, tab, khoảng trắng, ta không làm gì và chỉ ... mặc kệ nó. Một số ngôn ngữ như Python không sử dụng dấu ngoặc để phân định block code mà sử dụng khoảng trắng để phân biệt nhưng ViL thì không nên ta chỉ bỏ qua nó.
À không quên điều chỉnh hàng và cột qua mỗi khoảng trắng.

Source: `lib/scannner.dart`, hàm `_scanToken`, trong `switch` ... `case`.
```dart
...
case ' ':
    _col++;
    break;
case '\n':
    _col = 1;
    _line++;
    break;
case '\t':
    _col += 2;
    break;
case '\r':
    break;
...
```

#### Token từ khóa và identifier (tên hàm, tên biến, tên lớp)
Với loại token này chúng ta có thể sử dụng cách cũ xét từng kí tự nhưng hãy nghĩ xem với hơn 10 từ khóa và tổ hợp chữ cái khác nhau, cách này không hề hiệu quả.
Thay vào đó ta lưu giá trị lexeme tương ứng từng từ khóa vào một Map có key là lexeme và value chính là token type của keyword đó, sau đó truy xuất vào Map nếu có giá trị thì thêm một token từ khóa.

Source: `lib/scanner.dart`
```dart
class Scanner {
    ...
    
    Map<String, TokenType> _keywords = {
        "khi": TokenType.kKhi,
        "lặp": TokenType.kLap,
        "tạo": TokenType.kTao,
        "xuất": TokenType.kXuat,
        "đúng": TokenType.kDung,
        "sai": TokenType.kSai,
        "nếu": TokenType.kNeu,
        "hoặc": TokenType.kHoac,
        "lớp": TokenType.kLop,
        "hàm": TokenType.kHam,
        "rỗng": TokenType.kRong,
        "cha": TokenType.kCha,
        "this": TokenType.kThis,
        "return": TokenType.kReturn,
        "&&": TokenType.kAnd,
        "||": TokenType.kOr,
     };
}
```

Tiếp theo nếu không phải trường hợp đơn kí tự hay đa kí tự nào định sẵn thì đó sẽ là một tên lớp, tên biến hoặc tên hàm nào đó mà phần sau `parser` và `interpreter` sẽ xử lí trong runtime.

Source `lib/scanner.dart` hàm `_scanToken`, trong `switch` ... `case`.
```dart
    default:
        if (_isNumber(current)) {
            _addNumberToken();
        } else if (_isAlphabet(current)) {
            _identifier();
        }
```

Để kiểm tra kí tự có hợp lệ hay không, chúng ta sử dụng `RegExp` để kiểm tra chuỗi nhập vào.
Rất may dart hỗ trợ `RegExp` đầy đủ và đây là hàm kiểm tra của chúng ta.

Source `lib/scanner.dart`, thêm sau hàm `_peek`
```dart
bool _isNumber(String number) => RegExp(r'\d').hasMatch(number);

bool _isAlphabet(String source) =>
    RegExp(r'[a-zA-Z\u00C0-\u024F\u1E00-\u1EFF_]').hasMatch(source);
```

Ở đây mình sử dụng cú pháp `RegExp` đơn giản để tách.
- `\d`: Tất cả các số từ 0-9
- `[a-z]`, `[A-Z]`, `[\u00C0-\u024F]`, `[\u1E00-\u1EFF]`: Từ a-z, A-Z, tập hợp các chữ có dấu mà chúng ta cho phép đặt tên biến.
- `_`: Dấu gạch dưới.
- Bạn có thể tìm hiểm thêm về  `RegExp` tại: https://regexr.com/

Chúng ta ưu tiên kiểm tra số trước để lấy ra token số. Kiểm tra từng kí tự tiếp theo có là số hay không và cuối cùng chuyển từ chuỗi sang số để lưu token số.

Source `lib/scanner.dart`, thêm sau hàm `_addStringToken`
```dart
void _addNumberToken() {
    while (!_isAtEnd && _isNumber(_peek())) {
        _autoIncrementPeek();
    }
    if (_isAtEnd) error('Đã đến cuối file, phân tích số thất bại.');

    _addToken(
        TokenType.kSo,
        literal: int.parse(
            source.substring(_startPosition, _currentPosition),
        ),
    );
}
```

Tương tự với cách add token số, tuy nhiên token identifier ta chấp nhận cả số và chữ có dấu.
Bạn nhớ chúng ta vừa thêm một Map `_keywords` ở phía trên chứ, nếu lexeme của identifer có trong map chúng ta đã tìm được một keyword rồi thêm vào mảng `_token` thôi.

Source `lib/scanner.dart`, thêm sau hàm `_addStringToken`
```dart
void _identifier() {
    while (!_isAtEnd && _isNumberAlphabet(_peek())) {
        _autoIncrementPeek();
    }

    if (_isAtEnd) error('Đã đến cuối file, phân tích tên biến thất bại.');

    if (_keywords[source.substring(_startPosition, _currentPosition)] != null) {
        _addToken(_keywords[source.substring(_startPosition, _currentPosition)]!);
    } else {
        _addToken(TokenType.identifier);
    }
}
```

Source `lib/scanner.dart`, thêm sau hàm `_isAlphabet`
```dart
bool _isNumberAlphabet(String source) =>
    _isNumber(source) || _isAlphabet(source);
```

Ok vậy ta đã xử lí xong phần `scanner`. Quay lại file `vil.dart` và thêm nó vào hàm `run` nào.

Source: `lib/vil.dart`
```dart
static void run(String source) {
    Scanner scanning = Scanner(source);
    List<Token> tokens = scanning.scan();
    for (final token in tokens) {
        print(token);
    }
}
```

Mọi chương trình dart giống như C, khởi đầu tại hàm `main`, tạo một hàm `main` và chạy thử thành quả của chúng ta nào.

Source: `lib/vil.dart`
```dart
void main() {
  Vil.runPrompt();
}
```

Trong terminal chạy lệnh `dart run liv/vil.dart`, nhập thử câu lệnh "Hello world" vào ta được:
```bash
lib/vil.dart: Warning: Interpreting this as package URI, 'package:vil/vil.dart'.
definev@ubuntu:/media/definev/Program/crafting-interpreters/vil/vil$ dart run lib/vil.dart
lib/vil.dart: Warning: Interpreting this as package URI, 'package:vil/vil.dart'.
> xuất "Hello world";
[1, 2]: TokenType.kXuat | lexeme: xuất | literal: null
[1, 7]: TokenType.kChuoi | lexeme: "Hello world" | literal: Hello world
[1, 20]: TokenType.semicolon | lexeme: ; | literal: null
> 
```

Yessss, ngôn ngữ ViL của chúng ta bắt đầu hình thành những tế bào đầu tiên rồi.