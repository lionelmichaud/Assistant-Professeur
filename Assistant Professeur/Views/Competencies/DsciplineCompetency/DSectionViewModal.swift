//
//  DSectionViewModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 09/06/2023.
//

import Foundation

class DSectionViewModel: ObservableObject {
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
    convenience init(from section: DSectionEntity) {
        self.init()
        self.update(from: section)
    }

    // MARK: - Methods

    /// Initialiser le View Model à partir d'un objet existant
    /// - Parameter section: bjet exis
    func update(from section: DSectionEntity) {
        self.number = section.viewNumber
        self.description = section.viewDescription
    }

    /// Mettre à jour un objet existant à partir d'un View Model
    /// - Parameter section: objet existant
    func update(this section: DSectionEntity) {
        section.viewNumber = self.number
        section.viewDescription = self.description
    }

    /// Créer une entité `DSectionEntity` à partir du VM et
    /// le sauveagrader dans le context.
    /// - Important: Saves the context
    /// - Parameter theme: Chapitre dans lequel crééer la compétence.
    func createAndSaveEntity(
        inTheme theme: DThemeEntity
    ) {
        DSectionEntity.create(
            number: number,
            description: description,
            inTheme: theme
        )
    }
}
