//
//  Data+Types.swift
//  Sandstone
//
//  Created by Spotlight Deveaux on 2022-07-24.
//

import Foundation

/// Some helper functions for common operations, like
/// reading certain data widths to types.
extension Data {
    /// Reads the UInt16 at the given offset.
    /// - Parameter offset: The offset within data.
    /// - Returns: A usable UInt16.
    func uint16(at offset: Int = 0) -> UInt16 {
        // TODO: There has to be a safer way to do this.
        // Courtesy of https://stackoverflow.com/a/47764694
        let contents = [self[offset], self[offset + 1]]

        return contents.withUnsafeBytes { bytes in
            bytes.load(as: UInt16.self)
        }
    }

    /// Reads the UInt8 at the given offset.
    /// This is no different than the normal subscript/accessor
    /// function, but it makes life slightly less chaotic.
    /// Even if slightly.
    /// - Parameter offset:The offset within data.
    /// - Returns: A usable UInt8.
    func uint8(at offset: Int = 0) -> UInt8 {
        self[offset]
    }
}
