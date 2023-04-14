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
        self._pdfImages = State(initialValue: getPdfImages())
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
            if pdfImages.isNotEmpty {
                ScrollView(
                    [.vertical, .horizontal],
                    showsIndicators: true
                ) {
                    pdfImages[pgNumber]
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
                    // Importer un fichier PDF
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

    // MARK: - Methods

    /// Extrait les pages du document PDF sous forme d'image `Image`
    /// - Returns: Array d'images
    private func getPdfImages() -> [Image] {
        if let pdfDocument = document.pdfDocument,
           let nativeImages = imagesFromPDF(pdfDocument) {
            return nativeImages.map { nativeImage in
                #if os(iOS)
                    Image(uiImage: nativeImage)
                #else
                    Image(nsImage: nativeImage)
                #endif
            }
        } else {
            return []
        }
    }

    #if os(iOS)
        /// Retourne une suite d'images créées à partir d'un document PDF.
        /// - Parameter url: URL du document PDF à convertir
        /// - Returns: Une image pour chaque page du PDF.
        private func imagesFromPDF(_ pdfDocument: PDFDocument) -> [UIImage]? {
            let numberOfPages = pdfDocument.pageCount
            guard numberOfPages.isPositive else {
                return nil
            }

            let pagesRange = 0 ... numberOfPages - 1
            var images = [UIImage]()

            pagesRange.forEach { pageNumber in
                // Get the nth page of the PDF document.
                guard let page = pdfDocument.page(at: pageNumber) else {
                    return
                }

                // Fetch the page rect for the page we want to render.
                let pageRect = page.bounds(for: .mediaBox)
                let renderer = UIGraphicsImageRenderer(size: pageRect.size)
                let img = renderer.image { ctx in
                    // Set and fill the background color.
                    UIColor.white.set()
                    ctx.fill(pageRect)

                    // Translate the context so that we only draw the `cropRect`.
                    ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)

                    // Flip the context vertically because the Core Graphics coordinate system starts from the bottom.
                    ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

                    // Draw the PDF page.
                    page.draw(with: .mediaBox, to: ctx.cgContext)
                }

                images.append(img)
            }

            return images
        }
    #else
        private func imagesFromPDF(_: PDFDocument) -> [NSImage]? {
            [NSImage(
                systemSymbolName: "questionmark.app",
                accessibilityDescription: nil
            )!]
        }
    #endif
}

// struct PdfDocumentViewer_Previews: PreviewProvider {
//    static var previews: some View {
//        PdfDocumentViewer()
//    }
// }
