//
//  BytecodeProfile.swift
//  Sandstone
//
//  Created by Spotlight Deveaux on 2022-07-29.
//

import Foundation

/// BytecodeProfile represents a raw representation of a profile.
public struct BytecodeProfile {
    /// The index of this profile within policies.
    public let index: Int

    /// The offset to the name of this profile.
    /// Individual profiles will not have a name.
    public var nameOffset: TableOffset?

    /// The offset to the syscall masks specified by this profile.
    /// Individual profiles utilize the mask specified within the header flags.
    public var syscallMask: UInt16

    /// The offset of this profile within this bytecode format.githu
    public let offset: Int

    /// The operation number this profile specifies for each available operation.
    /// You can match each index to the operation's name.
    /// Its value will be the operation number for what to evaluate on this profile.
    ///
    /// Note that this length directly matches to that specified within the
    /// bytecode format's header, and can (and does) vary across releases.
    public let operations: [UInt16]
}