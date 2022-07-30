//
//  BytecodeHeader.swift
//  Sandstone
//
//  Created by Spotlight Deveaux on 2022-07-24.
//

import Foundation

/// Represents the header format for our bytecode.
public struct BytecodeHeader {
    // MARK: Actual Properties

    // These values should correspond to the exact length
    // and sequence within the raw header data.

    /// Flags specified within the header of this bytecode format.
    ///
    /// Known values:
    ///  - 0x0000 represents a normal profile.
    ///  - 0x8000 represents a collection.
    ///
    ///  For ease of detection, see ``isCollection``.
    let flags: UInt16

    /// The amount of operation entries.
    /// Operations dictate how rules are evaluated, and enforce the profile's policy.
    /// Each operation entry is 0x8 in length.
    let operationEntryCount: UInt8

    /// An unknown value.
    /// Its data is a whopping 0x800 in length.
    // TODO: determine what this represents
    let unknownThree: UInt8

    /// Sandbox operation count.
    /// This must match the sandbox operation name table.
    /// Obeserved values have been 0xb6 (182) to 0xb9 (185),
    /// and likely will continue to increase as the operating systems grow.
    let tableOperationCount: UInt8

    /// The amount of pattern variables, such as `PROCESS_TEMP_DIR`,
    /// `ANY_USER`, or `ANY_USER_HOME`.
    /// Their data typically resides at the end of a profile or collection.
    let variableCount: UInt8

    /// A persistent state regarding variables.
    // ...possibly. TODO: verify
    let variableStateCount: UInt8

    /// The amount of profiles available.
    /// Note that value will always be `0` if this is a regular profile.
    /// You may wish to check ``isProfile`` or ``isCollection``.
    let profileCount: UInt16

    /// The amount of regex contents within this bytecode format.
    let regexCount: UInt16

    /// The amount of entitlement key strings present
    /// within this bytecode format.
    // TODO: This value likely replaces the "ENTITLEMENT:"
    // prefixed strings within iOS/watchOS/tvOS - can we confirm?
    let entitlementKeyCount: UInt16

    /// The amount of instructions present within this bytecode format.
    // TODO: What defines an instruction?
    let instructionCount: UInt16

    /// Reads from the given contents and stores header values.
    /// - Parameter contents: 16 (0x10) bytes.
    public init(with contents: Data) throws {
        if contents.count != 0x10 {
            // If updating this length, please additionally update BytecodeWrapper.
            preconditionFailure("The header contents should always be 0x10 in length per subscripts.")
        }

        // And now we read!
        // For the curious: Documentation here is sparse.
        // See the commented description of values on
        //
        // Starting at 0x0...
        flags = contents.uint16(at: 0)

        // Next, two mystery values at 0x2 and 0x3.
        operationEntryCount = contents.uint8(at: 0x2)
        unknownThree = contents.uint8(at: 0x3)

        // Count after count after count for offsets...
        tableOperationCount = contents.uint8(at: 0x4)
        variableCount = contents.uint8(at: 0x5)
        variableStateCount = contents.uint8(at: 0x6)

        // 0x7 goes unused, as far as xrefs go.
        // It has been observed to be zero consistently.

        profileCount = contents.uint16(at: 0x8)
        regexCount = contents.uint16(at: 0xA)
        entitlementKeyCount = contents.uint16(at: 0xC)
        instructionCount = contents.uint16(at: 0xE)

        // And we're done!

        // We want to perform exactly one sanity check: checking flag contents.
        if !isSingleProfile, !isCollection {
            throw BytecodeError.unknownBytecodeFlag
        }
    }

    // MARK: Helper functions

    /// Whether this bytecode format represents a collection of profiles.
    var isCollection: Bool {
        flags == 0x8000
    }

    /// Whether this bytecode format represents an individual profile.
    var isSingleProfile: Bool {
        flags == 0x0000
    }
}
