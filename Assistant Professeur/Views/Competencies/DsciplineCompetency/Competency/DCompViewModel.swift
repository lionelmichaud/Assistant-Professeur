//
//  DCompViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 09/06/2023.
//

import Foundation

class DCompViewModel: ObservableObject {
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
    /// - Parameter section: objet existant
    convenience init(from section: DCompEntity) {
        self.init()
        self.update(from: section)
    }

    // MARK: - Methods

    /// Initialiser le View Model à partir d'un objet existant
    /// - Parameter competency: bjet exis
    func update(from competency: DCompEntity) {
        self.number = competency.viewNumber
        self.description = competency.viewDescription
    }

    /// Mettre à jour un objet existant à partir d'un View Model
    /// - Parameter competency: objet existant
    func update(this competency: DCompEntity) {
        competency.viewNumber = self.number
        competency.viewDescription = self.description
    }

    /// Créer une entité `DCompEntity` à partir du VM et
    /// le sauveagrader dans le context.
    /// - Important: Saves the context
    /// - Parameter section: Section dans lequel crééer la compétence.
    func createAndSaveEntity(
        inSection section: DSectionEntity
    ) {
        DCompEntity.create(
            number: number,
            description: description,
            inSection: section
        )
    }
}
