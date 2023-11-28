//
//  SchoolViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/11/2022.
//

import CoreData
import Foundation

@Observable
final class SchoolViewModel {
    // MARK: - Properties

    var name: String
    var niveau: LevelSchool
    var annotation: String

    // MARK: - Initializers

    init(
        name: String = "",
        niveau: LevelSchool = .college,
        annotation: String = ""
    ) {
        self.name = name
        self.niveau = niveau
        self.annotation = annotation
    }

    convenience init(from school: SchoolEntity) {
        self.init()
        self.update(from: school)
    }

    // MARK: - Methods

    func update(from school: SchoolEntity) {
        self.name = school.viewName
        self.niveau = school.levelEnum
        self.annotation = school.viewAnnotation
    }

    func save() {
        let school = SchoolEntity.create()
        school.name = name
        school.annotation = annotation
        school.setLevel(niveau)

        try? SchoolEntity.saveIfContextHasChanged()
    }
}

extension SchoolViewModel: Equatable {
    static func == (
        lhs: SchoolViewModel,
        rhs: SchoolViewModel
    ) -> Bool {
        lhs.name == rhs.name &&
            lhs.niveau == rhs.niveau &&
            lhs.annotation == rhs.annotation
    }
}
