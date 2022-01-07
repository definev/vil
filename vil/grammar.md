# Cú pháp của VL
Mỗi ngôn ngữ đều có một số cú pháp riêng và có nhưng điểm chung kế thừa lại của nhau.
VL có cú pháp theo phong cách ngôn ngữ C.

```js
program             => declaration* EOF ;

declaration         => variableDecl
                    | funcDecl
                    | statement ;

funcDecl            => "hàm" IDENTIFIER "(" IDENTIFIER* ")" "{" statement* "}" ;
variableDecl        => "tạo" IDENTIFIER ("=" expression)? ";" ;

statement           => expressionStatement
                    | printStatement
                    | ifStatement
                    | whileStatement
                    | block
                    | breakStatement ;

breakStatement      => "thoát" ";" ;

forStatement        => "lặp" "(" ( variableDecl | expressionStatement | ";" )
                    expression? ";"
                    expression? ")" statement ;

whileStatement      => "khi" "(" condition ")" statement ;

expressionStatement => expression ";" ;
printStatement      => "xuất" expression ";" ;
block               => "{" declaration* "}" ;

expression          => assignment ;
assignment          => ternary ( "=" assignment)+ ;
ternary             => or ( "?" ternary ":" ternary )+ ;
or                  => and ( "||" and)* ;
and                 => postfix ( "&&" postfix )* ;
postfix              => equality ( "++" | "--" )+ ;
equality            => comparison ( ( "==" | "!=" ) comparison )* ;
comparison          => term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
term                => factor ( ( "+" | "-" ) factor )* ;
factor              => unary ( ( "/" | "*" ) unary )* ;
call                => primary ( "(" arguments? ")" )* ;
unary               => ( "!" | "-" ) unary
                    | primary ;
primary             => số | chuỗi | "đúng" | "sai" | "(" expression ")"                   | IDENTIFIER ;
```