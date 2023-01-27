//
//  ProgramEditor.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/01/2023.
//

import SwiftUI
import HelpersView

struct ProgramEditorModal: View {
    @ObservedObject
    var program: ProgramEntity

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.horizontalSizeClass)
    private var hClass

    @Preference(\.programAnnotationEnabled)
    private var annotationEnabled

    @State
    private var alertTitle = ""

    @State
    private var alertMessage = ""

    @State
    private var alertIsPresented = false

    var niveauView: some View {
        HStack {
            // niveau de cette classe
            Image(systemName: "person.3.sequence.fill")
                .sfSymbolStyling()
                .foregroundColor(program.levelEnum.color)

            CasePicker(pickedCase: $program.levelEnum,
                       label: "")
            .pickerStyle(.menu)
        }
    }

    var segpaView: some View {
        Toggle(isOn: $program.segpa.animation()) {
            Text("SEGPA")
        }
        .toggleStyle(.button)
        .controlSize(.small)
    }

    var disciplineView: some View {
        CasePicker(pickedCase: $program.disciplineEnum,
                   label: "Discipline")
        .pickerStyle(.menu)
        .frame(width: 300)
    }
    
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
            if annotationEnabled {
                TextField(
                    "Annotation",
                    text : $program.annotation.bound,
                    axis : .vertical
                )
                .lineLimit(5)
                .font(hClass == .compact ? .callout : .body)
                .textFieldStyle(.roundedBorder)
            }
            WebsiteEditView(website: $program.url)
        }
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: { },
            message: { Text(alertMessage) }
        )
        #if os(iOS)
        .navigationTitle("Programme")
        #endif
        .navigationBarTitleDisplayModeInline()
        .toolbar(content: myToolBarContent)
    }
}

// MARK: Toolbar Content

extension ProgramEditorModal {
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
                if ProgramEntity.exists(
                    dscipline: program.disciplineEnum,
                    classeLevel: program.levelEnum,
                    classeIsSegpa: program.segpa,
                    objectID: program.objectID
                ) {
                    // doublon
                    alertTitle   = "Ajout impossible"
                    alertMessage = "Un programme pour ce niveau existe déjà dans cette discipline."
                    alertIsPresented.toggle()

                } else {
                    withAnimation {
                        try? ProgramEntity.saveIfContextHasChanged()
                    }
                    dismiss()
                }
            }
        }
    }
}

//struct ProgramEditor_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgramEditor()
//    }
//}
