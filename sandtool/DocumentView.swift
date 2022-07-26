//
//  DocumentView.swift
//  sandtool
//
//  Created by Spotlight Deveaux on 2022-07-25.
//

import Sandstone
import SwiftUI

struct SandboxItem: Hashable, Identifiable {
    var id: Self { self }

    var name: String
    var contents: Data?
    var children: [SandboxItem]?
}

struct DocumentView: View {
    @Binding var bytecode: SandboxDocument
    private var format: BytecodeWrapper {
        bytecode.bytecode
    }

    @State var currentItem: SandboxItem?

    var sandboxItems: [SandboxItem] {
        let unknownTwo = format.unknownTwo.enumerated().map { index, i in
            SandboxItem(name: "\(index)", contents: i)
        }

        let unknownThree = format.unknownThree.enumerated().map { index, i in
            SandboxItem(name: "\(index)", contents: i)
        }

        let variableItems = format.variables.map { v in
            // TODO: this is awful
            SandboxItem(name: v, contents: Data())
        }

        let entitlementItems = format.entitlements.map { e in
            // TODO: this is awful
            SandboxItem(name: e, contents: Data())
        }

        return [
            SandboxItem(name: "Regex"),
            SandboxItem(
                name: "Variables",
                children: variableItems
            ),
            SandboxItem(
                name: "Entitlements",
                children: entitlementItems
            ),
            SandboxItem(
                name: "Unknown Two",
                children: unknownTwo
            ),
            SandboxItem(
                name: "Unknown Three",
                children: unknownThree
            ),
            SandboxItem(name: "Instructions"),
        ]
    }

    var body: some View {
        NavigationSplitView {
            List(sandboxItems, children: \.children, selection: $currentItem) { item in
                // TODO: Do not show contents if the item is empty
                if let children = item.children {
                    NavigationLink("\(item.name) (\(children.count))", value: item)
                } else {
                    // We'd like to show a count.
                    NavigationLink("\(item.name)", value: item)
                }
            }
        } detail: {
            if let toShow = currentItem, let currentContents = toShow.contents {
                HexView(contents: currentContents)
            } else {
                Text("Please select an item.")
            }
        }
        .navigationTitle("Bytecode Format")
    }
}
