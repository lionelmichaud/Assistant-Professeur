//
//  ProgramEditor.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/01/2023.
//

import HelpersView
import PDFKit
import SwiftUI

struct ProgramEditorModal: View {
    @ObservedObject
    var program: ProgramEntity

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.horizontalSizeClass)
    private var hClass

    @EnvironmentObject
    private var pref: UserPreferences

    @State
    private var isImportingPdfFile = false

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

            if pref.programAnnotationEnabled {
                TextField(
                    "Annotation",
                    text: $program.annotation.bound,
                    axis: .vertical
                )
                .lineLimit(5)
                .font(hClass == .compact ? .callout : .body)
                .textFieldStyle(.roundedBorder)
            }

            if let document = program.document {
                HStack(spacing: 5) {
                    // afficher le nom du document
                    DocumentRow(
                        document: document,
                        saveChanges: false
                    )

                    // supprimer le document
                    Button(role: .destructive) {
                        DocumentEntity.context.delete(document)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                // ajouter un document
                Button {
                    isImportingPdfFile.toggle()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Ajouter un document")
                    }
                }
                .buttonStyle(.borderless)
                .dropDestination(for: Data.self) { items, _ in
                    guard let item = items.first else {
                        return false
                    }
                    if PDFDocument(data: item) != nil {
                        DocumentEntity.create(
                            forProgram: program,
                            withData: item,
                            withName: "Nouveau document"
                        )
                        return true
                    } else {
                        return false
                    }
                }
            }

            WebsiteEditView(website: $program.url)
        }
        // Importer des fichiers PDF
        .fileImporter(
            isPresented: $isImportingPdfFile,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            (
                alertTitle,
                alertMessage,
                alertIsPresented
            ) = ImportExportManager.importUserSelectedFiles(
                result: result
            ) { data, fileName in
                DocumentEntity.create(
                    forProgram: program,
                    withData: data,
                    withName: fileName
                )
            }
        }
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {},
            message: { Text(alertMessage) }
        )
        #if os(iOS)
        .navigationTitle("Programme")
        #endif
        .navigationBarTitleDisplayModeInline()
        .toolbar(content: myToolBarContent)
    }
}

// MARK: Subviews

extension ProgramEditorModal {
    var niveauView: some View {
        HStack {
            // niveau de cette classe
            Image(systemName: "person.3.sequence.fill")
                .sfSymbolStyling()
                .foregroundColor(program.levelEnum.color)

            CasePicker(
                pickedCase: $program.levelEnum,
                label: ""
            )
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
        CasePicker(
            pickedCase: $program.disciplineEnum,
            label: "Discipline"
        )
        .pickerStyle(.menu)
        .frame(width: 300)
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
                    alertTitle = "Ajout impossible"
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

struct ProgramEditor_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            ProgramEditorModal(program: ProgramEntity.all().first!)
                .padding()
                .environmentObject(NavigationModel(selectedProgramMngObjId: ProgramEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")
            ProgramEditorModal(program: ProgramEntity.all().first!)
                .padding()
                .environmentObject(NavigationModel(selectedProgramMngObjId: ProgramEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
