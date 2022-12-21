//
//  School+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/11/2022.
//

import Foundation
import CoreData

/// Un établissement scolaire
extension SchoolEntity {

    // MARK: - Type Methods

    static func < (lhs: SchoolEntity, rhs: SchoolEntity) -> Bool {
        if lhs.levelEnum.rawValue != rhs.levelEnum.rawValue {
            return lhs.levelEnum.rawValue < rhs.levelEnum.rawValue
        } else {
            return (lhs.name ?? "") < (rhs.name ?? "")
        }
    }

    // MARK: - Computed properties

    var levelEnum: LevelSchool {
        get {
            if let level {
                return LevelSchool(rawValue: level) ?? .college
            } else {
                return .college
            }
        }
        set {
            self.level = newValue.rawValue
        }
    }

    @objc
    var viewName: String {
        get {
            self.name ?? ""
        }
        set {
            self.name = newValue
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
    var levelString: String {
        levelEnum.displayString
    }

    @objc
    var displayString: String {
        "\(levelEnum.displayString) \(viewName)"
    }

    @objc
    var classesLabel: String {
        if nbOfClasses == 0 {
            return "Aucune Classe"
        } else if nbOfClasses == 1 {
            return "1 Classe"
        } else {
            return "\(nbOfClasses) Classes"
        }
    }
}

// MARK: - Extension Core Data

extension SchoolEntity: ModelEntityP {

    // MARK: - Type Computed Properties

    static var byLevelNameNSSortDescriptor: [NSSortDescriptor] = [
        NSSortDescriptor(
            keyPath: \SchoolEntity.level,
            ascending: true),
        NSSortDescriptor(
            keyPath: \SchoolEntity.name,
            ascending: true)
    ]

    static var requestAllSortedByLevelName: NSFetchRequest<SchoolEntity> {
        let request = NSFetchRequest<SchoolEntity>(entityName: "SchoolEntity")
        request.sortDescriptors = SchoolEntity.byLevelNameNSSortDescriptor
        return request
    }

    // MARK: - Computed Properties

    /// Nombre de classes dans l'établissement
    var nbOfClasses: Int {
        Int(self.classesCount)
    }

    /// Liste des classes de l'établissement triées par niveau puis par numéro
    var classesSortedByLevelNumber: [ClasseEntity] {
        let sortComparators =
        [
            SortDescriptor(\ClasseEntity.level, order: .reverse),
            SortDescriptor(\ClasseEntity.numero, order: .forward),
            SortDescriptor(\ClasseEntity.segpa, order: .forward)
        ]
        return (self.classes?.allObjects as! [ClasseEntity])
            .sorted(using: sortComparators)
    }

    var heures: Double {
        classesSortedByLevelNumber.sum(for: \.heures)
    }

    // MARK: - Methods

    /// Recherche si la classe existe déjà dans l'établissement
    /// - Parameters:
    ///   - classeLevel: niveau de la classe
    ///   - classeNumero: numéro dela classe
    ///   - classeIsSegpa: classe de SEGPA ou non
    /// - Returns: Vrai si la classe existe déjà dans l'établissement
    func exists(
        classeLevel   : LevelClasse,
        classeNumero  : Int,
        classeIsSegpa : Bool
    ) -> Bool {
        (self.classes?.allObjects as! [ClasseEntity])
            .contains {
                $0.levelEnum == classeLevel &&
                $0.numero == classeNumero &&
                $0.segpa == classeIsSegpa
            }
    }

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        //Set defaults here
        //        self.fileName = ""
//        self.fileDate = Date()
    }

    /// Change le niveau de l'établissement
    func toggleNiveau() {
        levelEnum.toggle()
        try? SchoolEntity.saveIfContextHasChanged()
    }
}

// MARK: - Extension Debug

extension SchoolEntity {
    public override var description: String {
        """

        ETABLISSEMENT: \(displayString)
           ID     : \(id)
           Niveau : \(levelString)
           Nom    : \(viewName)
           Note   : \(viewAnnotation)
           Nombre de classes: \(nbOfClasses)
        """
//           ClassesID: \(String(describing: classesID).withPrefixedSplittedLines("     "))
//           Evénements: \(String(describing: events).withPrefixedSplittedLines("     "))
//           Documents: \(String(describing: documents).withPrefixedSplittedLines("     "))
//           Salles: \(String(describing: rooms).withPrefixedSplittedLines("     "))
//           Ressources: \(String(describing: ressources).withPrefixedSplittedLines("     "))
//        """
    }
}
