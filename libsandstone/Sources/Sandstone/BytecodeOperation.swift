//
//  BytecodeOperation.swift
//  Sandstone
//
//  Created by Spotlight Deveaux on 2022-07-30.
//

import Foundation

/// BytecodeOperation represents the format of an operation
/// within our bytecode format.
public struct BytecodeOperation: Equatable, Hashable {
    // MARK: Actual properties

    /// The type of this operation.
    ///
    /// Known values:
    ///   - `0x00`: This operation node entry continues evaluation to another entry.
    ///   - `0x01`: This operation node entry ends evaluation.
    public let opcode: UInt8

    /// The filter to apply while evaluating this operation.
    public let filter: UInt8

    /// The number of this operation entry.
    public let operationNum: UInt16

    /// A further unknown value.
    public let unknownTwo: UInt16

    /// Yet another unknown value.
    public let unknownThree: UInt16

    // MARK: Helpers

    /// The offset of this profile within this bytecode format.
    public let offset: Int

    init(with contents: Data, at offset: Int) {
        opcode = contents.uint8(at: 0x0)
        filter = contents.uint8(at: 0x01)
        operationNum = contents.uint16(at: 0x02)
        unknownTwo = contents.uint16(at: 0x04)
        unknownThree = contents.uint16(at: 0x06)

        self.offset = offset
    }
}

extension BytecodeWrapper {
    /// Resolves all profiles to a higher level mapping.
    func resolve(operations: [BytecodeOperation]) -> [BytecodeItem] {
        operations.enumerated().map { index, operation in
            BytecodeItem.operation(
                index: index,
                value: operation
            )
        }
    }
}
