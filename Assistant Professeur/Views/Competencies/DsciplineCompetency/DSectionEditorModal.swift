//
//  DSectionEditorModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 09/06/2023.
//

import HelpersView
import SwiftUI

struct DSectionEditorModal: View {
    @ObservedObject
    var section: DSectionEntity

    /// utilisé seulement si `isEditing`= false
    var nextNumber: Int = 1

    var inTheme: DThemeEntity

    var isEditing: Bool

    @StateObject
    private var disciplineSectionVM = DSectionViewModel()

    @Environment(\.dismiss)
    private var dismiss

    /// Focused filed manager
    enum FocusableField: Hashable {
        case number
        case description
        case progressivity
        case none

        mutating func moveToNext() {
            switch self {
                case .number:
                    self = .description
                case .description:
                    self = .progressivity
                case .progressivity:
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
            Section("Repères de progressivité") {
                progressivity
            }
        }
        .onSubmit {
            focus?.moveToNext()
        }
        .onAppear {
            focus = .number
            if isEditing {
                disciplineSectionVM.update(from: section)
            } else {
                disciplineSectionVM.number = nextNumber
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
            .navigationTitle(isEditing ? "Modification de la Section" : "Nouvelle Section")
        #endif
    }
}

// MARK: - Subviews

extension DSectionEditorModal {
    var number: some View {
        IntegerEditView2(
            label: "Numéro",
            integer: $disciplineSectionVM.number
        )
        .submitLabel(.next)
        .focused($focus, equals: .number)
    }

    var description: some View {
        TextField(
            "Description",
            text: $disciplineSectionVM.description,
            axis: .vertical
        )
        .lineLimit(5)
        .onSubmit {
            disciplineSectionVM.description.trim()
        }
        .textFieldStyle(.roundedBorder)
        .autocorrectionDisabled()
        .submitLabel(.next)
        .focused($focus, equals: .description)
    }

    var progressivity: some View {
        TextField(
            "Repères de progressivté",
            text: $disciplineSectionVM.progressivity,
            axis: .vertical
        )
        //.lineLimit(5)
        .onSubmit {
            disciplineSectionVM.progressivity.trim()
        }
        .textFieldStyle(.roundedBorder)
        .autocorrectionDisabled()
        .submitLabel(.next)
        .focused($focus, equals: .progressivity)
    }
}

// MARK: Toolbar Content

extension DSectionEditorModal {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Annuler") {
                DSectionEntity.rollback()
                dismiss()
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(isEditing ? "Ok" : "Ajouter") {
                // Ajouter un nouveau programme
                if inTheme.exists(
                    number: disciplineSectionVM.number,
                    thisObjectID: isEditing ? section.objectID : nil
                ) {
                    // doublon
                    alertTitle = "Ajout impossible"
                    alertMessage = "Une compétence avec ce numéro existe déjà."
                    alertIsPresented.toggle()

                } else if disciplineSectionVM.description.isEmpty {
                    alertTitle = "Ajout impossible"
                    alertMessage = "La description de la compétence est obligatoire."
                    focus = .description
                    alertIsPresented.toggle()

                } else {
                    // Créer et Ajouter un nouveau chapitre de compétences
                    withAnimation {
                        if isEditing {
                            disciplineSectionVM.update(this: section)
                            try? WCompEntity
                                .saveIfContextHasChanged()
                        } else {
                            disciplineSectionVM
                                .createAndSaveEntity(inTheme: inTheme)
                        }
                    }
                    dismiss()
                }
            }
        }
    }
}

// struct DSectionEditorModal_Previews: PreviewProvider {
//    static var previews: some View {
//        DSectionEditorModal()
//    }
// }
