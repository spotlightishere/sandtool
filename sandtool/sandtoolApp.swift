//
//  sandtoolApp.swift
//  sandtool
//
//  Created by Spotlight Deveaux on 2022-07-24.
//

import SwiftUI

@main
struct sandtoolApp: App {
    var body: some Scene {
        DocumentGroup(viewing: SandboxDocument.self) { file in
            DocumentView(bytecode: file.$document)
        }
    }
}
