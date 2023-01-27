//
//  SequenceEditorMODAL.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 25/01/2023.
//

import SwiftUI
import HelpersView

struct SequenceEditorModal: View {
    @ObservedObject
    var sequence: SequenceEntity

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.horizontalSizeClass)
    private var hClass

    @Preference(\.programAnnotationEnabled)
    private var annotationEnabled

    @State
    private var alertTitle = ""

    @State
    private var alertMessage = ""

    @State
    private var alertIsPresented = false

    var body: some View {
        Form {
            TextField(
                "Titre",
                text : $sequence.name.bound,
                axis : .vertical
            )
            .lineLimit(5)
            .font(hClass == .compact ? .callout : .body)
            .textFieldStyle(.roundedBorder)

            if annotationEnabled {
                TextField(
                    "Annotation",
                    text : $sequence.annotation.bound,
                    axis : .vertical
                )
                .lineLimit(5)
                .font(hClass == .compact ? .callout : .body)
                .textFieldStyle(.roundedBorder)
            }
            WebsiteEditView(website: $sequence.url)
        }
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: { },
            message: { Text(alertMessage) }
        )
        #if os(iOS)
        .navigationTitle("Séquence")
        #endif
        .navigationBarTitleDisplayModeInline()
        .toolbar(content: myToolBarContent)
    }
}

// MARK: Toolbar Content

extension SequenceEditorModal {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Annuler") {
                SequenceEntity.rollback()
                dismiss()
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button("Ok") {
                withAnimation {
                    try? SequenceEntity.saveIfContextHasChanged()
                }
                dismiss()
            }
        }
    }
}

//struct SequenceEditorModal_Previews: PreviewProvider {
//    static var previews: some View {
//        SequenceEditorModal()
//    }
//}
