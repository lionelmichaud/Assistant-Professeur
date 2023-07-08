//
//  ActivityDocumentList.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 02/11/2022.
//

import Files
import HelpersView
import os
import SwiftUI
import PDFKit

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "ActivityDocumentList"
)

/// Vue de la liste des documents importants de l'activité
struct ActivityDocumentList: View {
    @ObservedObject
    var activity: ActivityEntity

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
                    Text("Ajouter un ou plusieurs documents")
                }
            }
            .buttonStyle(.borderless)
            .dropDestination(for: Data.self) { items, _ in
                guard let item = items.first else {
                    return false
                }
                if PDFDocument(data: item) != nil {
                    DocumentEntity.create(
                        forActivity: activity,
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
                        forActivity: activity,
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
            // Visualisation de la liste des documents
            ForEach(activity.documentsSortedByName, id: \.objectID) { document in
                DocumentRow(
                    document: document,
                    saveChanges: true
                )
            }
            .onDelete(perform: deleteItems)

        } header: {
            Text("Documents (\(activity.nbOfDocuments))")
                .style(.sectionHeader)
        }
    }

    // MARK: - Methods

    private func deleteItems(indexSet: IndexSet) {
        withAnimation {
            indexSet
                .map { activity.documentsSortedByName[$0] }
                .forEach(managedObjectContext.delete)
        }
    }
}
