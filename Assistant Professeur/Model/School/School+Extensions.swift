//
//  School+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/11/2022.
//

import Foundation
import CoreData

extension SchoolEntity: ModelEntityP {

    // MARK: - Type Prooperties

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
            NiveauSchool(rawValue: level!) ?? .college
        }
        set {
            level = newValue.rawValue
        }
    }
}
