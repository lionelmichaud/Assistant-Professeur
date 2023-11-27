//
//  WCompChapterEditorModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 05/06/2023.
//

import HelpersView
import SwiftUI

struct WCompChapterEditorModal: View {
    @ObservedObject
    var chapter: WCompChapterEntity

    @State
    private var workedCompChapterVM = WCompChapterViewModel()

    var isEditing: Bool

    @Environment(\.dismiss)
    private var dismiss

    /// Focused filed manager
    enum FocusableField: Hashable {
        case acronym
        case description
        case none

        mutating func moveToNext() {
            switch self {
                case .acronym:
                    self = .description
                case .description:
                    self = .acronym
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
            cycle
            acronym
            description
        }
        .onSubmit {
            focus?.moveToNext()
        }
        .onAppear {
            focus = .acronym
            if isEditing {
                workedCompChapterVM.update(from: chapter)
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
            .navigationTitle(isEditing ? "Modification de l'Élément" : "Nouvel Élément")
        #endif
    }
}

// MARK: - Subviews

extension WCompChapterEditorModal {
    var cycle: some View {
        // niveau de cette classe
        LabeledContent {
            CasePicker(
                pickedCase: $workedCompChapterVM.cycle,
                label: ""
            )
            .pickerStyle(.menu)
        } label: {
            Image(systemName: WCompChapterEntity.defaultImageName)
                .sfSymbolStyling()
        }
        .frame(maxWidth: 140)
    }

    var acronym: some View {
        TextField(
            "Acronyme",
            text: $workedCompChapterVM.acronym
        )
        .onSubmit {
            workedCompChapterVM.acronym.trim()
        }
        .textFieldStyle(.roundedBorder)
        .frame(maxWidth: 100)
        .autocorrectionDisabled()
        .submitLabel(.next)
        .focused($focus, equals: .acronym)
    }

    var description: some View {
        TextField(
            "Description",
            text: $workedCompChapterVM.description,
            axis: .vertical
        )
        .lineLimit(5)
        .onSubmit {
            workedCompChapterVM.description.trim()
        }
        .textFieldStyle(.roundedBorder)
        .autocorrectionDisabled()
        .submitLabel(.next)
        .focused($focus, equals: .description)
    }
}

// MARK: Toolbar Content

extension WCompChapterEditorModal {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Annuler") {
                ProgramEntity.rollback()
                dismiss()
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(isEditing ? "Ok" : "Ajouter") {
                // Ajouter un nouveau programme
                if WCompChapterEntity.exists(
                    cycle: workedCompChapterVM.cycle,
                    acronym: workedCompChapterVM.acronym,
                    thisObjectID: isEditing ? chapter.objectID : nil
                ) {
                    // doublon
                    alertTitle = isEditing ? "Modification impossible" : "Ajout impossible"
                    alertMessage = "Un chapitre de compétences travaillées pour ce cycle existe déjà."
                    alertIsPresented.toggle()

                } else if workedCompChapterVM.acronym.isEmpty {
                    alertTitle = isEditing ? "Modification impossible" : "Ajout impossible"
                    alertMessage = "L'acronyme de la compétence est obligatoire."
                    focus = .acronym
                    alertIsPresented.toggle()

                } else if workedCompChapterVM.description.isEmpty {
                    alertTitle = isEditing ? "Modification impossible" : "Ajout impossible"
                    alertMessage = "La description de la compétence est obligatoire."
                    focus = .description
                    alertIsPresented.toggle()

                } else {
                    // Modifier le chapitre de compétences
                    withAnimation {
                        if isEditing {
                            workedCompChapterVM.update(this: chapter)
                            try? WCompChapterEntity.saveIfContextHasChanged()
                        } else {
                            workedCompChapterVM
                                .createAndSaveEntity()
                        }
                    }
                    dismiss()
                }
            }
        }
    }
}

// struct WCompChapterEditorModal_Previews: PreviewProvider {
//    static var previews: some View {
//        WorkedCompEditorModal()
//    }
// }
