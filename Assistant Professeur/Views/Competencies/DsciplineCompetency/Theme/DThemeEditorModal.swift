//
//  DThemeEditorModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 08/06/2023.
//

import HelpersView
import SwiftUI

struct DThemeEditorModal: View {
    @ObservedObject
    var theme: DThemeEntity

    var discipline: Discipline

    var isEditing: Bool

    @StateObject
    private var disciplineThemeVM = DThemeViewModel()

    @Environment(\.dismiss)
    private var dismiss

    /// Focused filed manager
    enum FocusableField: Hashable {
        case acronym
        case description
        case progressivity
        case none

        mutating func moveToNext() {
            switch self {
                case .acronym:
                    self = .description
                case .description:
                    self = .progressivity
                case .progressivity:
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
            cycleView
            acronymView
            descriptionView
            Section("Repères de progressivité") {
                progressivity
            }
        }
        .onSubmit {
            focus?.moveToNext()
        }
        .onAppear {
            focus = .acronym
            if isEditing {
                disciplineThemeVM.update(from: theme)
            } else {
                disciplineThemeVM.discipline = discipline
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
            .navigationTitle(isEditing ? "Modification du Thème" : "Nouveau Thème")
        #endif
    }
}

// MARK: - Subviews

extension DThemeEditorModal {
    var cycleView: some View {
        // niveau de cette classe
        LabeledContent {
            CasePicker(
                pickedCase: $disciplineThemeVM.cycle,
                label: ""
            )
            .pickerStyle(.menu)
        } label: {
            Image(systemName: DThemeEntity.defaultImageName)
                .sfSymbolStyling()
        }
        .frame(maxWidth: 140)
    }

    var acronymView: some View {
        TextField(
            "Acronyme",
            text: $disciplineThemeVM.acronym
        )
        .onSubmit {
            disciplineThemeVM.acronym.trim()
        }
        .textFieldStyle(.roundedBorder)
        .frame(maxWidth: 100)
        .autocorrectionDisabled()
        .submitLabel(.next)
        .focused($focus, equals: .acronym)
    }

    var descriptionView: some View {
        TextField(
            "Description",
            text: $disciplineThemeVM.description,
            axis: .vertical
        )
        .lineLimit(5)
        .onSubmit {
            disciplineThemeVM.description.trim()
        }
        .textFieldStyle(.roundedBorder)
        .autocorrectionDisabled()
        .submitLabel(.next)
        .focused($focus, equals: .description)
    }

    var progressivity: some View {
        TextField(
            "Repères de progressivté",
            text: $disciplineThemeVM.progressivity,
            axis: .vertical
        )
        // .lineLimit(5)
        .onSubmit {
            disciplineThemeVM.progressivity.trim()
        }
        .textFieldStyle(.roundedBorder)
        .autocorrectionDisabled()
        .submitLabel(.next)
        .focused($focus, equals: .progressivity)
    }
}

// MARK: Toolbar Content

extension DThemeEditorModal {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Annuler") {
                DThemeEntity.rollback()
                dismiss()
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(isEditing ? "Ok" : "Ajouter") {
                // Ajouter un nouveau thème de compétences
                if DThemeEntity.exists(
                    cycle: disciplineThemeVM.cycle,
                    discipline: disciplineThemeVM.discipline,
                    acronym: disciplineThemeVM.acronym,
                    thisObjectID: isEditing ? theme.objectID : nil
                ) {
                    // doublon
                    alertTitle = isEditing ? "Modification impossible" : "Ajout impossible"
                    alertMessage = "Un thème de compétences disciplinaires pour ce cycle existe déjà."
                    alertIsPresented.toggle()

                } else if disciplineThemeVM.acronym.isEmpty {
                    alertTitle = isEditing ? "Modification impossible" : "Ajout impossible"
                    alertMessage = "L'acronyme du thème de compétences disciplinaires est obligatoire."
                    focus = .acronym
                    alertIsPresented.toggle()

                } else if disciplineThemeVM.acronym.isEmpty {
                    alertTitle = isEditing ? "Modification impossible" : "Ajout impossible"
                    alertMessage = "L'acronyme du thème de compétences disciplinaires est obligatoire."
                    focus = .acronym
                    alertIsPresented.toggle()

                } else if disciplineThemeVM.description.isEmpty {
                    alertTitle = isEditing ? "Modification impossible" : "Ajout impossible"
                    alertMessage = "La description du thème de compétences disciplinaires est obligatoire."
                    focus = .description
                    alertIsPresented.toggle()

                } else {
                    // Modifier le thème de compétences
                    withAnimation {
                        if isEditing {
                            disciplineThemeVM.update(this: theme)
                            try? DThemeEntity.saveIfContextHasChanged()
                        } else {
                            disciplineThemeVM
                                .createAndSaveEntity()
                        }
                    }
                    dismiss()
                }
            }
        }
    }
}

// struct DThemeEditorModal_Previews: PreviewProvider {
//    static var previews: some View {
//        DThemeEditorModal()
//    }
// }
