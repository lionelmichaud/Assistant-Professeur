//
//  PdfDocumentViewer.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 02/11/2022.
//

import SwiftUI

struct PdfDocumentViewer: View {
    var document: Document

    @Environment(\.dismiss) private var dismiss

    @State
    private var pgNumber: Int = 0

    @State
    private var pdfImages = [Image]()

    // MARK: - Computed Properties

    private func getPdfImages() -> [Image] {
        if let uiImages = imagesFromPDF(at: document.url) {
            return uiImages.map { uiImage in
                Image(uiImage: uiImage)
            }
        } else {
            return [Image(systemName: "doc.richtext").resizable()]
        }
    }

    var body: some View {
        Group {
            if pdfImages.isNotEmpty {
                ScrollView([.vertical, .horizontal],
                           showsIndicators: true) {
                    pdfImages[pgNumber]
                }
            } else {
                Text("Chargement")
            }
        }
        #if os(iOS)
        .navigationTitle("\(document.docName)")
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

    /// Retourne une suite d'images créées à partir d'un document PDF.
    /// - Parameter url: URL du document PDF à convertir
    /// - Returns: Une image pour chaque page du PDF.
    private func imagesFromPDF(at url: URL) -> [UIImage]? {
        guard let document = CGPDFDocument(url as CFURL) else { return nil }

        let numberOfPages = document.numberOfPages
        guard numberOfPages.isPositive else { return nil }

        let pagesRange = 1 ... numberOfPages
        var images = [UIImage]()

        pagesRange.forEach { pageNumber in
            guard let page = document.page(at: pageNumber) else { return }

            let pageRect = page.getBoxRect(.mediaBox)
            let renderer = UIGraphicsImageRenderer(size: pageRect.size)
            let img = renderer.image { ctx in
                UIColor.white.set()
                ctx.fill(pageRect)

                ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
                ctx.cgContext.scaleBy(x: 1.0, y: -1.0)

                ctx.cgContext.drawPDFPage(page)
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
