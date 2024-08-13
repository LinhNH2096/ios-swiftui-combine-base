//
//  Combine_Lesson3.swift
//  ios-swiftui-combine
//
//  Created by LinhNguyen DGWA on 13/8/24.
//

import Foundation

/***
 Tổng quan
 “A protocol that declares a type that can receive input from a publisher.”

 — Apple —

 Như các bài giới thiệu trước thì bạn cũng đã biết về Subscriber nhiều rồi. Đơn giản nó là thực thể đón nhận các dữ liệu. Là điểm cuối cùng trong cả chuỗi tương tác bất đồng bộ.

 public protocol Subscriber {
     associatedtype Input
     associatedtype Failure : Error

     func receive(subscription: Subscription)
     func receive(_ input: Self.Input) -> Subscribers.Demand
     func receive(completion: Subscribers.Completion<Self.Failure>)
 }
 Khai báo phải kế thừa lại protocol Subscriber, trong đó:

 Input là kiểu dữ liệu cho giá trị nhận được. Nó phải trùng với kiểu dữ liệu Output của Publisher.
 Failure là kiểu dữ liệu cho error. Nếu không bao giờ nhận được error thì sử dụng Never.
 Có 3 function tiếp theo cần phải implement:

 receive(subscription:) : khi nhận được subscription từ Publisher. Lúc này Subscriber vẫn có quyền quyết định việc lấy bao nhiêu dữ liệu từ Publisher
 receive(_ input:) : khi Publisher phát đi các dữ liệu thì Subscriber nhận được. Mỗi lần nhận như vậy thì Subscriber sẽ điều chỉnh lại việc request lấy thêm hay là không. Đối tượng sử dụng là Demand.
 receive(completion:) : khi nhận được competion từ Publisher.
 Khi bạn đã có 1 đối tượng Subscriber. Và muốn đăng kí tới Publisher thì sử dụng hàm subscribe của Publisher.

 publisher.subscribe(subscriber)
 Và chỉ lúc nào subscriber kết nối tới, khi đó publisher mới phát đi dữ liệu. Đây là điều cực kì quan trọng trong Combine.

 Subscriber hỗ trợ việc tự huỷ khi subscription ngắt kết nối. Việc huỷ đó giúp cho bộ nhớ tự động giải phóng đi các đối tượng không cần thiết. Chúng ta có 2 kiểu huỷ:

 Tự động huỷ thông AnyCancellable, đó là việc tạo ra các subscriber bằng sink hoặc assign
 Huỷ bằng tay với việc subscriber gọi hàm cancel() của nó.
 2. Cách tạo Subscriber
 Có thể bạn đã tạo được các Subscriber nhiều rồi, bây giờ thì mình chỉ tổng hợp lại thôi.

 2.1. Assign
 Ta có 1 class Dog và 1 thuộc tính name. Tạo 1 đối tượng của Dog

 class Dog {
   var name: String

   init(name: String) {
     self.name = name
   }
 }
 let dog = Dog(name: "Pochi")
 print("Dog name is \(dog.name)")
 Tạo 1 đối tượng Subscriber với Assign. Nhằm đưa dữ liệu nhận được trực tiếp tới name của đối tượng dog.

 let subscriber = Subscribers.Assign(object: dog, keyPath: \.name)
 Tiến hành tạo publisher và phát dữ liệu đi.

 let publisher = Just("Milu")
 publisher.subscribe(subscriber)
 print("Dog name is \(dog.name)")
 Ta thấy với Subscribers.Assign thì ta có được 1 Subscriber và nó cũng là Cancellable. Đặc trưng của việc này giúp ta binding dữ liệu lên đối tượng một cách nhanh chóng.

 Nhược điểm thì publisher phải đảm bảo là không bao giờ phát đi error.

 2.2. Sink
 Ta xem qua ví dụ sau

 class Dog {
   var name: String

   init(name: String) {
     self.name = name
   }
 }
 let dog = Dog(name: "Pochi")
 print("Dog name is \(dog.name)")
 let subscriber = Subscribers.Sink<String, Never>(receiveCompletion: { (completion) in
   print(completion)
 }) { name in
   dog.name = name
 }
 let publisher = PassthroughSubject<String, Never>()
 publisher.subscribe(subscriber)
 publisher.send("Milu")
 print("Dog name is \(dog.name)")
 publisher.send(completion: .finished)
 print("Dog name is \(dog.name)")
 Vẫn là class Dog trên. Nhưng giờ subscriber đã khác. Dùng Subscribers.Sink để tạo ra 1 subscriber. Với đối tượng này thì ta có thể xử lí luôn việc có error phát sinh. Việc đăng kí tới Publisher thì vẫn không có thay đổi gì nhiều.

 Cần cung cấp cho nó các closure để xử lý giá trị và completion nhận được.

 2.3. AnyCancellable
 Đây là 1 type-erasing class nhằm tạo ra 1 đối tượng sẽ tự động huỷ. Khi nó huỷ thì các subscription sẽ bị huỷ theo. Và các Subscriber có implement nó cũng tự động huỷ theo. Ngoài ra, nó còn cung cấp thêm 1 phương thức cancel để cho subscriber tuỳ ý tự huỷ.

 Từ Publisher thì với 2 function của nó là sink và assign sẽ tạo ra đối tượng AnyCancellable.

 sink đính kèm theo 1 subscriber là 1 closure để xử lý các giá trị nhận được
 let publisher = PassthroughSubject<String, Never>()
 let cancellable = publisher.sink(receiveCompletion: { (completion) in
   print(completion)
 }) { (name) in
   dog.name = name
 }
 assign  đưa dữ liệu phát ra tới property của 1 đối tượng.
 let publisher = PassthroughSubject<String, Never>()
 let cancellable = publisher.assign(to: \.name, on: dog)
 Và 1 điều cần chú ý là bạn không thể tạo ra nhiều đối tượng cancellable cho một lần subscribe . Việc quản lý từng đứa như vậy cũng khá vất vả. Tốt nhất bạn cần phải quản lý tập trung.

 var subscriptions = Set<AnyCancellable>()
 let publisher = PassthroughSubject<String, Never>()
 //subscription 1
 publisher
   .sink(receiveCompletion: { (completion) in
     print(completion)
   }) { (value) in
     print(value)
   }
   .store(in: &subscriptions)
 //subscription 2
 publisher
   .assign(to: \.name, on: dog)
   .store(in: &subscriptions)
 Xem ví dụ trên ta thấy, cần phải lưu trữ lại subscription do sink và assign tạo ra. Thông qua 1 đối tượng subscriptions với kiểu Set<AnyCancellable>. Điều này có ý nghĩa khi xem publisher là trọng tâm. Và có nhiều kết nối tới nó, mỗi kết nối có thể tới từ 1 thực thể riêng biệt.

 Khi nguồn phát (publisher) kết thúc thì tất cả các kết nối cũng sẽ tự huỷ theo. Đó là ý nghĩa của việc sử dụng AnyCancellable.

 class ViewModel {
   //...
   var subscriptions = Set<AnyCancellable>()

   //...
   deinit {
     subscriptions.removeAll()
   }
 }
 Chi tiết cách sử dụng AnyCancellable mình sẽ đề cập kĩ hơn ở phần Combine trong UIKit.

 3. Custom Subscriber
 3.1. Define Class

 Đây là phần chính của bài. Khi bạn muốn thứ của riêng mình, thì sao không thử việc tạo 1 class Subscriber riêng. Bắt đầu với việc define 1 class có tên là IntSubscriber kế thừa trực tiếp từ Subscriber

 final class IntSubscriber: Subscriber {

   typealias Input = Int
   typealias Failure = Never

   func receive(subscription: Subscription) {

   }

   func receive(_ input: Int) -> Subscribers.Demand {

   }

   func receive(completion: Subscribers.Completion<Never>) {

   }
 }
 Như trình bày ở phần Tổng quát, thì cúng ta cần

 Định nghĩa 2 kiểu dữ liệu
 Implement 3 function cần thiết cho lớp này.
 Và thử tiếp đoạn code sau:

 final class IntSubscriber: Subscriber {

   typealias Input = Int
   typealias Failure = Never

   func receive(subscription: Subscription) {
     subscription.request(.max(1))
   }

   func receive(_ input: Int) -> Subscribers.Demand {
     print("Received value", input)
     return .unlimited
   }

   func receive(completion: Subscribers.Completion<Never>) {
     print("Received completion", completion)
   }
 }
 Tiếp tục, tạo publisher và thử kết nối tới.

 let publisher = (1...10).publisher
 let subscriber = IntSubscriber()
 publisher.subscribe(subscriber)
 Công việc của chúng ta đã đơn giản hơn nhiều rồi. Thay vì cung cấp các closure xử lí, giờ class mới của Subscriber đã tự quản lý oke rồi. Việc chỉ còn là tạo đối tượng và subscribe thôi.

 Thay đổi kiểu dữ liệu của Publisher như sau:

 let publisher = ["A", "B", "C", "D", "E", "F"].publisher
 Thì sẽ báo lỗi do khác kiểu dữ liệu cho Input.

 3.2. Dynamically adjusting Demand
 Còn bây giờ mới là màn hay nhất. Thử thay đổi request của subscription 1 chút.

 func receive(subscription: Subscription) {
     subscription.request(.max(0))
   }
 Với max(0), thì sẽ không có gì nhận được, mặc dù publisher vẫn phát đi. Tiếp tục thay đổi tiếp.

 func receive(subscription: Subscription) {
     subscription.request(.max(3))
   }

   func receive(_ input: Int) -> Subscribers.Demand {
     print("Received value", input)
     return .none
   }
 Build chạy thì thấy sẽ nhận được 3 giá trị đầu tiên. Sau đó sẽ không nhận được gì thêm nữa. Vì vậy, với việc return 1 Demand về thì cũng quyết định việc request lấy dữ liệu của Subscriber. Và tiếp tục thay đổi tiếp.

 func receive(_ input: Int) -> Subscribers.Demand {
     print("Received value", input)
     return .max(1)
   }
 Lần này, thì nhận được tất cả dữ liệu phát ra từ publisher. Có điều gì bất thường ở đây?

 Giải thích như sau: Mỗi lần nhận được dữ liệu, thì Subscriber lại điều chỉnh request của mình thông qua Demand. Với việc return về:

 none : không lấy thêm phần tử nào nữa
 unlimited : lấy sạch hết
 max(n) : lấy n phần tử tiếp theo
 Cứ như vậy, theo ví dụ trên. Ban đầu subscription request lấy 1 giá trị, sau đó Subscriber điều chỉnh lấy thêm 1 giá trị nữa. Nó sẽ lặp đi lặp lại cho tới hết.

 Như vậy, bạn có 2 nơi có thể điều chỉnh việc request dữ liệu từ Subscriber tới Publisher. Và bạn chủ động trong việc xử lý dữ liệu nhận được từ Publisher.

 Bạn xem qua code nâng cấp class Dog ở trên. Nhằm giúp cho nó có thể thực sự tự hoạt động như 1 Subscriber.

 Tạo thêm 1 extension để kế thừa lại Subscriber
 Khai báo 2 kiểu Input và Failure
 Implement 3 function cần thiết
 final class Dog {
   var name: String

   init(name: String) {
     self.name = name
   }
 }
 extension Dog: Subscriber {
   typealias Input = String
   typealias Failure = Never

   func receive(subscription: Subscription) {
      subscription.request(.max(3))
    }

    func receive(_ input: String) -> Subscribers.Demand {
      self.name = input
      return .unlimited
    }

    func receive(completion: Subscribers.Completion<Never>) {
      print("Received completion", completion)
    }
 }
 Sử dụng như sau:

 let dog = Dog(name: "Pochi")
 print("Dog name is \(dog.name)")
 let publisher = PassthroughSubject<String, Never>()
 publisher.subscribe(dog)
 publisher.send("Milu")
 print("Dog name is \(dog.name)")
 Build và cảm nhận kết quả.



 OKAY. Tới đây, mình xin kết thúc bài viết về Custom Subscriber. Cảm ơn bạn đã đọc bài viết này. Nếu thấy hay thì hãy like và share cho nhiều người khác cùng đọc. Còn nếu có góp ý gì cho mình, bạn có thể để lại comment hoặc email (theo contact của website).

 Chào thân ái và quyết thắng!

 Tạm kết
 Tổng quát về Subscriber
 Assign và Sink
 AnyCancellable
 Custom Subscriber
 Điều chỉnh request của Subscriber
 */
