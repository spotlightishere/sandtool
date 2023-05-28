//
//  BytecodeWrapper.swift
//  Sandstone
//
//  Created by Spotlight Deveaux on 2022-07-24.
//

import Foundation

/// Errors that can be encountered while dissecting bytecode.
public enum BytecodeError: String, Error {
    case tooSmall = "File is too small to be properly parsed."
    case offsetTooLarge = "File references an offset exceeding the length of usable data."
    case invalidString = "An invalid string was encountered while dissecting."
    case invalidOperationCount = "The specified amount of operations in the header did not match the given table."
    case unknownBytecodeFlag = "An unknown bytecode flag was encountered."
}

/// BytecodeWrapper allows reading various defined structures within a sandbox bytecode file.
/// It permits parsing the header, accessing offset tables, and common read operations.
public struct BytecodeWrapper {
    /// The reader wrapping the given bytecode.
    public let contents: SimpleReader

    // MARK: Actual properties

    /// The header of this bytecode format.
    public let header: BytecodeHeader

    /// Regex patterns within this file.
    // TODO: Determine their format and properly resolve.
    public let regexes: [TableOffset]

    /// Variable names within this bytecode format.
    public let variableOffsets: [TableOffset]

    /// Variable states, possibly.
    public let variableStates: [TableOffset]

    /// Instructions present within this bytecode format.
    public let instructions: [TableOffset]

    /// Profiles present within this bytecode format.
    /// Note that only collections will have more than one profile.
    public let profiles: [BytecodeProfile]

    /// Contents referenced by operation entries, each 0x8 in length.
    public let operationEntries: [BytecodeOperation]

    /// Contents referenced by unknownThree, each 0x800 in length.
    public let unknownThree: [DataOffset]

    /// Resolves many object types within the given bytecode format.
    /// - Parameter rawData: The raw data of this bytecode format.
    public init(with rawData: Data) throws {
        // Start reading!
        contents = SimpleReader(with: rawData)

        // We'll begin reading our header, starting at 0x0.
        let headerData = try contents.readHeaderBytes(length: Sandstone.SPBL_HEADER_LENGTH)
        header = try BytecodeHeader(with: headerData)

        // We're now at 0xe.
        // The next 5 variables are all offset tables, pointing to data
        // we'll finish at once done.

        // Read all offsets - that is, regexCount * 2 in length.
        regexes = try contents.readHeaderOffsetTable(count: header.regexCount)

        // Next, variable offsets - variableCount * 2.
        variableOffsets = try contents.readHeaderOffsetTable(count: header.variableCount)

        // Variable states, again following variableStateCount * 2.
        variableStates = try contents.readHeaderOffsetTable(count: header.variableStateCount)

        // Finally, instructions. This includes the last of offsets.
        // instructionCount * 2
        instructions = try contents.readHeaderOffsetTable(count: header.instructionCount)

        // That concludes offset tables! We're now at profile data.
        // This must be handled by the flags within the header.
        if header.isSingleProfile {
            // This is a little tricky - if we're an individual profile,
            // we only need to read the profile contents - no name, syscall mask, or index.
            // Its length is equal to the amount of operations times two:
            // that is, assuming 185 (0xb9) operations, its length is 370 (0x172).
            let profileContents = try contents.readHeaderOffsetTable(count: header.tableOperationCount)

            // This profile's syscall mask matches that of the header's.
            profiles = [BytecodeProfile(
                index: 0,
                syscallMask: header.flags,
                offset: contents.internalOffset,
                operations: profileContents
            )]
        } else {
            // If we're a collection, we need to iterate through all profiles.
            // Compared to individual profiles, each profile has an offset to its name,
            // a syscall mask, and a policy index prior to its actual contents.
            var tempProfiles: [BytecodeProfile] = []

            for _ in 0 ..< header.profileCount {
                // The first two bytes of this profile is its name offset.
                let nameOffset = try contents.readHeaderUInt16()

                // Next, syscall mask.
                let syscallMask = try contents.readHeaderUInt16()

                // Lastly, the profile's policy index.
                let index = try contents.readHeaderUInt16()

                // Finally, read the profile itself.
                let profileContents = try contents.readHeaderOffsetTable(count: header.tableOperationCount)

                tempProfiles.append(BytecodeProfile(
                    index: Int(index),
                    nameOffset: TableOffset(nameOffset),
                    syscallMask: syscallMask,
                    offset: contents.internalOffset,
                    operations: profileContents
                ))
            }

            profiles = tempProfiles
        }

        // Beyond this, we need padding.
        // Per Ghidra, this should be like the following:
        //
        //   instr_offset = offset of instruction table
        //   profile_offset = offset past profile 0x172 in length
        //   padding = (instr_offset - (profile_offset & 7)) + 0x17a
        //
        // However, 0x17a - 0x172 is 8, so we can (8 - (profile_offset & 7)).
        // In our case, the offset is the current position of our reader.
        let andedValue = contents.internalOffset & 7
        if andedValue != 0 {
            contents.internalOffset += 8 - andedValue
        }

        // Now, we read our operation entries.
        // Each operation entry has a length of 0x8.
        var tempOperations: [BytecodeOperation] = []
        for _ in 0 ..< header.operationEntryCount {
            let operationContents = try contents.readHeaderBytes(length: 0x8)
            let operationEntry = BytecodeOperation(with: operationContents, at: contents.internalOffset)
            tempOperations += [operationEntry]
        }
        operationEntries = tempOperations

        // From here on, we read our unknown block.
        // I'm choosing to believe it exists to bewilder.
        // It has a size of 0x800.
        unknownThree = try contents.readHeaderDynamicLength(count: header.unknownThree, length: 0x800)

        // For reading, we're now done!
        // We have reached the offset within our binary file
        // to resolve table offsets.
        // Subsequent calls to readBytes/readString will not need
        // to adjust the reader's position.
    }
}
