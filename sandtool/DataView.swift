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
    let bytecode: Bytecode
    let item: BytecodeItem

    var body: some View {
        VStack {
            switch item {
            case let .data(index, offset, value):
                // TODO: allow finding an offset of read blobs
                Text("\(index) at \(offset)")
                HexView(contents: value)
            case let .string(offset, value):
                Text("\(value) at \(offset)")
                Text("TODO: something something show references")
            case let .profile(name, syscallMask, index, offset, operations):
                Text("Profile: \(name)")
                Text("Syscall mask: \(syscallMask)")
                Text("Policy index: \(index), data at \(offset)")
                Table(operations) {
                    TableColumn("Operation ID", value: \.operationIdString)
                    TableColumn("Operation Name", value: \.name)
                    TableColumn("Operation Entry Number", value: \.operationEntryString)
                }
            case let .operation(index, value):
                Text("Entry \(index) at \(value.offset), operation \(value.operationNum)")
                Text("Opcode: \(value.opcode)")
                Text("Filter: \(value.filter & 0x7F) (\(String(format: "%02hhx", value.filter & 0x7F)))")
                Text("Unknown two: \(value.unknownTwo)")
                Text("Unknown three: \(value.unknownThree)")
            default:
                Text("Please select an item.")
            }
        }.frame(maxWidth: .infinity)
    }
}

extension BytecodeNamedOperation {
    var operationIdString: String {
        "\(operationId)"
    }

    var operationEntryString: String {
        "\(operationEntry)"
    }
}
