//
//  Combine_Lesson2.swift
//  ios-swiftui-combine
//
//  Created by LinhNguyen DGWA on 12/8/24.
//

import Foundation

/***
 1. Publishers
 Mình đã có trình bày về các thành phần chính trong Combine Framework rồi. Trong đó, có nói về Publisher. Bây giờ thì chúng ta sẽ tập trung vào các loại Publisher hay dùng và cách sử dụng của từng loại.

 1.1. Publisher từ giá trị
 Như các bài trước, chúng ta cũng đã biết được trong các framework truyền thống của iOS, thì Combine đã len lõi vào hết rồi. Các kiểu dữ liệu cơ bản đều có thêm các extension giúp biến đổi nó thành 1 Publisher. Xem lại ví dụ sau:

 let helloPublisher = "Hello Combine".publisher
 let _ = helloPublisher
   .sink { print($0) }
 Đó là 1 String, sau khi biến thành publisher thì giá trị của nó phát ra là các character. Và kiểu giá trị cơ bản đó phải thuộc kiểu Collection. Các các kiểu như Int, Float, Bool thì không thể.

 let helloPublisher = "Hello Combine".publisher
 _ = helloPublisher
   .sink { print($0) }
 let fibonacciPublisher = [0,1,1,2,3,5].publisher
 _ = fibonacciPublisher
   .sink { print($0) }
 let dictPublisher = [1:"Hello",2:"World"].publisher
 _ = dictPublisher
   .sink { print($0) }
 Đặc trưng của loại Publisher này là không bao giờ có lỗi. Hay kiểu dữ liệu cho Failure là Never.

 1.2. Publisher từ biến đổi
 Từ bài giới thiệu các thành phần trong Combine, thì chúng ta có thể tạo ra 1 publisher mới thông qua các Operator biến đổi nó.

 let pub1 = (1...10).publisher
 let pub2 = pub1.map { value -> String in
   return "\(value)"
 }
 pub2.sink { (value) in
   print(value)
 }
 Ví dụ trên ta thấy pub1 là 1 publisher với Output là Int, thông qua Operator map thì biến đổi các giá trị của nó thành String. Thêm phần thú vị thì ta xem kĩ giá trị nhận được từ 2 publisher trên

 et pub1 = (1...10).publisher
 let pub2 = pub1.map { (value) -> String in
   "\(value)"
 }
 pub1
   .reduce(0, +)
   .sink { (value) in
   print(value)
 }
 pub2
   .reduce("", +)
   .sink { (value) in
   print(value)
 }
 Ngoài ra, ta có thể tạo các Publisher từ các class của Publishers (có chữ s) . Chúng ta có thể biến đổi các upStream thành các publisher theo ý mình. Chúng thật ra là mô phỏng lại các operator mà thôi. Xem ví dụ sau:

 let subscriber = Subscribers.Sink<Int, Never>(
                     receiveCompletion: {
                        completion in
                       print(completion)
                   }) { value in
                       print(value)
                  }
 Publishers
       .Sequence<[Int], Never>(sequence: [1, 2, 3, 4])
       .receive(subscriber: subscriber)

 Cả 2 publisher và subscriber cũng dùng chung một cách thức tạo. Bây giờ,  bạn có khá nhiều thứ vũ khí trong tay rồi đó.

 1.3. Publisher từ property của Class
 Để tránh việc ảnh hưởng tới code cũ trong dự án của bạn. Thì Combine cũng cung cấp thêm 1 wrapper cho property là @Published. Nó sẽ biến 1 store property truyền thống thành 1 Publisher. Khi sử dụng, bạn chỉ cần thêm từ khoá $ phái trước để dùng nó như 1 Publisher. Mọi thứ còn lại vẫn không thay đổi gì nhiều

 class User {
   @Published var name: String
   @Published var age: Int

   init(name: String, age: Int) {
     self.name = name
     self.age = age
   }
 }
 let user = User(name: "Fx", age: 29)
 _ = user.$name.sink(receiveValue: { (value) in
   print("User name is \(value)")
 })
 user.name = "Fx Studio"
 Ví dụ trên chúng ta wrapper 2 property của class User lại. Tiến hành subscribe tới name và thay đổi giá trị của nó.

 Phát huy rất hiệu quả trong UIKit và SwiftUI. Khi bạn không muốn thay đổi cấu trúc code của project của bạn

 2. Just
 Đây là 1 Publisher đặc biệt. Nó sẽ phát ra 1 giá trị duy nhất tới subscriber và sau đó là finished. Khi khởi tạo 1 Just thì bạn cần phải cung cấp giá trị ban đầu cho nó. Kiểu giá trị của Output sẽ dựa vào kiểu giá trị bạn cung cấp.

 Giá trị của Just vẫn có thể là:

 value
 error
 finished
 Xem ví dụ sau:

 let just = Just("Hello world")
 //subscription 1
 _ = just
     .sink(receiveCompletion: {
         print("Received completion", $0)
     }, receiveValue: {
         print("Received value", $0)
     })
 //subscription 2
 _ = just .sink(
   receiveCompletion: {
     print("Received completion (another)", $0)
   },
   receiveValue: {
     print("Received value (another)", $0)
 })
 Ta tiến hành subscribe 2 lần tới just. Tại mỗi subscription thì chỉ nhận được 1 value và kết thúc.

 Phát huy hiệu quả khi bạn sử dụng nó làm kiểu dữ liệu cho return của function. Hoặc bạn chỉ muốn phát đi 1 giá trị mà thôi.

 3. Future
 Đây cũng là 1 Publisher đặc biệt. Tìm hiểu thử:

 Là một Class
 Là một Publisher
 Đối tượng này sẽ phát ra một giá trị duy nhất, sau đó kết thúc hoặc fail.
 Nó sẽ thực hiện một lời hứa Promise. Đó là 1 closure với kiểu Result, nên sẽ có 1 trong 2 trường hợp:
 Success : phát ra Output
 Failure : phát ra Error
 Khi hoạt động
 Lần subscribe đầu tiên, nó sẽ thực hiện đầy đủ các thủ tục. Và phát ra giá trị, sau đó kết thúc hoặc thất bại
 Lần subscribe tiếp theo, chỉ phát ra giá trị cuối cùng. Bỏ qua các bước thủ thục khác.
 var subscriptions = Set<AnyCancellable>()
 func futureIncrement(
   integer: Int,
   afterDelay delay: TimeInterval) -> Future<Int, Never> {
   Future<Int, Never> { promise in
     print("Original")
     DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
       promise(.success(integer + 1))
     }
   }
 }
 DispatchQueue.main.async {
   // publisher
   let future = futureIncrement(integer: 1, afterDelay: 3)
   // subscription 1
   future
     .sink(receiveCompletion: { print($0) },receiveValue: { print($0) })
     .store(in: &subscriptions)
   // subscription 2
   future
     .sink(receiveCompletion: { print("Second", $0) },receiveValue: { print("Second", $0) })
     .store(in: &subscriptions)
 }
 Ví dụ trên:

 Có 1 function là futureIncrement dùng để phát đi 1 giá trị trong tương lai. Với kiểu returen là Future<Int, Never>
 promise sẽ tăng giá trị và sau đó 1 khoản thời gian sẽ phát đi.
 Vấn tiến hành subscription như cũ
 Bạn suy nghĩ sao khi Future sẽ dùng làm call back trong các function. Thay cho các delegate & closure truyền thống.

 Vâng, đó là đặc trưng của Future.

 4. Subject
 Với các kiểu trên, bạn sẽ thấy 1 điều là dữ liệu sẽ được phát đi. Tiếp theo là kết thúc. Như vậy thì lập trình bật đồng bộ ở đâu? và luồng dữ liệu bất đồng bộ ở đâu?

 Cụ thể hơn, chúng ta sẽ cần 1 thứ, có thể phát dữ liệu đi bất cứ lúc nào nó muốn. Việc kết thúc cũng tuỳ ý nó quyết định.

 Đó là Subject, và nó:

 Ý nghĩa của Subject là nó cũng là 1 loại Publisher
 Là thực thể kết nối giữa code Combine và Non-Combine
 PassthroughSubject : lúc nào phát thì sẽ nhận được giá trị
 CurrentValueSubject : không quan tâm lúc nào phát, chỉ cần subscription là có giá trị (cuối cùng)
 Ví dụ, ta có 1 publisher như sau:

 let publisher = [1, 2, 3, 4].publisher
 Và ta sẽ có 1 subject tương tự như sau:

 let passthroughSubject = PassthroughSubject<Int, Never>()
 Với publisher sẽ phát các giá trị của nó lần lượt tới khi hết sẽ kết thúc. Còn với subject, muốn phát gì thì sẽ phát cái đó. Sử dụng send(:) để phát.

 passthroughSubject.send(1)
 passthroughSubject.send(2)
 passthroughSubject.send(3)
 passthroughSubject.send(4)
 passthroughSubject.send(completion: .finished)
 4.1. PassthroughSubject
 PassthoughtSubject cho phép phát các giá trị đi. Cũng như các loại Publisher khác thì cũng cần phải khai báo kiểu Output & Failure. Khi các subcriber có cùng kiểu, thì mới có thể subcribe tới được.

 Có thể có nhiều subscriber đăng kí tới. Tuy nhiên, chúng sẽ nhận được giá trị khi nào mà subject phát đi. Đây là điểm quan trọng nhất. Và sau khi subject kết thúc thì các subscription cũng kết thúc, nên các subscriber sẽ không nhận được gì thêm sau đó.

 Xem ví dụ code và build test thì bạn sẽ hiểu

 let subject = PassthroughSubject<Int, Never>()
 // send value
 subject.send(0)
 //subscription 1
 _ = subject.sink(receiveValue: { (value) in
   print("🔵 : \(value)")
 })
 // send values
 subject.send(1)
 subject.send(2)
 subject.send(3)
 subject.send(4)
 //subscription 2
 _ = subject.sink(receiveValue: { (value) in
   print("🔴 : \(value)")
 })
 // send value
 subject.send(5)
 // Finished
 subject.send(completion: .finished)
 // send value
 subject.send(6)
 Bạn sẽ thấy, giá trị 0 sẽ không có subscriber nào nhận được. Các giá trị từ 1 đến 4 thì subscriber 1 sẽ nhận được. Sau đó tiến hành thêm 1 subscription cho subscriber 2. Thì cả 2 đều nhận được 5.

 Tuy nhiên, sau khi finished thì cả 2 đều kết thúc và không ai nhận được 6.

 4.2. CurrentValueSubject
 Cũng là một loại Publisher đặc biệt. Nhưng subject này cho phép bạn:

 Khởi tạo với một giá trị ban đầu.
 Định nghĩa kiểu dữ liệu cho Output và Failure
 Khi một đối tượng subcriber thực hiện subcribe tới hoặc khi có một subscription mới. Thì lúc đó, Subject sẽ phát đi giá trị ban đầu (lúc khởi tạo) hoặc giá trị cuối cùng của nó.
 Tự động nhận được giá trị khi subscription, chứ không phải lúc nào phát thì mới nhận. Đây là điều khác biệt với PassThoughtSubject
 Ví dụ, chúng ta thay đổi lại chút code như thế này:

 let subject = CurrentValueSubject<Int, Never>(0)
 Tạo lại subject với kiểu CurrentValueSubject và cung cấp giá trị ban đầu là 0. Tiếp tục subcribe như sau:

 //subscription 1
 _ = subject.sink(receiveValue: { (value) in
   print("🔵 : \(value)")
 })
 // send values
 subject.send(1)
 subject.send(2)
 subject.send(3)
 subject.send(4)
 //subscription 2
 _ = subject.sink(receiveValue: { (value) in
   print("🔴 : \(value)")
 })
 // send value
 subject.send(5)
 // Finished
 subject.send(completion: .finished)
 // send value
 subject.send(6)
 Ta thấy, subscriber 1 sẽ nhận được 0, mặc dù subscribe sau khi khởi tạo subject. Tương tự, subscriber 2 sẽ nhận được 4, mặc dù subscrbe sau khi subject phát 4 đi.

 5. Type erasure
 Đôi khi bạn muốn subscribe tới publisher mà không cần biết quá nhiều về chi tiết của nó. Hoặc quá nhiều thứ đã biến đổi publisher của bạn. Bạn mệt mỏi khi nhớ các kiểu của chúng. Đây sẽ là giải pháp cho bạn:

 Type-erased publisher với class đại diện là AnyPublisher và cũng có quan hệ họ hàng với Publisher. Có thể mô tả như bạn có trải nghiệm déjà vu trong mơ. Nhưng sau này bạn sẽ thấy lại nó ở đâu đó, vì thực sự bạn đã thấy nó và nó đã xoá khỏi bộ nhớ của bạn. Đó là AnyPublisher (quá thật khó hiểu).

 Ngoài ra, ta còn có AnyCancellable cũng là 1 type-erased class. Bạn đã bắt gặp nó ở ví dụ trên. Các subscriber đều có quan hệ họ hàng với AnyCancellable & nó giúp cho quá trình tự huỷ của subscription xảy ra.

 Để tạo ra 1 type-erased publisher thì bạn sử dụng 1 subject và gọi 1 function eraseToAnyPublisher(). Khi đó kiểu giá trị cho đối tượng mới là AnyPublisher.

 Với AnyPublisher, thì không thể gọi function send(_:) được.
 Class này đã bọc và ẩn đi nhiều phương thức & thuộc tính của Publisher.
 Trong thực tế, bạn cũng không nên lạm dụng hay khuyến khích dùng nhiều kiểu này. Vì đôi khi bạn cần khai báo và xác định rõ kiểu giá trị nhận được.
 Ví dụ code như sau:

 var subscriptions = Set<AnyCancellable>()
 //1: Tạo 1 Passthrough Subject
 let subject = PassthroughSubject<Int, Never>()
 //2: Tạo tiếp 1 publisher từ subject trên, bằng cách gọi function để sinh ra 1 erasure publisher
 let publisher = subject.eraseToAnyPublisher()
 //3: Subscribe đối tượng type-erased publisher đó
 publisher
 .sink(receiveValue: { print($0) })
 .store(in: &subscriptions)
 //4: dùng Subject phát 1 giá trị đi
 subject.send(0)
 //5: dùng erased publisher để phát --> ko đc : vì không có function này
 //publisher.send(1)
 Ta có subject và tạo tiếp publisher bằng việc xoá đi subject, biến subject thành AnyPublisher. Đặc trưng chính là:

 subject có thể send giá trị
 publisher thì không send được giá trị
 khi subject send thì publisher sẽ phát theo.
 Rất là hay khi bạn không muốn ra mặt mà vẫn có thể ném đá giấu tay.



 OKAY. Tới đây, mình xin kết thúc bài viết về họ hàng của Publisher trong Combine. Tuy nhiên, vẫn còn 1 phần rất quan trọng nữa, đó là Custom Publisher. Nhưng đó là phần Combine nâng cao cực kì. Mình sẽ để dành nó sau cùng trong series này.

 Cảm ơn bạn đã đọc bài viết này. Nếu thấy hay thì hãy like và share cho nhiều người khác cùng đọc. Còn nếu có góp ý gì cho mình, bạn có thể để lại comment hoặc email (theo contact của website).

 Chào thân ái và quyết thắng!

 Tạm kết
 Với các Publisher đã tìm hiểu (như Notification hay Array chuyển đổi thành publisher) thì bạn sẽ phát một lần đi tất cả các giá trị mà nó đang nắm giữ
 Với Future thì sẽ phát ra duy nhất một lần mà thôi. Giá trị phát đi có thể là value hoặc completion hoặc error. Giá trị cung cấp có thể ở 1 thời điểm khác.
 Với Just cũng như vậy, nhưng nó sẽ phát đi các giá trị được cung cấp vào lúc khởi tạo đối tượng và chỉ phát ra như vậy.
 Với Subject thì ta có nhiều loại, nhiều class và dùng được cho nhiều trường hợp:
 PassThoughtSubject : cho phép gởi nhiều lần, từng giá trị (bất chấp). Muốn gởi giá trị nào, thì người lập trình có thể tuỳ ý mà không bị các hạn chế như các đối tượng publisher trên.
 CurrentValueSubject : tương tự như cái trên. Mà khi có 1 subscription mới tới, nó sẽ luôn phát đi giá trị cuối cùng của nó. Nếu lúc mới khởi tạo thì nó sẽ phát đi giá trị được khởi tạo đi. Nhằm đảm bảo việc lúc nào cũng có giá trị để subscriber nhận.
 Type Erasure cũng là một khái niệm hay trong Combine, dùng khi bạn không muốn quan tâm gì nhiều tới chi tiết của đối tượng mà bạn đang lắng nghe.
 */
