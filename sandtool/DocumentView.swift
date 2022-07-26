//
//  DocumentView.swift
//  sandtool
//
//  Created by Spotlight Deveaux on 2022-07-25.
//

import Sandstone
import SwiftUI

/// An item used for top-level iteration.
/// We really only need one sub-level within our list.
struct SidebarElement: Hashable, Identifiable {
    var id: Self { self }

    var value: SandboxItem
    var children: [SidebarElement]?
}

/// A generic item for our list.
enum SandboxItem: Hashable, Identifiable {
    var id: Self { self }

    case label(name: String)
    case data(index: Int, offset: Int, value: Data)
    case offset(index: Int, offset: TableOffset, length: Int)
    case string(offset: TableOffset)
}

/// Makes up some sandbox items.
// TODO: majorly refactor
func sandboxItems(format: BytecodeWrapper) -> [SidebarElement] {
    let unknownTwo = format.unknownTwo.enumerated().map { index, contents in
        SidebarElement(value: .data(index: index, offset: contents.offset, value: contents.data))
    }

    let unknownThree = format.unknownThree.enumerated().map { index, contents in
        SidebarElement(value: .data(index: index, offset: contents.offset, value: contents.data))
    }

    let variableItems = format.variableOffsets.map { v in
        // TODO: this is awful
        SidebarElement(value: .string(offset: v))
    }

    let entitlementItems = format.entitlementKeyOffsets.map { e in
        // TODO: this is awful
        SidebarElement(value: .string(offset: e))
    }

    return [
        SidebarElement(value: .label(name: "Regex")),
        SidebarElement(
            value: .label(name: "Variables"),
            children: variableItems
        ),
        SidebarElement(
            value: .label(name: "Entitlements"),
            children: entitlementItems
        ),
        SidebarElement(
            value: .label(name: "Unknown Two"),
            children: unknownTwo
        ),
        SidebarElement(
            value: .label(name: "Unknown Three"),
            children: unknownThree
        ),
        SidebarElement(value: .label(name: "Instructions")),
    ]
}

/// Some sugar so we don't have to handle errors.
/// Sue me. This isn't production software.
extension BytecodeWrapper {
    func resolveString(at offset: TableOffset) -> String {
        do {
            return try readString(at: offset)
        } catch {
            return "Error resolving"
        }
    }
}

struct DocumentView: View {
    @Binding var document: SandboxDocument
    private var bytecode: BytecodeWrapper {
        document.bytecode
    }

    /// Thrown together label items from our bytecode format.
    private var sidebarItems: [SidebarElement] {
        sandboxItems(format: bytecode)
    }

    /// The current sandbox item to work with.
    @State var selectedItem: SidebarElement?

    var body: some View {
        NavigationSplitView {
            List(sidebarItems, children: \.children, selection: $selectedItem) { item in
                switch item.value {
                case let .label(name):
                    Text(name)
                case let .data(index, _, _):
                    Text("\(index)")
                case let .offset(index, _, _):
                    Text("\(index)")
                case let .string(offset):
                    Text("\(bytecode.resolveString(at: offset))")
                }
            }
        } detail: {
            if let selectedItem = selectedItem {
                DataView(bytecode: bytecode, item: selectedItem.value)
            } else {
                Text("Please select an item.")
            }
        }
        .navigationTitle("Bytecode Format")
    }
}
