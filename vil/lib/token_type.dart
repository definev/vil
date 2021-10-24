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

  eof,
}
