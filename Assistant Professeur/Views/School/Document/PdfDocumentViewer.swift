//
//  PdfDocumentViewer.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 02/11/2022.
//

import SwiftUI
import PDFKit

struct PdfDocumentViewer: View {
    @ObservedObject
    var document: DocumentEntity

    @Environment(\.dismiss) private var dismiss

    @State
    private var pgNumber: Int = 0

    @State
    private var pdfImages = [Image]()

    // MARK: - Computed Properties

    var body: some View {
        Group {
            if pdfImages.isNotEmpty {
                ScrollView([.vertical, .horizontal],
                           showsIndicators: true) {
                    pdfImages[pgNumber]
                }
            } else {
                Text(pdfImages.isEmpty ? "Aucune page PDF trouvée" : "Chargement")
            }
        }
        #if os(iOS)
        .navigationTitle("\(document.viewName)")
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            pdfImages = getPdfImages()
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
                    Text("\(pgNumber+1)/\(pdfImages.count)")
                    Button {
                        pgNumber = min(pdfImages.count-1, pgNumber + 1)
                    } label: {
                        Image(systemName: "arrow.forward.circle", variableValue: 0)
                    }
                    .disabled(pgNumber == pdfImages.endIndex-1)
                }
            }
        }
    }

    // MARK: - Methods

    /// Extrait les pages du document PDF sous forme d'image `Image`
    /// - Returns: Array d'images
    private func getPdfImages() -> [Image] {
        if let pdfDocument = document.pdfDocument,
            let uiImages = imagesFromPDF(pdfDocument) {
            return uiImages.map { uiImage in
                Image(uiImage: uiImage)
            }
        } else {
            return [Image(systemName: "doc.richtext").resizable()]
        }
    }

    /// Retourne une suite d'images créées à partir d'un document PDF.
    /// - Parameter url: URL du document PDF à convertir
    /// - Returns: Une image pour chaque page du PDF.
    private func imagesFromPDF(_ pdfDocument: PDFDocument) -> [UIImage]? {
        let numberOfPages = pdfDocument.pageCount
        guard numberOfPages.isPositive else { return nil }

        let pagesRange = 0 ... numberOfPages - 1
        var images = [UIImage]()

        pagesRange.forEach { pageNumber in
            guard let page = pdfDocument.page(at: pageNumber) else { return }

            let pageRect = page.bounds(for: .mediaBox)
            let renderer = UIGraphicsImageRenderer(size: pageRect.size)
            let img = renderer.image { ctx in
                UIColor.white.set()
                ctx.fill(pageRect)

                ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
                ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

                page.draw(with: .mediaBox, to: ctx.cgContext)
            }

            images.append(img)
        }

        return images
    }
}

//struct PdfDocumentViewer_Previews: PreviewProvider {
//    static var previews: some View {
//        PdfDocumentViewer()
//    }
//}
