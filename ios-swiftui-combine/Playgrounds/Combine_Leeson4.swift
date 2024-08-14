//
//  Combine_Leeson4.swift
//  ios-swiftui-combine
//
//  Created by LinhNguyen DGWA on 14/8/24.
//

import Foundation

/***
 1. publisher
 Ta xem qua các ví dụ sau:

 let publisher1 = "Hello world".publisher
 let publisher2 = (1...19).publisher
 let publisher3 = ["A": 1, "B": 2, "C": 3].publisher
 Bạn đã bắt gặp chúng ở các bài đầu tiên khi giới thiệu về Combine rồi. Vậy với toán tử publisher sử dụng cho một số kiểu dữ liệu Collection (Array, String, Set, Dictionary … ) thì chúng ta có được một Publisher, với:

 Input chính là kiểu dữ liệu của phần tử trong đó
 Failure là Never
 Ngoài ra, bạn có thể tạo các extension để custom và đặt tên các Publisher đó publisher . Nhằm mục đích đồng nhất cách code trong Combine.

 2. Collecting values
 Tư tưởng lớn ở đây, chính là bạn mệt mỏi khi phải làm việc với từng giá trị đơn riêng lẻ. Đôi lúc bạn muốn tổng hợp lại và xử lý nhanh gọn 1 lần nhiều giá trị. Thì các operator liên quan tới collecting sẽ giúp đỡ bạn.

 Cách dùng đơn giản, cầm đầu thèn publisher nào đó. và gọi function sau:

 Gôm hết các giá trị lại 1 lần
 .collect()
 Gôm theo số lượng chỉ định
 .collect(2)
 Về bản chất, nó cũng trả về là một Publisher mà thôi. Nên sau đó bạn có thể subscribe như bình thường.

 Ví du code mình hoạ

 var subscriptions = Set<AnyCancellable>()
 let publisher = (1...99).publisher
 publisher
   .collect()
   .sink(receiveCompletion: { complete in
     print(complete)
   }) { value in
     print(value)
   }
   .store(in: &subscriptions)
 Với ví dụ trên, ta được 1 Array Int thay vì từng Int khi sử dụng .collect(). Còn nếu dùng collect(3), thì ta được mỗi giá trị là 1 Array Int với 3 phần tử Int.

 3. Mapping values
 Đây là những toán tử chuyển đổi kiểu giá trị này thành kiểu giá trị khác. Dựa theo việc ánh xạ từ phần tử này sang phần tử kia. Với một quy luật nào đó mà mình đặt ra.

 Ví dụ: Có 1 danh sách tên học sinh, mỗi cái tên ứng với một loài hoa -> sau khi biến đổi thì ta có 1 danh sách các loài hoa. Nghe hơi vô lý phải không nào 😀

 3.1. map
 Xem đoạn code sau và hình dung nha

 var subscriptions = Set<AnyCancellable>()
 let formatter = NumberFormatter()
 formatter.numberStyle = .spellOut
     [22, 7, 1989].publisher
         .map {
             formatter.string(for: NSNumber(integerLiteral: $0)) ?? "" }
         .sink(receiveValue: { print($0) })
         .store(in: &subscriptions)
 Giải thích:

 Tạo ra một formatter của Number. Nhiệm vụ nó biến đổi từ số thành chữ
 Tạo ra 1 publisher từ một array Integer
 Sử dụng toán tử .map để biến đối tường giá trị nhận được thành kiểu string
 Các toán tử còn lại thì như đã trình bày các phần trước rồi
 Toán tử map giúp biến đổi kiểu giá trị Output của Publisher.

 3.2. Map key paths
 Bổ sung cho toán tử map trên thì Combine hỗ trợ cho chúng ta thêm 3 function của nó như sau:

 map<T>(_:)
 map<T0, T1>(_:_:)
 map<T0, T1, T2>(_:_:_:)
 Thay vì tấn công biến đổi chính đối tượng khi nó là Output của 1 publisher nào đó. Thì ta có thể biến đổi publisher đó thành một publisher khác. Mà phát ra kiểu giá trị mới, chính là kiểu giá trị của 1 trong các thuộc tính đối tượng. Xem ví dụ đi cho chắc.

 struct Dog {
   var name: String
   var age: Int
 }
 let publisher = [Dog(name: "MiMi", age: 3),
                  Dog(name: "MiLy", age: 2),
                  Dog(name: "PoChi", age: 1),
                  Dog(name: "ChiPu", age: 3)].publisher
 publisher
   .map(\.name)
   .sink(receiveValue: { print($0) })
   .store(in: &subscriptions)
 Giải thích:

 Ta có class Dog
 Tạo 1 publisher từ việc biến đổi 1 Array Dog. Lúc này Output của publisher là Dog
 Sử dụng map(\.name) để tạo 1 publisher mới với Output là String. String là kiểu dữ liệu cho thuộc tính name của class Dog
 sink và store như bình thường
 3.3. tryMap
 Khi bạn làm những việc liên quan tới nhập xuất, kiểm tra, media, file … thì hầu như phải sử dụng try catch nhiều. Nó giúp cho việc đảm bảo chương trình của bạn không bị crash. Tất nhiên, nhiều lúc bạn phải cần biến đổi từ kiểu giá trị này tới một số kiểu giá trị mà có khả năng sinh ra lỗi. Khi đó bạn hãy dùng tryMap như một cứu cánh.

 Khi gặp lỗi trong quá trình biến đổi thì tự động cho vào completion hoặc error . Bạn vẫn có thể quản lí nó và không cần quan tâm gì tới bắt try catch …

 Xem ví dụ sau:

 Just("Đây là đường dẫn tới file XXX nè")
         .tryMap { try FileManager.default.contentsOfDirectory(atPath: $0) }
         .sink(receiveCompletion: { print("Finished ", $0) },
               receiveValue: { print("Value ", $0) })
         .store(in: &subscriptions)
 Giải thích:

 Just là 1 publisher, sẽ phát ra ngay giá trị khởi tạo
 sử dụng tryMap để biến đổi Output là string (hiểu là đường dẫn của 1 file nào đó) thành đối tượng là file (data)
 Trong closure của tryMap thì tiến hành đọc file với đường dẫn kia
 Nếu có lỗi (trong trường hợp ví dụ) thì sẽ nhận được ở completion với giá trị là failure
 OKE, rất khoẻ phải không nào. Giờ thì yêu Combine cmnr!

 3.4. flatMap
 Trước tiên thì ta cần hệ thống lại một chú về em map và em flatMap

 map là toán tử biến đổi kiểu dữ liệu Output. Ví dụ: Int -> String…
 flatMap là toán tử biến đổi 1 publisher này thành 1 publisher khác
 Mới hoàn toàn
 Khác với thèn publisher gốc kia
 Thường sử dụng flatMap để truy cập vào các thuộc tính trong của 1 publisher. Để hiểu thì bạn xem minh hoạ đoạn code sau:

 Trước tiên tạo 1 struct là Chatter, trong đó có name và message. Chú ý, message là một CurrentValueSubject, nó chính là publisher.

 public struct Chatter {
     public let name: String
     public let message: CurrentValueSubject<String, Never>
     public init(name: String, message: String) {
         self.name = name
         self.message = CurrentValueSubject(message)
     }
 }
 Ta tạo các đối tượng sau, là 2 nhân vật sẽ tham gia đàm thoại với nhau:

 let teo = Chatter(name: "Tèo", message: " --- TÈO đã vào room ---")
 let ti = Chatter(name: "Tí", message: " --- TÍ đã vào room ---")
 Tạo room chát là một publisher với PassthroughSubject với Output là Chatter và không bao giờ lỗi. Tiến hành subscribe nó. Nhưng trước tiên là phải sử dụng flatMap để biến đổi pulisher với kiểu Output Chatter thành publisher với kiểu Output là  String. Chúng ta chỉ subscribe publisher String đó thôi.

 let chat = PassthroughSubject<Chatter, Never>()

     chat
         .flatMap { $0.message }
         .sink { print($0) }
         .store(in: &subscriptions)
 OKE, chát thôi

 //let's go chat

     //1 : Tèo vảo room
     chat.send(teo)
     //2 : Tèo hỏi
     teo.message.value = "TÈO: Tôi là ai? Đây là đâu?"
     //3 : Tí vào room
     chat.send(ti)
     //4 : Tèo hỏi thăm
     teo.message.value = "TÈO: Tí khoẻ không."
     //5 : Tí trả lời
     ti.message.value = "TÍ: Tao không khoẻ lắm. Bị Thuỷ đậu cmnr mày."

     let thuydau = Chatter(name: "Thuỷ đậu", message: " --- THUỶ ĐẬU đã vào room ---")
     //6 : Thuỷ đậu vào room
     chat.send(thuydau)
     thuydau.message.value = "THUỶ ĐẬU: Các anh gọi em à."

     //7 : Tèo sợ
     teo.message.value = "TÈO: Toang rồi."
 Bạn run code vào xem kết quả. Mình sẽ giải thích như sau:

 chat là 1 publisher, chúng ta send các giá trị của nó đi (Chatter). Đó là các phần tử được join vào room
 Vì mỗi phần tử đó có thuộc tính là 1 publisher (messgae). Để đối tượng chatter có thể phát tin nhắn đi, thay vì phải join lại room.  Nên khi subscribe nếu không dùng flatMap thì sẽ ko nhận được giá trị từ các stream của các publisher join vào trước.
 flatMap giúp cho việc hợp nhất các stream của các publisher thành 1 stream và đại diện chung là 1 publisher mới với kiểu khác các publisher kia.
 Tất nhiên, khi các publisher riêng lẻ send các giá trị đi, thì chat vẫn nhận được và hợp chất chúng lại cho subcriber của nó.
 Cuối câu chuyện bạn cũng thấy là THUỶ ĐẬU đã join vào. Vì vậy, muốn khống chế số lượng publisher thì sử dụng thêm tham số maxPublishers

       chat
         .flatMap(maxPublishers: .max(2)) { $0.message }
         .sink { print($0) }
         .store(in: &subscriptions)
 OKE, em nó đã bị cấm cửa. Nếu không có giá trị max thì nó tương đường với unlimited.

 Tóm tắt nhanh cho các em map nha:

 map dùng để biến đối kiểu giá trị này thành kiểu giá trị khác
 Map key paths : dùng để biến đổi các thuộc tính của 1 đối tượng, thành cái gì đó mới hoặc cho vui cũng được.
 tryMap dùng để biến đổi như map, nhưng sử dụng với các kiểu dữ liệu có nguy cơ sinh ra lỗi. Khi có lỗi thì tự động chúng sẽ vào completion với error
 flatMap dùng để biến đổi 1 publisher này thành 1 publisher khác. Bên cạnh đó còn quản lí các stream của các publisher trong đó. Hiểu nôm na là hợp nhất các stream thành 1 steam và khống chế số lượng các steam lắng nghe.
 4. Replacing upstream output
 Cái này nghe cái tên thì cũng đoán ra được ít nhiều phần nào rồi. Đôi khi một số kiểu dữ liệu cho phép việc vắng mặt giá trị (Optional) hoặc khi giá trị là nil. Combine cung cấp cho chúng ta các toán tử để thay thế như sau:

 4.1. replaceNil(with:)
 ["A",  nil, "B"].publisher
         .replaceNil(with: "-")
         .sink { print($0) }
         .store(in: &subscriptions)
 Đơn giản là publisher phát ra giá trị nào nil thì sẽ thay thế bằng giá trị nào đó được chỉ định. Tuy nhiên chúng sẽ là kiểu Optional và muốn code sạch đẹp hơn thì bạn phải khử Optional đó. Ví dụ:

 ["A",  nil, "B"].publisher
         .replaceNil(with: "-")
         .map({$0!})
         .sink { print($0) }
         .store(in: &subscriptions)
 4.2. replaceEmpty(with:)
 Khi mà publisher không chịu phát gì hết thì sao? Khi đó toán tử replaceEmpty sẽ chèn thêm giá trị nếu pulisher không phát đi bất cứ gì mà lại complete. (choá thật)

 let empty = Empty<Int, Never>()

     empty
         .replaceEmpty(with: 1)
         .sink(receiveCompletion: { print($0) },
               receiveValue: { print($0) })
         .store(in: &subscriptions)
 5. Scan
 Chuyển đổi từng phần tử trên upstream của publisher. Bằng cách cung cấp phần tử hiện tại, là một closure với giá trị cuối cùng kèm theo.

 Nghe qua thì khá mơ hồ, tạm thời bạn qua ví dụ sau:

 let pub = (0...5).publisher

     pub
         .scan(0) { $0 + $1 }
         .sink { print ("\($0)", terminator: " ") }
         .store(in: &subscriptions)
 Giải thích:

 Tạo 1 publisher bằng cách biến đổi 1 Array Integer từ 0 tới 5 thông qua toán tử publisher
 Biển đổi từng phần tử của pub bằng toán tử scan với giá trị khởi tạo là 0
 Scan sẽ phát ra các phần tử mới bằng cách kết hợp 2 giá trị lại
 Cái khởi tạo là đầu tiên -> cái nhận được là thứ 2 -> cái tạo ra mới được phát đi và trở thành lại cái đầu tiên.
 Lặp lại cho đến hết
 Tóm tắt
 Họ nhà map Giúp biến đổi Output hay kể cả Publisher.
 map có 2 phiên bản, trực tiếp biến đổi đối tượng. Hoặc biến đổi các thuộc tính của đối tượng.
 tryMap dành cho việc tương tác với các kiểu dữ liệu có nguy cơ sinh ra lỗi
 flatMap biển đổi Publisher này thành Publisher khác
 replaceNil thay các giá trị nil thành 1 giá trị nào đó
 replaceEmpty cho nó một giá trị nếu publisher không phát đi bất cứ giá trị nào hết mà kết thúc
 scan quét sạch hết các giá trị nhận được từ publisher. Kết hợp chúng lại để phát ra một giá trị cuối cùng theo luật riêng được định nghĩa ở closure
 */
