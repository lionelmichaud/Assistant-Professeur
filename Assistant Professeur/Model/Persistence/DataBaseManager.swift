//
//  DataBaseManager.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 15/01/2023.
//

import Foundation

/// Erreur dans la base de donnée
enum DataBaseError: LocalizedError {
    case some(entity: String, name: String, id: UUID?)
    case noOwner(entity: String, name: String, id: UUID?)
    case outOfBound(entity: String, name: String, attribute: String, id: UUID?)
    case internalInconsistency(entity: String, name: String, attribute1: String, attribute2: String, id: UUID?)

    public var errorDescription: String? {
        switch self {
            case let .some(entity, name, _):
                return "L'objet de type \(entity) '\(name)' présente une erreur."

            case let .noOwner(entity, name, _):
                return "L'objet de type \(entity) '\(name)' est orphelin."

            case let .outOfBound( entity, name, attribute, _):
                return "L'objet de type \(entity) '\(name)' possède un attribut '\(attribute)' hors limites."

            case let .internalInconsistency( entity, name, attribute1, attribute2, _):
                return "L'objet de type \(entity) '\(name)' possède une valeur d'attribut '\(attribute1)' incompatible de la valeur de l'attribut '\(attribute2)'."
        }
    }

    public var failureReason: String? {
        switch self {
            default: return ""
        }
    }

    public var recoverySuggestion: String? {
        switch self {
            case .some:
                return ""

            case let .noOwner(entity, name, _):
                return "Supprimer l'objet de type \(entity) '\(name)'."

            case let .outOfBound(entity, name, attribute, _):
                return "Modifier la valeur de l'attribut'\(attribute)' hors limites pour \(entity) '\(name)'."

            case let .internalInconsistency(entity, name, attribute1, attribute2, _):
                return "Modifier une des valeurs des attributs '\(attribute1)' ou '\(attribute2)' pour \(entity) '\(name)'."
        }
    }
}

extension DataBaseError: CustomStringConvertible {
    var description: String {
        localizedDescription
    }
}

typealias DataBaseErrorList = [DataBaseError]

/// Gestion de la base de donnée Core Data
enum DataBaseManager { // swiftlint:disable:this type_body_length
    /// Vérifier l'état de la base de données Core Data.
    /// Les erreur éventuelles sont remontée sous forme de liste.
    /// - Parameter errorList: Les des errerus éventuelles
    static func check(
        errorList: inout DataBaseErrorList,
        tryToRepair: Bool
    ) {
        OwnerEntity.checkConsistency(
            errorList: &errorList, tryToRepair: tryToRepair
        )

        RoomEntity.checkConsistency(
            errorList: &errorList, tryToRepair: tryToRepair
        )
        SeatEntity.checkConsistency(
            errorList: &errorList, tryToRepair: tryToRepair
        )
        DocumentEntity.checkConsistency(
            errorList: &errorList, tryToRepair: tryToRepair
        )
        EventEntity.checkConsistency(
            errorList: &errorList, tryToRepair: tryToRepair
        )
        RessourceEntity.checkConsistency(
            errorList: &errorList, tryToRepair: tryToRepair
        )
        ClasseEntity.checkConsistency(
            errorList: &errorList, tryToRepair: tryToRepair
        )
        GroupEntity.checkConsistency(
            errorList: &errorList, tryToRepair: tryToRepair
        )
        ExamEntity.checkConsistency(
            errorList: &errorList, tryToRepair: tryToRepair
        )
        MarkEntity.checkConsistency(
            errorList: &errorList
        )
        EleveEntity.checkConsistency(
            errorList: &errorList, tryToRepair: tryToRepair
        )
        ColleEntity.checkConsistency(
            errorList: &errorList, tryToRepair: tryToRepair
        )
        ObservEntity.checkConsistency(
            errorList: &errorList, tryToRepair: tryToRepair
        )

        ProgramEntity.checkConsistency(
            errorList: &errorList
        )
        SequenceEntity.checkConsistency(
            errorList: &errorList, tryToRepair: tryToRepair
        )
        ActivityEntity.checkConsistency(
            errorList: &errorList, tryToRepair: tryToRepair
        )
        ActivityProgressEntity.checkConsistency(
            errorList: &errorList
        )

        #if DEBUG
            if errorList.isNotEmpty {
                print("Liste des \(errorList.count) erreurs trouvées:")
                errorList.forEach { error in
                    print(String(describing: error).withPrefix("   "))
                }
            }
        #endif
    }

    /// Retourne `true` si la BDD Core Data est vide.
    /// - Returns: `true` si la BDD Core Data est vide
    static func isEmpty() -> Bool {
        OwnerEntity.cardinal() == 0 &&

            SchoolEntity.cardinal() == 0 &&
            DocumentEntity.cardinal() == 0 &&
            EventEntity.cardinal() == 0 &&
            RessourceEntity.cardinal() == 0 &&
            RoomEntity.cardinal() == 0 &&
            SeatEntity.cardinal() == 0 &&
            ClasseEntity.cardinal() == 0 &&
            GroupEntity.cardinal() == 0 &&
            ExamEntity.cardinal() == 0 &&
            MarkEntity.cardinal() == 0 &&
            EleveEntity.cardinal() == 0 &&
            ObservEntity.cardinal() == 0 &&
            ColleEntity.cardinal() == 0 &&

            ProgramEntity.cardinal() == 0 &&
            SequenceEntity.cardinal() == 0 &&
            ActivityEntity.cardinal() == 0 &&
            ActivityProgressEntity.cardinal() == 0
    }

    /// Efface tout le contenu de la base de donnée Core Data
    /// - Parameter failed: true si l'opération à échouée
    static func clear(failed: inout Bool) {
        // Suppression des données personnelle de l'utilisateur de l'application
        do {
            try OwnerEntity.deleteAll()
        } catch {
            failed = true
        }

        // Suppression des Etablissements
        do {
            try SchoolEntity.deleteAll()
            try DocumentEntity.deleteAll()
            try EventEntity.deleteAll()
            try RessourceEntity.deleteAll()
            try RoomEntity.deleteAll()
            try SeatEntity.deleteAll()
        } catch {
            failed = true
        }

        // Suppression des Classes
        do {
            try ClasseEntity.deleteAll()
            try GroupEntity.deleteAll()
        } catch {
            failed = true
        }

        // Suppression des Evaluations
        do {
            try ExamEntity.deleteAll()
            try MarkEntity.deleteAll()
        } catch {
            failed = true
        }

        // Suppression des Eleves
        do {
            try EleveEntity.deleteAll()
            try ObservEntity.deleteAll()
            try ColleEntity.deleteAll()
        } catch {
            failed = true
        }

        // Suppression des Programmes
        do {
            try ProgramEntity.deleteAll()
            try SequenceEntity.deleteAll()
            try ActivityEntity.deleteAll()
            try ActivityProgressEntity.deleteAll()
        } catch {
            failed = true
        }

        // Vérifier que le contenu de la base est vide
        failed = failed || !isEmpty()
    }

    /// Peupler la base de donnée avec des données 'fake'.
    /// - Parameter failed: true si l'opération à échouée
    static func populateWithMockData(storeType: StoreType) {
        CoreDataManager.storeType = storeType

        // Owner
        OwnerEntity.create(
            familyName: "MICHAUD",
            givenName: "Lionel",
            numen: "16 E2 23 18 02 HNL",
            mailAdressAcademy: "Lionel.Michaud@ac-toulouse.fr",
            urlMailAcademy: URL(string: "https://messagerie.ac-toulouse.fr"),
            idMailAcademy: "lmichaud1",
            pwdMailAcademy: "motdepasse"
        )

        // Etablissement
        let college = SchoolEntity.create(
            name: "Un collège",
            level: .college,
            annotation: "Ceci est une annotation"
        )

        let lycee = SchoolEntity.create(
            name: "Un Lycée",
            level: .lycee,
            annotation: "Ceci est une annotation 2"
        )

        // Evenements
        EventEntity.create(
            dans: college,
            withName: "Un événement important"
        )

        // Ressources
        RessourceEntity.create(
            dans: college,
            withName: "Une ressource de l'établissement",
            quantity: 2
        )

        // Documents
        DocumentEntity.create(
            dans: college,
            withData: nil,
            withName: "Un document important"
        )

        // Salles de classe
        let roomForClasse5E1 = RoomEntity.create(
            withName: "TECHNO-2",
            withCapacity: 16,
            dans: college
        )

        // Chaises de la salle de classe
        let classe5E1TopLeftSeat = roomForClasse5E1
            .addSeatToPlan(x: 0.25, y: 0.25)
        let classe5E1BotRightSeat = roomForClasse5E1
            .addSeatToPlan(x: 0.75, y: 0.75)

        // Classes
        let classe5E1 = ClasseEntity.create(
            level: .n5ieme,
            numero: 1,
            segpa: true,
            discipline: .technologie,
            heures: 1.5,
            isFlagged: true,
            annotation: "Ceci est une annotation de classe",
            appreciation: "Ceci est une appreciation de classe",
            dans: college
        )
        classe5E1.setRoom(roomForClasse5E1)

        let classe3E2 = ClasseEntity.create(
            level: .n3ieme,
            numero: 2,
            segpa: true,
            discipline: .mathematiques,
            heures: 4.0,
            isFlagged: false,
            annotation: "Ceci est une annotation de classe 2",
            appreciation: "Ceci est une appreciation de classe 2",
            dans: college
        )

        let classeTerm = ClasseEntity.create(
            level: .n0terminale,
            numero: 5,
            segpa: false,
            discipline: .snt,
            heures: 1.5,
            isFlagged: false,
            annotation: "Ceci est une annotation de classe 3",
            appreciation: "Ceci est une appreciation de classe 3",
            dans: lycee
        )

        // Eleves
        let eleve5E1_1 = EleveEntity.create(
            familyName: "SAINT-Truc de MICHAUD",
            givenName: "Lionel",
            sex: .male,
            isFlagged: true,
            trouble: .begaiement,
            hasAddTime: true,
            annotation: "Ceci est une annotation d'élève",
            appreciation: "Ceci est une appreciation d'élève",
            bonus: 2,
            dans: classe5E1
        )
        eleve5E1_1.setSeat(classe5E1TopLeftSeat!)

        let eleve5E1_2 = EleveEntity.create(
            familyName: "DUPONT",
            givenName: "Mathilde",
            sex: .female,
            isFlagged: false,
            trouble: .none,
            hasAddTime: true,
            annotation: "Ceci est une annotation d'élève 2",
            appreciation: "Ceci est une appreciation d'élève 2",
            bonus: -2,
            dans: classe5E1
        )
        eleve5E1_2.setSeat(classe5E1BotRightSeat!)

        let eleve5E1_3 = EleveEntity.create(
            familyName: "GOBIN",
            givenName: "Bertrans",
            sex: .male,
            isFlagged: false,
            trouble: .none,
            hasAddTime: false,
            annotation: "Ceci est une annotation d'élève 3",
            appreciation: "Ceci est une appreciation d'élève 3",
            bonus: -2,
            dans: classe5E1
        )

        let eleve3E2_3 = EleveEntity.create(
            familyName: "BIDULE",
            givenName: "Françine",
            sex: .female,
            isFlagged: false,
            trouble: .none,
            hasAddTime: false,
            bonus: 0,
            dans: classe3E2
        )

        let eleveTerm = EleveEntity.create(
            familyName: "LEGENDRE",
            givenName: "Frédérick",
            sex: .male,
            isFlagged: false,
            trouble: .none,
            hasAddTime: false,
            bonus: 0,
            dans: classeTerm
        )

        // Examen
        let globalExam = ExamEntity.createGlobalExam(
            sujet: "Le sujet de l'évaluation Globale",
            coef: 0.5,
            maxMark: 10,
            pour: classe5E1
        )

        // Examen
        let setppedExam = ExamEntity.createSteppedExam(
            sujet: "Le sujet de l'évaluation Échelonnée",
            coef: 0.5,
            examSteps: [
                ExamStep(name: "1.1", points: 1),
                ExamStep(name: "1.2", points: 2),
                ExamStep(name: "2.1", points: 3)
            ],
            pour: classe5E1
        )

        // Notes
        globalExam.setGlobalMark(
            of: eleve5E1_1,
            markType: .absent
        )
        globalExam.setGlobalMark(
            of: eleve5E1_2,
            markType: .note,
            mark: 6.5
        )

        setppedExam.setSteppedMark(
            of: eleve5E1_2,
            markType: .nonRendu
        )
        setppedExam.setSteppedMark(
            of: eleve5E1_3,
            markType: .note,
            marks: [0.5, 1.5, 2.5]
        )

        // Groupes
        GroupManager.formOrderedGroups(
            nbEleveParGroupe: 2,
            dans: classe5E1
        )

        // Observations
        ObservEntity.create(
            pour: eleve5E1_1,
            motifEnum: .autre,
            descriptionMotif: "Comportement innacceptable",
            isConsignee: true,
            isVerified: false
        )
        ObservEntity.create(
            pour: eleve5E1_2,
            motifEnum: .bavardage,
            descriptionMotif: "Trop de bavardages",
            isConsignee: false,
            isVerified: true
        )
        ObservEntity.create(
            pour: eleve5E1_3,
            motifEnum: .attitudeIndaptee,
            descriptionMotif: "Description de l'attitude de l'élève",
            isConsignee: true,
            isVerified: true
        )

        // Colles
        ColleEntity.create(
            pour: eleve5E1_1,
            motifEnum: .autre,
            descriptionMotif: "Comportement innacceptable",
            isConsignee: false,
            isVerified: false,
            duree: 2
        )
        ColleEntity.create(
            pour: eleve5E1_1,
            motifEnum: .bavardage,
            descriptionMotif: "Trop de bavardages",
            isConsignee: true,
            isVerified: false,
            duree: 1
        )
        ColleEntity.create(
            pour: eleve5E1_1,
            motifEnum: .attitudeIndaptee,
            descriptionMotif: "Description de l'attitude de l'élève",
            isConsignee: true,
            isVerified: true,
            duree: 2
        )

        // Programmes
        let progTechno5 = ProgramEntity.create(
            discipline: .technologie,
            level: .n5ieme,
            segpa: true,
            annotation: "Programme de technologie de classe de 5ième SEGPA"
        )
        ProgramEntity.create(
            discipline: .technologie,
            level: .n6ieme,
            segpa: false,
            annotation: "Programme de technologie de classe de 6ième",
            url: URL(string: "http://www.apple.com")
        )
        let progSntTerm = ProgramEntity.create(
            discipline: .snt,
            level: .n0terminale,
            segpa: false,
            annotation: "Programme de SNT de classe de Terminale"
        )

        // Séquences
        let progTechno5Seq1 = SequenceEntity.create(
            name: "Séquence 1 du Programme de Technologie de 5ième",
            annotation: "Une annotation de séquence 1",
            url: URL(string: "http://www.google.com"),
            dans: progTechno5
        )
        let progTechno5Seq2 = SequenceEntity.create(
            name: "Séquence 2 du Programme de Technologie de 5ième",
            annotation: "Une annotation de séquence 2",
            dans: progTechno5
        )
        SequenceEntity.create(
            name: "Séquence 3 du Programme de Technologie de 5ième",
            annotation: "Une annotation de séquence 3",
            dans: progTechno5
        )
        SequenceEntity.create(
            name: "Séquence 4 du Programme de Technologie de 5ième",
            annotation: "Une annotation de séquence 4",
            dans: progTechno5
        )
        let progSntTermSeq1 = SequenceEntity.create(
            name: "Séquence 1 du Programme de SNT",
            annotation: "Une annotation de séquence 1 du Programme de SNT",
            url: URL(string: "http://www.google.com"),
            dans: progSntTerm
        )
        let progSntTermSeq2 = SequenceEntity.create(
            name: "Séquence 2 du Programme de SNT",
            annotation: "Une annotation de séquence 2 du Programme de SNT",
            dans: progSntTerm
        )

        // Activités
        ActivityEntity.create(
            name: "Activité 1 de Séquence 1 de Techno",
            annotation: "Une annotation d'activité 1",
            url: URL(string: "http://apple.fr"),
            duration: 1.0,
            isEvalSommative: false,
            isEvalFormative: false,
            isTP: false,
            isProject: false,
            dans: progTechno5Seq1
        )
        ActivityEntity.create(
            name: "Activité 2 de Séquence 1 de Techno",
            annotation: "Une annotation d'activité 2",
            duration: 2.0,
            isEvalSommative: false,
            isEvalFormative: true,
            isTP: false,
            isProject: true,
            dans: progTechno5Seq1
        )
        ActivityEntity.create(
            name: "Activité 3 de Séquence 1 de Techno",
            annotation: "Une annotation d'activité 3",
            duration: 3.0,
            isEvalSommative: false,
            isEvalFormative: true,
            isTP: true,
            isProject: true,
            dans: progTechno5Seq1
        )
        ActivityEntity.create(
            name: "Activité 4 de Séquence 1 de Techno",
            annotation: "Une annotation d'activité 4",
            duration: 4.0,
            isEvalSommative: true,
            isEvalFormative: false,
            isTP: false,
            isProject: false,
            dans: progTechno5Seq1
        )
        ActivityEntity.create(
            name: "Activité 5 de Séquence 1 de Techno",
            annotation: "Une annotation d'activité 4",
            duration: 5.0,
            isEvalSommative: true,
            isEvalFormative: false,
            isTP: false,
            isProject: true,
            dans: progTechno5Seq1
        )
        ActivityEntity.create(
            name: "Activité 6 de Séquence 1 de Techno",
            annotation: "Une annotation d'activité 4",
            duration: 6.0,
            isEvalSommative: true,
            isEvalFormative: false,
            isTP: false,
            isProject: false,
            dans: progTechno5Seq1
        )
        ActivityEntity.create(
            name: "Activité 1 de Séquence 2 de Techno",
            annotation: "Une annotation d'activité 1",
            duration: 3.0,
            isEvalSommative: true,
            isEvalFormative: false,
            isTP: false,
            isProject: true,
            dans: progTechno5Seq2
        )
        ActivityEntity.create(
            name: "Activité 1 de Séquence 2 de SNT Activité 1 de Séquence 1 de Techno Activité 1 de Séquence 1 de Techno",
            annotation: "Une annotation d'activité 1",
            url: URL(string: "http://apple.fr"),
            duration: 1.0,
            isEvalSommative: false,
            isEvalFormative: false,
            isTP: true,
            isProject: true,
            dans: progSntTermSeq2
        )
        ActivityEntity.create(
            name: "Activité 2 de Séquence 2 de SNT",
            annotation: "Une annotation d'activité 2",
            duration: 2.0,
            isEvalSommative: false,
            isEvalFormative: true,
            isTP: false,
            isProject: true,
            dans: progSntTermSeq2
        )

        let allProgresses5E1 = classe5E1.allProgresses
        let progress5E1 = allProgresses5E1.first!
        progress5E1.viewProgress = 0.75
    }
}
