//
//  ColleViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 30/12/2022.
//

import Foundation

class ColleViewModel: ObservViewModel {

    // MARK: - Properties

    @Published var duree: Int = 0

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

    override func save(pourEleve: EleveEntity) {
        let colle = ColleEntity.create()
        colle.eleve = pourEleve // lien vers l'élève

        colle.setMotif(motifEnum)
        colle.date             = date
        colle.descriptionMotif = descriptionMotif
        colle.isConsignee      = isConsignee
        colle.isVerified       = isVerified
        colle.duree            = Int16(duree)

        try? ColleEntity.saveIfContextHasChanged()
    }
}
