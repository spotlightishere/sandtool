//
//  HexView.swift
//  sandtool
//
//  Created by Spotlight Deveaux on 2022-07-24.
//

import SwiftUI

struct HexView: View {
    var contents: Data

    init(contents: Binding<Data>) {
        self.contents = contents.wrappedValue
    }

    init(contents: Data) {
        self.contents = contents
    }

    var body: some View {
        TextEditor(text: .constant(contents.hexEncodedString()))
            // #1F1F1F
            .foregroundColor(Color(red: 31, green: 31, blue: 31))
            .font(.system(.body, design: .monospaced))
    }
}

struct HexView_Previews: PreviewProvider {
    @State static var emptyData = Data()
    @State static var genericData = Data(repeating: 0xFF, count: 32)
    static var genericDataNotBinding = Data(repeating: 0xAA, count: 32)

    static var previews: some View {
        // Generic empty view
        HexView(contents: $emptyData)
        // Generic data view
        HexView(contents: $genericData)
        // Generic data view without binding variable
        HexView(contents: genericDataNotBinding)
    }
}

// http://stackoverflow.com/a/40089462
extension Data {
    func hexEncodedString() -> String {
        map { String(format: "%02hhx ", $0) }.joined()
    }
}
