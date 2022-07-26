//
//  HexView.swift
//  sandtool
//
//  Created by Spotlight Deveaux on 2022-07-24.
//

import SwiftUI

struct HexView: View {
    var contents: Data

    var body: some View {
        TextEditor(text: .constant(contents.hexEncodedString()))
            // #1F1F1F
            .foregroundColor(Color(red: 31, green: 31, blue: 31))
            .font(.system(.body, design: .monospaced))
    }
}

struct HexView_Previews: PreviewProvider {
    static var emptyData = Data()
    static var genericData = Data(repeating: 0xFF, count: 32)

    static var previews: some View {
        // Generic empty view
        HexView(contents: emptyData)
        // Generic data view
        HexView(contents: genericData)
    }
}

// http://stackoverflow.com/a/40089462
extension Data {
    func hexEncodedString() -> String {
        map { String(format: "%02hhx", $0) }.joined()
    }
}
