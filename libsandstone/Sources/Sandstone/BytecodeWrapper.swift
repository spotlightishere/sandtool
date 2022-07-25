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

/// BytecodeProfile represents a raw representation of a profile.
// TODO: learn more about this
public struct BytecodeProfile {
    /// The contents of this profile.
    public let data: Data
}

/// BytecodeWrapper allows reading various defined structures within a sandbox bytecode file.
/// It permits parsing the header, accessing offset tables, and common read operations.
public struct BytecodeWrapper {
    /// The reader wrapping the given bytecode.
    let contents: SimpleReader

    /// The header of this bytecode format.
    let header: BytecodeHeader

    /// Regex patterns within this file.
    // TODO: Determine their format and properly resolve.
    let regexes: [TableOffset]

    /// Variable names within this bytecode format.
    let variables: [String]

    /// Variable states, possibly.
    let variableStates: [TableOffset]

    /// Entitlement key values within this bytecode format.
    let entitlements: [String]

    /// Instructions present within this bytecode format.
    let instructions: [TableOffset]

    /// Profiles present within this bytecode format.
    /// Note that only collections will have more than one profile.
    let profiles: [BytecodeProfile]

    /// Contents referenced by unknownTwo, each 0x8 in length.
    let unknownTwo: [Data]

    /// Contents referenced by unknownThree, each 0x800 in length.
    let unknownThree: [Data]

    public init(with rawData: Data) throws {
        // Start reading!
        contents = SimpleReader(with: rawData)

        // We'll begin reading our header, starting at 0x0.
        // If updating this length, please additionally update BytecodeHeader.
        let headerData = contents.readHeaderBytes(length: 0x10)
        header = try BytecodeHeader(with: headerData)

        // We're now at 0x10.
        // The next 5 variables are all offset tables, pointing to data
        // we'll finish at once done.

        // Read all offsets - that is, regexCount * 2 in length.
        regexes = contents.readHeaderOffsetTable(count: header.regexCount)

        // Next, variable offsets - variableCount * 2.
        // We'll come back to resolve variable offsets later.
        let variableOffsets = contents.readHeaderOffsetTable(count: header.variableCount)

        // Variable states, again following variableStateCount * 2.
        variableStates = contents.readHeaderOffsetTable(count: header.variableStateCount)

        // Entitlement keys. Similar to variables, we'll resolve their strings
        // later in initialization. Once again, entitlementKeyCount * 2.
        let entitlementKeyOffsets = contents.readHeaderOffsetTable(count: header.entitlementKeyCount)

        // Finally, instructions. This includes the last of offsets.
        // instructionCount * 2
        instructions = contents.readHeaderOffsetTable(count: header.instructionCount)

        // That concludes offset tables! We're now at profile data.
        // This must be handled by the flags within the header.
        if header.isSingleProfile {
            // This is a little tricky - if we're an individual profile,
            // we have exactly one profile 0x172 in length.
            // We'll read only that far in.
            let profileData = contents.readHeaderBytes(length: 0x172)
            profiles = [BytecodeProfile(data: profileData)]
        } else {
            // If we're a collection, we need to iterate through all profiles.
            // For an unknown reason, collection profiles are 0x178 in length.
            // Perhaps the extra bytes provide an offset for the bundle's name.
            // TODO: determine
            let profileContents = contents.readHeaderDynamicLength(count: header.profileCount, length: 0x172)

            var tempProfiles: [BytecodeProfile] = []
            for profile in profileContents {
                tempProfiles += [BytecodeProfile(data: profile)]
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

        // From here on, we read our two unknown blocks.
        // It's not entirely clear on what this is - it may be
        // some sort of address table, given its size of 0x8.
        // Perhaps we can assume it's related to raw operations.
        // It is referenced directly within the
        // "ProfileData" structure.
        unknownTwo = contents.readHeaderDynamicLength(count: header.unknownTwo, length: 0x8)

        // This is additionally unknown.
        // I'm choosing to believe it exists to bewilder.
        // It has a size of 0x800.
        unknownThree = contents.readHeaderDynamicLength(count: header.unknownThree, length: 0x800)

        // For reading, we're now done!
        // We have reached the offset within our binary file
        // to resolve table offsets.

        // Lastly, resolve string offsets.
        var variableTemp: [String] = []
        for offset in variableOffsets {
            variableTemp += [try contents.readString(at: offset)]
        }
        variables = variableTemp

        var entitlementTemp: [String] = []
        for offset in entitlementKeyOffsets {
            entitlementTemp += [try contents.readString(at: offset)]
        }
        entitlements = entitlementTemp
    }
}
