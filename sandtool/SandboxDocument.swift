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
    var bytecode: Bytecode?

    /// The raw, binary contents.
    var rawContents: Data?

    /// Whether the document can represent bytecode,
    /// and is not an empty document.
    // TODO: can we do away with this somehow?
    var hasBytecode: Bool = false

    /// An effective hack to allow UI representation.
    var sidebarElements: [SidebarElement]?

    /// Initializes an empty document.
    init() {}

    /// Initializes this document via a file containing our bytecode format.
    /// - Parameter config: File configuration given by the system.
    init(configuration config: ReadConfiguration) throws {
        guard let contents = config.file.regularFileContents else {
            throw BytecodeError.tooSmall
        }
        // Minimum bytecode length.
        guard contents.count > Sandstone.SPBL_HEADER_LENGTH else {
            throw BytecodeError.tooSmall
        }

        try updateBytecode(contents: contents)
    }

    mutating func updateSBPL(_ sbpl: String) throws {
        let contents = try Sandstone.compile(profile: sbpl)
        try updateBytecode(contents: contents)
    }

    mutating func updateBytecode(contents: Data) throws {
        rawContents = contents
        // Create our bytecode representation from the passed raw data.
        bytecode = try Sandstone.dissect(bytecode: contents)
        sidebarElements = try generateSidebarItems(with: bytecode!)
        hasBytecode = true
    }

    func fileWrapper(configuration _: WriteConfiguration) throws -> FileWrapper {
        .init(regularFileWithContents: rawContents ?? Data())
    }
}
