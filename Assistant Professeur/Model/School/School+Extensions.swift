//
//  School+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/11/2022.
//

import Foundation
import CoreData

extension SchoolEntity: BaseModel {

    var niveau: NiveauSchool {
        get {
            NiveauSchool(rawValue: level!) ?? .college
        }
        set {
            level = newValue.rawValue
        }
    }
}
