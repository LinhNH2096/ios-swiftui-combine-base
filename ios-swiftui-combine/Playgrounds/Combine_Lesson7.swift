//
//  Combine_Lesson7.swift
//  ios-swiftui-combine
//
//  Created by LinhNguyen DGWA on 19/8/24.
//

import Foundation

/***
 1. Delay
 Toán tử delay sẽ tạo ra 1 publisher mới từ 1 publisher gốc. Cơ chế hoạt động rất đơn giản, khi publisher gốc phát đi 1 giá trị, thì sau khoảng thời gian cài đặt thì publisher delay sẽ phát cùng giá trị đó đi.

 var subscriptions = Set<AnyCancellable>()
 let valuesPerSecond = 1.0
 let delayInSeconds = 2.0
 let sourcePublisher = PassthroughSubject<Date, Never>()
 let delayedPublisher = sourcePublisher.delay(for: .seconds(delayInSeconds), scheduler: DispatchQueue.main)
 //subscription
 sourcePublisher
     .sink(receiveCompletion: { print("Source complete: ", $0) }) { print("Source: ", $0)}
     .store(in: &subscriptions)
 delayedPublisher
    .sink(receiveCompletion: { print("Delay complete: \($0) - \(Date()) ") }) { print("Delay: \($0) - \(Date()) ")}
    .store(in: &subscriptions)
 //emit values by timer
 DispatchQueue.main.async {
     Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
         sourcePublisher.send(Date())
     }
 }
 Giải thích:

 sourcePublisher là 1 subject
 delayPublisher được tạo ra nhờ toán tử delay của publisher trên
 Tiến hành subscription và cứ mỗi giây cho sourcePublisher phát đi
 Thì sau 1 khoảng thời gian được cài đặt trên thì delayPublisher sẽ phát tiếp
 Kết quả chạy chương trình như sau:

 Source:  2020-03-02 08:37:26 +0000
 Source:  2020-03-02 08:37:27 +0000
 Source:  2020-03-02 08:37:28 +0000
 Delay: 2020-03-02 08:37:26 +0000 - 2020-03-02 08:37:28 +0000
 Source:  2020-03-02 08:37:29 +0000
 Delay: 2020-03-02 08:37:27 +0000 - 2020-03-02 08:37:29 +0000
 Source:  2020-03-02 08:37:30 +0000
 Delay: 2020-03-02 08:37:28 +0000 - 2020-03-02 08:37:30 +0000
 Source:  2020-03-02 08:37:31 +0000
 Delay: 2020-03-02 08:37:29 +0000 - 2020-03-02 08:37:31 +0000
 Source:  2020-03-02 08:37:32 +0000
 Delay: 2020-03-02 08:37:30 +0000 - 2020-03-02 08:37:32 +0000
 Source:  2020-03-02 08:37:33 +0000
 Delay: 2020-03-02 08:37:31 +0000 - 2020-03-02 08:37:33 +0000
 Source:  2020-03-02 08:37:34 +0000
 Delay: 2020-03-02 08:37:32 +0000 - 2020-03-02 08:37:34 +0000
 Source:  2020-03-02 08:37:35 +0000
 Delay: 2020-03-02 08:37:33 +0000 - 2020-03-02 08:37:35 +0000
 ...
 Chú ý:

 Toán tử này sẽ ra 1 Publisher mới. Publisher đó sẽ phát lại giá trị của Publisher gốc sau 1 khoảng thời gian. Chứ không phải delay thời gian phát của Publisher gốc.

 2. Collecting values
 Cái tên của nó chắc cũng ít nhiều đoán được ý nghĩa rồi phải không nào. Thử xem qua đoạn code sau:

 var subscriptions = Set<AnyCancellable>()
 let valuesPerSecond = 1.0
 let collectTimeStride = 4
 let sourcePublisher = PassthroughSubject<Int, Never>()
 let collectedPublisher = sourcePublisher
         .collect(.byTime(DispatchQueue.main, .seconds(collectTimeStride)))
         .flatMap { dates in dates.publisher }
 //subscription
 sourcePublisher
     .sink(receiveCompletion: { print("\(Date()) - 🔵 complete: ", $0) }) { print("\(Date()) - 🔵: ", $0)}
     .store(in: &subscriptions)
 collectedPublisher
    .sink(receiveCompletion: { print("\(Date()) - 🔴 complete: \($0)") }) { print("\(Date()) - 🔴: \($0)")}
    .store(in: &subscriptions)
 DispatchQueue.main.async {
     sourcePublisher.send(0)

     var count = 1
     Timer.scheduledTimer(withTimeInterval: 1.0 / valuesPerSecond, repeats: true) { _ in
         sourcePublisher.send(count)
         count += 1
     }
 }
 Trước tiên thì ta xem kết quả chạy chương trình:

 2020-03-02 08:49:01 +0000 - 🔵:  0
 2020-03-02 08:49:02 +0000 - 🔵:  1
 2020-03-02 08:49:03 +0000 - 🔵:  2
 2020-03-02 08:49:04 +0000 - 🔵:  3
 2020-03-02 08:49:05 +0000 - 🔴: 0
 2020-03-02 08:49:05 +0000 - 🔴: 1
 2020-03-02 08:49:05 +0000 - 🔴: 2
 2020-03-02 08:49:05 +0000 - 🔴: 3
 2020-03-02 08:49:05 +0000 - 🔵:  4
 2020-03-02 08:49:06 +0000 - 🔵:  5
 2020-03-02 08:49:07 +0000 - 🔵:  6
 2020-03-02 08:49:08 +0000 - 🔵:  7
 2020-03-02 08:49:09 +0000 - 🔴: 4
 2020-03-02 08:49:09 +0000 - 🔴: 5
 2020-03-02 08:49:09 +0000 - 🔴: 6
 2020-03-02 08:49:09 +0000 - 🔴: 7
 2020-03-02 08:49:09 +0000 - 🔵:  8
 2020-03-02 08:49:10 +0000 - 🔵:  9
 ...
 Ta theo dõi đoạn code trên để hiểu về toán tử collect

 Tạo 1 publisher từ 1 PassthroughSubject với Output là Int
 Tạo tiếp 1 publisher nữa từ publisher trên với toán tử collect
 Tiến hành subscription 2 publisher để xem giá trị sau mỗi lần nhận được
 Cho vào vòng lặp vô tận để quan sát kết quả
 Ta thấy

 Nếu không có flatMap thì cứ sau 1 khoản thời gian được cài đặt collectTimeStride thì các giá trị sẽ được thu thập. Và kiểu giá trị của nó là một Array
 Sử dụng flatMap để biến đổi chúng cho dễ nhìn hơn
 Bỏ flatMap thì kết quả in ra trông như thế này:

 2020-03-02 08:53:30 +0000 - 🔵:  0
 2020-03-02 08:53:31 +0000 - 🔵:  1
 2020-03-02 08:53:32 +0000 - 🔵:  2
 2020-03-02 08:53:33 +0000 - 🔵:  3
 2020-03-02 08:53:34 +0000 - 🔴: [0, 1, 2, 3]
 2020-03-02 08:53:34 +0000 - 🔵:  4
 2020-03-02 08:53:35 +0000 - 🔵:  5
 2020-03-02 08:53:36 +0000 - 🔵:  6
 2020-03-02 08:53:37 +0000 - 🔵:  7
 2020-03-02 08:53:38 +0000 - 🔴: [4, 5, 6, 7]
 2020-03-02 08:53:38 +0000 - 🔵:  8
 2020-03-02 08:53:39 +0000 - 🔵:  9
 2020-03-02 08:53:40 +0000 - 🔵:  10
 2020-03-02 08:53:41 +0000 - 🔵:  11
 2020-03-02 08:53:42 +0000 - 🔴: [8, 9, 10, 11]
 2020-03-02 08:53:42 +0000 - 🔵:  12
 ...
 Chúng ta tiếp tục nâng cấp thêm cho toán tử collect để tăng cường khả năng thu thập giá trị.

 let collectedPublisher2 = sourcePublisher
         .collect(.byTimeOrCount(DispatchQueue.main, .seconds(collectTimeStride), collectMaxCount))
         .flatMap { dates in dates.publisher }
 Ta chú ý điểm byTimeOrCount, có nghĩa là:

 Nếu đủ số lượng thu thập theo collectMaxCount –> thì sẽ bắn giá trị đi
 Nếu chưa đủ giá trị mà tới thời gian thu thập collectTimeStride thì vẫn gom hàng và bắn
 Khá là hay và linh hoạt trong thời buổi kinh thế khó khăn hiện nay.

 3. Hodling off on events
 Bài toán hay gặp trong ứng dụng là search. Thường sẽ là gõ tới đâu thì search tới đó. Nhưng đôi khi chờ 1 chút thời gian để xem ý đồ của người dùng là dừng lại hay gõ tiếp. Nếu họ gõ tiếp, thì việc search các từ khoá chưa hoàn thành giống như bạn đêm lòng đi crush 1 cô gái,  mà cô ta chẵn hết biết tới.

 Oke, chúng ta sẽ gỡ rối phần này với các toán tử sau:

 3.1. debounce
 Toán tử này cũng khá vui, nó có một số đặc điểm sau:

 Publisher sử dụng nó thì sẽ tạo ra 1 Publisher mới
 Với gian được gán vào
 Khi đủ thời gian thì Publisher mới này sẽ phát ra giá trị, với gián trị là giá trị mới nhất của Publisher gốc
 Ta xem ví dụ code sau:

 Trước tiên bổ sung thêm 1 function để in thời gian cho dễ nhìn hơn
 func printDate() -> String {
     let formatter = DateFormatter()
     formatter.dateFormat = "HH:mm:ss.S"
     return formatter.string(from: Date())
 }
 Quẩy thôi
 //data
 let typingHelloWorld: [(TimeInterval, String)] = [
   (0.0, "H"),
   (0.1, "He"),
   (0.2, "Hel"),
   (0.3, "Hell"),
   (0.5, "Hello"),
   (0.6, "Hello "),
   (2.0, "Hello W"),
   (2.1, "Hello Wo"),
   (2.2, "Hello Wor"),
   (2.4, "Hello Worl"),
   (2.5, "Hello World")
 ]
 //subject
 let subject = PassthroughSubject<String, Never>()
 //debounce publisher
 let debounced = subject
     .debounce(for: .seconds(1.0), scheduler: DispatchQueue.main)
     .share()
 //subscription
 subject
     .sink { string in
         print("\(printDate()) - 🔵 : \(string)")
     }
     .store(in: &subscriptions)
 debounced
     .sink { string in
         print("\(printDate()) - 🔴 : \(string)")
     }
     .store(in: &subscriptions)
 //loop
 let now = DispatchTime.now()
 for item in typingHelloWorld {
     DispatchQueue.main.asyncAfter(deadline: now + item.0) {
         subject.send(item.1)
     }
 }
 Giải thích:

 typingHelloWorld là để giả lập việc gõ bàn phím với kiểu dữ liệu là Array Typle gồm
 Thời gian gõ
 Ký tự gõ
 Tạo subject với Output là String
 Tạo tiếp debounce với time là 1.0 -> nghĩa là cứ sau 1 giây, nếu subject không biến động gì thì sẽ phát giá trị đi
 hàm share() để đảm bảo tính đồng nhất khi có nhiều subcriber subscribe tới nó
 Phần subscription để xem kết quả
 For và hẹn giờ lần lượt theo dữ liệu giả lập để subject gởi giá trị đi.
 Xem kết quả chạy chương trình:

 15:59:39.0 - 🔵 : H
 15:59:39.1 - 🔵 : He
 15:59:39.2 - 🔵 : Hel
 15:59:39.4 - 🔵 : Hell
 15:59:39.6 - 🔵 : Hello
 15:59:39.7 - 🔵 : Hello
 15:59:40.7 - 🔴 : Hello
 15:59:41.2 - 🔵 : Hello W
 15:59:41.2 - 🔵 : Hello Wo
 15:59:41.2 - 🔵 : Hello Wor
 15:59:41.7 - 🔵 : Hello Worl
 15:59:41.7 - 🔵 : Hello World
 15:59:42.7 - 🔴 : Hello World
 3.2. throttle
 Toán tử điều tiết này cũng khá thú vị. Ta xem qua các đặc trưng của nó:

 Cũng từ 1 publisher khác tạo ra, thông qua việc thực thi toán tử throttle
 Cài đặt thêm giá trị thời gian điều tiết
 Trong khoảng thời gian điều tiết này, thì nó sẽ nhận và phát giá trị đầu tiên hay mới nhất nhận được từ publisher gốc (dựa theo tham số latest quyết định)
 Xem đoạn code ví dụ sau:

 //data
 let typingHelloWorld: [(TimeInterval, String)] = [
   (0.0, "H"),
   (0.1, "He"),
   (0.2, "Hel"),
   (0.3, "Hell"),
   (0.5, "Hello"),
   (0.6, "Hello "),
   (2.0, "Hello W"),
   (2.1, "Hello Wo"),
   (2.2, "Hello Wor"),
   (2.4, "Hello Worl"),
   (2.5, "Hello World")
 ]
 //subject
 let subject = PassthroughSubject<String, Never>()
 //debounce publisher
 let throttle = subject
     .throttle(for: .seconds(1.0), scheduler: DispatchQueue.main, latest: true)
     .share()
 //subscription
 subject
     .sink { string in
         print("\(printDate()) - 🔵 : \(string)")
     }
     .store(in: &subscriptions)
 throttle
     .sink { string in
         print("\(printDate()) - 🔴 : \(string)")
     }
     .store(in: &subscriptions)
 //loop
 let now = DispatchTime.now()
 for item in typingHelloWorld {
     DispatchQueue.main.asyncAfter(deadline: now + item.0) {
         subject.send(item.1)
     }
 }
 Giải thích:

 Ở giây thứ 0.0 thì chưa có gì mới từ subject và throttle bắt đầu sau 1.0 giây
 Tới thời điểm 1.0 thì có dữ liệu là Hello vì nó đc phát đi bởi subject ở 0.6
 Nhưng tới 2.0 thì vẫn không có gì mới để throttle phát đi vì subject lúc đó mới phát Hello cách
 Tới thời điểm 3.0 thì subject đã có Hello world ở 2.5 rồi, nên throttle sẽ phát được
 Xem kết quả chạy chương trình:

 16:04:51.8 - 🔵 : H
 16:04:51.9 - 🔵 : He
 16:04:52.0 - 🔵 : Hel
 16:04:52.1 - 🔵 : Hell
 16:04:52.3 - 🔵 : Hello
 16:04:52.4 - 🔵 : Hello
 16:04:52.8 - 🔴 : Hello
 16:04:53.8 - 🔵 : Hello W
 16:04:54.1 - 🔵 : Hello Wo
 16:04:54.1 - 🔵 : Hello Wor
 16:04:54.4 - 🔵 : Hello Worl
 16:04:54.4 - 🔵 : Hello World
 16:04:54.8 - 🔴 : Hello World
 Tóm tắt nhanh 2 em này:

 debounce lúc nào source ngừng một khoảng thời gian theo cài đặt, thì sẽ phát đi giá trị mới nhất
 throttle không quan tâm soucer dừng lại lúc nào, miễn tới thời gian điều tiết thì sẽ lấy giá trị (mới nhất hoặc đầu tiên trong khoảng thời gian điều tiết) để phát đi. Nếu không có chi thì sẽ âm thầm skip
 4. Timing out
 Toán tử này rất chi là dễ hiểu, bạn cần set cho nó 1 thời gian. Nếu quá thời gian đó mà publisher gốc không có phát bất cứ gì ra thì publisher timeout sẽ tự động kết thúc.

 Còn nếu có giá trị gì mới được phát trong thời gian timeout thì sẽ tính lại từ đầu.

 Xem đoạn code sau:

     let subject = PassthroughSubject<Void, Never>()

     let timeoutSubject = subject.timeout(.seconds(5), scheduler: DispatchQueue.main)

     subject
         .sink(receiveCompletion: { print("\(printDate()) - 🔵 completion: ", $0) }) { print("\(printDate()) - 🔵 : event")}
         .store(in: &subscriptions)

     timeoutSubject
         .sink(receiveCompletion: { print("\(printDate()) - 🔴 completion: ", $0) }) { print("\(printDate()) - 🔴 : event")}
         .store(in: &subscriptions)

     print("\(printDate()) - BEGIN")

     DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
         subject.send()
     }
 Đơn giản là build lên và xem. Tuy nhiên, nếu quá timeout thì sẽ sang completion là finished. Cái này có vẻ sai sai. Nên ta sẽ edit lại đoạn code trên để có thể gởi về error.

 Khai báo thêm 1 enum để handler các error

 enum TimeoutError: Error {
     case timedOut
 }
 Cài đặt lại code khởi tạo của publisher timeout

 let subject = PassthroughSubject<Void, TimeoutError>()

 let timeoutSubject = subject
             .timeout(.seconds(5), scheduler: DispatchQueue.main, customError: {.timedOut})
 Mọi thứ còn lại không thay đổi gì. Run lại và xem kết quả đã đúng như dự tính chưa?

 16:09:56.6 - BEGIN
 16:09:58.8 - 🔵 : event
 16:09:58.8 - 🔴 : event
 16:10:03.9 - 🔴 completion:  failure(__lldb_expr_17.TimeoutError.timedOut)
 5. Measuring time
 Toán tử này, đo lường thời gian khi có sự thay đổi trên publisher. Nói chung chưa thấy có ý nghĩa chi hết. Chắc ở các phần nâng cao.

 Xem code ví dụ:

 //data
 let typingHelloWorld: [(TimeInterval, String)] = [
   (0.0, "H"),
   (0.1, "He"),
   (0.2, "Hel"),
   (0.3, "Hell"),
   (0.5, "Hello"),
   (0.6, "Hello "),
   (2.0, "Hello W"),
   (2.1, "Hello Wo"),
   (2.2, "Hello Wor"),
   (2.4, "Hello Worl"),
   (2.5, "Hello World")
 ]
 //subject
 let subject = PassthroughSubject<String, Never>()
 //measure
 let measureSubject = subject.measureInterval(using: DispatchQueue.main)
 let measureSubject2 = subject.measureInterval(using: RunLoop.main)
 //subscription
 subject
     .sink { string in
         print("\(printDate()) - 🔵 : \(string)")
     }
     .store(in: &subscriptions)
 measureSubject
     .sink { string in
         print("\(printDate()) - 🔴 : \(string)")
     }
     .store(in: &subscriptions)
 measureSubject2
     .sink { string in
         print("\(printDate()) - 🔶 : \(string)")
     }
     .store(in: &subscriptions)
 //loop
 let now = DispatchTime.now()
 for item in typingHelloWorld {
     DispatchQueue.main.asyncAfter(deadline: now + item.0) {
         subject.send(item.1)
     }
 }
 Giải thích:

 subject là 1 publisher với Output là String
 Tạo tiếp 2 publisher với toán tử measureInterval. Khác nhau ở
 Trên main queue: thời gian thật với đơn vị thời gian là nano giây
 Runloop trên main : thời gian trên main thread với đơn vị thời gian là giây
 Tiến hành subscription các publisher
 Loop để subject phát ra các giái trị
 Kết quả chạy chương trình như sau:

 16:15:16.9 - 🔵 : H
 16:15:16.9 - 🔴 : Stride(magnitude: 14150674)
 16:15:16.9 - 🔶 : Stride(magnitude: 0.013264894485473633)
 16:15:17.0 - 🔵 : He
 16:15:17.0 - 🔴 : Stride(magnitude: 92261574)
 16:15:17.0 - 🔶 : Stride(magnitude: 0.09206008911132812)
 16:15:17.1 - 🔵 : Hel
 16:15:17.1 - 🔴 : Stride(magnitude: 99538358)
 16:15:17.1 - 🔶 : Stride(magnitude: 0.0997239351272583)
 16:15:17.2 - 🔵 : Hell
 16:15:17.2 - 🔴 : Stride(magnitude: 119046120)
 16:15:17.2 - 🔶 : Stride(magnitude: 0.11890506744384766)
 16:15:17.4 - 🔵 : Hello
 16:15:17.4 - 🔴 : Stride(magnitude: 217532048)
 16:15:17.4 - 🔶 : Stride(magnitude: 0.2176969051361084)
 16:15:17.5 - 🔵 : Hello
 16:15:17.5 - 🔴 : Stride(magnitude: 115862662)
 16:15:17.5 - 🔶 : Stride(magnitude: 0.11581504344940186)
 16:15:19.1 - 🔵 : Hello W
 16:15:19.1 - 🔴 : Stride(magnitude: 1533730594)
 16:15:19.1 - 🔶 : Stride(magnitude: 1.5338540077209473)
 16:15:19.1 - 🔵 : Hello Wo
 16:15:19.1 - 🔴 : Stride(magnitude: 2019553)
 16:15:19.1 - 🔶 : Stride(magnitude: 0.0020079612731933594)
 16:15:19.3 - 🔵 : Hello Wor
 16:15:19.3 - 🔴 : Stride(magnitude: 215367307)
 16:15:19.3 - 🔶 : Stride(magnitude: 0.21544504165649414)
 16:15:19.3 - 🔵 : Hello Worl
 16:15:19.3 - 🔴 : Stride(magnitude: 2165601)
 16:15:19.3 - 🔶 : Stride(magnitude: 0.001994013786315918)
 16:15:19.6 - 🔵 : Hello World
 16:15:19.6 - 🔴 : Stride(magnitude: 330266556)
 16:15:19.6 - 🔶 : Stride(magnitude: 0.33020997047424316)


 Tóm tắt
 delay : cứ sau 1 khoảng thời gian thì sẽ phát lại giá trị của publisher gốc
 collect : gôm các giá trị mà publisher gốc phát ra, rồi sẽ phát lại. Có 2 tiêu chí
 theo thời gian chờ
 theo số lượng cần gom
 debounce : lúc nào source ngừng một khoảng thời gian theo cài đặt thì sẽ phát đi giá trị mới nhất
 throttle không quan tâm soucer dừng lại lúc nào, miễn tới thời gian điều tiết thì sẽ lấy giá trị (mới nhất hoặc đầu tiên trong khoảng thời gian điều tiết) để phát đi. Nếu không có chi thì sẽ âm thầm skip
 timeout : hết thời gian mà không có giá trị nào được phát đi, thì auto kết thúc
 Kết hợp thêm error để cho ngầu
 measureInterval : đo thời gian của publisher phát tín hiệu hoặc có sự thay đổi nào đó
 */
