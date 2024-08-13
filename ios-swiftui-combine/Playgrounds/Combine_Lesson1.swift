//
//  Combine_Lesson1.swift
//  ios-swiftui-combine
//
//  Created by LinhNguyen DGWA on 12/8/24.
//

import Foundation

/***
     Sự hoạt động

     Chúng ta giải quyết bài toán cho luồng dữ liệu bất đồng bộ. Và cái quan tâm chính đó là dữ liệu. Vì vậy, dữ liệu sẽ được phát đi ( emit ) bất cứ lúc nào. Thực thể dùng để phát các dữ liệu đi đó là các Publisher.

     Có người phát thì phải có người nhận. Các thực thể nhận các dữ liệu phát đi đó thì gọi là các Subscriber. Các subscriber không nhất thiết phải ở gần, hay cùng chung class với các publisher. Hay cùng chung 1 queue hoặc 1 thread. Mà chúng ta có thể phát và nhận ở bất kì đâu.

     Việc Subscriber đăng ký tới Publisher thì người ta gọi nó là subscription.

     Câu chuyện không chỉ đơn giản như chúng ta nghĩ. Bạn muốn có 1 cái bánh mì đem tới tay người dùng, công việc của bạn ngoài việc giao bánh mì thì phải chế biến các nguyên liệu làm bánh thành cái bánh đúng như ý đồ của bạn. Công việc này gọi là các công việc biến đổi giá trị. Và trong Combine nó được gọi là các Operator.

     Với Combine, thì chỉ khi nào có Subscriber đăng ký tới Publisher. Thì Publisher mới phát dữ liệu đi.

     Ngoài ra, các thành phần khác nằm trong các Framework truyền thống cũng có chứa 1 phần của Combine. Chúng ta xem qua ví dụ sau:

     let myNotification = Notification.Name("fxNotification")
     let center = NotificationCenter.default
     let observer = center.addObserver(forName: myNotification, object: nil, queue: nil) { (notification) in
       print("Notification received!")
     }
     center.post(name: myNotification, object: nil)
     center.removeObserver(observer)
     Giải thích:

     Khai báo 1 notification mới với tên là fxNotification
     Thêm các observer để lắng nghe notification phát ra
     Quan trọng là phải remove các observer sau khi hoàn thành
     Đó là cách truyền thống của chúng ta. Nó cũng như là 1 phiên bản Combine sơ khai. Còn giờ chúng ta sang cách mới.

     let myNotification = Notification.Name("fxNotification")
     let publisher = NotificationCenter.default.publisher(for: myNotification, object: nil)
     let center = NotificationCenter.default
     //SUBSCRIPTION
     let subscription = publisher.sink { _ in
         print("FxNotification received from a publisher!")
     }
     //POST
     center.post(name: myNotification, object: nil)
     center.post(name: myNotification, object: nil)
     center.post(name: myNotification, object: nil)
     Thêm 1 đối tượng publisher tạo ra từ center. Và tiến hành lắng nghe chúng, là subscription. Công việc còn lại thì center post đi 1 thông báo, publisher sẽ tự động phát ra cho các subscriber đăng ký tới nó.

     Bạn không cần quan tâm tới việc phải add  và remove các observer.

     OKAY, đó là sự giải thích đơn giản nhất cho toàn bộ cơ chế hoạt động trong Combine. Chúng ta tiếp tục đi vào chi tiết hơn của chúng.

     2. Publisher
     Publisher chính là trái tim của toàn bộ Combine. Chịu trách nhiệm phát đi các giá trị và quản lý các subscription tới nó. Nó chính là nguồn phát. Xem qua protocol của các Publisher

     public protocol Publisher {
         associatedtype Output
         associatedtype Failure : Error
         func receive<S>(subscriber: S) where S : Subscriber, Self.Failure == S.Failure, Self.Output == S.Input
     }
     Tất cả các Publisher đều phải kế thừa protocol này. Bạn sẽ thấy có 2 kiểu yêu cầu bạn phải cung cấp

     Output : chính là kiểu giá trị cho dữ liệu bạn phát ra
     Failure: kiểu dữ liệu cho trường hợp lỗi
     Do đó, 1 publisher sẽ phát ra 1 trong 3 kiểu giá trị sau:

     value : chính là cái chúng ta cần, dữ liệu
     error : nếu gặp lỗi thì các subscriber sẽ nhận được như vậy
     complete : là kết thúc vòng đời đau khổ của 1 publisher
     Nếu publisher phát ra complete hay error thì sẽ không phát thêm được nữa. Nó sẽ kết thúc ở đây.

     3. Subscriber
     Đây là thực thể ở cuối cùng trong cả quá trình tương tác. Nó sẽ nhận các giá trị từ Publisher. Và cũng như publisher, thì tất cả các subscriber để phải kế thừa protocol Subscriber.

     public protocol Subscriber {
         associatedtype Input
         associatedtype Failure : Error
         func receive(subscription: Subscription)
         func receive(_ input: Self.Input) -> Subscribers.Demand
         func receive(completion: Subscribers.Completion<Self.Failure>)
     }
     Đối nghịch với Publisher, thì Subscriber sẽ cần dữ liệu đầu vào và ta phải cung cấp kiểu dữ liệu cho Input. Tất nhiên, bắt buộc phải cung cấp kiểu dữ liệu cho Failure.

     Tiếp theo là 3 function quan trong nhất:

     receive(subscription:) khi nhận được subscription từ Publisher
     receive(input:) khi nhận được giá trị từ Publisher và chúng ta sẽ điểu chỉnh request tiếp dữ liệu thông qua Demand . Có nghĩa bạn muốn nhận tiếp hay không hay nhận hết, thì bạn có thể tuỳ ý quyết định … đây là ưu điểm mà Combine hơn người tiền nhiệm RxSwift.
     receive(completion:) khi nhận completion từ publisher.
     Tiếp theo, là cách bạn tạo ra 1 subscriber.

     SINK
     Là cách đơn giản nhất mà bạn có thể dùng để tạo ra 1 Subscriber
     Bạn không cần quan tâm gì nhiều tới các đối tượng hay class
     Bạn cung cấp cho nó 1 closure để xử lý các giá trị nhận được hay completion từ Publisher
     Xem ví dụ sau:

     let just = Just("Hello world")
     let subscriber1 = just
         .sink(receiveCompletion: {
             print("Received completion", $0)
         }, receiveValue: {
             print("Received value", $0)
         })
     let subscriber2 = just .sink(
       receiveCompletion: {
         print("Received completion (another)", $0)
       },
       receiveValue: {
         print("Received value (another)", $0)
     })
     Bạn sẽ thắc mắc về JUST. Nó là 1 class đặc biệt để tạo 1 Publisher với 1 giá trị cung cấp. Sau khi có subscriber đăng ký tới, thì nó sẽ phát ngay giá trị đó đi.

     Chúng ta tạo tiếp 2 subscriber 1 & 2 bằng sink. Trong closure đó chúng ta handler 2 trường hợp:

     receiveValue nhận được giá trị
     receiveCompletion nhận được completion
     1 Publisher sẽ có nhiều Subscriber đăng ký tới.

     ASSIGN
     Đây là cách phổ biến thứ 2 khi bạn muốn có 1 subscriber. Lần này thì đặc biệt hơn một chút. Bạn có thể gán giá trị của mình tới 1 property của 1 object nào đó.

     Xem ví dụ là sẽ hiểu thôi

     class MyClass {
             var name: String = "" {
                 didSet {
                     print(name)
                 }
             }
         }

     let obj = MyClass()
     let publisher = ["Apple", "iOS", "Combine"].publisher

     _ = publisher
             .assign(to: \.name, on: obj)
     Giải thích:

     Class có tên là MyClass, như bao class bình thường khác, với 1 property là name
     Tạo 1 object của class
     Tạo 1 publisher bằng cách dùng toán tử publisher cho Array String
     Dùng assign để tạo ra 1 subscriber nhằm đưa thẳng giá trị nhận được từ Publisher tới thuộc tính name của đối tượng class MyClass
     Qua đó, bạn sẽ thấy Combine đã len lỏi vào xâu trong các framework khác của Apple. Nó cung cấp các extension giúp cho các Class truyền thống (như Array, Set) để có thể tạo nhanh các publisher.

     Ngoài ra, việc sử dụng assign có một số lưu ý sau:

     Publisher đó phải luôn trả về giá trị, không có trường hợp trả về Error
     Để không trả về Error thì kiểu dữ liệu của Failure sẽ là Never
     Giờ thì bạn sẽ thấy là không cần thay đổi các code, class, function … cũ trong project của bạn. Mà vẫn tự tin sử dụng thêm được Combine Code vào.

     CANCELLABLE
     Khi 1 subscriber trong một thời gian dài, mà không nhận được dữ liệu từ publisher, thì giải pháp tốt nhất là huỹ nó đi. Điều này có lợi cho việc quản lý bộ nhớ. Nhất là trong các trường hợp dùng cùng với UIKit.

     Ví dụ như khi ViewController mất đi, thì các subscriber của nó cũng sẽ mất theo một cách tự động. Bạn không cần quan tâm gì nhiều tới chúng.

     Khi bạn đăng ký subscriber cho publisher thì subscription trả về sẽ là 1 cancellable. Nếu như bạn không kiên nhẫn để chờ huỹ, thì có thể sử dụng function sau cancel() của subscription. Mọi việc sẽ được giải quyết.

     Còn nếu bạn không dùng function kia, thì subscriber vẫn có thể tự huỹ được subscription. Nếu nó nhận được completion hoặc error từ publisher.

     Ví dụ code minh hoạ

         let myNotification = Notification.Name("fxNotification")

         let publisher = NotificationCenter.default.publisher(for: myNotification, object: nil)

         let center = NotificationCenter.default

         //SINK
         let subscription = publisher.sink { _ in
             print("FxNotification received from a publisher!")
         }

         //POST
         center.post(name: myNotification, object: nil)
         center.post(name: myNotification, object: nil)
         center.post(name: myNotification, object: nil)

         //CANCEL
         subscription.cancel()

         center.post(name: myNotification, object: nil) // không nhận được
     4. Life cycle
     Mình sẽ tóm tắt lại vòng đời, từ khi Publisher phát ra giá trị tới khi Subscriber nhận được giá trị. Và subscription mất đi kết nối… thông qua hình minh hoạ sau:



     Bước 1: phải có Subscriber đăng ký (subscribe) tới Publisher
     Bước 2: khi nhận được đăng ký từ Subscriber thì Publisher gởi về cho Subscriber một subscription
     Bước 3: Subscriber sẽ request để Publisher phát đi giá trị.
     Bước 4: Publisher sẽ gởi giá trị đi, có thể lần lượt, hoặc tất cả, hoặc không, hoặc theo 1 luật gì đó … cái này subscriber sẽ quyết đinh thông qua việc trả về cho Publisher một lời hứa (Demand)
     Bước 5: Publisher sẽ gởi completion để kết thúc chuỗi đăng ký này

     Chắc bạn sẽ thắc mắc: “vì sao sink hay assign lại trả về 1 Cancellable chứ không phải Subscriber?”. Điều này sẽ giải thích ở các bài sau. Còn sau đây là đoạn code mô tả lại các thực thể trình bày trong bài.

     let publisher = (1...10).publisher
     let subscriber = Subscribers.Sink<Int, Never>(receiveCompletion: { completion in
       print(completion)
     }) { value in
       print(value)
     }
     publisher.subscribe(subscriber)
     Giải thích:

     Tạo ra publisher từ 1 Array Int có các giá trị từ 1 đến 10. Kiểu của Publisher lúc này là:
     Output: Int
     Failure: Never
     Tạo một Subscriber bằng sử dụng class Subscriber.Sink
     Không quên việc cung cấp các kiểu giá trị cho subscriber là
     Input : Int
     Failure: Never (không bao giờ lỗi)
     Tiến hành đăng ký subscriber cho publisher bằng toán tử subscribe(:)
     5. Operators
     Hiểu đơn giản thì các Operators chính là các từ vựng, giúp bạn diễn đạt logic/ý nghĩa của mình trong code.

     Đây là phần khá là lớn trong Combine. Bạn sẽ đối mặt với hằng hà sa số các phép toán. Bạn sẽ phải hiểu chúng để có thể sử dụng thành thạo và biến đổi các đối tượng theo ý muốn của mình.

     Bạn có thể dùng kết hợp nhiều các Operator với nhau. Và output của operator trước sẽ là input của operater sau. Cú pháp chính mà bạn sử dụng ở đây là declarative syntax.

     Ví dụ:

     let publisher = ["H", "e", "l", "l", "o", " ", nil, "W", "o", nil, "r", "l", "!"].publisher
     let subscriber = Subscribers.Sink<String, Never>(receiveCompletion: { completion in
       print(completion)
     }) { value in
       print(value)
     }
     publisher
       .filter { $0 != nil }
       .map { $0! }
       .reduce("", +)
       .subscribe(subscriber)
     Thay đổi lại ví dụ trên 1 chút. Sử dụng đầu vào là 1 Array String? , với việc xuất hiện các giá trị nil. Công việc chúng ta sẽ biến đổi thành String và xoá đi các phần tử nil. Đơn giản, bạn chỉ cần kết hợp vài toán tử lại với nhau thôi. Ahihi!

     Các nhóm operator chính như sau:

     Transforming Operators
     Filtering Operators
     Combining Operators
     Time Manipulation Operators
     Sequence Operators
     Chi tiết các nhóm này mình sẽ viết ở loạt bài sau về các Operators hay sử dụng. Còn bây giờ thì xin kết thúc bài dài này. Cảm ơn bạn đã đọc bài viết!

     Tạm kết
     Các thành phần chính trong Combine (Publisher, Subscriber, Operators)
     Các cách tạo Subscriber & Cancellable
     Các subscription hoạt động và vòng đời của chúng
     SINK & ASSIGN
     JUST
*/
