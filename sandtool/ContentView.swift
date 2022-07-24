//
//  ContentView.swift
//  sandtool
//
//  Created by Spotlight Deveaux on 2022-07-24.
//

import Sandstone
import SwiftUI

struct ContentView: View {
    @State private var input: String = "Input"
    @State private var output: String = "Compiled Output Goes Here"

    var body: some View {
        VStack {
            TextEditor(text: $input)
                .foregroundColor(Color(red: 31, green: 31, blue: 31))
                .font(.system(.body, design: .monospaced))

            Button("Compile", action: {
                do {
                    let result = try Sandstone.compile(profile: input)
                    output = result.hexEncodedString()
                } catch let e {
                    output = "An error occurred: \(e)"
                }
            })

            TextEditor(text: .constant(output))
                // #1F1F1F
                .foregroundColor(Color(red: 31, green: 31, blue: 31))
                .font(.system(.body, design: .monospaced))
        }.padding()
    }
}

// http://stackoverflow.com/a/40089462
extension Data {
    func hexEncodedString() -> String {
        map { String(format: "%02hhx", $0) }.joined()
    }
}

// lol
// https://stackoverflow.com/a/66725525
extension NSTextView {
    override open var frame: CGRect {
        didSet {
            isAutomaticQuoteSubstitutionEnabled = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
