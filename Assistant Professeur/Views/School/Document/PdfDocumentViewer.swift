//
//  PdfDocumentViewer.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 02/11/2022.
//

import SwiftUI
import HelpersView

struct PdfDocumentViewer: View {
    @ObservedObject
    var document: DocumentEntity

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var alertTitle = ""

    @State
    private var alertMessage = ""

    @State
    private var alertIsPresented = false

    @State
    private var isImportingPdfFile = false

    @State
    private var isExportingPdfFile = false

    @State
    private var exportedDocURL: URL?

    // MARK: - Computed Properties

    var body: some View {
        Group {
            if let pdfDocument = document.pdfDocument {
                // Using the PDFKitView and passing the previously created pdfURL
                PDFKitView(pdfDocument: pdfDocument)
                    //.scaledToFill()
            } else {
                VStack(alignment: .center) {
                    Text("Document PDF introuvable.")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    // ajouter un document PDF
                    Button("Ajouter un document") {
                        isImportingPdfFile = true
                    }
                    .buttonStyle(.borderless)
                    .padding(.top)
                }
            }
        }
        .padding()
        #if os(iOS)
            .navigationTitle("\(document.viewName)")
            .navigationBarTitleDisplayMode(.inline)
        #endif
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
                ) { data, _ in
                    document.pdfData = data
                    try? DocumentEntity.saveIfContextHasChanged()
                }
            }
            .alert(
                alertTitle,
                isPresented: $alertIsPresented,
                actions: {},
                message: {
                    Text(alertMessage)
                }
            )

            // Exporter le fichier PDF
            .fileMover(
                isPresented: $isExportingPdfFile,
                files: exportedDocURL != nil ? [exportedDocURL!] : []
            ) { _ in
            }

            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button("OK") {
                        dismiss()
                    }
                }

//            if pdfImages.count > 1 {
//                ToolbarItemGroup(placement: .automatic) {
//                    Button {
//                        pgNumber = max(0, pgNumber - 1)
//                    } label: {
//                        Image(systemName: "arrow.backward.circle", variableValue: 1)
//                    }
//                    .disabled(pgNumber == pdfImages.startIndex)
//                    Text("\(pgNumber + 1)/\(pdfImages.count)")
//                    Button {
//                        pgNumber = min(pdfImages.count - 1, pgNumber + 1)
//                    } label: {
//                        Image(systemName: "arrow.forward.circle", variableValue: 0)
//                    }
//                    .disabled(pgNumber == pdfImages.endIndex - 1)
//                }
//            }
//
                ToolbarItem(placement: .automatic) {
                    Button {
                        exportedDocURL = document.exportDocFile()
                        isExportingPdfFile.toggle()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
    }
}

// struct PdfDocumentViewer_Previews: PreviewProvider {
//    static var previews: some View {
//        PdfDocumentViewer()
//    }
// }
