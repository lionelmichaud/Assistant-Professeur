//
//  PdfViewConverter.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/07/2023.
//

import PDFKit
import SwiftUI

/// Convertion de PDF => Image ou View => PDF
enum PdfViewConverter {
    // MARK: - View => PDF

    /// Render a SwiftUI view `content` to a PDF and stores it into a `fileUrl`.
    /// - Parameters:
    ///   - content: View à convertir en PDF
    ///   - fileUrl: URL du fichier dans lequel stocker le PDF
    /// - Returns: `true` si la convertion a réussie
    @MainActor
    static func renderAsPDF(
        content: some View,
        to fileUrl: URL,
        withProposedSize proposedSize: ProposedViewSize = .unspecified
    ) -> Bool {
        var result = true

        // 1: Renderer for the `content` view
        let renderer = ImageRenderer(content: content)
        renderer.proposedSize = proposedSize

        // 3: Start the rendering process
        renderer.render { size, renderer in
            // 4: Tell SwiftUI our PDF should be the same size as the views we're rendering
            var mediaBox = CGRect(origin: .zero, size: size)

            // 5: Create the CGContext for our PDF pages
            guard let pdfContext = CGContext(fileUrl as CFURL, mediaBox: &mediaBox, nil) else {
                result = false
                return
            }

            // 6: Start a new PDF page
            pdfContext.beginPDFPage(nil)

            // 7: Render the SwiftUI view data onto the page
            renderer(pdfContext)

            // 8: End the page and close the file
            pdfContext.endPDFPage()
            pdfContext.closePDF()
        }

        return result
    }

    // MARK: - PDF => Image

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
