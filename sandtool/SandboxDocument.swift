//
//  SandboxDocument.swift
//  sandtool
//
//  Created by Spotlight Deveaux on 2022-07-25.
//

import Sandstone
import SwiftUI
import UniformTypeIdentifiers

struct SandboxDocument: FileDocument {
    // We do not want to associate ourselves to anything specific.
    static var readableContentTypes: [UTType] = [
        UTType.data,
    ]

    /// Whether we have bytecode. If we don't
    /// we we'll hackily display something blank.
    let hasBytecode: Bool

    /// The bytecode representation our document is meant to hold.
    let bytecode: BytecodeWrapper

    /// Initializes this document via a SBPL string.
    /// - Parameter sbpl: The SBPL to compile and dissect.
    init(sbpl: String) throws {
        let data = try Sandstone.compile(profile: sbpl)
        bytecode = try Sandstone.dissect(bytecode: data)
        hasBytecode = true
    }

    /// Initializes this document via a file containing our bytecode format.
    /// - Parameter config: File configuration given by the system.
    init(configuration config: ReadConfiguration) throws {
        guard let contents = config.file.regularFileContents else {
            throw BytecodeError.tooSmall
        }

        bytecode = try Sandstone.dissect(bytecode: contents)
        hasBytecode = true
    }

    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
        // We do not support writing.
        .init(regularFileWithContents: Data())
    }
}
