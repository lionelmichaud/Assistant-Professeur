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
        if lhs.niveau.rawValue != rhs.niveau.rawValue {
            return lhs.niveau.rawValue < rhs.niveau.rawValue
        } else {
            return (lhs.name ?? "") < (rhs.name ?? "")
        }
    }

    // MARK: - Computed properties

    var niveau: NiveauSchool {
        get {
            if let level {
                return NiveauSchool(rawValue: level) ?? .college
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
    var niveauString: String {
        niveau.displayString
    }

    @objc
    var displayString: String {
        "\(niveau.displayString) \(viewName)"
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

    // MARK: - Type Computed properties

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

    func toggleNiveau() {
        niveau.toggle()
        try? SchoolEntity.saveIfContextHasChanged()
    }
}
