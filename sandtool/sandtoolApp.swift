//
//  sandtoolApp.swift
//  sandtool
//
//  Created by Spotlight Deveaux on 2022-07-24.
//

import Sandstone
import SwiftUI

@main
struct sandtoolApp: App {
    // SBPL that should always compile.
    func validSandbox() -> SandboxDocument {
        do {
            return try SandboxDocument(sbpl: "(version 3)\n(deny default)")
        } catch let e {
            fatalError("Should not reach here. \(e)")
        }
    }

    var body: some Scene {
        DocumentGroup(newDocument: validSandbox()) { file in
            DocumentView(document: file.$document)
        }
    }
}
