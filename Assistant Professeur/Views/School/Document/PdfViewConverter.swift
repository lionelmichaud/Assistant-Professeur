//
//  PdfViewConverter.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/07/2023.
//

import PDFKit
import SwiftUI

enum PdfViewConverter {
    /// Extrait les pages du document PDF sous forme d'image `Image`
    /// - Returns: Array d'images
    static func getPdfImages(pdfDocument: PDFDocument?) -> [Image] {
        if let pdfDocument,
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
        static func imagesFromPDF(_ pdfDocument: PDFDocument) -> [UIImage]? {
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
        static func imagesFromPDF(_: PDFDocument) -> [NSImage]? {
            [NSImage(
                systemSymbolName: "questionmark.app",
                accessibilityDescription: nil
            )!]
        }
    #endif
}
