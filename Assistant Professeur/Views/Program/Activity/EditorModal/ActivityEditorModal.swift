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

    @ObservedObject
    private var pref = UserPrefEntity.shared

    /// Focused filed manager
    enum FocusableField: Hashable {
        case title
        case annotation
        case duration
        case url

        mutating func moveToNext() {
            switch self {
                case .title:
                    self = .annotation
                case .annotation:
                    self = .duration
                case .duration:
                    self = .url
                case .url:
                    self = .title
            }
        }
    }

    @FocusState
    private var focus: FocusableField?

    @State
    private var isImportingPdfFile = false

    var body: some View {
        Form {
            // Titre
            TextField(
                "Titre",
                text: $activity.name.bound,
                axis: .vertical
            )
            .lineLimit(5)
            .font(hClass == .compact ? .callout : .body)
            .textFieldStyle(.roundedBorder)
            .submitLabel(.next)
            .focused($focus, equals: .title)

            // Annotation
            if pref.viewActivityAnnotationEnabled {
                TextField(
                    "Annotation",
                    text: $activity.annotation.bound,
                    axis: .vertical
                )
                .lineLimit(5)
                .font(hClass == .compact ? .callout : .body)
                .textFieldStyle(.roundedBorder)
                .focused($focus, equals: .annotation)
            }

            // Nombre de séances nécessaires
            AmountEditView(
                label: "Durée",
                comment: "nombre de séances",
                amount: $activity.duration,
                validity: .greaterThanOrEqualTo(limit: 0),
                currency: false
            )
            .focused($focus, equals: .duration)

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
            .onChange(of: activity.isEval) { newValue in
                // Vérifier si on vient de faire de cette activité une Evaluation Sommative
                if newValue {
                    // Associer toutes les compétences disciplinaires de la séquence à cette activité
                    if let disciplineCompSortedByAcronym = activity.sequence?.disciplineCompSortedByAcronym {
                        let set = NSSet(array: disciplineCompSortedByAcronym)
                        activity.addToCompetencies(set)
                    }
                }
            }

            // Liste des documents utiles
            ActivityDocListSection(activity: activity)

            // URL associée
            WebsiteEditView(website: $activity.url)
                .focused($focus, equals: .url)

            // Compétences disciplinaires associées
            ActivityDCompListSection(activity: activity)
        }
        .onSubmit {
            focus?.moveToNext()
        }
        .onAppear {
            focus = .title
        }
        .interactiveDismissDisabled()
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
