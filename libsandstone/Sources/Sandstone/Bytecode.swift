//
//  SandboxItem.swift
//  Sandstone
//
//  Created by Spotlight Deveaux on 2022-07-26.
//

import Foundation

/// A generic item representing a bytecode type.
public enum BytecodeItem: Hashable, Identifiable {
    public var id: Self { self }

    // TODO: remove label case! This is a hack for SidebarElement
    // in sandtool. It should not be in Sandstone.
    case label(name: String)
    case data(index: Int, offset: Int, value: Data)
    case string(offset: Int, value: String)
    case profile(name: String, syscallMask: UInt16, index: Int, offset: Int, operations: [BytecodeNamedOperation])
    case operation(index: Int, value: BytecodeOperation)
}

/// BytecodeNamedOperation represents a pairing between an operation's name
/// and its entrypoint, per profile definition.
public struct BytecodeNamedOperation: Hashable, Identifiable {
    public var id: Self { self }

    /// The number or ID of this operation.
    public let operationId: Int

    /// The name of the operation.
    public let name: String

    /// The number of the operation entry this profile specifies.
    /// Look for corresponding operation entry numbers within the operations table.
    public let operationEntry: Int
}

// Some helpers to assist with conversion. A little too repetitive for my tastes!
// This would be nice to refactor eventually, though
// it may happen by simply discovering how to handle types.
extension BytecodeWrapper {
    /// Resolves an array of table offsets pointing to data.
    func resolve(data offsets: [TableOffset]) throws -> [BytecodeItem] {
        try offsets.enumerated().map { index, offset in
            let data = try contents.readSizedOffset(at: offset)
            return BytecodeItem.data(index: index, offset: offset.position, value: data)
        }
    }

    /// Resolves an array of table offsets pointing to strings.
    func resolve(string offsets: [TableOffset]) throws -> [BytecodeItem] {
        try offsets.enumerated().map { _, offset in
            let data = try contents.readString(at: offset)
            return BytecodeItem.string(offset: offset.position, value: data)
        }
    }

    /// Transforms a ``DataOffset`` to a ``BytecodeItem.data``.
    func map(data offsets: [DataOffset]) -> [BytecodeItem] {
        offsets.enumerated().map { index, data in
            BytecodeItem.data(index: index, offset: data.offset, value: data.value)
        }
    }
}

/// Bytecode is a high-level wrapper around defined structures within a sandbox bytecode file.
/// It permits easy access of its contents in several representations.
public struct Bytecode {
    /// A way to access lower-level contents of this bytecode format.
    public let wrapper: BytecodeWrapper

    /// Regexes available within this bytecode format.
    public let regexes: [BytecodeItem]

    /// Variables available within this bytecode format.
    public let variables: [BytecodeItem]

    /// Variable states available within this bytecode format.
    public let variableStates: [BytecodeItem]

    /// Instructions available within this bytecode format.
    public let instructions: [BytecodeItem]

    /// Profiles available within this bytecode format.
    public let profiles: [BytecodeItem]

    /// Operation entries within this bytecode format.
    public let operationEntries: [BytecodeItem]

    /// Whatever's available of unknown three.
    public let unknownThree: [BytecodeItem]

    init(with contents: Data) throws {
        // Parse our lower-level types.
        wrapper = try BytecodeWrapper(with: contents)

        // TODO: rewrite a decent amount of this

        // Resolve all table offsets.
        regexes = try wrapper.resolve(data: wrapper.regexes)
        variables = try wrapper.resolve(string: wrapper.variableOffsets)
        variableStates = try wrapper.resolve(data: wrapper.variableStates)
        // TODO: how can we handle these?
        // Possibly "indexed profiles"?
        instructions = wrapper.instructions.enumerated().map { index, value in
            BytecodeItem.data(index: index, offset: value.position, value: "broken, come back later".data(using: .utf8)!)
        }
        // TODO: provide proper representation of profiles
        profiles = try wrapper.resolve(profiles: wrapper.profiles)
        operationEntries = wrapper.resolve(operations: wrapper.operationEntries)
        unknownThree = wrapper.map(data: wrapper.unknownThree)
    }
}
