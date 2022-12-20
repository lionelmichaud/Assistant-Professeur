//
//  Classe+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/11/2022.
//

import Foundation
import CoreData

extension ClasseEntity {

    // MARK: - Type Methods

    static func < (lhs: ClasseEntity, rhs: ClasseEntity) -> Bool {
        if lhs.levelEnum.rawValue != rhs.levelEnum.rawValue {
            return lhs.levelEnum.rawValue > rhs.levelEnum.rawValue
        } else {
            return lhs.numero < rhs.numero
        }
    }

    // MARK: - Computed properties

    var levelEnum: LevelClasse {
        get {
            if let level {
                return LevelClasse(rawValue: level) ?? .n6ieme
            } else {
                return .n6ieme
            }
        }
        set {
            self.level = newValue.rawValue
        }
    }

    @objc
    var viewAnnotation: String {
        get {
            self.annotation ?? ""
        }
        set {
            self.annotation = newValue
        }
    }

    @objc
    var viewAppreciation: String {
        get {
            self.appreciation ?? ""
        }
        set {
            self.appreciation = newValue
        }
    }

    @objc
    var levelString: String {
        levelEnum.displayString
    }

    var hasAssociatedRoom: Bool {
        false
//        roomId != nil
    }

    var nbOfEleves: Int {
        0
//        elevesID.count
    }

    var nbOfExams: Int {
        0
//        exams.count
    }

    var elevesListLabel: String {
        if nbOfEleves == 0 {
            return "Aucun élève"
        } else if nbOfEleves == 1 {
            return "Liste de 1 élève"
        } else {
            return "Liste des \(nbOfEleves) élèves"
        }
    }

    var examsListLabel: String {
        if nbOfExams == 0 {
            return "Aucune Évaluation"
        } else if nbOfExams == 1 {
            return "1 Évaluation"
        } else {
            return "\(nbOfExams) Évaluations"
        }
    }

    var displayString: String {
        "\(levelEnum.displayString)\(numero)\(segpa ? "S" : "")"
    }

}

// MARK: - Extension Core Data

extension ClasseEntity: ModelEntityP {

    // MARK: - Type Computed Properties

    static var byLevelNumberNSSortDescriptor: [NSSortDescriptor] = [
        NSSortDescriptor(
            keyPath: \ClasseEntity.level,
            ascending: true),
        NSSortDescriptor(
            keyPath: \ClasseEntity.numero,
            ascending: true)
    ]

    static var requestAllSortedByLevelNumber: NSFetchRequest<ClasseEntity> {
        let request = NSFetchRequest<ClasseEntity>(entityName: "ClasseEntity")
        request.sortDescriptors = ClasseEntity.byLevelNumberNSSortDescriptor
        return request
    }

    // MARK: - Type Computed Methods

    static func requestAllSortedByLevelNumber(inSchool: SchoolEntity) -> NSFetchRequest<ClasseEntity> {
        let request = NSFetchRequest<ClasseEntity>(entityName: "ClasseEntity")
        request.sortDescriptors = ClasseEntity.byLevelNumberNSSortDescriptor
        request.predicate = NSPredicate(format: "school = %@", inSchool.objectID)
        return request
    }

    /// Recherche si la classe existe déjà dans l'établissement
    /// - Parameters:
    ///   - classeLevel: niveau de la classe
    ///   - classeNumero: numéro dela classe
    ///   - inSchool: établissement
    /// - Returns: Vrai si la classe existe déjà dans l'établissement
    static func exists(
        classeLevel  : LevelClasse,
        classeNumero : Int,
        inSchool     : NSManagedObjectID
    ) -> Bool {
        false
    }
}

// MARK: - Extension Debug

extension ClasseEntity {
    public override var description: String {
        """

        CLASSE: \(displayString)
           ID      : \(id)
           Niveau  : \(levelString)
           Numéro  : \(numero)
           SEGPA   : \(segpa.frenchString)
           Heures  : \(heures)
           Flagged : \(isFlagged.frenchString)
           Appréciation: \(viewAppreciation)
           Annotation  : \(viewAnnotation)
        """
//           SchoolID: \(String(describing: schoolId))
//           RoomID  : \(String(describing: roomId))
//           Eleves  : \(String(describing: elevesID).withPrefixedSplittedLines("     "))
//           Examens : \(String(describing: exams).withPrefixedSplittedLines("     "))
//        """
    }
}
