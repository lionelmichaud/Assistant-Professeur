//
//  WorkedCompViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 05/06/2023.
//

import Foundation

class WCompChapterViewModel: ObservableObject {
    // MARK: - Properties

    @Published
    var cycle: Cycle

    @Published
    var acronym: String

    @Published
    var description: String = ""

    // MARK: - Initializers

    /// Créer un View Model par défaut ou pas
    internal init(
        cycle: Cycle = .cycle4,
        acronym: String = "",
        description: String = ""
    ) {
        self.cycle = cycle
        self.acronym = acronym
        self.description = description
    }

    /// Créer un View Model à partir d'un objet existant
    /// - Parameter workedCompChapter: objet existant
    convenience init(from workedCompChapter: WCompChapterEntity) {
        self.init()
        self.update(from: workedCompChapter)
    }

    // MARK: - Methods

    /// Initialiser le View Model à partir d'un objet existant
    /// - Parameter workedCompChapter: objet existant
    func update(from workedCompChapter: WCompChapterEntity) {
        self.cycle = workedCompChapter.viewCycleEnum
        self.acronym = workedCompChapter.viewAcronym
        self.description = workedCompChapter.viewDescription
    }

    /// Mettre à jour un objet existant à partir d'un View Model
    /// - Parameter workedCompChapter: objet existant
    func update(this workedCompChapter: WCompChapterEntity) {
        workedCompChapter.viewCycleEnum = self.cycle
        workedCompChapter.viewAcronym = self.acronym
        workedCompChapter.viewDescription = self.description
    }

    /// Créer une entité `WCompChapterEntity` à partir du VM et
    /// le sauveagrader dans le context.
    /// - Important: Saves the context
    func createAndSaveEntity() {
        WCompChapterEntity.create(
            cycle: cycle,
            acronym: acronym,
            description: description
        )
    }
}
