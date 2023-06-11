//
//  DCompEditorModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 10/06/2023.
//

import SwiftUI
import HelpersView

struct DCompEditorModal: View {
    @ObservedObject
    /// utilisé seulement si `isEditing`= true
    var competency: DCompEntity

    /// utilisé seulement si `isEditing`= false
    var nextNumber: Int = 1

    var inSection: DSectionEntity

    var isEditing: Bool

    @StateObject
    private var disciplineCompVM = DCompViewModel()

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
                disciplineCompVM.update(from: competency)
            } else {
                disciplineCompVM.number = nextNumber
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
        .navigationTitle(isEditing ? "Modification Compétence" : "Nouvelle Compétence")
#endif
    }
}
// MARK: - Subviews

extension DCompEditorModal {
    var number: some View {
        IntegerEditView2(
            label: "Numéro",
            integer: $disciplineCompVM.number
        )
        .submitLabel(.next)
        .focused($focus, equals: .number)
    }

    var description: some View {
        TextField(
            "Description",
            text: $disciplineCompVM.description,
            axis: .vertical
        )
        .lineLimit(5)
        .onSubmit {
            disciplineCompVM.description.trim()
        }
        .textFieldStyle(.roundedBorder)
        .autocorrectionDisabled()
        .submitLabel(.next)
        .focused($focus, equals: .description)
    }
}

// MARK: Toolbar Content

extension DCompEditorModal {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Annuler") {
                DCompEntity.rollback()
                dismiss()
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(isEditing ? "Ok" : "Ajouter") {
                // Ajouter un nouveau programme
                if inSection.exists(
                    number: disciplineCompVM.number,
                    thisObjectID: isEditing ? competency.objectID : nil
                ) {
                    // doublon
                    alertTitle = "Ajout impossible"
                    alertMessage = "Une compétence avec ce numéro existe déjà."
                    alertIsPresented.toggle()

                } else if disciplineCompVM.description.isEmpty {
                    alertTitle = "Ajout impossible"
                    alertMessage = "La description de la compétence est obligatoire."
                    focus = .description
                    alertIsPresented.toggle()

                } else {
                    // Créer et Ajouter un nouveau chapitre de compétences
                    withAnimation {
                        if isEditing {
                            disciplineCompVM.update(this: competency)
                            try? WCompEntity
                                .saveIfContextHasChanged()
                        } else {
                            disciplineCompVM
                                .createAndSaveEntity(inSection: inSection)
                        }
                    }
                    dismiss()
                }
            }
        }
    }
}


//struct DCompEditorModal_Previews: PreviewProvider {
//    static var previews: some View {
//        DCompEditorModal()
//    }
//}
