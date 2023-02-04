//
//  ActivityEditorModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 25/01/2023.
//

import HelpersView
import SwiftUI

struct ActivityEditorModal: View {
    @ObservedObject
    var activity: ActivityEntity

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
                text: $activity.name.bound,
                axis: .vertical
            )
            .lineLimit(5)
            .font(hClass == .compact ? .callout : .body)
            .textFieldStyle(.roundedBorder)

            if annotationEnabled {
                TextField(
                    "Annotation",
                    text: $activity.annotation.bound,
                    axis: .vertical
                )
                .lineLimit(5)
                .font(hClass == .compact ? .callout : .body)
                .textFieldStyle(.roundedBorder)
            }

            WebsiteEditView(website: $activity.url)

            AmountEditView(
                label: "Durée",
                comment: "nombre de séances",
                amount: $activity.duration,
                validity: .greaterThanOrEqualTo(limit: 0),
                currency: false
            )

            Toggle(isOn: $activity.isProject) {
                Label(
                    "Partie d'un projet",
                    systemImage: ActivityEntity.projectSymbol
                )
            }
            Toggle(isOn: $activity.isTP) {
                Label(
                    "Inclue des Travaux Pratiques",
                    systemImage: ActivityEntity.tpSymbol
                )
            }
            Toggle(isOn: $activity.isEvalFormative) {
                Label(
                    "Inclue une Evaluation Formative",
                    systemImage: ActivityEntity.evalFormativeSymbol
                )
            }
            Toggle(isOn: $activity.isEval) {
                Label(
                    "Inclue une Evaluation Sommative",
                    systemImage: ActivityEntity.evalSommativeSymbol
                )
            }
        }
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {},
            message: { Text(alertMessage) }
        )
        #if os(iOS)
        .navigationTitle("Activité")
        #endif
        .navigationBarTitleDisplayModeInline()
        .toolbar(content: myToolBarContent)
    }
}

// MARK: Toolbar Content

extension ActivityEditorModal {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Annuler") {
                ActivityEntity.rollback()
                dismiss()
            }
        }

        ToolbarItem(placement: .confirmationAction) {
            Button("Ok") {
                withAnimation {
                    try? ActivityEntity.saveIfContextHasChanged()
                }
                dismiss()
            }
        }
    }
}

// struct ActivityEditorModal_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityEditorModal()
//    }
// }
