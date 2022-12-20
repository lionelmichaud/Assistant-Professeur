//
//  School+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/11/2022.
//

import Foundation
import CoreData

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

    // MARK: - Properties

    var nbOfClasses: Int {
        Int(self.classesCount)
    }

    // MARK: - Methods

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
