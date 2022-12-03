//
//  SchoolViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/11/2022.
//

import Foundation
import CoreData

class SchoolViewModel: ObservableObject {

    // MARK: - Properties

    @Published var name       : String       = ""
    @Published var niveau     : NiveauSchool = .college
    @Published var annotation : String       = ""

    // MARK: - Initializers

    init(
        name       : String       = "",
        niveau     : NiveauSchool = .college,
        annotation : String       = "")
    {
        self.name       = name
        self.niveau     = niveau
        self.annotation = annotation
    }

    init(from school: SchoolEntity) {
        self.name       = school.viewName
        self.niveau     = school.niveau
        self.annotation = school.viewAnnotation
    }

    // MARK: - Methods

    func update(from school: SchoolEntity) {
        self.name       = school.viewName
        self.niveau     = school.niveau
        self.annotation = school.viewAnnotation
    }

    func save() {
        let school = SchoolEntity(context: SchoolEntity.viewContext)
        school.viewName       = name
        school.niveau         = niveau
        school.viewAnnotation = annotation

        try? SchoolEntity.saveIfContextHasChanged()
    }
}

extension SchoolViewModel: Equatable {
    static func == (lhs: SchoolViewModel,
                    rhs: SchoolViewModel) -> Bool {
        lhs.name == rhs.name &&
        lhs.niveau == rhs.niveau &&
        lhs.annotation == rhs.annotation
    }
}
