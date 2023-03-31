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

    /// Retourne le nom du fichier PDF associé
    var fileName: String? {
        guard let uuidString = id?.uuidString else {
            return nil
        }
        return "doc_" + uuidString + ".pdf"
    }
}

// MARK: - Extension Core Data

extension DocumentEntity {
    // MARK: - Type Methods

    static func byId(id: UUID) -> Self? {
        all().first { object in
            object.id == id
        }
    }

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

    @discardableResult
    static func create(
        forProgram program: ProgramEntity,
        withData data: Data?,
        withName name: String
    ) -> DocumentEntity {
        let doc = DocumentEntity.create()
        // établissement d'appartenance.
        // mandatory
        doc.program = program

        if let data {
            doc.pdfData = data
        }
        doc.docName = name

        try? ProgramEntity.saveIfContextHasChanged()

        return doc
    }

    @discardableResult
    static func create(
        forSequence sequence: SequenceEntity,
        withData data: Data?,
        withName name: String
    ) -> DocumentEntity {
        let doc = DocumentEntity.create()
        // établissement d'appartenance.
        // mandatory
        doc.sequence = sequence

        if let data {
            doc.pdfData = data
        }
        doc.docName = name

        try? SequenceEntity.saveIfContextHasChanged()

        return doc
    }

    @discardableResult
    static func create(
        forActivity activity: ActivityEntity,
        withData data: Data?,
        withName name: String
    ) -> DocumentEntity {
        let doc = DocumentEntity.create()
        // établissement d'appartenance.
        // mandatory
        doc.activity = activity

        if let data {
            doc.pdfData = data
        }
        doc.docName = name

        try? SequenceEntity.saveIfContextHasChanged()

        return doc
    }

    /// Check the correctness and consistency of all database entities of this type.
    /// - Parameters:
    ///   - errorList: Liste des erreurs trouvées.
    static func checkConsistency(
        errorList: inout DataBaseErrorList
    ) {
        all().forEach { doc in
            if doc.school == nil &&
                doc.program == nil &&
                doc.sequence == nil &&
                doc.activity == nil {
                errorList
                    .append(DataBaseError.noOwner(
                        entity: Self.entity().name!,
                        name: doc.viewName,
                        id: doc.id
                    ))
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
        try? DocumentEntity.saveIfContextHasChanged()
    }
}

// MARK: - Extension Debug

public extension DocumentEntity {
    override var description: String {
        var owner = "nil"
        let top =
            """

            DOCUMENT:
               ID         : \(String(describing: id))
               Nom        : \(viewName)

            """
        if let school {
            owner = "school: \(school.displayString)"
        } else if let program {
            owner = "program: \(program.disciplineString)"
        } else if let sequence {
            owner = "sequence: \(sequence.viewName)"
        } else if let activity {
            owner = "activity: \(activity.viewName)"
        }
        return top + owner
    }
}
