//	ZObservable
//	ZKit
//
//	The MIT License (MIT)
//
//	Copyright (c) 2016 Electricwoods LLC, Kaz Yoshikawa.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy 
//	of this software and associated documentation files (the "Software"), to deal 
//	in the Software without restriction, including without limitation the rights 
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
//	copies of the Software, and to permit persons to whom the Software is 
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in 
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.


import Foundation


public protocol ZObserver: ZObservable {
	func observableDidChange(_ observable: ZObservable)
	var observables: [ZObservable] { get }
}

public extension ZObserver {
	var observables: [ZObservable] {
		return ZObservatory.shared.observables(for: self)
	}
	func removeObservable(_ observable: ZObservable) {
		return ZObservatory.shared.removeObservable(observable, for: self)
	}
}


public protocol ZObservable: AnyObject {
	func observableDidChange()
	func addObserver(_ observer: ZObserver)
	var observers: [ZObserver] { get }
}

public extension ZObservable {
	func observableDidChange() {
		ZObservatory.observableDidChange(self)
	}
	func addObserver(_ observer: ZObserver) {
		ZObservatory.shared.add(observer: observer, observable: self)
	}
	func removeObserver(_ observer: ZObserver) {
		ZObservatory.shared.removeObserver(observer, for: self)
	}
	var observers: [ZObserver] {
		return ZObservatory.shared.observers(for: self)
	}
}


public class ZObservatory {

	fileprivate var table = NSMapTable<AnyObject, ZWeakObjects<AnyObject>>.weakToStrongObjects()

	public static let shared = ZObservatory()

	private let _lock = NSLock()

	private init() {
	}
	
	public func observableDidChange(_ observable: ZObservable) {
		for observer in self.observers(for: observable) {
			observer.observableDidChange(observable)
		}
	}

	public class func observableDidChange(_ observable: ZObservable) {
		self.shared.observableDidChange(observable)
	}

	func add(observer: ZObserver, observable: ZObservable) {
		_lock.lock()
		defer { _lock.unlock() }

		if let objectSet = self.table.object(forKey: observable) {
			objectSet.add(observer)
		}
		else {
			let objectSet = ZWeakObjects<AnyObject>()
			objectSet.add(observer as AnyObject)
			self.table.setObject(objectSet, forKey: observable)
		}
	}

	func removeObserver(_ observer: ZObserver, for observable: ZObservable) {
		_lock.lock()
		defer { _lock.unlock() }

		if let _ = self.table.object(forKey: observable) {
			self.table.removeObject(forKey: observable)
		}
	}

	func removeObservable(_ observable: ZObservable, for observer: ZObserver) {
		_lock.lock()
		defer { _lock.unlock() }

		if let objectSet = self.table.object(forKey: observable) {
			print("\(#function): \(#line)")
			objectSet.remove(observer)
			print("\(#function): \(#line)")
			if objectSet.objects.count == 0 {
				print("\(#function): \(#line)")
				self.table.removeObject(forKey: observable)
			}
		}
	}

	public func observers(for observable: ZObservable) -> [ZObserver] {
		var observers = [ZObserver]()
		if let objectSet = self.table.object(forKey: observable) {
			for pointerObject in objectSet.objects {
				if let observer = pointerObject as? ZObserver {
					observers.append(observer)
				}
			}
		}
		return observers
	}

	public func observables(for observer: ZObserver) -> [ZObservable] {
		var observables = [ZObservable]()
		for observable in self.table.keyEnumerator() {
			if let observable = observable as? ZObservable {
				if let objectSet = self.table.object(forKey: observable) {
					if objectSet.contains(object: observer) {
						observables.append(observable)
					}
				}
			}
		}
		return observables
	}

	public var observables: [ZObservable] {
		var observables = [ZObservable]()
		for observable in self.table.keyEnumerator() {
			if let observable = observable as? ZObservable {
				observables.append(observable)
			}
		}
		return observables
	}
	
}


