//
//  WorkedCompEditorModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 05/06/2023.
//

import HelpersView
import SwiftUI

struct WorkedCompEditorModal: View {
    @ObservedObject
    var chapter: WorkedCompChapterEntity

    @StateObject
    private var workedCompChapterVM = WorkedCompViewModel()

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
            VStack {
                HStack {
                    cycle
                        .padding(.trailing)
                    acronym
                }
                description
            }
        }
        .onSubmit {
            focus?.moveToNext()
        }
        .onAppear {
            focus = .acronym
            workedCompChapterVM.update(from: chapter)
        }
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {},
            message: { Text(alertMessage) }
        )
        .toolbar(content: myToolBarContent)
        #if os(iOS)
            .navigationTitle("Modification")
        #endif
    }
}

// MARK: - Subviews

extension WorkedCompEditorModal {
    var cycle: some View {
        // niveau de cette classe
        LabeledContent {
            CasePicker(
                pickedCase: $workedCompChapterVM.cycle,
                label: ""
            )
            .pickerStyle(.menu)
        } label: {
            Image(systemName: WorkedCompChapterEntity.defaultImageName)
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

extension WorkedCompEditorModal {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Annuler") {
                ProgramEntity.rollback()
                dismiss()
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Ok") {
                // Ajouter un nouveau programme
                if WorkedCompChapterEntity.exists(
                    cycle: workedCompChapterVM.cycle,
                    acronym: workedCompChapterVM.acronym
                ) {
                    // doublon
                    alertTitle = "Ajout impossible"
                    alertMessage = "Un chapitre de compétences travaillées pour ce cycle existe déjà."
                    alertIsPresented.toggle()

                } else if workedCompChapterVM.acronym.isEmpty {
                    alertTitle = "Ajout impossible"
                    alertMessage = "L'acronyme de la compétence est obligatoire."
                    focus = .acronym
                    alertIsPresented.toggle()

                } else if workedCompChapterVM.description.isEmpty {
                    alertTitle = "Ajout impossible"
                    alertMessage = "La description de la compétence est obligatoire."
                    focus = .description
                    alertIsPresented.toggle()

                } else {
                    // Modifier le chapitre de compétences
                    withAnimation {
                        workedCompChapterVM.update(this: chapter)
                        try? WorkedCompChapterEntity.saveIfContextHasChanged()
                    }
                    dismiss()
                }
            }
        }
    }
}

//struct WorkedCompEditorModal_Previews: PreviewProvider {
//    static var previews: some View {
//        WorkedCompEditorModal()
//    }
//}
