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
        leesion_3()
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
        //            .store(in: &self.subscriptions)

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
