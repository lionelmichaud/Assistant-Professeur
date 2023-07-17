//
//  ProgramCreatorModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/01/2023.
//

import HelpersView
import SwiftUI

struct ProgramCreatorModal: View {
    @StateObject
    private var programVM = ProgramViewModel()

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.horizontalSizeClass)
    private var hClass

    @ObservedObject
    private var pref = UserPrefEntity.shared

    @State
    private var alertTitle = ""

    @State
    private var alertMessage = ""

    @State
    private var alertIsPresented = false

    var body: some View {
        Form {
            ViewThatFits(in: .horizontal) {
                // priorité 1
                HStack {
                    disciplineView
                    Spacer()
                    niveauView
                        .frame(maxWidth: 150)
                    segpaView
                        .layoutPriority(1)
                }

                // priorité 2
                VStack {
                    disciplineView
                    HStack {
                        niveauView
                            .frame(maxWidth: 180)
                        Spacer()
                        segpaView
                    }
                }
            }

            if pref.viewProgramAnnotationEnabled {
                TextField(
                    "Annotation",
                    text: $programVM.annotation,
                    axis: .vertical
                )
                .lineLimit(5)
                .font(hClass == .compact ? .callout : .body)
                .textFieldStyle(.roundedBorder)
            }

            WebsiteEditView(website: $programVM.url)
        }
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {},
            message: { Text(alertMessage) }
        )
        .toolbar(content: myToolBarContent)
        #if os(iOS)
            .navigationTitle("Nouveau Programme")
        #endif
    }
}

// MARK: - Subviews

extension ProgramCreatorModal {
    var niveauView: some View {
        HStack {
            // niveau de cette classe
            Image(systemName: ClasseEntity.defaultImageName)
                .sfSymbolStyling()
                .foregroundColor(programVM.levelEnum.imageColor)

            CasePicker(
                pickedCase: $programVM.levelEnum,
                label: ""
            )
            .pickerStyle(.menu)
        }
    }

    var segpaView: some View {
        Toggle(isOn: $programVM.segpa.animation()) {
            Text("SEGPA")
        }
        .toggleStyle(.button)
        .controlSize(.small)
    }

    var disciplineView: some View {
        CasePicker(
            pickedCase: $programVM.disciplineEnum,
            label: "Discipline"
        )
        .pickerStyle(.menu)
        .frame(width: 300)
    }
}

// MARK: Toolbar Content

extension ProgramCreatorModal {
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
                if ProgramEntity.exists(
                    dscipline: programVM.disciplineEnum,
                    classeLevel: programVM.levelEnum,
                    classeIsSegpa: programVM.segpa
                ) {
                    // doublon
                    alertTitle = "Ajout impossible"
                    alertMessage = "Un programme pour ce niveau existe déjà dans cette discipline."
                    alertIsPresented.toggle()

                } else {
                    // Créer et Ajouter un nouveau programme
                    withAnimation {
                        programVM.createAndSaveEntity()
                    }
                    dismiss()
                }
            }
        }
    }
}

struct ProgramCreatorModal_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            EmptyView()
            ProgramCreatorModal()
        }
    }
}
