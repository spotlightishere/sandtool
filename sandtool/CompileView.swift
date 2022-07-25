//
//  CompileView.swift
//  sandtool
//
//  Created by Spotlight Deveaux on 2022-07-24.
//

import Sandstone
import SwiftUI

struct CompileView: View {
    @State private var input: String = "Input"
    @State private var output: Data = .init()
    @State private var compilerError: String = ""

    var body: some View {
        VStack {
            TextEditor(text: $input)
                .foregroundColor(Color(red: 31, green: 31, blue: 31))
                .font(.system(.body, design: .monospaced))

            Button("Compile", action: {
                do {
                    output = try Sandstone.compile(profile: input)
                    compilerError = ""
                } catch let e as SandboxError {
                    compilerError = "An error occurred while compiling:\n\n \(e.message)"
                } catch let e {
                    compilerError = "A generic error occurred while compiling:\n\n \(e)"
                }
            })

            ZStack {
                // Hex output view on success
                HexView(contents: $output)

                // Error view on failure
                if !compilerError.isEmpty {
                    TextEditor(text: .constant(compilerError))
                        // #1F1F1F
                        .foregroundColor(.red)
                        .font(.system(.body, design: .monospaced))
                }
            }
        }.padding()
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

struct CompileView_Previews: PreviewProvider {
    static var previews: some View {
        CompileView()
    }
}
