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

    var value: BytecodeItem
    var children: [SidebarElement]?
}

extension Array where Element == BytecodeItem {
    /// Helper to allow easy mapping of BytecodeItems to SidebarElements.
    func elements() -> [SidebarElement]? {
        if isEmpty {
            return nil
        }

        return map { item in
            SidebarElement(value: item)
        }
    }
}

/// Makes up some sandbox items based on our available elements.
func generateSidebarItems(with format: Bytecode) throws -> [SidebarElement] {
    [
        SidebarElement(
            value: .label(name: "Regex"),
            children: format.regexes.elements()
        ),
        SidebarElement(
            value: .label(name: "Variables"),
            children: format.variables.elements()
        ),
        SidebarElement(
            value: .label(name: "Variable States"),
            children: format.variableStates.elements()
        ),
        SidebarElement(
            value: .label(name: "Entitlements"),
            children: format.entitlements.elements()
        ),
        SidebarElement(
            value: .label(name: "Instructions"),
            children: format.instructions.elements()
        ),
        SidebarElement(
            value: .label(name: "Profiles"),
            children: format.profiles.elements()
        ),
        SidebarElement(
            value: .label(name: "Operation Entries"),
            children: format.operationEntries.elements()
        ),
        SidebarElement(
            value: .label(name: "Unknown Three"),
            children: format.unknownThree.elements()
        ),
    ]
}

struct DocumentView: View {
    @Binding var document: SandboxDocument

    /// The current sandbox item to work with.
    @State var selectedItem: SidebarElement?

    var body: some View {
        NavigationSplitView {
            List($document.sidebarElements.wrappedValue, children: \.children, selection: $selectedItem) { item in
                switch item.value {
                case let .label(name):
                    Text(name)
                case let .data(index, _, _):
                    Text("\(index)")
                case let .profile(name, _, _, _, _):
                    Text("\(name)")
                case let .string(_, value):
                    Text("\(value)")
                case let .operation(index, _):
                    Text("\(index)")
                }
            }.frame(minWidth: 200)
        } detail: {
            if let selectedItem = selectedItem {
                VSplitView {
                    DataView(bytecode: $document.bytecode.wrappedValue, item: selectedItem.value)
                        .frame(minHeight: 250)
                        .padding()

                    HexView(contents: $document.rawContents.wrappedValue)
                        .frame(minHeight: 200)
                        .padding()
                }.frame(minWidth: 800, minHeight: 500)
            } else {
                // Ensure this frame matches that of the VSplitView above.
                Text("Please select an item.")
                    .frame(minWidth: 800, minHeight: 500)
            }
        }
    }
}
