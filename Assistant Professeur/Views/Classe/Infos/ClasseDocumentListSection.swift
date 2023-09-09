//
//  ClasseDocumentListSection.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 09/09/2023.
//

import Files
import HelpersView
import os
import PDFKit
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "ClasseDocumentListSection"
)

/// Vue de la liste des documents importants de la classe
struct ClasseDocumentListSection: View {
    @ObservedObject
    var classe: ClasseEntity

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    @State
    private var isImportingPdfFile = false

    @State
    private var alertTitle = ""

    @State
    private var alertMessage = ""

    @State
    private var alertIsPresented = false

    @State
    private var indexSet: IndexSet = []

    var body: some View {
        Section {
            // ajouter un ou plusieurs documents utiles
            Button {
                isImportingPdfFile.toggle()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Ajouter des documents")
                }
            }
            .buttonStyle(.borderless)
            .dropDestination(for: Data.self) { items, _ in
                guard let item = items.first else {
                    return false
                }
                if PDFDocument(data: item) != nil {
                    DocumentEntity.create(
                        dans: classe,
                        withData: item,
                        withName: "Nouveau document"
                    )
                    return true
                } else {
                    return false
                }
            }
            // Importer des fichiers PDF
            .fileImporter(
                isPresented: $isImportingPdfFile,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: true
            ) { result in
                (
                    alertTitle,
                    alertMessage,
                    alertIsPresented
                ) = ImportExportManager.importUserSelectedFiles(
                    result: result
                ) { data, fileName in
                    DocumentEntity.create(
                        dans: classe,
                        withData: data,
                        withName: fileName
                    )
                }
            }
            .alert(
                alertTitle,
                isPresented: $alertIsPresented,
                actions: {
                    Button("Supprimer", role: .destructive, action: deleteItems)
                },
                message: {
                    Text(alertMessage)
                }
            )

            // Visualisation de la liste des documents
            ForEach(classe.documentsSortedByName, id: \.objectID) { document in
                DocumentRow(
                    document: document,
                    saveChanges: true
                )
            }
            .onDelete { indexSet in
                DispatchQueue.main.async {
                    self.indexSet = indexSet
                    alertTitle = "Supprimer ce document?"
                    alertMessage =
                        """
                        Cette action ne peut pas être annulée.
                        """
                    alertIsPresented.toggle()
                }
            }

        } header: {
            Text("Documents (\(classe.nbOfDocuments))")
                .style(.sectionHeader)
        }
    }

    // MARK: - Methods

    private func deleteItems() {
        withAnimation {
            indexSet
                .map { classe.documentsSortedByName[$0] }
                .forEach(managedObjectContext.delete)

            try? DocumentEntity.saveIfContextHasChanged()
        }
    }
}
