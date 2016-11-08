![swift](https://img.shields.io/badge/swift-3.0-orange.svg) ![license](https://img.shields.io/badge/license-MIT-yellow.svg)

## ZObservable

When there are some changes made on a model object, some views, view controllers and others may be interested in to get notified that changes for updating user interfaces for example.  We call these mechanism is called observable and observer in this documentation.  `ZObservable` and `ZObserver` are designed for this purpose.  It it based on protocol, and it is lightweight, so that there aren't much features in there, but it does the job.

### ZObservable

Here is the typical implementation of observable side.  Assume there is a property called `value`, which is being interested in other objects to get notified upon changes.  You may write `didSet` or other mechanism to detect the changes, and call `observableDidChange()`.  As you can see, this is not automatic, trigger to make notifications are made programatically.


```.swift
class MyObservable: ZObservable {
	var value: Int = 0 {
		didSet {
			self.observableDidChange()
		}
	}
}
```

### ZObserver

Here is the typical implementation of observer side.  Observer class must implement `func observableDidChange(_ observable: ZObservable)`, this is the place to get called when interested models are changed.  Since an observer is able to listen to multiple types or instances, you might use `switch` statement or other to identify which type or which instance has made some changes as follows.

```.swift
class MyObserver: ZObserver {
	func observableDidChange(_ observable: ZObservable) {
		switch observable {
		case let object as MyObservable:
			print("\(object) did change to \(object.value).")
		default:
			break
		}
	}
}
```

### Start Listening

By adding observer object to observable object by calling `addObserver()` method, now this notification mechanism is set and ready for making changes.

```.swift
let observable = MyObservable()
let observer = MyObserver()
observable.addObserver(observer)
```

### Make some changes to get notified

When ever you made some changes to `value`, then observer will get called and left some foot print on console screen.

```.swift
observable.value = 1 // "MyObservable did change to 1."
observable.value = 3 // "MyObservable did change to 3."
observable.value = 7 // "MyObservable did change to 7."
```

### Stop listening

When observer or observable is no longer interested in get notified then call ether methods to stop notifying.  However, both observers and observables are weakly referenced internally, whichever either observer or observable went out of scope to get released, the notification related to that object also will be lost.  So in many cases, you may not have remove observer or observable programatically.

```.swift
observable.removeObserver(observer)
```

```.swift
observer.removeObservable(observable)
```

### Issues

Since `ZObservable` and `ZObserver` are protocol and protocol extension base, but some classes like `NSMutableString`, `NSMutableArray` and `NSMutableDictionary` can be `ZObservable` but notification capabilities will be lost after made changes.  I am assuming this is caused by cluster classes but I am not sure.

```.swift
class Observer: ZObserver {
	func observableDidChange(_ observable: ZObservable) {
		switch observable {
		case let string as NSMutableString:
			print("\(string) did change.")
		case let array as NSMutableArray:
			print("\(array) did change.")
		case let dictionary as NSMutableDictionary:
			print("\(dictionary) did change.")
		default:
			break
		}
	}
}

extension NSMutableString: ZObservable {}
extension NSMutableArray: ZObservable {}
extension NSMutableDictionary: ZObservable {}

let string = NSMutableString(string: "abc")
let array = NSMutableArray(array: [1, 2, 3])
let dictionary = NSMutableDictionary(dictionary: ["a": 1, "b": 2])

let observer = Observer()
string.addObserver(observer)
array.addObserver(observer)
dictionary.addObserver(observer)

string.observableDidChange() // notify
array.observableDidChange() // notify
dictionary.observableDidChange() // notify

string.append("def")
array.add(4)
dictionary["c"] = 3

string.observableDidChange() // not notify
array.observableDidChange() // not notify
dictionary.observableDidChange() // not notify
```

But `NSMutableURLRequest` and many other foundation classes are other classes are Ok to be observable, but needs to trigger notification manually and it just works.  

```.swift
extension NSMutableURLRequest: ZObservable {}

let request = NSMutableURLRequest(url: URL(string: "https://domain.com")!)
let observer = Observer()
request.addObserver(observer)
request.observableDidChange() // notify
request.addValue("string", forHTTPHeaderField: "custom")
request.observableDidChange() // notify
```


### Feedback

If you have found any bugs or issues, please feel free to contact Kaz Yoshikawa [kaz@digitallynx.com](kaz@digitallynx.com)

### Environment

```.log
Xcode Version 8.1 (8B62)
Apple Swift version 3.0.1 (swiftlang-800.0.58.6 clang-800.0.42.1)
```


### License

The MIT License.

