//
//  DocumentList.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 02/11/2022.
//

import SwiftUI
import os
import Files
import HelpersView

private let customLog = Logger(subsystem : "com.michaud.lionel.Cahier-du-Professeur",
                               category  : "DocumentList")

/// Vue de la liste des documents importants de l'établissement
struct DocumentList: View {
    @ObservedObject
    var school: SchoolEntity

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
            /// ajouter un ou plusieurs documents utiles
            Button {
                isImportingPdfFile.toggle()
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Ajouter un ou plusieurs documents")
                }
            }
            .buttonStyle(.borderless)
            /// Importer des fichiers PDF
            .fileImporter(isPresented             : $isImportingPdfFile,
                          allowedContentTypes     : [.pdf],
                          allowsMultipleSelection : true) { result in
                importUserSelectedFiles(result: result)
            }

            /// Visualisation de la liste des événements
            ForEach(school.documentsSortedByName, id: \.objectID) { document in
                DocumentRow(document: document)
            }
            .onDelete { indexSet in
                alertTitle = "Supprimer ce document?"
                alertMessage =
                    """
                    Cette action ne peut pas être annulée.
                    """
                self.indexSet = indexSet
                alertIsPresented.toggle()
            }
            .alert(
                alertTitle,
                isPresented : $alertIsPresented,
                actions     : {
                    Button("Supprimer", role: .destructive, action: deleteItems)
                }
            )

        } header: {
            Text("Documents (\(school.nbOfDocuments))")
                .font(.callout)
                .foregroundColor(.secondary)
                .fontWeight(.bold)
        }
    }

    // MARK: - Methods

    private func deleteItems() {
        withAnimation {
            indexSet
                .map { school.allDocuments[$0] }
                .forEach(managedObjectContext.delete)

            try? DocumentEntity.saveIfContextHasChanged()
        }
        //                indexSet.forEach { index in
        //                    let doc = school.documents[index]
        //                    let name = doc.fileName
        //
        //                    // vérifier l'existence du Folder Document
        //                    guard let documentsFolder = Folder.documents else {
        //                        self.alertItem = AlertItem(title         : Text("Échec"),
        //                                                   message       : Text("La suppression du fichier a échouée"),
        //                                                   dismissButton : .default(Text("OK")))
        //                        let error = FileError.failedToResolveDocuments
        //                        customLog.log(level: .fault, "\(error.rawValue))")
        //                        return
        //                    }
        //
        //                    do {
        //                        let file = try documentsFolder.file(named: name)
        //                        try file.delete()
        //                    } catch {
        //                        self.alertItem = AlertItem(title         : Text("Échec"),
        //                                                   message       : Text("La suppression du fichier a échouée"),
        //                                                   dismissButton : .default(Text("OK")))
        //                        customLog.log(level: .fault, "\(error))")
        //                    }
        //                }
        //                school.documents.remove(atOffsets: indexSet)
    }

    /// Copier les fichiers  sélectionnés dans le dossier Document de l'application.
    /// Ajouter un document à l'établissement pour chaque fichier importé.
    /// - Parameter result: résultat de la sélection des fichiers issue de fileImporter.
    private func importUserSelectedFiles(result: Result<[URL], Error>) {
        switch result {
            case .failure(let error):
                break
//                self.alertItem = AlertItem(title         : Text("Échec"),
//                                           message       : Text("L'importation des fichiers a échouée"),
//                                           dismissButton : .default(Text("OK")))
//                customLog.log(level: .fault,
//                              "Error selecting file: \(error.localizedDescription)")

            case .success(let filesUrl):
                break
//                do {
//                    try ImportExportManager
//                        .importURLsToDocumentsFolder(filesUrl             : filesUrl,
//                                                     importIfAlreadyExist : false) { file in
//                            withAnimation {
//                                // créer le document associé à l'établissement
//                                school
//                                    .documents
//                                    .append(Document(filenameExcludingExtension : file.nameExcludingExtension,
//                                                     fileExtension              : file.extension))
//                            }
//                        }
//
//                } catch {
//                    self.alertItem = AlertItem(title         : Text("Échec"),
//                                               message       : Text("L'importation des fichiers a échouée"),
//                                               dismissButton : .default(Text("OK")))
//                }
        }
    }
}

//struct DocumentList_Previews: PreviewProvider {
//    static var previews: some View {
//        DocumentList()
//    }
//}
