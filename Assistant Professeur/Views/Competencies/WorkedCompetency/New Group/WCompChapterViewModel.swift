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

    internal init(
        cycle: Cycle = .cycle4,
        acronym: String = "",
        description: String = ""
    ) {
        self.cycle = cycle
        self.acronym = acronym
        self.description = description
    }

    convenience init(from workedCompChapter: WCompChapterEntity) {
        self.init()
        self.update(from: workedCompChapter)
    }

    // MARK: - Methods

    func update(from workedCompChapter: WCompChapterEntity) {
        self.cycle = workedCompChapter.viewCycleEnum
        self.acronym = workedCompChapter.viewAcronym
        self.description = workedCompChapter.viewDescription
    }

    func update(this workedCompChapter: WCompChapterEntity) {
        workedCompChapter.viewCycleEnum = self.cycle
        workedCompChapter.viewAcronym = self.acronym
        workedCompChapter.viewDescription = self.description
    }

    /// Créer une entité `ProgramEntity` à partir du VM et
    ///
    /// Crée un Groupe 0 pour les élèves de la classe n'appartenant à aucun groupe
    /// - Important: Saves the context
    func createAndSaveEntity() {
        WCompChapterEntity.create(
            cycle: cycle,
            acronym: acronym,
            description: description
        )
    }
}
