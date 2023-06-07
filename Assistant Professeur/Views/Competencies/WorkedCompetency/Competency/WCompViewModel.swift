//
//  WorkedCompViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 06/06/2023.
//

import Foundation

class WCompViewModel: ObservableObject {
    // MARK: - Properties

    @Published
    var number: Int

    @Published
    var description: String = ""

    // MARK: - Initializers

    internal init(
        number: Int = 1,
        description: String = ""
    ) {
        self.number = number
        self.description = description
    }

    convenience init(from workedComp: WCompEntity) {
        self.init()
        self.update(from: workedComp)
    }

    // MARK: - Methods

    func update(from workedComp: WCompEntity) {
        self.number = workedComp.viewNumber
        self.description = workedComp.viewDescription
    }

    func update(this workedComp: WCompEntity) {
        workedComp.viewNumber = self.number
        workedComp.viewDescription = self.description
    }

    /// Créer une entité `ProgramEntity` à partir du VM et
    ///
    /// Crée un Groupe 0 pour les élèves de la classe n'appartenant à aucun groupe
    /// - Important: Saves the context
    func createAndSaveEntity(
        inChapter chapter: WCompChapterEntity
    ) {
        WCompEntity.create(
            number: number,
            description: description,
            inChapter: chapter
        )
    }
}
