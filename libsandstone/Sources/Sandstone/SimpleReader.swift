//
//  SimpleReader.swift
//  Sandstone
//
//  Created by Spotlight Deveaux on 2022-07-25.
//

import Foundation

/// TableOffset holds a value that can be resolved within lookup data
/// towards the end of the bytecode format.
public typealias TableOffset = UInt16

public extension TableOffset {
    /// Returns the exact position within our file.
    /// Table offsets should be multiplied by 0x8 to get their exact offset.
    var position: Int {
        Int(self) * 0x8
    }
}

/// A blob of data and its obtained offset.
public struct DataOffset {
    public let offset: Int
    public let value: Data
}

/// SimpleReader hacks together a read-only buffer, positioning,
/// and a way to stop increasing positioning. This is useful so that
/// ``BytecodeWrapper`` and friends can iterate through the header
/// and then eventually resolve offsets at the end of their data.
///
/// An alternate name could be "HackyReader".
public class SimpleReader {
    /// The data to read from.
    public let contents: Data

    /// The internal offset to base data from.
    var internalOffset: Int = 0

    /// Creates a SimpleReader over the given contents, starting its offset at 0.
    /// - Parameter contents: The contents to read with.
    init(with contents: Data) {
        self.contents = contents
        internalOffset = contents.startIndex
    }

    // MARK: Positional readers

    /// Reads the specified amount of bytes, increasing positioning.
    /// - Parameter length: The amount of bytes to read.
    /// - Returns: The specified amoiunt of data.
    func readHeaderBytes(length: Int) throws -> Data {
        // Special case: as we're still tracking, this is at position+0.
        let readData = try readBytes(at: 0, length: length)
        // Increase internal position.
        internalOffset += length

        return readData
    }

    /// Reads a UInt16, increasing positioning.
    /// - Returns: Usable UInt16 created.
    func readHeaderUInt16() throws -> UInt16 {
        try readHeaderBytes(length: 2).uint16()
    }

    /// Reads a repeated value for count over the amount specified by length.
    /// - Parameter count: Count of offset entries.
    /// - Parameter length: Amount of data to read.
    /// - Returns: An array of offsets.
    func readHeaderDynamicLength(count: UInt16, length: Int) throws -> [DataOffset] {
        var result: [DataOffset] = []

        for _ in 0 ..< count {
            let data = try readHeaderBytes(length: length)
            let value = DataOffset(offset: internalOffset, value: data)

            result += [value]
        }

        return result
    }

    func readHeaderDynamicLength(count: UInt8, length: Int) throws -> [DataOffset] {
        try readHeaderDynamicLength(count: UInt16(count), length: length)
    }

    /// Reads a table of offsets for the given length.
    /// - Parameter count: Count of offset entries.
    /// - Returns: An array of offsets.
    func readHeaderOffsetTable(count: UInt16) throws -> [TableOffset] {
        var offsets: [TableOffset] = []

        for _ in 0 ..< count {
            let offset = try readHeaderBytes(length: 2).uint16()
            offsets += [TableOffset(offset)]
        }

        return offsets
    }

    /// Reads a table of offsets for the given length, with a count of UInt8s.
    func readHeaderOffsetTable(count: UInt8) throws -> [TableOffset] {
        try readHeaderOffsetTable(count: UInt16(count))
    }

    // MARK: Non-positional readers

    /// Reads the specified amount of bytes at the given offset.
    /// - Parameters:
    ///   - offset: The offset within the binary format to read from.
    ///   - length: How many bytes to read.
    /// - Returns: The specified amount of data.
    func readBytes(at offset: TableOffset, length: Int) throws -> Data {
        // Table offsets should be multiplied by 0x8 to get their true value.
        try readBytes(at: offset.position, length: length)
    }

    /// Reads the specified amount of bytes at the given offset.
    /// - Parameters:
    ///   - offset: The offset within the binary format to read from.
    ///   - length: How many bytes to read.
    /// - Returns: The specified amount of data.
    func readBytes(at offset: Int, length: Int) throws -> Data {
        let effectiveOffset = internalOffset + offset
        if effectiveOffset > contents.count {
            throw BytecodeError.offsetTooLarge
        }

        return contents[effectiveOffset ..< effectiveOffset + length]
    }

    /// Reads a table offset pointing to its size, and then reads the contents of its bytes.
    /// - Parameter offset: The offset within the binary format to read from.
    /// - Returns: The specified amount of data.
    func readSizedOffset(at offset: TableOffset) throws -> Data {
        // Table offsets are multiplied by 0x8 to get their true value.
        let realOffset = offset.position

        // The size of our lengthed data is a UInt16, prefixing its contents.
        let dataLength = try readBytes(at: realOffset, length: 2).uint16()

        // Our data begins at offset + 2 to skip past the UInt16.
        return try readBytes(at: realOffset + 2, length: Int(dataLength))
    }

    /// Reads the specified string at the given offset.
    /// - Parameters:
    ///   - offset: The offset within the binary format to read from.
    /// - Returns: The specified amoiunt of data.
    func readString(at offset: TableOffset) throws -> String {
        // Each string holds a "sized" offset: a UInt16
        // prefixes its actual contents.
        let stringData = try readSizedOffset(at: offset)

        // Attempt to encode. Fingers crossed...
        guard let string = String(bytes: stringData, encoding: .utf8) else {
            throw BytecodeError.invalidString
        }
        return string
    }
}
