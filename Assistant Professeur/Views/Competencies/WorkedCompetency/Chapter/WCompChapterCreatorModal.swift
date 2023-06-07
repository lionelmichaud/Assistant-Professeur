//
//  WorkedCompCreatorModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/06/2023.
//

import HelpersView
import SwiftUI

struct WCompChapterCreatorModal: View {
    @StateObject
    private var workedCompChapterVM = WCompChapterViewModel()

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
        }
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {},
            message: { Text(alertMessage) }
        )
        .toolbar(content: myToolBarContent)
        #if os(iOS)
            .navigationTitle("Nouvel Élément")
        #endif
    }
}

// MARK: - Subviews

extension WCompChapterCreatorModal {
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

extension WCompChapterCreatorModal {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Annuler") {
                ProgramEntity.rollback()
                dismiss()
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Ajouter") {
                // Ajouter un nouveau programme
                if WCompChapterEntity.exists(
                    cycle: workedCompChapterVM.cycle,
                    acronym: workedCompChapterVM.acronym
                ) {
                    // doublon
                    alertTitle = "Ajout impossible"
                    alertMessage = "Un chapitre de compétences travaillées pour ce cycle existe déjà."
                    alertIsPresented.toggle()

                } else if workedCompChapterVM.acronym.isEmpty {
                    alertTitle = "Ajout impossible"
                    alertMessage = "L'acronyme du chapitre de compétences est obligatoire."
                    focus = .acronym
                    alertIsPresented.toggle()

                } else if workedCompChapterVM.description.isEmpty {
                    alertTitle = "Ajout impossible"
                    alertMessage = "La description du chapitre de compétences est obligatoire."
                    focus = .description
                    alertIsPresented.toggle()

                } else {
                    // Créer et Ajouter un nouveau chapitre de compétences
                    withAnimation {
                        workedCompChapterVM.createAndSaveEntity()
                    }
                    dismiss()
                }
            }
        }
    }
}

struct WorkedCompChapterCreatorModal_Previews: PreviewProvider {
    static var previews: some View {
        WCompChapterCreatorModal()
    }
}
