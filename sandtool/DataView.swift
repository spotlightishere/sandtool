//
//  DataView.swift
//  sandtool
//
//  Created by Spotlight Deveaux on 2022-07-26.
//

import Sandstone
import SwiftUI

/// DataView previews the given data type,
/// providing a somewhat sane preview and highlighting
/// it within the hex view.
struct DataView: View {
    let bytecode: BytecodeWrapper
    let item: SandboxItem

    var body: some View {
        switch item {
        case let .data(index, offset, value):
            // TODO: allow finding an offset of read blobs
            Text("\(index) at \(offset)")
            HexView(contents: value)
        case let .offset(index, offset, length):
            Text("\(index) at \(offset)")
            HexView(contents: bytecode.readBytes(at: offset, length: length))
        case let .string(offset):
            Text("\(bytecode.resolveString(at: offset))")
            Text("TODO: something something show references")
        default:
            Text("Please select an item.")
        }

        HexView(contents: bytecode.contents.contents)
    }
}
