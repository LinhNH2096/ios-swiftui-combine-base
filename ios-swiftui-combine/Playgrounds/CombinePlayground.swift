//
//  CombinePlayground.swift
//  ios-swiftui-combine
//
//  Created by LinhNguyen DGWA on 12/8/24.
//

import Combine
import Foundation

final class CombinePlayground {
    // Singleton
    static var shared: CombinePlayground = CombinePlayground()
    private init() { }

    // CombinePlayground Variables
    var subscriptions = Set<AnyCancellable>()

    func start() {
        print("[CombinePlayground]: START")
        leeson_8()
    }
}

// MARK: - LESSON 1
extension CombinePlayground {
    private func leeson_1() {
        print("[CombinePlayground]: ===========")
        print("[CombinePlayground]: Combine Lesson 1\n")
        print("[CombinePlayground]: SINK")

        let justPublisher: Just<String> = Just("Combine Lesson 1")
        let subscriber_1: AnyCancellable = justPublisher.sink { completion in
            print("[CombinePlayground]: Sink Completion: \(completion)")
        } receiveValue: { value in
            print("[CombinePlayground]: Sink Value: \(value)")
        }
        subscriber_1.cancel()

        print("[CombinePlayground]: ASSIGN")
        let obj = Lesson1MyClass()
        let arrayPublisher: Publishers.Sequence<[String], Never> = ["Apple", "iOS", "Combine"].publisher
        let subscribe_2: AnyCancellable = arrayPublisher.assign(to: \.stringValue, on: obj)
        subscribe_2.cancel()

        print("[CombinePlayground]: SUBSCRIBER & OPERATORS")
        let helloPublisher = ["H", "e", "l", "l", "o", " ", nil, "W", "o", nil, "r", "l", "d", "!"].publisher
        let helloSubscriber = Subscribers.Sink<String, Never> { completion in
            print("[CombinePlayground]: Sink Subscibe Completion: \(completion)")
        } receiveValue: { value in
            print("[CombinePlayground]: Sink Value: \(value)")
        }

        helloPublisher
            .compactMap({ $0 })
            .reduce("", +)
            .subscribe(helloSubscriber)
    }

    private class Lesson1MyClass {
        var stringValue: String = "" {
            didSet {
                print("[CombinePlayground]: Assign Value - \(stringValue)")
            }
        }
    }
}

// MARK: - LESSON 2
extension CombinePlayground {
    private func leeson_2() {
        print("[CombinePlayground]: ===========")
        print("[CombinePlayground]: Combine Lesson 2\n")
        print("[CombinePlayground]: PUBLISHER")

        let helloPublisher: Publishers.Sequence<String, Never> = "Hello Combine".publisher
        helloPublisher
            .sink { completion in
                print("[CombinePlayground]: \(completion)\n")
            } receiveValue: { value in
                print("[CombinePlayground]: Sink Value: \(value)")
            }
            .cancel()

        let fibonacciPublisher: Publishers.Sequence<[Int], Never> = [0,1,1,2,3,5].publisher
        fibonacciPublisher
            .sink { completion in
                print("[CombinePlayground]: \(completion)\n")
            } receiveValue: { value in
                print("[CombinePlayground]: Sink Value: \(value)")
            }
            .cancel()

        let dictPublisher: Publishers.Sequence<[Int: String], Never> = [1: "Hello", 2: "World"].publisher
        dictPublisher
            .sink { completion in
                print("[CombinePlayground]: \(completion)\n")
            } receiveValue: { value in
                print("[CombinePlayground]: Sink Value: \(value)")
            }
            .cancel()

        let publisher1: Publishers.Sequence<[Int], Never> = Array(1...10).publisher
        let publisher2: Publishers.Sequence<[String], Never> = publisher1.map { $0.description }

        publisher1
            .reduce(0, +)
            .sink { completion in
                print("[CombinePlayground]: \(completion)\n")
            } receiveValue: { value in
                print("[CombinePlayground]: Sink Value: \(value)")
            }
            .cancel()

        publisher2
            .reduce("", +)
            .sink { completion in
                print("[CombinePlayground]: \(completion)\n")
            } receiveValue: { value in
                print("[CombinePlayground]: Sink Value: \(value)")
            }
            .cancel()

        let publisher3: Publishers.Sequence<[Int], Never> = Publishers.Sequence(sequence: [1, 1, 2, 3, 5, 8])

        let publisher4: Just = Just(100)

        let subscribe3: Subscribers.Sink<Int, Never> = Subscribers.Sink<Int, Never> { completion in
            print("[CombinePlayground]: \(completion)\n")
        } receiveValue: { value in
            print("[CombinePlayground]: Sink Value: \(value)")
        }

        Publishers.Merge(publisher3, publisher4)
            .subscribe(subscribe3)

        let user = Lesson2User(name: "Linh Nguyen", age: 20)
        let ageUserSubscribe = user.$age
            .sink { completion in
                print("[CombinePlayground]: \(completion)\n")
            } receiveValue: { value in
                print("[CombinePlayground]: User age: \(value)")
            }
        ageUserSubscribe.cancel() // cancel subscription
        user.age = 28

        print("[CombinePlayground]: \nFUTURE\n")

        let future: Future<Int, Never> = self.futureValue()
        future
            .sink { completion in
                print("[CombinePlayground]: Future completed \(completion)")
            } receiveValue: { value in
                print("[CombinePlayground]: Future value: \(value)")
            }
            .store(in: &self.subscriptions)

        print("[CombinePlayground]: \nSUBJECTS\n")
        let passthroughSubject = PassthroughSubject<Int, Never>()
        passthroughSubject.send(0)
        passthroughSubject.sink { completion in
            print("[CombinePlayground]: PassthroughSubject 1 \(completion)")
        } receiveValue: { value in
            print("[CombinePlayground]: PassthroughSubject 1: \(value)")
        }
        .store(in: &self.subscriptions)

        passthroughSubject.send(1)
        passthroughSubject.send(2)
        passthroughSubject.send(3)
        passthroughSubject.send(4)
        passthroughSubject.send(5)

        let passthroughSubscribe2 = passthroughSubject.sink { completion in
            print("[CombinePlayground]: PassthroughSubject 2 \(completion)")
        } receiveValue: { value in
            print("[CombinePlayground]: PassthroughSubject 2: \(value)")
        }
        passthroughSubscribe2.store(in: &self.subscriptions)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            passthroughSubject.send(6)
        }
        //        passthroughSubject.send(completion: .finished)


        let currentValueSubject = CurrentValueSubject<Int, Never>(0)

        let currentValueSubscribe1 = currentValueSubject
            .sink { completion in
                print("[CombinePlayground]: CurrentValueSubject 1 \(completion)")
            } receiveValue: { value in
                print("[CombinePlayground]: CurrentValueSubject 1: \(value)")
            }
        currentValueSubscribe1.cancel()

        currentValueSubject.send(2)
        currentValueSubject.send(3)
        currentValueSubject.send(4)
        currentValueSubject.send(5)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            currentValueSubject.send(6)
        }

        currentValueSubject
            .sink { completion in
                print("[CombinePlayground]: CurrentValueSubject 2 \(completion)")
            } receiveValue: { value in
                print("[CombinePlayground]: CurrentValueSubject 2: \(value)")
            }.store(in: &subscriptions)

        //        let anyPublisher: AnyPublisher = passthroughSubject.eraseToAnyPublisher()
        let anyPublisher: AnyPublisher = currentValueSubject.eraseToAnyPublisher()

        anyPublisher
            .sink { completion in
                print("[CombinePlayground]: AnyPublisher \(completion)")
            } receiveValue: { value in
                print("[CombinePlayground]: AnyPublisher: \(value)")
            }.store(in: &subscriptions)

    }

    private class Lesson2User {
        @Published var name: String
        @Published var age: Int

        init(name: String, age: Int) {
            self.name = name
            self.age = age
        }
    }

    private func futureValue() -> Future<Int, Never> {
        return Future<Int, Never> { promise in
            print("[CombinePlayground]: Future Function")
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                promise(.success(100))
            }
        }
    }
}

// MARK: - LESSON 3
extension CombinePlayground {
    private func leeson_3() {
        print("[CombinePlayground]: ===========")
        print("[CombinePlayground]: Combine Lesson 3\n")
        print("[CombinePlayground]: CUSTOM SUBSCRIBE")

        let dog = Lesson3Dog(name: "Milu")
        print("[CombinePlayground]: Dog Name: \(dog.name)")
        let subscriberAssign = Subscribers.Assign(object: dog, keyPath: \.name)
        let nameJust = Just("Miloo")
        nameJust.subscribe(subscriberAssign)
        print("[CombinePlayground]: Dog Name: \(dog.name)")

        let subscribeSink = Subscribers.Sink<String, Never> { completion in
            print("[CombinePlayground]: Subscribers Sink \(completion)")
        } receiveValue: { value in
            dog.name = value
            print("[CombinePlayground]: Subscribers Sink Value \(value)")
        }

        let nameSubject: PassthroughSubject<String, Never> = PassthroughSubject()
        //        subscribeSink.cancel() // Not work
        nameSubject.subscribe(subscribeSink)
        //        subscribeSink.cancel() // Work

        nameSubject.send("Mino")
        print("[CombinePlayground]: Dog Name: \(dog.name)")
        nameSubject.send(completion: .finished)
        print("[CombinePlayground]: Dog Name: \(dog.name)")

        let stringPublisher = Just("Linh Nguyen")
        let stringSubscribe = StringSubscribe()
        stringPublisher.subscribe(stringSubscribe)

        let intPublisher: Publishers.Sequence<[Int], Never> = Array(1...10).publisher
        let intSubscribe = IntSubscribe()
        intPublisher.subscribe(intSubscribe)

        print("\n")

        let newDog = Lesson3Dog(name: "Dog 1")

        let namePublisher: Publishers.Sequence<[String], Never> = Array(2...10).publisher.map({ "Dog \($0)" })

        namePublisher.subscribe(newDog)
        print("[CombinePlayground]: Dog: \(newDog.name)")
    }

    private class Lesson3Dog: Subscriber {
        typealias Input = String

        typealias Failure = Never

        func receive(subscription: any Subscription) {
            subscription.request(.max(5))
        }

        func receive(_ input: String) -> Subscribers.Demand {
            print("[CombinePlayground]: Received Dog name ", input)
            self.name = input
            return .none
        }

        func receive(completion: Subscribers.Completion<Never>) {
            print("[CombinePlayground]: Received Dog completion ", completion)
        }

        var name: String

        init(name: String) {
            self.name = name
        }
    }

    private class StringSubscribe: Subscriber {

        typealias Input = String

        typealias Failure = Never

        func receive(subscription: any Subscription) {
            subscription.request(.unlimited)
        }

        func receive(_ input: String) -> Subscribers.Demand {
            print("[CombinePlayground]: Received String value ", input)
            return .max(0)
        }

        func receive(completion: Subscribers.Completion<Never>) {
            print("[CombinePlayground]: Received String completion ", completion)
        }
    }

    private class IntSubscribe: Subscriber {

        typealias Input = Int

        typealias Failure = Never

        func receive(subscription: any Subscription) {
            subscription.request(.max(3))
        }

        func receive(_ input: Int) -> Subscribers.Demand {
            print("[CombinePlayground]: Received Int value ", input)
            return .max(0)
        }

        func receive(completion: Subscribers.Completion<Never>) {
            print("[CombinePlayground]: Received Int completion ", completion)
        }
    }

}

// MARK: - LESSON 4
extension CombinePlayground {
    private func leeson_4() {
        print("[CombinePlayground]: ===========")
        print("[CombinePlayground]: Combine Lesson 4\n")
        print("[CombinePlayground]: TRANSFORMING OPERATORS\n")

        let intPublisher: Publishers.Sequence<[Int], Never> = Array(0...9).publisher
        intPublisher
            .collect(3) // the number of element that enough to emit
            .sink { array in
                print("[CombinePlayground]: Collect array \(array)")
            }
            .cancel()

        let personPublisher: Publishers.Sequence<[Lesson4Person], Never> = [Lesson4Person(name: "MiMi", age: 3),
                                                                            Lesson4Person(name: "MiLy", age: 2),
                                                                            Lesson4Person(name: "PoChi", age: 1),
                                                                            Lesson4Person(name: "ChiPu", age: 3)].publisher
        personPublisher
            .sink { person in
                print("[CombinePlayground]: \(person.name) - \(person.age)")
            }
            .cancel()

        personPublisher
            .map({ person in
                return (person.name, person.age)
            })
            .sink { name, age in
                print("[CombinePlayground]: \(name) - \(age)")
            }
            .cancel()

        personPublisher
            .map(\.name, \.age)
            .sink { name, age in
                print("[CombinePlayground]: \(name) - \(age)")
            }
            .cancel()

        ["Hello", "world", nil, "!"].publisher
            .tryMap { word in
                return try self.throwFunction(input: word)
            }
            .sink { completion in
                print("[CombinePlayground]: Try Map completion \(completion)")
            } receiveValue: { value in
                print("[CombinePlayground]: Try Map valye \(value)")
            }
            .cancel()

        print("\n[CombinePlayground]: FLAT MAP")

        let chatterA = Lesson4Chatter(name: "A", message: CurrentValueSubject("--A đã vào room--"))
        let chatterB = Lesson4Chatter(name: "B", message: CurrentValueSubject("--B đã vào room--"))
        let chatterC = Lesson4Chatter(name: "C", message: CurrentValueSubject("--C đã vào room--"))
        chatterB.message.value = "B: Toi la B"
        let roomChat = PassthroughSubject<Lesson4Chatter, Never>()

        roomChat
            .flatMap(maxPublishers: .max(2)) { $0.message }
            .sink { chatCompletion in
                print("[CombinePlayground]: Chat Completion \(chatCompletion)")
            } receiveValue: { message in
                print("[ROOM]: \(message)")
            }
            .store(in: &subscriptions)

        roomChat.send(chatterA)
        roomChat.send(chatterC)
        chatterC.message.value = "C: Toi la C"
        chatterA.message.send("A: Hello !")
        roomChat.send(chatterB)
        chatterB.message.value = "B: Hello A"

        print("\n[CombinePlayground]: REPLACE")

        ["Hello", nil, "World", "!"].publisher
            .replaceNil(with: " ")
            .compactMap({ $0 })
            .sink(receiveValue: { print($0, terminator: " ")})
            .cancel()

        print("\n")

        Empty<Any, Never>()
            .replaceEmpty(with: "<3")
            .sink { value in
                print("[CombinePlayground]: value \(value)")
            }
            .cancel()

        (1...5).publisher
            .scan(0, +)
            .sink { value in
                print(value, terminator: " ")
            }
            .cancel()

        print("\n")

        (1...5).publisher
            .reduce(0, +)
            .sink { value in
                print(value )
            }
            .cancel()
    }

    private struct Lesson4Chatter {
        let name: String
        let message: CurrentValueSubject<String, Never>
    }

    private enum Lesson4Error: Error {
        case nilValue
    }

    private func throwFunction(input: String?) throws -> String {
        if input == nil {
            throw Lesson4Error.nilValue
        }
        return input!
    }

    private struct Lesson4Person {
        var name: String
        var age: Int
    }
}

// MARK: - LESSON 5
extension CombinePlayground {
    private func leeson_5() {
        print("[CombinePlayground]: ===========")
        print("[CombinePlayground]: Combine Lesson 5\n")
        print("[CombinePlayground]: FILTERING OPERATORS\n")
        let numberPublisher = (1...10).publisher

        numberPublisher
            .filter { number in
                number.isMultiple(of: 2)
            }
            .sink(receiveValue: { print($0, terminator: " ")})
            .cancel()

        print("\n")

        let wordsPublisher = "Hôm nay nay, trời trời nhẹ trời lên cao cao. Tôi Tôi buồn buồn không hiểu vì vì sao tôi tôi buồn."
            .components(separatedBy: " ")
            .publisher

        wordsPublisher
            .removeDuplicates()
            .sink(receiveValue: { print($0, terminator: " ")})
            .cancel()

        print("\n ignoreOutput")

        numberPublisher
            .ignoreOutput()
            .sink { completion in
                print("[CombinePlayground]: Number Publisher completion")
            } receiveValue: { value in
                print("[CombinePlayground]: Number \(value)")
            }
            .cancel()

        print("\n first where")
        numberPublisher
            .first(where: { $0 % 2 == 0 })
            .sink(receiveValue: { print($0)})
            .cancel()

        print("\n last where")
        numberPublisher
            .last(where: { $0 % 2 == 0 })
            .sink(receiveValue: { print($0)})
            .cancel()

        print("\n dropFirst")
        numberPublisher
            .dropFirst(5)
            .sink(receiveValue: { print($0)})
            .cancel()

        print("\n drop while")
        numberPublisher
            .drop(while: { $0 <= 5})
            .sink(receiveValue: { print($0)})
            .cancel()

        print("\n drop untilOutputFrom")
        let tapNumberSubject = PassthroughSubject<Int, Never>()
        let isReady = PassthroughSubject<Void, Never>()

        tapNumberSubject
            .drop(untilOutputFrom: isReady)
            .sink(receiveValue: { print($0, terminator: " ")})
            .store(in: &subscriptions)

        (1...10)
            .forEach { number in
                tapNumberSubject.send(number)
                if number == 5 {
                    isReady.send(())
                }
            }

        print("\n prefix")
        numberPublisher
            .prefix(5)
            .sink(receiveValue: { print($0, terminator: " ")})
            .cancel()

        print("\n prefix while")
        numberPublisher
            .prefix(while: { $0 < 5 })
            .sink(receiveValue: { print($0, terminator: " ")})
            .cancel()

        print("\n prefix untilOutputFrom")
        let sendSubject = PassthroughSubject<Int, Never>()
        let isDone = PassthroughSubject<Void, Never>()

        sendSubject
            .prefix(untilOutputFrom: isDone)
            .sink(receiveValue: { print($0, terminator: " ")})
            .store(in: &subscriptions)

        (1...15).forEach { n in
            sendSubject.send(n)

            if n == 5 {
                isDone.send()
            }
        }
    }
}

// MARK: - LESSON 6
extension CombinePlayground {
    private func leeson_6() {
        print("[CombinePlayground]: ===========")
        print("[CombinePlayground]: Combine Lesson \n")
        print("[CombinePlayground]: COMBINING OPERATORS\n")

        print("\n[CombinePlayground]: prepend")
        let numbers = [2, 3].publisher
        numbers
            .prepend(1, 2, 5)
            .prepend(0, -1)
            .sink(receiveValue: { print($0, terminator: " ")})
            .cancel()
        print("\n")

        numbers
            .prepend([0, 1])
            .prepend(Set(2...5))
            .prepend(stride(from: 6, to: 10, by: 2))
            .sink(receiveValue: { print($0, terminator: " ")})
            .cancel()
        print("\n")

        let prependPublisher = PassthroughSubject<Int, Never>()
        numbers
            .prepend(prependPublisher)
            .sink(receiveValue: { print($0, terminator: " ")})
            .store(in: &subscriptions)
        print("\n")
        prependPublisher.send(0)
        prependPublisher.send(1)
        prependPublisher.send(completion: .finished) // prepend must be completion for trigger own publisher

        print("\n[CombinePlayground]: Append")
        let appendPublisher = CurrentValueSubject<Int, Never>(0)

        Empty<Int, Never>()
            .replaceEmpty(with: 0)
            .append(13)
            .append([11, 12])
            .append(stride(from: 10, to: 15, by: 1))
            .append(appendPublisher)
            .sink(receiveValue: { print($0, terminator: " ")})
            .store(in: &subscriptions)
        appendPublisher.send(100)

        print("\n[CombinePlayground]: Switch To Lastest")
        let publisher1 = PassthroughSubject<Int, Never>()
        let publisher2 = PassthroughSubject<Int, Never>()
        let publisher3 = PassthroughSubject<Int, Never>()
        let publishers = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()

        publishers
        //            .flatMap({ $0 })
            .switchToLatest()
            .sink(receiveValue: { print($0, terminator: " ")})
            .store(in: &subscriptions)

        print("\n")

        publishers.send(publisher1)
        publishers.send(publisher2)
        publishers.send(publisher3)

        publisher2.send(21)
        publisher2.send(22)

        publisher1.send(11)
        publisher1.send(12)

        publisher3.send(31)
        publisher3.send(32)

        print("\n")

        let stringPublisher = CurrentValueSubject<String, Never>("-")
        let intPublisher = CurrentValueSubject<Int, Never>(0)

        stringPublisher.combineLatest(intPublisher) { string, int in
            return string + "-combine-" + int.description
        }
        .sink(receiveValue: { print($0, terminator: " ")})
        .store(in: &subscriptions)

        stringPublisher.zip(intPublisher) { string, int in
            return string + "-zip-" + int.description
        }
        .sink(receiveValue: { print($0, terminator: " ")})
        .store(in: &subscriptions)

        stringPublisher.send("Linh")
        stringPublisher.send("Nguyen")

        intPublisher.send(1)
        intPublisher.send(100)


        let publisher = ["A", "B", "C", "D", "E"].publisher
        publisher
            .output(in: 0...10)
            .sink(receiveCompletion: { print($0) },
                  receiveValue: { print("Value in range: \($0)") })
            .store(in: &subscriptions)

        (2...10).publisher
            .print("publisher")
            .allSatisfy { $0 % 2 == 0 }
            .sink(receiveValue: { allEven in
                print(allEven ? "All numbers are even"
                      : "Something is odd...")
            })
            .store(in: &subscriptions)

        let publisherWord = ["Hel", "lo", " ", "Wor", "ld", "!"].publisher

        publisherWord
            .reduce("", +)
            .sink(receiveValue: { print("Reduced into: \($0)") })
            .store(in: &subscriptions)

        publisherWord
            .scan("", +)
            .sink(receiveValue: { print("Scan into: \($0)") })
            .store(in: &subscriptions)
    }
}

// MARK: - LESSON 7
extension CombinePlayground {
    private func leeson_7() {
        print("[CombinePlayground]: ===========")
        print("[CombinePlayground]: Combine Lesson \n")
        print("[CombinePlayground]: TIME MANIPULATION OPERATORS\n")

        leeson7_measureInterval()
    }

    private func leeson7_share() {
        let dataPublisher = fetchData()

        dataPublisher
            .sink { data in
                print("FETCH1: \(data)")
            }
            .store(in: &subscriptions)

        dataPublisher
            .sink { data in
                print("FETCH2: \(data)")
            }
            .store(in: &subscriptions)
    }

    func fetchData() -> AnyPublisher<String, Never> {
        Future { promise in
            print("Bắt đầu tải dữ liệu từ mạng...")
            DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                promise(.success("Fetch data: SUCCESS"))
            }
        }
        .eraseToAnyPublisher()
    }

    private func leeson7_delay() {
        print("[Lession7]: ===========DELAY========")
        let timerPublisher = Timer
            .publish(every: 1, on: .main, in: .default)
            .autoconnect()

        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .long

        timerPublisher
            .handleEvents(receiveOutput: { date in
                print ("Sending Timestamp \'\(df.string(from: date))\' to delay()")
            })
            .delay(for: 3, scheduler: RunLoop.main)
            .sink(
                receiveCompletion: { print ("completion: \($0)", terminator: "\n") },
                receiveValue: { value in
                    let now = Date()
                    print ("At \(df.string(from: now)) received  Timestamp \'\(df.string(from: value))\' sent:\(String(format: "%.2f", now.timeIntervalSince(value))) secs ago", terminator: "\n")
                }
            )
            .store(in: &subscriptions)
    }

    private func leeson7_collect() {
        let timerPublisher = Timer
            .publish(every: 1, on: RunLoop.main, in: .default)
            .autoconnect()

        timerPublisher
            .collect(.byTime(RunLoop.current, .seconds(3)))
            .flatMap { dates in dates.publisher }
            .sink { completion in
                print("Completion: \(completion)")
            } receiveValue: { output in
                print("output: \(output)")
            }
            .store(in: &subscriptions)
    }

    private func leeson7_timeout() {
        let timerPublisher = Timer
            .publish(every: 1, on: RunLoop.main, in: .default)
            .autoconnect()

        timerPublisher
            .handleEvents(receiveOutput: { output in
                print("Output: \(output)")
            })
            .delay(for: 3, scheduler: RunLoop.current)
            .timeout(4, scheduler: RunLoop.current)
            .sink { completion in
                print("Completion: \(completion)")
            } receiveValue: { value in
                print("Value: \(value)")
            }
            .store(in: &subscriptions)
    }

    private func leeson7_measureInterval() {
        let timerPublisher = Timer
            .publish(every: 1, on: RunLoop.main, in: .default)
            .autoconnect()

        timerPublisher
            .measureInterval(using: DispatchQueue.main)
            .sink { string in
                   print("🔵 : \(string)")
               }
               .store(in: &subscriptions)

        timerPublisher
            .measureInterval(using: RunLoop.main)
            .sink { string in
                   print("🔴 : \(string)")
               }
               .store(in: &subscriptions)
    }
}

// MARK: - LESSON 8
extension CombinePlayground {
    private func leeson_8() {
        print("[CombinePlayground]: ===========")
        print("[CombinePlayground]: Combine Lesson \n")
        print("[CombinePlayground]: SEQUENCE OPERATORS\n")

        leeson8_finding()
    }

    private func leeson8_finding() {
        [1, -50, 246, 0].publisher
            .min()
            .sink(receiveValue: { print("Lowest value is \($0)") })
            .store(in: &subscriptions)

        ["12345",
         "ab",
         "hello world"]
            .compactMap { $0.data(using: .utf8) } // [Data]
            .publisher
            .max(by: { $0.count < $1.count }) // must be < operator
            .sink(receiveValue: { data in
                let string = String(data: data, encoding: .utf8)!
                print("Smallest data is \(string), \(data.count) bytes")
            })
            .store(in: &subscriptions)

        ["J", "O", "H", "N"]
            .publisher
            .first(where: { "Hello World".contains($0) })
            .sink(receiveValue: { print("First match is \($0)") })
            .store(in: &subscriptions)

        ["A", "B", "C"]
            .publisher
            .output(at: 3) // Out of bound -> emit Never
            .sink(receiveValue: { print("Value at index 1 is \($0)") })
            .store(in: &subscriptions)

        ["A", "B", "C", "D", "E"]
            .publisher
            .output(in: 0...10) // -1 make crash
            .collect()
            .sink(receiveCompletion: { print($0) },
                  receiveValue: { print("Value in range: \($0)") })
            .store(in: &subscriptions)

        ["A", "B", "C"]
            .publisher
            .count()
            .sink(receiveValue: { print("I have \($0) items") })
            .store(in: &subscriptions)

        [(1, "A"),
         (2, "B"),
         (3, "C"),
         (4, "D"),
         (5, "E"),
         (6, "F")]
        .publisher
        .map(Leeson8Person.init)
        .contains(where: { $0.id == 1 })
        .sink(receiveValue: { print($0, terminator: "\n")})
        .store(in: &subscriptions)
    }

    private struct Leeson8Person {
        var id: Int
        var name: String
    }
}
