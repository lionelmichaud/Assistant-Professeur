//
//  ColleViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 30/12/2022.
//

import Foundation

@Observable final class ColleViewModel: ObservViewModel {

    // MARK: - Properties

    var duree: Int = 0

    // MARK: - Initializers

    internal init(
        date             : Date      = Date.now,
        motifEnum        : MotifEnum = .bavardage,
        descriptionMotif : String    = "",
        isConsignee      : Bool      = false,
        isVerified       : Bool      = false,
        duree            : Int       = 1
    ) {
        super.init(
            date             : date,
            motifEnum        : motifEnum,
            descriptionMotif : descriptionMotif,
            isConsignee      : isConsignee,
            isVerified       : isVerified
        )
        self.duree = duree
    }

    convenience init(from colle: ColleEntity) {
        self.init()
        self.update(from: colle)
    }

    // MARK: - Methods

    func update(from colle: ColleEntity) {
        self.date             = colle.viewDate
        self.motifEnum        = colle.motifEnum
        self.descriptionMotif = colle.viewDescriptionMotif
        self.isConsignee      = colle.isConsignee
        self.isVerified       = colle.isVerified
        self.duree            = colle.viewDuree
    }

    override func createAndSaveEntity(pourEleve: EleveEntity) {
        ColleEntity.create(
            pour             : pourEleve,
            date             : date,
            motifEnum        : motifEnum,
            descriptionMotif : descriptionMotif,
            isConsignee      : isConsignee,
            isVerified       : isVerified,
            duree            : duree
        )
    }
}
