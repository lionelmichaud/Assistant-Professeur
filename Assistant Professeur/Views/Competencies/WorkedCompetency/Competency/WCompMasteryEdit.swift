//
//  WCompMasteryEdit.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 25/06/2023.
//

import HelpersView
import SwiftUI

struct WCompMasteryEdit: View {
    @ObservedObject
    var workedComp: WCompEntity

    var editedLevel: MasteryLevel

    @State
    private var defintion: String = ""

    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        Form {
            Section(editedLevel.displayString) {
                TextField(
                    "Définition",
                    text: $defintion,
                    axis: .vertical
                )
                .textFieldStyle(.roundedBorder)
            }
        }
        .onAppear {
            defintion = workedComp.viewMasteryDefinitions[editedLevel]!
        }
        .toolbar(content: myToolBarContent)
        #if os(iOS)
            .navigationTitle("Définition")
        #endif
            .navigationBarTitleDisplayModeInline()
    }
}

// MARK: Toolbar Content

extension WCompMasteryEdit {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Annuler") {
                dismiss()
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Ok") {
                workedComp.viewMasteryDefinitions[editedLevel] = defintion
                try? WCompEntity.saveIfContextHasChanged()
                dismiss()
            }
        }
    }
}

// struct WCompMasteryEdit_Previews: PreviewProvider {
//    static var previews: some View {
//        WCompMasteryEdit()
//    }
// }
