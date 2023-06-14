//
//  DKnowEditorModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 12/06/2023.
//

import SwiftUI
import HelpersView

struct DKnowEditorModal: View {
    @ObservedObject
    /// utilisé seulement si `isEditing`= true
    var knowledge: DKnowledgeEntity

    /// utilisé seulement si `isEditing`= false
    var nextNumber: Int = 1

    var inCompetency: DCompEntity

    var isEditing: Bool

    @StateObject
    private var knowledgeVM = DKnowViewModel()

    @Environment(\.dismiss)
    private var dismiss

    /// Focused filed manager
    enum FocusableField: Hashable {
        case number
        case description
        case none

        mutating func moveToNext() {
            switch self {
                case .number:
                    self = .description
                case .description:
                    self = .number
                case .none:
                    self = .none
            }
        }
    }

    @FocusState
    private var focus: FocusableField?

    @State
    private var alertTitle = ""
    @State
    private var alertMessage = ""
    @State
    private var alertIsPresented = false

    var body: some View {
        Form {
            number
            description
        }
        .onSubmit {
            focus?.moveToNext()
        }
        .onAppear {
            focus = .number
            if isEditing {
                knowledgeVM.update(from: knowledge)
            } else {
                knowledgeVM.number = nextNumber
            }
        }
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {},
            message: { Text(alertMessage) }
        )
        .toolbar(content: myToolBarContent)
        #if os(iOS)
            .navigationTitle(isEditing ? "Modification de la Connaissance" : "Nouvelle Connaissance")
        #endif
    }
}

// MARK: - Subviews

extension DKnowEditorModal {
    var number: some View {
        IntegerEditView2(
            label: "Numéro",
            integer: $knowledgeVM.number
        )
        .submitLabel(.next)
        .focused($focus, equals: .number)
    }

    var description: some View {
        TextField(
            "Description",
            text: $knowledgeVM.description,
            axis: .vertical
        )
        .lineLimit(5)
        .onSubmit {
            knowledgeVM.description.trim()
        }
        .textFieldStyle(.roundedBorder)
        .autocorrectionDisabled()
        .submitLabel(.next)
        .focused($focus, equals: .description)
    }
}

// MARK: Toolbar Content

extension DKnowEditorModal {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Annuler") {
                DKnowledgeEntity.rollback()
                dismiss()
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(isEditing ? "Ok" : "Ajouter") {
                // Ajouter un nouveau programme
                if inCompetency.exists(
                    number: knowledgeVM.number,
                    thisObjectID: isEditing ? knowledge.objectID : nil
                ) {
                    // doublon
                    alertTitle = "Ajout impossible"
                    alertMessage = "Une connaissance avec ce numéro existe déjà."
                    alertIsPresented.toggle()

                } else if knowledgeVM.description.isEmpty {
                    alertTitle = "Ajout impossible"
                    alertMessage = "La description de la connaissance est obligatoire."
                    focus = .description
                    alertIsPresented.toggle()

                } else {
                    // Créer et Ajouter un nouveau chapitre de compétences
                    withAnimation {
                        if isEditing {
                            knowledgeVM.update(this: knowledge)
                            try? WCompEntity
                                .saveIfContextHasChanged()
                        } else {
                            knowledgeVM
                                .createAndSaveEntity(inCompetency: inCompetency)
                        }
                    }
                    dismiss()
                }
            }
        }
    }
}

// struct DKnowEditorModal_Previews: PreviewProvider {
//    static var previews: some View {
//        DKnowEditorModal()
//    }
// }
