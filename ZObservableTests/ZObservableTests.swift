//
//	ZObservableTests.swift
//	ZObservableTests
//
//	Created by Kaz Yoshikawa on 11/8/16.
//
//

import XCTest

class Logger {
	var records = [String]()
	func append(_ record: String) {
		records.append(record)
	}
}

class Observer: ZObserver {
	let logger: Logger
	let name: String
	init(logger: Logger, name: String) {
		self.logger = logger
		self.name = name
	}
	func observableDidChange(_ observable: ZObservable) {
		switch observable {
		case let object as Observable<String>:
			self.logger.append(self.name + ":" + object.string)
		case let object as Observable<Int>:
			self.logger.append(self.name + ":" + object.string)
		default: break
		}
	}
}

class Observable<T>: ZObservable {
	var value: T? {
		didSet { self.observableDidChange() }
	}
	var string: String {
		if let value = value { return "\(value)" }
		else { return "nil" }
	}
}


func == (lhs: [String], rhs: [String]) -> Bool {
	var enumerator1 = lhs.makeIterator()
	var enumerator2 = rhs.makeIterator()

	if lhs.count != rhs.count { return false }

	while let object1 = enumerator1.next(), let object2 = enumerator2.next() {
		if object1 != object2 {
			return false
		}
	}
	return true
}

class ZObservableTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testBasic() {
		let logger = Logger()
		let observer = Observer(logger: logger, name: "city")
		let observable = Observable<String>()
		observable.addObserver(observer)
		observable.value = "Tokyo"
		observable.value = "Osaka"
		XCTAssert(logger.records == ["city:Tokyo", "city:Osaka"])
	}

	func testOutOfScope() {
		let logger = Logger()
		let observer = Observer(logger: logger, name: "food")
		do {
			let observable = Observable<String>()
			observable.addObserver(observer)
			observable.value = "sushi"
			observable.value = "tempura"
		}
		XCTAssert(logger.records == ["food:sushi", "food:tempura"])
	}

	func testRemovingObserver() {
		let logger = Logger()
		let observable = Observable<String>()
		let observer = Observer(logger: logger, name: "color")
		observable.addObserver(observer)

		observable.value = "blue"
		observable.value = "black"
		observable.removeObserver(observer)
		
		observable.value = "red"
		observable.value = "green"

		XCTAssert(logger.records == ["color:blue", "color:black"])
	}

	func testRemovingObservable() {
		let logger = Logger()
		let observable = Observable<String>()
		let observer = Observer(logger: logger, name: "color")
		observable.addObserver(observer)
		print("1", observable.observers)

		observable.value = "blue"
		observable.value = "black"
		observer.removeObservable(observable)
		print("2", observable.observers)
		
		observable.value = "red"
		observable.value = "green"
		print(logger.records)
		XCTAssert(logger.records == ["color:blue", "color:black"])
	}


	func testMultipleObservers() {
		let logger = Logger()
		let observable = Observable<String>()
		let observer1 = Observer(logger: logger, name: "city")
		let observer2 = Observer(logger: logger, name: "food")
		let observer3 = Observer(logger: logger, name: "color")
		observable.addObserver(observer1)
		observable.addObserver(observer2)
		observable.addObserver(observer3)
		observable.value = "wow"
		XCTAssert(Set<String>(logger.records) == Set<String>(["city:wow", "food:wow", "color:wow"]))
	}

	func testTypeCombination() {
		let logger = Logger()
		let observable1 = Observable<String>()
		let observable2 = Observable<Int>()
		let observer = Observer(logger: logger, name: "what")
		observable1.addObserver(observer)
		observable2.addObserver(observer)
		observable1.value = "fire"
		observable2.value = 42
		XCTAssert(Set<String>(logger.records) == Set<String>(["what:fire", "what:42"]))
	}

	func testPerformanceExample() {
		self.measure {
		}
	}
	
}
