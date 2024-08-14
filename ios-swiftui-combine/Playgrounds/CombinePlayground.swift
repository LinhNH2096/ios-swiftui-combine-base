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
        leesion_5()
    }
}

// MARK: - LESSON 1
extension CombinePlayground {
    private func leesion_1() {
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
    private func leesion_2() {
        print("[CombinePlayground]: ===========")
        print("[CombinePlayground]: Combine Lesson 2\n")
        print("[CombinePlayground]: PUBLISHER")

        let helloPublisher: Publishers.Sequence<String, Never> = "Hello Combine".publisher
        let helloSubscribe: AnyCancellable = helloPublisher
            .sink { completion in
                print("[CombinePlayground]: \(completion)\n")
            } receiveValue: { value in
                print("[CombinePlayground]: Sink Value: \(value)")
            }

        let fibonacciPublisher: Publishers.Sequence<[Int], Never> = [0,1,1,2,3,5].publisher
        let fibonacciSubscribe: AnyCancellable = fibonacciPublisher
            .sink { completion in
                print("[CombinePlayground]: \(completion)\n")
            } receiveValue: { value in
                print("[CombinePlayground]: Sink Value: \(value)")
            }

        let dictPublisher: Publishers.Sequence<[Int: String], Never> = [1: "Hello", 2: "World"].publisher
        let dictSubscribe = dictPublisher
            .sink { completion in
                print("[CombinePlayground]: \(completion)\n")
            } receiveValue: { value in
                print("[CombinePlayground]: Sink Value: \(value)")
            }


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
        let passthroughSubscribe1 = passthroughSubject.sink { completion in
            print("[CombinePlayground]: PassthroughSubject 1 \(completion)")
        } receiveValue: { value in
            print("[CombinePlayground]: PassthroughSubject 1: \(value)")
        }

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
    private func leesion_3() {
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
    private func leesion_4() {
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
    private func leesion_5() {
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
