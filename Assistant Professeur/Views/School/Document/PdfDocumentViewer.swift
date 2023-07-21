//
//  PdfDocumentViewer.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 02/11/2022.
//

import PDFKit
import SwiftUI

struct PdfDocumentViewer: View {
    init(document: DocumentEntity) {
        self.document = document
        self._pdfImages = State(
            initialValue: PdfViewConverter.getPdfImages(pdfDocument: document.pdfDocument)
        )
    }

    @ObservedObject
    var document: DocumentEntity

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var pgNumber: Int = 0

    @State
    private var pdfImages = [Image]()

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
            GeometryReader { gr in
                if pdfImages.isNotEmpty {
                    ScrollView(
                        [.vertical, .horizontal],
                        showsIndicators: true
                    ) {
                        pdfImages[pgNumber]
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: gr.size.width, alignment: .topLeading)
                    }
                } else {
                    VStack(alignment: .center) {
                        Text(pdfImages.isEmpty ? "Document PDF introuvable." : "Chargement")
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
        }
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

            if pdfImages.count > 1 {
                ToolbarItemGroup(placement: .automatic) {
                    Button {
                        pgNumber = max(0, pgNumber - 1)
                    } label: {
                        Image(systemName: "arrow.backward.circle", variableValue: 1)
                    }
                    .disabled(pgNumber == pdfImages.startIndex)
                    Text("\(pgNumber + 1)/\(pdfImages.count)")
                    Button {
                        pgNumber = min(pdfImages.count - 1, pgNumber + 1)
                    } label: {
                        Image(systemName: "arrow.forward.circle", variableValue: 0)
                    }
                    .disabled(pgNumber == pdfImages.endIndex - 1)
                }
            }

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
