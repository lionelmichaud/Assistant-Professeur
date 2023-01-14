//
//  Document+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/11/2022.
//

import Foundation
import CoreData
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
        get {
            if let pdfData {
                guard let cgDataProvider = CGDataProvider(data: pdfData as CFData) else { return nil }
                guard let pdf = CGPDFDocument(cgDataProvider) else { return nil }
                return pdf
            } else {
                return nil
            }
        }
    }

}

// MARK: - Extension Core Data

extension DocumentEntity: ModelEntityP {

    // MARK: - Type Methods

    @discardableResult static func create(
        dans school   : SchoolEntity,
        withData data : Data,
        withName name : String
    ) -> DocumentEntity {
        let doc = DocumentEntity.create()
        // établissement d'appartenance.
        // mandatory
        doc.school = school

        doc.pdfData = data
        doc.docName = name

        try? SchoolEntity.saveIfContextHasChanged()

        return doc
    }

    // MARK: - Computed properties

}
