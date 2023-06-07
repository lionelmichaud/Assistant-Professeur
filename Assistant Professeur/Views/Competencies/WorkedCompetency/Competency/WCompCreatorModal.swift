//
//  WCompCreatorModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 06/06/2023.
//

import HelpersView
import SwiftUI

struct WCompCreatorModal: View {
    var chapter: WCompChapterEntity

    @StateObject
    private var workedCompVM = WCompViewModel()

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
        }
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {},
            message: { Text(alertMessage) }
        )
        .toolbar(content: myToolBarContent)
        #if os(iOS)
            .navigationTitle("Nouvelle Compétence")
        #endif
    }
}

// MARK: - Subviews

extension WCompCreatorModal {
    var number: some View {
        IntegerEditView2(
            label: "Numéro",
            integer: $workedCompVM.number
        )
//        .textFieldStyle(.roundedBorder)
//        .frame(maxWidth: 100)
//        .autocorrectionDisabled()
        .submitLabel(.next)
        .focused($focus, equals: .number)
    }

    var description: some View {
        TextField(
            "Description",
            text: $workedCompVM.description,
            axis: .vertical
        )
        .lineLimit(5)
        .onSubmit {
            workedCompVM.description.trim()
        }
        .textFieldStyle(.roundedBorder)
        .autocorrectionDisabled()
        .submitLabel(.next)
        .focused($focus, equals: .description)
    }
}

// MARK: Toolbar Content

extension WCompCreatorModal {
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
                if WCompEntity.exists(
                    number: workedCompVM.number
                ) {
                    // doublon
                    alertTitle = "Ajout impossible"
                    alertMessage = "Une compétence avec ce numéro existe déjà."
                    alertIsPresented.toggle()

                } else if workedCompVM.description.isEmpty {
                    alertTitle = "Ajout impossible"
                    alertMessage = "La description de la compétence est obligatoire."
                    focus = .description
                    alertIsPresented.toggle()

                } else {
                    // Créer et Ajouter un nouveau chapitre de compétences
                    withAnimation {
                        workedCompVM
                            .createAndSaveEntity(inChapter: chapter)
                    }
                    dismiss()
                }
            }
        }
    }
}

// struct WorkedCompCreatorModal_Previews: PreviewProvider {
//    static var previews: some View {
//        WorkedCompCreatorModal()
//    }
// }
