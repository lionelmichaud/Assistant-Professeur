//
//  ObservViewModel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 28/12/2022.
//

import Foundation

class ObservViewModel: ObservableObject {

    // MARK: - Properties

    @Published var date             : Date      = Date.now
    @Published var motifEnum        : MotifEnum = .bavardage
    @Published var descriptionMotif : String    = ""
    @Published var isConsignee      : Bool      = false
    @Published var isVerified       : Bool      = false

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

    func save(pourEleve: EleveEntity) {
        let observ = ObservEntity.create()
        
        // élève d'appartenance.
        // mandatory
        observ.eleve = pourEleve // lien vers l'élève

        observ.setMotif(motifEnum)
        observ.date             = date
        observ.descriptionMotif = descriptionMotif
        observ.isConsignee      = isConsignee
        observ.isVerified       = isVerified

        try? ObservEntity.saveIfContextHasChanged()
    }
}
