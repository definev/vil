enum TokenType {
  // kí tự
  /* { */                  leftBrace,
  /* ( */                  leftParen,
  /* } */                  rightBrace,
  /* ) */                  rightParen,
  /* , */                  comma,
  /* . */                  dot,
  /* - -- */               minus, minusMinus,
  /* + ++ */               plus, plusPlus,
  /* ; */                  semicolon,
  /* / */                  slash,
  /* * */                  star,
  /* ? */                  question,
  /* : */                  colon,
  /* && */                 kAnd,
  /* || */                 kOr,

  // so sánh
  /* ! != */               bang, bangEqual,
  /* = == */               equal, equalEqual,
  /* > >= */               greater, greaterEqual,
  /* < <= */               less, lessEqual,

  // Từ khóa
  /* while - khi */        kKhi,
  /* for - lặp */          kLap,
  /* var - tạo */          kTao,
  /* print - in */         kIn,
  /* true - đúng */        kDung,
  /* false - sai */        kSai,
  /* if - nếu */           kNeu,
  /* else - hoặc */        kHoac,
  /* break - thoát */      kThoat,
  /* class - lớp */        kLop,
  /* fun - hàm */          kHam,
  /* null - rỗng */        kRong,
  /* super - cha */        kCha,
  /* this - self */        kSelf,
  /* return - trả */       kTra,
  /* string */             kChuoi,
  /* number */             kSo,

  // Tên biến / tên class / tên hàm
  /* identifier */          identifier,

  eof,
}
