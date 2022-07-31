//
//  IntermediateView.swift
//  sandtool
//
//  Created by Spotlight Deveaux on 7/31/22.
//

import SwiftUI

/// Allows compiling SBPL and showing its representation.
struct IntermediateView: View {
    @Binding var document: SandboxDocument

    var body: some View {
        if $document.hasBytecode.wrappedValue {
            DocumentView(document: $document)
        } else {
            CompileView(document: $document)
        }
    }
}
