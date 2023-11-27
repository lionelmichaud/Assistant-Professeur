//
//  EleveViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 23/12/2022.
//

import Foundation

@Observable final class EleveViewModel {

    // MARK: - Properties

    var sexEnum      : Sexe
    var familyName   : String
    var givenName    : String
    var isFlagged    : Bool
    var annotation   : String
    var appreciation : String
    var bonus        : Int

    // MARK: - Initializers

    internal init(
        sexEnum      : Sexe   = .male,
        familyName   : String = "",
        givenName    : String = "",
        isFlagged    : Bool   = false,
        annotation   : String = "",
        appreciation : String = "",
        bonus        : Int    = 0
    ) {
        self.sexEnum      = sexEnum
        self.familyName   = familyName
        self.givenName    = givenName
        self.isFlagged    = isFlagged
        self.annotation   = annotation
        self.appreciation = appreciation
        self.bonus        = bonus
    }

    convenience init(from eleve: EleveEntity) {
        self.init()
        self.update(from: eleve)
    }

    // MARK: - Methods

    func update(from eleve: EleveEntity) {
        self.sexEnum      = eleve.sexEnum
        self.familyName   = eleve.viewFamilyName
        self.givenName    = eleve.viewGivenName
        self.isFlagged    = eleve.isFlagged
        self.annotation   = eleve.viewAnnotation
        self.appreciation = eleve.viewAppreciation
        self.bonus        = Int(eleve.bonus)
    }

    /// Créer une entité `EleveEntity` à partir du VM et
    ///
    /// Ajouter une note pour chaque évaluation de la classe
    /// - Important: Saves the context
    func createAndSaveEntity(_ inClasse: ClasseEntity) {
        EleveEntity.create(
            familyName: familyName,
            givenName: givenName,
            sex: sexEnum,
            isFlagged: isFlagged,
            annotation: annotation,
            appreciation: appreciation,
            bonus: Int16(bonus),
            dans: inClasse
        )
    }
}
