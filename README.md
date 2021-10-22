<img src="https://user-images.githubusercontent.com/62325868/138510986-cdfb34b2-12c4-4b83-947c-32735c6a7478.png" width="200">

# Giới thiệu chung về ViL
ViL là ngôn ngữ kịch bản (Scripting language). ViL là ngôn ngữ bậc cao, có kiểu khai báo động.
ViL với cú pháp thuần việt, giúp học sinh tiếp cận với lập trình dễ dàng hơn.
ViL cho phép sử dụng kí tự UTF-8 giúp định nghĩa các từ khóa có dấu.
Chương trình `hello world` trong ViL.
```js
// Hello world
xuất "Hello world!";
```

## Hàm build-in
ViL cung cấp hàm `xuất` để đưa dữ liệu ra console.
```js
tạo tên = "Tèo";
tạo tên_bạn = "Tí";
xuất tên " + là bạn của " + tên_bạn; // Tèo là bạn của Tí
```

## Kiểu dữ liệu
Trong ViL, các nguyên liệu cơ bản để tạo nên ngôn ngữ chỉ có một số kiểu.
- **boolean** Bạn không thể lâp trình logic mà thiếu đi kiểu dữ liệu logic được, cú pháp của nó chỉ đơn giản là `đúng` và `sai`
```js
đúng; // Tương ứng với true
sai;  // Tương ứng với false 
```
- **số** ViL chỉ có một kiểu số là số thập phân để đại diện cho cả số nguyên và số thập phân. Trong nhiều ngôn ngữ lập trình đầy đủ sẽ hỗ trợ rất nhiều kiểu số như số nhị phân, số bát phân, ... tuy nhiên để đơn giản thì ViL chỉ có một kiểu số.
```js
 12.34; // Số thập phân
 1234;  // Số nguyên
```
- **chuỗi** Chúng ta đã thấy nó ở ví dụ từ chương trình `Hello world`. Một chuỗi được định nghĩa trong cặp dấu ".
```js
"Con người";
"Con vật";
"1234"; // đây là kiểu chuỗi không phải kiểu số
""; // Chuỗi rỗng
```
- **rỗng** Một kiểu dữ liệu gây ra biết bao nhiêu bug cho lập trình viên. Hướng tới cú pháp thuần việt của ViL, kiểu dữ liệu `rỗng` được khai báo bằng từ khóa `rỗng`. Nó tương đương với `null` trong Java hay C.
```js
rỗng;
```

## Biểu thức
Nếu ví kiểu dữ liệu là những hạt nhân thì biểu thức chắc chắn là các phân tử tạo nên ViL.

### Biểu thức toán học
ViL cung cấp các toán tử cơ bản để cộng, trừ, nhân và chia.
```js
1 + 1;
2 - 2;
1 * 1;
2 / 2;
```
Đây là các toán tử được viết giữa hai số, ngoài ra còn hai kiểu nữa đó là toán tử đứng trước biến và toán tử đứng sau biến.

Toán tử `-` để đổi dấu.
```js
-số_âm;
```

ViL có hỗ trợ toán tử `++` và `--` như trong C ở cả trước và sau một biến kiểu số.
```js
xuất 4++; // 4
xuất ++4; // 5
```

### Biểu thức so sánh
Tiếp theo, chúng ta có một số toán tử khác luôn trả về kết quả Boolean. Chúng tacó thể so sánh các con số (và chỉ những con số), sử dụng Toán tử so sánh hơn kém.
```js
bé < hơn;
bé_hơn <= hoặc_bằng;
lớn > hơn;
lớn_hơn >= hoặc_bằng;
```

Chúng ta có thể so sánh hai kiểu dữ liệu bất kì và trả ra kết quả nó có bằng hoặc không bằng nhau hay không.
```js
// Cùng kiểu dữ liệu
1 == 2;    // sai
// Khác kiểu dữ liệu
100 == ""; // sai
2 != "2";  // đúng
```

### Biểu thức Logic
Với kiểu Boolean, ViL cung cấp prefix `!` để đảo trạng thái.
```js
!đúng; // sai
!sai;  // đúng
```

Có 2 kiểu so sánh được hỗ trợ:
- **và**
```js
đúng và sai; // sai
```
- **hoặc**
```js
đúng hoặc sai; // sai
```


## Khai báo biến
Giống như javascript, lua, python, ... Đây là cách khai báo một biến trong ViL.
```js
tạo tên = "Tèo"; // Kiểu chuỗi
tạo tuổi = 18;   // Kiểu số
```
Như bạn thấy thì chúng ta không cần khai báo kiểu dữ liệu của biến. Trình thông dịch của ViL sẽ tự hiểu kiểu dữ liệu là gì.

Để biểu thị cho giá trị null, ViL sử dụng từ khóa `rỗng`. Với việc gán dữ liệu vào biến ta sẽ thực hiện như sau.
```js
tạo a; // a == rỗng
a = 10;
```

## Câu lệnh điều kiện và vòng lặp
ViL cung cấp 2 từ khóa `nếu` <=> `if` và `thì` <=> `else`. Cách khai báo một điều kiện sẽ giống với ngôn ngữ họ C.
```js
nếu (tuổi_anh == tuổi_em) {
    xuất "sinh đôi";
} thì {
    xuất "Anh hơn em " + (tuổi_anh - tuổi_em) + " tuổi.";
}
```

Vòng lặp `while`: từ khóa `while` được thay thế bằng `khi` cú pháp như sau.
```js
khi (điều_kiện) {
    câu_lệnh;
}
```

Vòng lặp `for`: từ khóa `for` được thay thế bằng `lặp` cú pháp sẽ giống với hàm for của C. Tức là vòng for sẽ chia làm 3 phần.
```js
lặp (tạo i = 0;   i < 10;        i++) {
 //  khởi tạo  | điều kiện | sau điều kiện
}
```

## Khai báo hàm
Để khai báo một hàm, đơn giản bạn chỉ cần đặt từ khóa "hàm" phía trước tên hàm và thêm các tham số cho hàm trong cặp ngoặc.
Cú pháp khai báo hàm của ViL khá giống với các ngôn ngữ C, Java, Dart, Javascript ... nên nếu bạn có biết qua về những ngôn ngữ này thì ViL rất dễ tiếp cận.
Để trả về sử dụng từ khóa `return`, do một số từ khóa khi chuyển ngữ sang tiếng việt mình không thấy có từ một âm tiết nào phù hợp, để đơn giản mình sẽ vẫn giữ nguyên tiếng anh.
```js
hàm bao_giờ_bán_được_một_tỉ_gói_mè() {
    return "Dạ em bán kem đánh răng.";
}

hàm cộng(a, b) {
    return a + b;
}
```

## Khai báo lớp
ViL có hỗ trợ lập trình hướng đối tượng (OOP). 
Cách khai báo một lớp (class) trong ViL.  
```js
lớp Xe {
    // hàm `khởi_tạo` được chạy khi tạo một instance cho lớp.
    khởi_tạo(hãng, chủ_sở_hữu) {
        this.chủ_sở_hữu = chủ_sở_hữu
    }
    
    bóp_còi() {
        xuất chủ_sở_hữu + " Bíp!!!"
    }
}

tạo xe_tui = Xe("Tèo");
xe_tui.bóp_còi(); // Tèo Bíp!!!
```

### Kế thừa
Cú pháp khai báo kế thừa lớp trong ViL được định khai báo qua dấu `<`.
```js
lớp Mẹ {
    khởi_tạo(tên) {
        this.tên = tên;
    }
    
    nấu_ăn() {
        return tên + " đang nấu ăn";
    }
}

lớp ConGai < Mẹ {
    quay_tiktok() {
        xuất "Quay tiktok chủ đề " + nấu_ăn();
    }
} 

tạo con_gái = ConGai("Nở");
con_gái.quay_tiktok(); // Quay tiktok chủ đề Nở nấu ăn
```
