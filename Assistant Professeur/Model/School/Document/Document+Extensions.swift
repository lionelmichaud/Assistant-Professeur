//
//  Document+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/11/2022.
//

import CoreData
import Foundation
import PDFKit

extension DocumentEntity {
    // MARK: - Computed properties

    /// Wrapper of `docName`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewName: String {
        get {
            self.docName ?? ""
        }
        set {
            self.docName = newValue
            try? DocumentEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `pdfData`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var pdfDocument: PDFDocument? {
        get {
            if let pdfData {
                return PDFDocument(data: pdfData)
            } else {
                return nil
            }
        }
        set {
            self.pdfData = newValue?.dataRepresentation()
            try? DocumentEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `pdfData`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var cgPDFDocument: CGPDFDocument? {
        if let pdfData {
            guard let cgDataProvider = CGDataProvider(data: pdfData as CFData) else {
                return nil
            }
            guard let pdf = CGPDFDocument(cgDataProvider) else {
                return nil
            }
            return pdf
        } else {
            return nil
        }
    }
}

// MARK: - Extension Core Data

extension DocumentEntity {
    // MARK: - Type Methods

    @discardableResult
    static func create(
        dans school: SchoolEntity,
        withData data: Data?,
        withName name: String
    ) -> DocumentEntity {
        let doc = DocumentEntity.create()
        // établissement d'appartenance.
        // mandatory
        doc.school = school

        if let data {
            doc.pdfData = data
        }
        doc.docName = name

        try? SchoolEntity.saveIfContextHasChanged()

        return doc
    }

    static func checkConsistency(errorFound: inout Bool) {
        all().forEach { doc in
            guard doc.school != nil else {
                errorFound = true
                return
            }
        }
    }

    // MARK: - Methods

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set defaults here
        self.id = UUID()
    }

    /// Rempalce les données PDF éventuellement présentes par de nouvelles
    /// - Parameter newPdfData: les nouvelle données PDF
    func setPdfData(to newPdfData: Data) {
        pdfData = newPdfData
        try? SchoolEntity.saveIfContextHasChanged()
    }
}
