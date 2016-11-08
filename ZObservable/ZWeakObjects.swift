//
//	ZWeakSet.swift
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
//


import Foundation


private class ZWeakContainer<T: AnyObject> {

	weak var object: T?
	
	init(_ object: T) {
		self.object = object
	}
}

private func == <T> (lhs: ZWeakContainer<T>, rhs: ZWeakContainer<T>) -> Bool {
	return lhs.object === rhs.object
}


public class ZWeakObjects<T: AnyObject>: Sequence {

	private var containers = [ZWeakContainer<T>]()
	
	public init() {
	}

	public init(_ objects: [T]) {
		self.containers = objects.map { ZWeakContainer($0) }
	}

	public var objects: [T] {
		return containers.flatMap { $0.object }
	}
	
	public func contains(object: T) -> Bool {
		for container in containers {
			if let _object = container.object, _object === object {
				return true
			}
		}
		return false
	}

	public func add(_ object: T) {
		compact()
		containers = self.objects.map { ZWeakContainer($0) }
		containers.append(ZWeakContainer(object))
	}

	public func add(_ objects: [T]) {
		compact()
		containers += objects.map { ZWeakContainer($0) }
	}

	public func remove(_ object: T) {
		compact()
		for container in containers {
			if let _object = container.object, _object === object {
				container.object = nil
			}
		}
	}

	public func remove(_ objects: [T]) {
		compact()
		for object in objects {
			for container in containers {
				if let _object = container.object, _object === object {
					container.object = nil
				}
			}
		}
	}

	public func compact() {
		containers = self.objects.map { ZWeakContainer($0) }
	}

	public func makeIterator() -> AnyIterator<T> {
		let objects = self.objects
		var index = 0
		return AnyIterator {
			defer { index += 1 }
			return index < objects.count ? objects[index] : nil
		}
	}
}

