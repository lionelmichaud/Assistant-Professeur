//
//  SequenceDocumentList.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 23/03/2023.
//

import Files
import HelpersView
import os
import SwiftUI
import PDFKit
import TipKit

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "SequenceDocumentList"
)

/// Vue de la liste des documents importants de la sequence
struct SequenceDocumentList: View {
    @ObservedObject
    var sequence: SequenceEntity

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    @State
    private var isImportingPdfFile = false

    @State
    private var alertInfo = AlertInfo()

    @State
    private var indexSet: IndexSet = []

    // Create an instance of your tip content.
    var addDocumentsTip = AddDocumentsTip()

    var body: some View {
        Section {
            // ajouter un ou plusieurs documents utiles
            TipView(addDocumentsTip, arrowEdge: .bottom)
                .customizedTipKitStyle()
            Button {
                // Invalidate the tip when someone uses the feature.
                addDocumentsTip.invalidate(reason: .actionPerformed)
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
                    // Invalidate the tip when someone uses the feature.
                    addDocumentsTip.invalidate(reason: .actionPerformed)
                    DocumentEntity.createWithoutSaving(
                        forSequence: sequence,
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
                    alertInfo.title,
                    alertInfo.message,
                    alertInfo.isPresented
                ) = ImportExportManager.importUserSelectedFiles(
                    result: result
                ) { data, fileName in
                    DocumentEntity.createWithoutSaving(
                        forSequence: sequence,
                        withData: data,
                        withName: fileName
                    )
                }
            }
            .alert(
                alertInfo.title,
                isPresented: $alertInfo.isPresented,
                actions: {},
                message: { Text(alertInfo.message) }
            )
            // Visualisation de la liste des documents
            ForEach(sequence.documentsSortedByName, id: \.objectID) { document in
                DocumentRow(
                    document: document,
                    saveChanges: false
                )
            }
            .onDelete(perform: deleteItems)

        } header: {
            Text("Documents (\(sequence.nbOfDocuments))")
                .style(.sectionHeader)
        }
    }

    // MARK: - Methods

    private func deleteItems(indexSet: IndexSet) {
        withAnimation {
            indexSet
                .map { sequence.documentsSortedByName[$0] }
                .forEach(managedObjectContext.delete)
        }
    }
}
