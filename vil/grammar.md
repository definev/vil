# Cú pháp của ViL
Mỗi ngôn ngữ đều có một số cú pháp riêng và có nhưng điểm chung kế thừa lại của nhau.
ViL có cú pháp theo phong cách ngôn ngữ C.

```js
program             => declaration* EOF ;

declaration         => variableDecl
                    | funcDecl
                    | classDecl
                    | statement ;


classDecl           => "lớp" IDENTIFIER "{" *functions "}" ;
functions           => IDENTIFIER "(" parameters? ")" block ;
parameters          => IDENTIFIER ( "," IDENTIFIER )* ;

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
printStatement      => "in" expression ";" ;
block               => "{" declaration* "}" ;

expression          => assignment ;
assignment          => ( call "." )? IDENTIFIER "=" assignment 
                    | ternary ;
ternary             => or ( "?" ternary ":" ternary )+ ;
or                  => and ( "||" and)* ;
and                 => postfix ( "&&" postfix )* ;
postfix              => equality ( "++" | "--" )+ ;
equality            => comparison ( ( "==" | "!=" ) comparison )* ;
comparison          => term ( ( ">" | ">=" | "<" | "<=" ) term )* ;
term                => factor ( ( "+" | "-" ) factor )* ;
factor              => unary ( ( "/" | "*" ) unary )* ;
call                => primary ( "(" arguments? ")" | "." INDENTIFIER )*  ;
unary               => ( "!" | "-" ) unary
                    | primary ;
primary             => số | chuỗi | "đúng" | "sai" | "(" expression ")"                   | IDENTIFIER ;
```