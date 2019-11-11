/// A specification object statically determining the properties of a `SemanticType` object
/// associated with it.
public protocol GeneralizedSemanticTypeSpec {
    
    /// The type of the primitive value wrapped by the `SemanticType`.
    /// Must possess value semantics.
    ///
    /// `RawValue` must possess *value semantics* to insure that the structure of a value is
    /// not modified by outside forces after passing through the `SemanticType`'s `gateway` function
    /// and becoming stored inside of a `SemanticType` instance.
    associatedtype RawValue
    
    /// The type of the gateway-associated metadata available on the `SemanticType`.
    /// Must possess value semantics.
    ///
    /// The metadata must possess *value semantics* to ensure that the structure of a value is
    /// not modified by outside forces after passing through the `SemanticType`'s `gateway` function
    /// and becoming stored inside of a `SemanticType` instance.
    ///
    /// ---
    ///
    /// The `gatewayMap` function may verify that the internal sub-structure of a returned `RawValue`
    /// satisfies any number of constraints.
    /// `Metadata` encodes a **compiler-visible fascet** of said verified sub-structure.
    ///
    /// ---
    ///
    /// As an example: suppose we create a `NonEmptyArray` `SemanticType`, i.e.
    /// a type whose instances wrap an `Array` which is *always* non-empty.
    ///
    /// Unlike instances of `Array`, instances of `NonEmptyArray` are **guarenteed** to have `first` and `last` elements.
    /// Thus we may expose `first: Element` and `last: Element` in place of `Array`'s corresponding *optional* properties.
    ///
    /// Since we know that instances of `NonEmptyArray` are not empty, we _could_ implement said non-optionoal
    /// `first` and `last` overrides by forwarding the call to `Array`'s optional properties and force-unwrapping the result.
    ///
    /// While *we* know this process ought to work, the *compiler* does not -- hence the need for the force-unwrapping.
    /// And so we lose the celebrated compiler verification normally characterizing idiomatic swift code.
    ///
    /// Instead, we could implement `first` and `last` without circumventing compiler verifications by storing the `Array`'s `first` and `last`
    /// values as *metadata* during the `gatewayMap`ing (where we could return an error if `first` and `last` are not available).
    /// The non-optional `first` and `last` properties on `NonEmptyArray` could then be implemented by querying said metadata values.
    associatedtype Metadata
    
    /// The type of the error which could be returned when attempting to create instance of the `SemanticType`.
    associatedtype Error: Swift.Error
    
    /// The output of the [gatewayMap function](x-source-tag://SemanticTypeSpec.gateway).
    /// See additional documentation on the [struct definition](x-source-tag://GeneralizedSemanticTypeSpec_GatewayOutput)
    ///
    /// - Tag: GeneralizedSemanticTypeSpec.GatewayOutput
    typealias GatewayOutput = GeneralizedSemanticTypeSpec_GatewayOutput<RawValue, Metadata>
    
    /// A function gating the creation of all `SemanticType` instances associated with this Spec.
    ///
    /// - Parameter preMap: The `RawValue` to be analyzed and modified for association with a `SemanticType` instance.
    /// - Returns: If a `SemanticType` instance should be created given the provided input, returns the (possibly transformed) `RawValue` to back the created `SemanticType` instance. Otherwise, returns the error specifying why the instance cannot be creted given the provided input.
    /// - Tag: SemanticTypeSpec.gateway
    static func gateway(
       preMap: RawValue
    ) -> Result<GatewayOutput, Error>
}
/// The output of the [gatewayMap function](x-source-tag://SemanticTypeSpec.gateway).
///
///
/// NOTE: Since Swift does not currently support nesting definitions of types nested inside a protocol,
/// we utilize a naming convention + [a typealias on the target protocol](x-source-tag://GeneralizedSemanticTypeSpec.GatewayOutput)
/// to effectively achieve this goal.
/// In other words, this type should be viewed as if it were nested under the `GeneralizedSemanticTypeSpec` protocol.
///
/// - Tag: GeneralizedSemanticTypeSpec_GatewayOutput
public struct GeneralizedSemanticTypeSpec_GatewayOutput<RawValue, Metadata> {
    
    /// The primitive value to back a succesfully-created `SemanticType` instance.
    /// The behavior of the `SemanticType` construct largely revolves around this field.
    /// (see [SemanticType](x-source-tag://SemanticType)).
    var rawValue: RawValue
    
    /// Additinoal metadata available to the successfully-created `SemanticType` instance.
    /// May be utilized to provide compiler-verified extensions on the SemanticType, taking advantage of the
    /// constraints satisfied by the distilled `RawValue`.
    var metadata: Metadata
}


/// A `SemanticTypeSpec` with no gateway metadata.
public protocol SemanticTypeSpec: GeneralizedSemanticTypeSpec where Metadata == () {
    static func gateway(
       preMap: RawValue
    ) -> Result<RawValue, Error>
}
extension SemanticTypeSpec {
    public static func gateway(
       preMap: RawValue
    ) -> Result<GatewayOutput, Error> {
        return gateway(preMap: preMap)
            .map { .init(rawValue: $0, metadata: ()) }
    }
}

/// A `SemanticTypeSpec` whose `gateway` function never errors.
public protocol ErrorlessSemanticTypeSpec: SemanticTypeSpec where Error == Never {
    static func gateway(
       preMap: RawValue
    ) -> RawValue
}
extension ErrorlessSemanticTypeSpec {
    public static func gateway(
       preMap: RawValue
    ) -> Result<RawValue, Error> {
        return .success(gateway(preMap: preMap))
    }
    
    public static func gateway(
       preMap: RawValue
    ) -> RawValue {
        return preMap
    }
}

