//
//  DataBaseManager.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 15/01/2023.
//

import Foundation

struct DataBaseManager {

    static func check(errorFound: inout Bool) {
        RoomEntity.checkConsistency(errorFound: &errorFound)
        SeatEntity.checkConsistency(errorFound: &errorFound)
        DocumentEntity.checkConsistency(errorFound: &errorFound)
        EventEntity.checkConsistency(errorFound: &errorFound)
        RessourceEntity.checkConsistency(errorFound: &errorFound)
        ClasseEntity.checkConsistency(errorFound: &errorFound)
        GroupEntity.checkConsistency(errorFound: &errorFound)
        ExamEntity.checkConsistency(errorFound: &errorFound)
        MarkEntity.checkConsistency(errorFound: &errorFound)
        EleveEntity.checkConsistency(errorFound: &errorFound)
        ColleEntity.checkConsistency(errorFound: &errorFound)
        ObservEntity.checkConsistency(errorFound: &errorFound)

        ProgramEntity.checkConsistency(errorFound: &errorFound)
        SequenceEntity.checkConsistency(errorFound: &errorFound)
        ActivityEntity.checkConsistency(errorFound: &errorFound)
    }

    /// Effacer tout le contenu de la base de donnée Core Data
    /// - Parameter failed: true si l'opération à échouée
    static func clear(failed: inout Bool) {
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
        } catch {
            failed = true
        }
    }

    /// Peupler la base de donnée
    static func populate() {
        /// Etablissement
        let college = SchoolEntity.create(
            name       : "Caousou",
            level      : .college,
            annotation : "Ceci est une annotation"
        )

        let lycee = SchoolEntity.create(
            name       : "Caousou",
            level      : .lycee,
            annotation : "Ceci est une annotation 2"
        )

        /// Evenements
        EventEntity.create(
            dans     : college,
            withName : "Un événement important"
        )

        /// Ressources
        RessourceEntity.create(
            dans     : college,
            withName : "Une ressource de l'établissement",
            quantity : 2
        )

        /// Documents
        DocumentEntity.create(
            dans     : college,
            withData : nil,
            withName : "Un document important"
        )

        /// Salles de classe
        let room = RoomEntity.create(
            withName     : "TECHNO-2",
            withCapacity : 16,
            dans         : college
        )

        /// Classes
        let classe5E1 = ClasseEntity.create(
            level        : .n5ieme,
            numero       : 1,
            segpa        : false,
            discipline   : .technologie,
            heures       : 1.5,
            isFlagged    : true,
            annotation   : "Ceci est une annotation de classe",
            appreciation : "Ceci est une appreciation de classe",
            dans         : college
        )
        classe5E1.room = room

        let classe3E2 = ClasseEntity.create(
            level        : .n3ieme,
            numero       : 2,
            segpa        : false,
            discipline   : .mathematiques,
            heures       : 4.0,
            isFlagged    : false,
            annotation   : "Ceci est une annotation de classe 2",
            appreciation : "Ceci est une appreciation de classe 2",
            dans       : college
        )

        let classe2E5 = ClasseEntity.create(
            level        : .n2nd,
            numero       : 5,
            segpa        : true,
            discipline   : .snt,
            heures       : 1.5,
            isFlagged    : false,
            annotation   : "Ceci est une annotation de classe 3",
            appreciation : "Ceci est une appreciation de classe 3",
            dans         : lycee
        )

        /// Eleves
        let eleve5E1_1 = EleveEntity.create(
            familyName   : "MICHAUD",
            givenName    : "Lionel",
            sex          : .male,
            isFlagged    : true,
            trouble      : .begaiement,
            hasAddTime   : true,
            annotation   : "Ceci est une annotation d'élève",
            appreciation : "Ceci est une appreciation d'élève",
            bonus        : 2,
            dans         : classe5E1
        )

        let eleve5E1_2 = EleveEntity.create(
            familyName   : "DUPONT",
            givenName    : "Mathilde",
            sex          : .female,
            isFlagged    : false,
            trouble      : .none,
            hasAddTime   : true,
            annotation   : "Ceci est une annotation d'élève 2",
            appreciation : "Ceci est une appreciation d'élève 2",
            bonus        : -2,
            dans         : classe5E1
        )

        let eleve5E1_3 = EleveEntity.create(
            familyName   : "GOBIN",
            givenName    : "Bertrans",
            sex          : .male,
            isFlagged    : false,
            trouble      : .none,
            hasAddTime   : false,
            annotation   : "Ceci est une annotation d'élève 3",
            appreciation : "Ceci est une appreciation d'élève 3",
            bonus        : -2,
            dans         : classe5E1
        )

        let eleve3E2_3 = EleveEntity.create(
            familyName   : "BIDULE",
            givenName    : "Françine",
            sex          : .female,
            isFlagged    : false,
            trouble      : .none,
            hasAddTime   : false,
            bonus        : 0,
            dans         : classe3E2
        )

        let eleve2E5_3 = EleveEntity.create(
            familyName   : "LEGENDRE",
            givenName    : "Frédérick",
            sex          : .male,
            isFlagged    : false,
            trouble      : .none,
            hasAddTime   : false,
            bonus        : 0,
            dans         : classe2E5
        )

        /// Examen
        ExamManager.createExam(
            sujet   : "Le sujet de l'évaluation",
            coef    : 0.5,
            maxMark : 10,
            pour    : classe5E1
        )

        /// Groupes
        GroupManager.formOrderedGroups(
            nbEleveParGroupe : 2,
            dans             : classe5E1
        )

        /// Observations
        ObservEntity.create(
            pour             : eleve5E1_1,
            motifEnum        : .autre,
            descriptionMotif : "Comportement innacceptable",
            isConsignee      : true,
            isVerified       : false
        )
        ObservEntity.create(
            pour             : eleve5E1_2,
            motifEnum        : .bavardage,
            descriptionMotif : "Trop de bavardages",
            isConsignee      : false,
            isVerified       : true
        )
        ObservEntity.create(
            pour             : eleve5E1_3,
            motifEnum        : .attitudeIndaptee,
            descriptionMotif : "Description de l'attitude de l'élève",
            isConsignee      : true,
            isVerified       : true
        )

        /// Colles
        ColleEntity.create(
            pour: eleve5E1_1,
            motifEnum        : .autre,
            descriptionMotif : "Comportement innacceptable",
            isConsignee      : false,
            isVerified       : false,
            duree: 2
        )
        ColleEntity.create(
            pour: eleve5E1_1,
            motifEnum        : .bavardage,
            descriptionMotif : "Trop de bavardages",
            isConsignee      : true,
            isVerified       : false,
            duree: 1
        )
        ColleEntity.create(
            pour: eleve5E1_1,
            motifEnum        : .attitudeIndaptee,
            descriptionMotif : "Description de l'attitude de l'élève",
            isConsignee      : true,
            isVerified       : true,
            duree: 2
        )

        /// Programmes
        let progTechno6 = ProgramEntity.create(
            discipline : .technologie,
            level      : .n6ieme,
            segpa      : false,
            annotation : "Programme de technologie de classe de 6ième",
            url        : URL(string: "http://www.apple.com")
        )
        ProgramEntity.create(
            discipline : .technologie,
            level      : .n5ieme,
            segpa      : true,
            annotation : "Programme de technologie de classe de 5ième SEGPA"
        )
        ProgramEntity.create(
            discipline : .histoireGeo   ,
            level      : .n0terminale,
            segpa      : false,
            annotation : "Programme d'Histoire-Géographie de classe de Terminale"
        )

        /// Séquences
        let progTechno6Seq1 = SequenceEntity.create(
            name       : "Séquence 1 du Programme de Technologie",
            annotation : "Une annotation de séquence 1",
            dans       : progTechno6
        )
        SequenceEntity.create(
            name       : "Séquence 2 du Programme de Technologie",
            annotation : "Une annotation de séquence 2",
            dans       : progTechno6
        )
        SequenceEntity.create(
            name       : "Séquence 3 du Programme de Technologie",
            annotation : "Une annotation de séquence 3",
            dans       : progTechno6
        )
        SequenceEntity.create(
            name       : "Séquence 4 du Programme de Technologie",
            annotation : "Une annotation de séquence 4",
            dans       : progTechno6
        )

        /// Activités
        ActivityEntity.create(
            name       : "Activité 1 de Séquence 1 de Techno",
            annotation : "Une annotation d'activité 1",
            duration   : 1.0,
            isEval     : false,
            dans       : progTechno6Seq1
        )
        ActivityEntity.create(
            name       : "Activité 2 de Séquence 1 de Techno",
            annotation : "Une annotation d'activité 1",
            duration   : 2.0,
            isEval     : false,
            dans       : progTechno6Seq1
        )
        ActivityEntity.create(
            name       : "Activité 3 de Séquence 1 de Techno",
            annotation : "Une annotation d'activité 1",
            duration   : 1.0,
            isEval     : true,
            dans       : progTechno6Seq1
        )
    }
}
