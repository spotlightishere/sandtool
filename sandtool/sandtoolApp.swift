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
    var body: some Scene {
        DocumentGroup(newDocument: SandboxDocument()) { file in
            IntermediateView(document: file.$document)
        }
    }
}
