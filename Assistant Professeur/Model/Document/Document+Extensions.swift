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

    /// Nom du symbol par défaut utilisée pour représenter un établissement
    static let defaultImageName: String = "doc.richtext"

    static let forEleveImageName: String = "printer.filled.and.paper"
    static let forEntImageName: String = "externaldrive.connected.to.line.below"
    static let forTeacherImageName: String = "person.and.background.striped.horizontal"

    /// Nom du symbol à utiliser en tête du document en fonction des destinations du document.
    var destinationImageName: String {
        if isForEleve {
            if isForENT {
                "externaldrive.badge.person.crop"
            } else {
                DocumentEntity.forEleveImageName
            }
        } else if isForENT {
            DocumentEntity.forEntImageName
        } else {
            DocumentEntity.forTeacherImageName
        }
    }

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

    /// Wrapper of `isForEleve`
    /// - Note: Un doc à distribuer aux élèves n'est pas pour le prof seulement
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewIsForEleve: Bool {
        get {
            self.isForEleve
        }
        set {
            self.isForEleve = newValue
            if newValue {
                // Un doc à distribuer aux élèves n'est pas pour le prof seulement
                self.isForTeacher = false
            }
            try? DocumentEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `isForEleve`
    /// - Note: Un doc à distribuer aux élèves n'est pas pour le prof seulement
    /// - Important: *Does NOT the context to the store after modification is done*
    @objc
    var unsavedIsForEleve: Bool {
        get {
            self.isForEleve
        }
        set {
            self.isForEleve = newValue
            if newValue {
                // Un doc à distribuer aux élèves n'est pas pour le prof seulement
                self.isForTeacher = false
            }
        }
    }

    /// Wrapper of `isForTeacher`
    /// - Note: Un doc pour le prof seulement ne peut être partagé sur l'ENT ni distribué aux élèves
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewIsForTeacher: Bool {
        get {
            self.isForTeacher
        }
        set {
            self.isForTeacher = newValue
            if newValue {
                // Un doc pour le prof seulement ne peut être partagé sur l'ENT ni distribué aux élèves
                self.isForEleve = false
                self.isForENT = false
            }
            try? DocumentEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `isForTeacher`
    /// - Note: Un doc pour le prof seulement ne peut être partagé sur l'ENT ni distribué aux élèves
    /// - Important: *Does NOT the context to the store after modification is done*
    @objc
    var unsavedIsForTeacher: Bool {
        get {
            self.isForTeacher
        }
        set {
            self.isForTeacher = newValue
            if newValue {
                // Un doc pour le prof seulement ne peut être partagé sur l'ENT ni distribué aux élèves
                self.isForEleve = false
                self.isForENT = false
            }
        }
    }

    /// Wrapper of `isForENT`
    /// - Note: Un doc à stocker sur l'ENT n'est pas pour le prof seulement
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewIsForENT: Bool {
        get {
            self.isForENT
        }
        set {
            self.isForENT = newValue
            if newValue {
                // Un doc à stocker sur l'ENT n'est pas pour le prof seulement
                self.isForTeacher = false
            }
            try? DocumentEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `isForENT`
    /// - Note: Un doc à stocker sur l'ENT n'est pas pour le prof seulement
    /// - Important: *Does NOT the context to the store after modification is done*
    @objc
    var unsavedIsForENT: Bool {
        get {
            self.isForENT
        }
        set {
            self.isForENT = newValue
            if newValue {
                // Un doc à stocker sur l'ENT n'est pas pour le prof seulement
                self.isForTeacher = false
            }
        }
    }

    /// Retourne le nom du fichier PDF associé pour les archivages / désarchivage JSON
    var uuidFileName: String? {
        guard let uuidString = id?.uuidString else {
            return nil
        }
        return "doc_" + uuidString + ".pdf"
    }
}

// MARK: - Extension Core Data

extension DocumentEntity {
    // MARK: - Type Methods

    @discardableResult
    /// Créer et ajouter un nouveau document PDF à l'établissement.
    /// - Parameters:
    ///   - school: établissement
    ///   - data: contenu du document PDF
    ///   - name: nom du document
    /// - Returns: Document créé.
    /// - Important: *Saves the context to the store after modification is done*
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

        // Les documents attachés à un établissement sont destinés au professeur
        doc.isForEleve = false
        doc.isForENT = false
        doc.isForTeacher = true

        try? SchoolEntity.saveIfContextHasChanged()

        return doc
    }

    @discardableResult
    /// Créer et ajouter un nouveau document PDF à la classe.
    /// - Parameters:
    ///   - classe: classe
    ///   - data: contenu du document PDF
    ///   - name: nom du document
    /// - Returns: Document créé.
    /// - Important: *Saves the context to the store after modification is done*
    static func create(
        dans classe: ClasseEntity,
        withData data: Data?,
        withName name: String
    ) -> DocumentEntity {
        let doc = DocumentEntity.create()
        // établissement d'appartenance.
        // mandatory
        doc.classe = classe

        if let data {
            doc.pdfData = data
        }
        doc.docName = name

        // Les documents attachés à une classe sont destinés au professeur
        doc.isForEleve = false
        doc.isForENT = false
        doc.isForTeacher = true

        try? ClasseEntity.saveIfContextHasChanged()

        return doc
    }

    @discardableResult
    /// Créer et ajouter un nouveau document PDF au programme scolaire.
    /// - Parameters:
    ///   - program: programme scolaire
    ///   - data: contenu du document PDF
    ///   - name: nom du document
    /// - Returns: Document créé.
    /// - Important: *Does NOT save the context to the store after modification is done*
    static func createWithoutSaving(
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

        // Les documents attachés à une progression sont destinés au professeur
        doc.isForEleve = false
        doc.isForENT = false
        doc.isForTeacher = true

        return doc
    }

    @discardableResult
    /// Créer et ajouter un nouveau document PDF à la séquence pédagogique.
    /// - Parameters:
    ///   - sequence: séquence pédagogique
    ///   - data: contenu du document PDF
    ///   - name: nom du document
    /// - Returns: Document créé.
    /// - Important: *Does NOT save the context to the store after modification is done*
    static func createWithoutSaving(
        forSequence sequence: SequenceEntity,
        withData data: Data?,
        withName name: String,
        isForEleve: Bool? = nil,
        isForENT: Bool? = nil,
        isForTeacher: Bool? = nil
    ) -> DocumentEntity {
        let doc = DocumentEntity.create()
        // établissement d'appartenance.
        // mandatory
        doc.sequence = sequence

        if let data {
            doc.pdfData = data
        }
        doc.docName = name

        // Les documents attachés à une séquence sont destinés au professeur
        if let isForEleve {
            doc.isForEleve = isForEleve
        } else {
            doc.isForEleve = false
        }
        if let isForENT {
            doc.isForENT = isForENT
        } else {
            doc.isForENT = false
        }
        if let isForTeacher {
            doc.isForTeacher = isForTeacher
        } else {
            doc.isForTeacher = true
        }

        return doc
    }

    @discardableResult
    /// Créer et ajouter un nouveau document PDF à l'activité pédagogique.
    /// - Parameters:
    ///   - activity: activité pédagogique
    ///   - data: contenu du document PDF
    ///   - name: nom du document
    /// - Returns: Document créé.
    /// - Important: *Does NOT save the context to the store after modification is done*
    static func createWithoutSaving(
        forActivity activity: ActivityEntity,
        withData data: Data?,
        withName name: String,
        isForEleve: Bool? = nil,
        isForENT: Bool? = nil,
        isForTeacher: Bool? = nil
    ) -> DocumentEntity {
        let doc = DocumentEntity.create()
        // établissement d'appartenance.
        // mandatory
        doc.activity = activity

        if let data {
            doc.pdfData = data
        }
        doc.docName = name

        // Les documents attachés à une activité
        // sont par défaut destinés aux élèves
        if let isForEleve {
            doc.isForEleve = isForEleve
        } else {
            doc.isForEleve = true
        }
        if let isForENT {
            doc.isForENT = isForENT
        } else {
            doc.isForENT = false
        }
        if let isForTeacher {
            doc.isForTeacher = isForTeacher
        } else {
            doc.isForTeacher = false
        }

        return doc
    }

    /// Check the correctness and consistency of all database entities of this type.
    /// - Parameters:
    ///   - errorList: Liste des erreurs trouvées.
    static func checkConsistency(
        errorList: inout DataBaseErrorList,
        tryToRepair: Bool
    ) {
        all().forEach { doc in
            if doc.school == nil &&
                doc.classe == nil &&
                doc.program == nil &&
                doc.sequence == nil &&
                doc.activity == nil {
                if tryToRepair {
                    do {
                        // la destruction est sauvegardée
                        try doc.delete()
                    } catch {
                        errorList
                            .append(DataBaseError.noOwner(
                                entity: Self.entity().name!,
                                name: doc.viewName,
                                id: doc.id
                            ))
                    }
                } else {
                    errorList
                        .append(DataBaseError.noOwner(
                            entity: Self.entity().name!,
                            name: doc.viewName,
                            id: doc.id
                        ))
                }
            }
        }
    }

    // MARK: - Methods

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set defaults here
        self.id = UUID()
        self.isForEleve = false
        self.isForENT = false
        self.isForTeacher = true
    }

    /// Cloner le document et l'associer à une séquence pédagogique.
    /// - Parameters:
    ///   - sequence: séquence pédagogique
    /// - Returns: Document créé.
    /// - Important: *Saves the context to the store after modification is done*
    @discardableResult
    func clone(dans sequence: SequenceEntity) -> DocumentEntity {
        let newDoc = DocumentEntity.createWithoutSaving(
            forSequence: sequence,
            withData: self.pdfData,
            withName: self.viewName,
            isForEleve: self.isForEleve,
            isForENT: self.isForENT,
            isForTeacher: self.isForTeacher
        )

        try? Self.saveIfContextHasChanged()
        return newDoc
    }

    /// Cloner le document et l'associer à une activité pédagogique.
    /// - Parameters:
    ///   - activity: activité pédagogique
    /// - Returns: Document créé.
    /// - Important: *Saves the context to the store after modification is done*
    @discardableResult
    func clone(dans activity: ActivityEntity) -> DocumentEntity {
        let newDoc = DocumentEntity.createWithoutSaving(
            forActivity: activity,
            withData: self.pdfData,
            withName: self.viewName
        )

        try? Self.saveIfContextHasChanged()
        return newDoc
    }

    /// Remplace les données PDF éventuellement présentes par de nouvelles
    /// - Parameter newPdfData: les nouvelle données PDF
    func setPdfData(to newPdfData: Data) {
        pdfData = newPdfData
        try? DocumentEntity.saveIfContextHasChanged()
    }

    /// Exporter le document PDF vers le directory Cache.
    /// - Returns: URL du fichier enregistré ou nil si l'opération a échoué.
    func exportDocFile() -> URL? {
        let cachesUrl = URL.cachesDirectory
        guard var fileName = self.docName else {
            return nil
        }
        fileName += ".pdf"
        let fileUrl = cachesUrl.appending(component: fileName)
        do {
            try self.pdfData?.write(to: fileUrl)
            return fileUrl
        } catch {
            return nil
        }
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
               Pour élèves: \(isForEleve)
               Pour prof. : \(isForTeacher)
               Pour ENT   : \(isForENT)

            """
        if let school {
            owner = "   school: \(school.displayString)"
        } else if let classe {
            owner = "   classe: \(classe.displayString)"
        } else if let program {
            owner = "   program: \(program.disciplineString)"
        } else if let sequence {
            owner = "   sequence: \(sequence.viewName)"
        } else if let activity {
            owner = "   activity: \(activity.viewName)"
        }
        return top + owner
    }
}
