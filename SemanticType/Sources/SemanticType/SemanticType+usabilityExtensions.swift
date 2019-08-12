//
//  File.swift
//  
//
//  Created by Atai Barkai on 8/8/19.
//

// MARK: - Universal usability extensions -
extension SemanticType {
    public init(_ preMap: Spec.BackingPrimitiveWithValueSemantics) throws {
        self = try Self.create(preMap).get()
    }
    
    public var backingPrimitive: Spec.BackingPrimitiveWithValueSemantics {
        get {
            _backingPrimitiveProxy
        }
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<Spec.BackingPrimitiveWithValueSemantics, T>) -> T {
        get {
            backingPrimitive[keyPath: keyPath]
        }
    }
    
    public func tryMap(
        _ map: (_ backingPrimitive: Spec.BackingPrimitiveWithValueSemantics) throws -> Spec.BackingPrimitiveWithValueSemantics
    ) rethrows -> Result<Self, Spec.Error> {
        return Self.create(
            try map(backingPrimitive)
        )
    }
    
//    public func tryMap(
//        _ mutatingMap: (_ backingPrimitive: inout Spec.BackingPrimitiveWithValueSemantics) throws -> ()
//    ) rethrows -> Result<Self, Spec.Error> {
//        return try tryMap { original -> Spec.BackingPrimitiveWithValueSemantics in
//            var toBeModified = original
//            try mutatingMap(&toBeModified) // Here we make use of the assumption that `Spec.BackingPrimitiveWithValueSemantics` has
//                                           // value-semantics, i.e. that this mutation of `backingPrimitiveCopy` would bear no
//                                           // effect on the original `backingPrimitive`.
//            return toBeModified
//        }
//    }
}


// MARK: - `Error == Never` extensions -
extension SemanticType where Spec.Error == Never {
    public init(_ preMap: Spec.BackingPrimitiveWithValueSemantics) {
        self = Self.create(preMap).get()
    }
    
    /// The value assigned to `backingPrimitive` is passed through the `Spec.gatewayMap` function before making it to `self`.
    public var backingPrimitive: Spec.BackingPrimitiveWithValueSemantics {
        get {
            _backingPrimitiveProxy
        }
        set {
            self = .init(newValue)
        }
    }
    
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Spec.BackingPrimitiveWithValueSemantics, T>) -> T {
        get {
            backingPrimitive[keyPath: keyPath]
        }
        set {
            backingPrimitive[keyPath: keyPath] = newValue
        }
    }
    
    public func map(
        _ map: (_ backingPrimitive: Spec.BackingPrimitiveWithValueSemantics) throws -> Spec.BackingPrimitiveWithValueSemantics
    ) rethrows -> Self {
        return Self.init(
            try map(backingPrimitive)
        )
    }}



private extension Result where Failure == Never {
    
    /// A variant of `Result.get()` specific to error-less `Result` instances
    /// -- which is therefore statically guarenteed to never `throw`.
    ///
    /// - Returns: The `Success` value wrapped by this error-less `Result` instance
    func get() -> Success {
        switch self {
        case .success(let success):
            return success
        case .failure(let never):
            switch never { }
        }
    }
}