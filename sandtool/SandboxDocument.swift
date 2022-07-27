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

    /// A high level representation of the bytecode format we represent.
    var bytecode: Bytecode

    /// An effective hack to allow UI representation.
    var sidebarElements: [SidebarElement]

    /// The raw, binary contents.
    var rawContents: Data

    /// Initializes this document via a SBPL string.
    /// - Parameter sbpl: The SBPL to compile and dissect.
    init(sbpl: String) throws {
        let contents = try Sandstone.compile(profile: sbpl)
        try self.init(data: contents)
    }

    /// Initializes this document via a file containing our bytecode format.
    /// - Parameter config: File configuration given by the system.
    init(configuration config: ReadConfiguration) throws {
        guard let contents = config.file.regularFileContents else {
            throw BytecodeError.tooSmall
        }

        try self.init(data: contents)
    }

    /// Initializes this document via our bytecode format directly.
    init(data: Data) throws {
        rawContents = data

        // Create our bytecode representation from the passed raw data.
        bytecode = try Sandstone.dissect(bytecode: data)
        sidebarElements = try generateSidebarItems(with: bytecode)
    }

    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
        // We do not support writing.
        .init(regularFileWithContents: Data())
    }
}
