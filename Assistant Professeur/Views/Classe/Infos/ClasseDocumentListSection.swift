//
//  ClasseDocumentListSection.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 09/09/2023.
//

import HelpersView
import OSLog
import PDFKit
import SwiftUI
import TipKit

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
                    Text("Ajouter des documents")
                }
            }
            .buttonStyle(.borderless)
            .customizedListItemStyle(
                isSelected: false
            )
            .dropDestination(for: Data.self) { items, _ in
                guard let item = items.first else {
                    return false
                }
                if PDFDocument(data: item) != nil {
                    // Invalidate the tip when someone uses the feature.
                    addDocumentsTip.invalidate(reason: .actionPerformed)
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
                    alertInfo.title,
                    alertInfo.message,
                    alertInfo.isPresented
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
                alertInfo.title,
                isPresented: $alertInfo.isPresented,
                actions: {
                    Button("Supprimer", role: .destructive, action: deleteItems)
                },
                message: {
                    Text(alertInfo.message)
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
                    alertInfo.title = "Supprimer ce document?"
                    alertInfo.message =
                        """
                        Cette action ne peut pas être annulée.
                        """
                    alertInfo.isPresented.toggle()
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
