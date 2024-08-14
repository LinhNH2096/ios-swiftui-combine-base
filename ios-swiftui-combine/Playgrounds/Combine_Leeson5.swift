//
//  Combine_Leeson5.swift
//  ios-swiftui-combine
//
//  Created by LinhNguyen DGWA on 14/8/24.
//

import Foundation

/***
 1. Filtering basic
 1.1. filter
 Sử dụng toán tử filter để tiến hành lọc các phần tử được phát ra từ publisher. Dễ hiểu nhất là thử làm việc với 1 closure trả về giá trị bool. Xem ví dụ sau:

 var subscriptions = Set<AnyCancellable>()
 let numbers = (1...10).publisher
 numbers
     .filter { $0.isMultiple(of: 3) }
     .sink { n in
         print("\(n) is a multiple of 3!")
     }
     .store(in: &subscriptions)
 Giải thích:

 Tạo 1 publisher từ 1 Array Int từ 0 đến 10
 Sử dụng toán tử filter với quy luật đặt ra là giá trị của numbers phải chi hết cho 3
 Khi đó, các subcribers sẽ chỉ nhận được các giá trị mà được returm là true từ closure của filter
 1.2. removeDuplicates
 Khi bạn nhận quá nhiều các giá trị giống nhau, thì cách đơn giản nhất để loại trừ chúng thì sử dụng toán tử sau:

 var subscriptions = Set<AnyCancellable>()

 let words = "Hôm nay nay, trời trời nhẹ lên cao cao. Tôi Tôi buồn buồn không hiểu vì vì sao tôi tôi buồn."
     .components(separatedBy: " ")
     .publisher

 words
     .removeDuplicates()
     .sink(receiveValue: { print($0) })
     .store(in: &subscriptions)
 Chú ý, toán tử removeDuplicates chỉ bỏ đi các phần tử liên tiếp mà giống nhau, giữ lại duy nhất một phần tử. Còn nếu các phần tử giống nhau mà không liên tiếp thì vẫn bình thường.

 2. Compacting & ignoring
 2.1. compactMap

 Nhiều publisher sẽ phát ra các giá trị là optional hoặc nil. Và bạn không muốn thay thế nó, chỉ muốn đơn giản là loại bỏ nó đi. Thì hay dùng toán tử compactMap

 var subscriptions = Set<AnyCancellable>()
 let strings = ["a", "1.24", "3", "def", "45", "0.23"].publisher
 strings
     .compactMap { Float($0) }
     .sink(receiveValue: {  print($0) })
     .store(in: &subscriptions)
 Xem ví dụ trên thì bạn cũng sẽ tự hiểu ra. Hiểu đơn giản thì nó cũng như map, biến đổi các phần tử với kiểu giá trị này thành kiểu giá trị khác và lượt bỏ đi các giá trị không đạt theo điều kiện.

 2.2. ignoreOutPut
 Xem đoạn code sau:

 var subscriptions = Set<AnyCancellable>()
 let numbers = (1...10_000_000).publisher
 numbers
     .ignoreOutput()
     .sink(receiveCompletion: { print("Completed with: \($0)") }, receiveValue: { print($0) })
     .store(in: &subscriptions)
 Với toán tử ignoreOutput , thì sẽ loại trừ hết tất cả các phần tử được phát ra. Tới lúc nhận được completion thì sẽ kết thúc.

 3. Finding values
 3.1. first(where:)
 Dùng để tìm kiếm phần tử đầu tiên phù hợp với yêu cầu đặt ra. Sau đó sẽ tự completion. Xem đoạn code sau:

 var subscriptions = Set<AnyCancellable>()
 let numbers = (1...9).publisher
 numbers
   .print("numbers")
   .first(where: { $0 % 2 == 0 })
   .sink(receiveCompletion: { print("Completed with: \($0)") },
         receiveValue: { print($0) })
   .store(in: &subscriptions)
 Ta có 1 Array Int từ 0 đến 9 và biến nó thành 1 publisher.
 Sau đó dùng hàm print với tiền tố in ra là numbers –> để kiểm tra các giá trị có nhận được lần lượt hay không?
 Sử dụng toán tử first để tìm giá trị đầu tiên phù hợp với điều kiện là chia hết cho 2
 Sau đó subscription nó và in giá trị nhận được ra.
 Ta thấy, sau khi gặp giá trị đầu tiền phù hợp điều kiện thì publisher sẽ gọi completion.

 3.2. last(where:)
 Đối trọng lại với first. Sẽ tìm ra phần tử cuối cùng được phát đi phù hợp với điều kiện. Miễn là trước khi có completion. Lại xem và thấu hiểu đoạn code sau:

 var subscriptions = Set<AnyCancellable>()
 let numbers = PassthroughSubject<Int, Never>()
 numbers
   .last(where: { $0 % 2 == 0 })
   .sink(receiveCompletion: { print("Completed with: \($0)") },
         receiveValue: { print($0) })
   .store(in: &subscriptions)
 numbers.send(1)
 numbers.send(2)
 numbers.send(3)
 numbers.send(4)
 numbers.send(5)
 numbers.send(completion: .finished)
 Lần này sử dụng 1 subject để tiện phát theo ý mình. Bạn sẽ thấy giá trị in ra được là 4. Và tất nhiên phải sau khi phát completion thì mới in được giá trị ra.

 4. Dropping values
 Các toán tử này sẽ giúp loại bỏ đi nhiều phần tử. Mà không cần quan tâm gì nhiều tới điều kiện. Chỉ quan tâm tới thứ tự và số lượng.

 4.1. dropFirst
 Xem đoạn code sau:

 let numbers = ["a","b","c","e","f","g","h","i","k","l","m","n"].publisher
     numbers
         .dropFirst(8)
         .sink(receiveValue: { print($0) })
         .store(in: &subscriptions)
 Toán tử này sẽ có 1 tham số là số lượng các giá trị sẽ được bỏ đi. Với ví dụ trên thì phần tử thứ 9 sẽ được in ra, các phần tử trước nó sẽ bị loại bỏ đi.

 4.2. drop(while:)
 Toán tử này là phiên bản nâng cấp hơn. Khi bạn không xác định được số lượng các phần tử cần phải loại trừ đi. Thì sẽ đưa cho nó 1 điều kiện. Và trong vòng while, thì phần tử nào thoả mãn điều kiện sẽ bị loại trừ. Cho đến khi gặp phần tử đầu tiên không toản mãn. Từ phần tử đó trở về sau (cho đến lúc kết thúc) thì các subcribers sẽ nhận được các giá trị đó.

 Ví dụ:

 let numbers = (1...10).publisher
 numbers
   .drop(while: {
     print("x")
     return $0 % 5 != 0
   })
   .sink(receiveValue: { print($0) })
   .store(in: &subscriptions)
 Ưu điểm là cách này có thể handle được các phần tử bị loại trừ. Tuy nhiên không thể nhận được chúng.

 4.3. drop(untilOutputFrom:)
 Một bài toán được đưa ra như sau:

 Bạn tap liên tục vào một cái nút
 Lúc nào có trạng thái isReady thì sẽ nhận giá trị từ cái nút bấm đó
 Code như sau:

   let isReady = PassthroughSubject<Void, Never>()
   let taps = PassthroughSubject<Int, Never>()

   taps
     .drop(untilOutputFrom: isReady)
     .sink(receiveValue: { print($0) })
     .store(in: &subscriptions)

   (1...15).forEach { n in
     taps.send(n)

     if n == 3 {
       isReady.send()
     }
   }
 Giải thích:

 isReady là 1 subject. Với kiểu Void nên chi phát tín hiệu chứ không có giá trị được gởi đi
 taps là một subject với Output là Int
 Tiến hành subcription taps, trước đó thì gọi toán tử drop(untilOutputFrom:) để lắng nghe sự kiện phát ra từ isReady
 For xem như là chạy liên tục, mỗi lần thì taps sẽ phát đi 1 giá trị
 Với n == 3, thì isReady sẽ phát
 5. Limiting values
 Đối trọng với drop thì toán tử prefix sẽ làm điều ngược lại ngược lại:

 prefix(:) Giữ lại các phần tử từ lúc đầu tiên tới index đó (với index là tham số truyền vào)
 prefix(while:) Giữ lại các phần tử cho đến khi điều kiện không còn thoả mãn nữa
 prefix(untilOutputFrom:) Giữ lại các phần tử cho đến khi nhận được sự kiện phát của 1 publisher khác
 Xem ví dụ và chiêm nghiệm

 let numbers = (1...10).publisher

   numbers
     .prefix(2)
     .sink(receiveCompletion: { print("Completed with: \($0)") },
           receiveValue: { print($0) })
     .store(in: &subscriptions)
 Giữa lại 2 phần tử đầu tiên nhận được, các phần tử còn lại thì bỏ qua

 let numbers = (1...10).publisher

   numbers
     .prefix(while: { $0 < 7 })
     .sink(receiveCompletion: { print("Completed with: \($0)") },
           receiveValue: { print($0) })
     .store(in: &subscriptions)
 Các phần tử đầu tiên mà bé hơn 7 thì sẽ được in ra. Tại phần tử nào mà đã thoả mãn điều kiện, thì từ đó trở về sau sẽ bị skip.

 let isReady = PassthroughSubject<Void, Never>()
 let taps = PassthroughSubject<Int, Never>()
   taps
     .prefix(untilOutputFrom: isReady)
     .sink(receiveCompletion: { print("Completed with: \($0)") },
           receiveValue: { print($0) })
     .store(in: &subscriptions)

   (1...15).forEach { n in
     taps.send(n)

     if n == 5 {
       isReady.send()
     }
   }
 Các sự kiện taps sẽ nhận được liên tiếp, cho tới khi isReady phát.

  Với untilOutputFrom cho cả 2 toán tử drop và prefix thì được xem như là một trigger. Cái này sẽ rất là hữu ích sau này.
 Tóm tắt
 Filter lọc các phần tử phát ra theo 1 điều kiện nào đó
 removeDuplicates bỏ các các phần tử liên tiếp giống nhau. Chỉ giữ lại 1 mà thôi.
 compacMap tương tự như map. Nhưng nó sẽ auto bỏ đi các phần tử mà không biến đổi được
 ignoreOutput khi bạn không muốn nhận gì từ publisher
 first(where:) & last(where:) tìm kiến phần tử đầu tiên hoặc cuối cùng thoả điều kiện
 Họ nhà drop bỏ đi các phần tử theo 1 quy luật nào đó
 Bây giờ có sự so sánh sự khác nhau giữa filter và drop
 Điểm thứ 1: điều kiện
 Filter : cho phép các giá trị thoả mãn điều kiện được thông qua
 Drop : bỏ qua các giá trị thoả mãn điều kiện
 Điểm thứ 2: duyệt phần tử
 Filter: sau khi thoả điều kiện, thì các phần tử vẫn bị duyệt qua
 Drop: sẽ dừng việc kiểm tra khi đã thoả điều kiện
 Tóm tắt cho drop
 dropFirst cho giá trị tĩnh
 drop(while:) cho điều kiện
 drop(untilOutputFrom:) cho một publisher
 Toán tử prefix ngược lại với drop. Nó nhằm giữ lại các phần tử được phát ra với 1 quy luật nào đó.
 */
