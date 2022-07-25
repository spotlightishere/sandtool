//
//  SimpleReader.swift
//  Sandstone
//
//  Created by Spotlight Deveaux on 2022-07-25.
//

import Foundation

/// TableOffset holds a value that can be resolved within lookup data
/// towards the end of the bytecode format.
typealias TableOffset = UInt16

/// SimpleReader hacks together a read-only buffer, positioning,
/// and a way to stop increasing positioning. This is useful so that
/// ``BytecodeWrapper`` and friends can iterate through the header
/// and then eventually resolve offsets at the end of their data.
///
/// An alternate name could be "HackyReader".
class SimpleReader {
    /// The data to read from.
    let contents: Data

    /// The internal offset to base data from.
    var internalOffset: Int = 0

    /// Creates a SimpleReader over the given contents, starting its offset at 0.
    /// - Parameter contents: The contents to read with.
    init(with contents: Data) {
        self.contents = contents
    }

    // MARK: Positional readers

    /// Reads the specified amount of bytes, increasing positioning.
    /// - Parameter length: The amount of bytes to read.
    /// - Returns: The specified amoiunt of data.
    func readHeaderBytes(length: Int) -> Data {
        let readData = contents[internalOffset ..< internalOffset + length]
        // Increase internal position.
        internalOffset += length

        return readData
    }

    /// Reads a repeated value for count over the amount specified by length.
    /// - Parameter count: Count of offset entries.
    /// - Parameter length: Amount of data to read.
    /// - Returns: An array of offsets.
    func readHeaderDynamicLength(count: UInt16, length: Int) -> [Data] {
        var result: [Data] = []

        for _ in 0 ..< count {
            let value = readHeaderBytes(length: length)
            result += [value]
        }

        return result
    }

    func readHeaderDynamicLength(count: UInt8, length: Int) -> [Data] {
        readHeaderDynamicLength(count: UInt16(count), length: length)
    }

    /// Reads a table of offsets for the given length.
    /// - Parameter count: Count of offset entries.
    /// - Returns: An array of offsets.
    func readHeaderOffsetTable(count: UInt16) -> [TableOffset] {
        var offsets: [TableOffset] = []

        for _ in 0 ..< count {
            let offset = readHeaderBytes(length: 2).uint16()
            offsets += [TableOffset(offset)]
        }

        return offsets
    }

    /// Reads a table of offsets for the given length, with a count of UInt8s.
    func readHeaderOffsetTable(count: UInt8) -> [TableOffset] {
        readHeaderOffsetTable(count: UInt16(count))
    }

    // MARK: Non-positional readers

    /// Reads the specified amount of bytes at the given offset.
    /// - Parameters:
    ///   - offset: The offset within the binary format to read from.
    ///   - length: How many bytes to read.
    /// - Returns: The specified amount of data.
    func readBytes(at offset: TableOffset, length: Int) -> Data {
        readBytes(at: Int(offset), length: length)
    }

    /// Reads the specified amount of bytes at the given offset.
    /// - Parameters:
    ///   - offset: The offset within the binary format to read from.
    ///   - length: How many bytes to read.
    /// - Returns: The specified amount of data.
    func readBytes(at offset: Int, length: Int) -> Data {
        let effectiveOffset = internalOffset + offset
        return contents[effectiveOffset ..< effectiveOffset + length]
    }

    /// Reads the specified string at the given offset.
    /// - Parameters:
    ///   - offset: The offset within the binary format to read from.
    ///   - length: How many bytes to read.
    /// - Returns: The specified amoiunt of data.
    func readString(at offset: TableOffset) throws -> String {
        let effectiveOffset = internalOffset + Int(offset)

        // Every string has a UInt16 prefixing its length, i.e. Pascal strings.
        let stringLength = readBytes(at: effectiveOffset, length: 2).uint16()

        // Our string begins at offset + 2 to skip past the UInt16.
        let stringData = readBytes(at: effectiveOffset + 2, length: Int(stringLength))

        // Attempt to encode. Fingers crossed...
        guard let string = String(bytes: stringData, encoding: .utf8) else {
            throw BytecodeError.invalidString
        }
        return string
    }
}
