//
//  SchoolViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/11/2022.
//

import Foundation
import CoreData

struct SchoolViewModel: Identifiable {

    private var school: SchoolEntity

    init(school: SchoolEntity) {
        self.school = school
    }

    var id: NSManagedObjectID {
        school.objectID
    }

    var nom: String {
        get {
            school.name ?? ""
        }
        set {
            school.name = newValue
        }
    }

    var niveau: NiveauSchool {
        get {
            school.niveau
        }
        set {
            school.niveau = newValue
        }
    }

    var annotation: String {
        get {
            school.annotation ?? ""
        }
        set {
            school.annotation = newValue
        }
    }

    var displayString: String {
        "\(niveau.displayString) \(nom)"
    }
}

class SchoolObservableModel: ObservableObject {
    var nom        : String       = ""
    var niveau     : NiveauSchool = .college
    var annotation : String       = ""

    func save() {
        let school = SchoolEntity(context: SchoolEntity.viewContext)
        school.name       = nom
        school.niveau     = niveau
        school.annotation = annotation

        try? SchoolEntity.save()
    }
}
