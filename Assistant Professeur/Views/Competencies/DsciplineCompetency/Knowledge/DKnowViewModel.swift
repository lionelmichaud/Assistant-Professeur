//
//  DKnowViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 12/06/2023.
//

import Foundation

class DKnowViewModel: ObservableObject {
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
    /// - Parameter knowledge: objet existant
    convenience init(from knowledge: DKnowledgeEntity) {
        self.init()
        self.update(from: knowledge)
    }

    // MARK: - Methods

    /// Initialiser le View Model à partir d'un objet existant
    /// - Parameter knowledge: objet exis
    func update(from knowledge: DKnowledgeEntity) {
        self.number = knowledge.viewNumber
        self.description = knowledge.viewDescription
    }

    /// Mettre à jour un objet existant à partir d'un View Model
    /// - Parameter knowledge: objet existant
    func update(this knowledge: DKnowledgeEntity) {
        knowledge.viewNumber = self.number
        knowledge.viewDescription = self.description
    }

    /// Créer une entité `DKnowledgeEntity` à partir du VM et
    /// le sauveagrader dans le context.
    /// - Important: Saves the context
    /// - Parameter competency: Compétence à laquelle ajouter la connaissance.
    func createAndSaveEntity(
        inCompetency: DCompEntity
    ) {
        DKnowledgeEntity.create(
            number: number,
            description: description,
            inCompetency: inCompetency
        )
    }
}
