# Cú pháp của VL
Mỗi ngôn ngữ đều có một số cú pháp riêng và có nhưng điểm chung kế thừa lại của nhau.
VL có cú pháp theo phong cách ngôn ngữ C.

```js
expression     => literal
               | unary
               | binary
               | grouping ;

literal        => số | chuỗi | "đúng" | "sai" | "rỗng" ;
grouping       => "(" expression ")" ;
unary          => ( "-" | "!" ) expression ;
binary         => expression operator expression ;
operator       => "==" | "!=" | "<" | "<=" | ">" | ">="
               | "+"  | "-"  | "*" | "/" ;
```