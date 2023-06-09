//
//  DThemeViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 09/06/2023.
//

import Foundation

class DThemeViewModel: ObservableObject {
    // MARK: - Properties

    @Published
    var cycle: Cycle

    @Published
    var discipline: Discipline

    @Published
    var acronym: String

    @Published
    var description: String = ""

    // MARK: - Initializers

    /// Créer un View Model par défaut ou pas
    internal init(
        cycle: Cycle = .cycle4,
        discipline: Discipline = .autre,
        acronym: String = "",
        description: String = ""
    ) {
        self.cycle = cycle
        self.discipline = discipline
        self.acronym = acronym
        self.description = description
    }

    /// Créer un View Model à partir d'un objet existant
    /// - Parameter disciplineTheme: objet existant
    convenience init(from disciplineTheme: DThemeEntity) {
        self.init()
        self.update(from: disciplineTheme)
    }

    // MARK: - Methods

    /// Initialiser le View Model à partir d'un objet existant
    /// - Parameter disciplineTheme: objet existant
    func update(from disciplineTheme: DThemeEntity) {
        self.cycle = disciplineTheme.viewCycleEnum
        self.discipline = disciplineTheme.disciplineEnum
        self.acronym = disciplineTheme.viewAcronym
        self.description = disciplineTheme.viewDescription
    }

    /// Mettre à jour un objet existant à partir d'un View Model
    /// - Parameter disciplineTheme: objet existant
    func update(this disciplineTheme: DThemeEntity) {
        disciplineTheme.viewCycleEnum = self.cycle
        disciplineTheme.viewDisciplineEnum = self.discipline
        disciplineTheme.viewAcronym = self.acronym
        disciplineTheme.viewDescription = self.description
    }

    /// Créer une entité `DThemeEntity` à partir du VM et
    /// le sauveagrader dans le context.
    /// - Important: Saves the context
    func createAndSaveEntity() {
        DThemeEntity.create(
            cycle: cycle,
            discipline: discipline,
            acronym: acronym,
            description: description
        )
    }
}
