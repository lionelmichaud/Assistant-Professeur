//
//  ObservViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 28/12/2022.
//

import Foundation

@Observable class ObservViewModel {

    // MARK: - Properties

    var date             : Date
    var motifEnum        : MotifEnum
    var descriptionMotif : String
    var isConsignee      : Bool
    var isVerified       : Bool

    // MARK: - Initializers

    internal init(
        date             : Date      = Date.now,
        motifEnum        : MotifEnum = .bavardage,
        descriptionMotif : String    = "",
        isConsignee      : Bool      = false,
        isVerified       : Bool      = false
    ) {
        self.date             = date
        self.motifEnum        = motifEnum
        self.descriptionMotif = descriptionMotif
        self.isConsignee      = isConsignee
        self.isVerified       = isVerified
    }

    convenience init(from observ: ObservEntity) {
        self.init()
        self.update(from: observ)
    }

    // MARK: - Methods

    func update(from observ: ObservEntity) {
        self.date             = observ.viewDate
        self.motifEnum        = observ.motifEnum
        self.descriptionMotif = observ.viewDescriptionMotif
        self.isConsignee      = observ.isConsignee
        self.isVerified       = observ.isVerified
    }

    func createAndSaveEntity(pourEleve: EleveEntity) {
        ObservEntity.create(
            pour             : pourEleve,
            date             : date,
            motifEnum        : motifEnum,
            descriptionMotif : descriptionMotif,
            isConsignee      : isConsignee,
            isVerified       : isVerified
        )
    }
}
