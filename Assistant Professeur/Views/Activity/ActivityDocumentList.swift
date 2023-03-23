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

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Cahier-du-Professeur",
    category: "ActivityDocumentList"
)

/// Vue de la liste des documents importants de l'établissement
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
                actions: {
                    Button(
                        "Supprimer",
                        role: .destructive,
                        action: deleteItems
                    )
                },
                message: {
                    Text(alertMessage)
                }
            )

            // Visualisation de la liste des documents
            ForEach(activity.documentsSortedByName, id: \.objectID) { document in
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
            Text("Documents (\(activity.nbOfDocuments))")
                .font(.callout)
                .foregroundColor(.secondary)
                .fontWeight(.bold)
        }
    }

    // MARK: - Methods

    private func deleteItems() {
        withAnimation {
            indexSet
                .map { activity.documentsSortedByName[$0] }
                .forEach(managedObjectContext.delete)
        }
    }
}
