# Ngôn ngữ lập trình VL.
Dự án tạo ra ngôn ngữ lập trình mới với cú pháp tiếng việt, bạn có thể sử dụng ngôn ngữ khác để tạo trình thông dịch cho ngôn ngữ VL, trong dự án này tôi sẽ sử dụng dart để triển khai trình thông dịch. VL được tạo ra với chuỗi bài viết về cách tạo trình thông dịch của mình.

## Giới thiệu về cú pháp của VL 😂
---
VL là một ngôn ngữ kịch bản (Scripting language). Với cú pháp theo phong cách của ngôn ngữ C.

### <b>Kiểu dữ liệu</b>

VL có sẵn 2 kiểu dữ liệu nguyên thủy: chuỗi (string), số (number).
VL là ngôn ngữ kiểu động tức là bạn không cần phải định kiểu cho biến, trình thông dịch sẽ tự suy kiểu của biến.

### <b>Khai báo biến</b>

```bash 
tạo tên = "Bùi Đại Dương";
```
Từ khóa "tạo" để khai báo biến, tiếp sau đó là tên của biến. VL hỗ trợ kí tự UTF-8, tên biến không được chứa khoảng trắng.

### <b>Hàm build-in</b>
VL có sẵn hàm in ra màn hình theo cú pháp.
```
tạo tên = "Tôi";
xuất tên + " chào thế giới!"; // Tôi chào thế giới!
```
