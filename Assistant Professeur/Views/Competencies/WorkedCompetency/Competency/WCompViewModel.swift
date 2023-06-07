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

    /// Créer un View Model par défaut ou pas
    internal init(
        number: Int = 1,
        description: String = ""
    ) {
        self.number = number
        self.description = description
    }

    /// Créer un View Model à partir d'un objet existant
    /// - Parameter workedComp: objet existant
    convenience init(from workedComp: WCompEntity) {
        self.init()
        self.update(from: workedComp)
    }

    // MARK: - Methods

    /// Initialiser le View Model à partir d'un objet existant
    /// - Parameter workedComp: bjet exis
    func update(from workedComp: WCompEntity) {
        self.number = workedComp.viewNumber
        self.description = workedComp.viewDescription
    }

    /// Mettre à jour un objet existant à partir d'un View Model
    /// - Parameter workedComp: objet existant
    func update(this workedComp: WCompEntity) {
        workedComp.viewNumber = self.number
        workedComp.viewDescription = self.description
    }

    /// Créer une entité `WCompChapterEntity` à partir du VM et
    /// le sauveagrader dans le context.
    /// - Important: Saves the context
    /// - Parameter chapter: Chapitre dans lequel crééer la compétence.
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
