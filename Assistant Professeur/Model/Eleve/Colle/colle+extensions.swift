//
//  colle+extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 26/12/2022.
//

import Foundation
import CoreData

extension ColleEntity {

    // MARK: - Computed properties

    /// Wrapper of `motif`
    /// - Important: *Saves the context to the store after modification is done*
    var motifEnum: MotifEnum {
        get {
            MotifEnum(rawValue: motif) ?? .bavardage
        }
        set {
            self.motif = newValue.rawValue
            try? ObservEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `descriptionMotif`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewDescriptionMotif: String {
        get {
            self.descriptionMotif ?? ""
        }
        set {
            self.descriptionMotif = newValue
            try? ObservEntity.saveIfContextHasChanged()
        }
    }

    // MARK: - Methods

    /// Modifie l'attribut `motif`
    func setMotif(_ newMotif: MotifEnum) {
        self.motif = newMotif.rawValue
    }

}


// MARK: - Extension Core Data

extension ColleEntity: ModelEntityP {

    // MARK: - Type Computed Properties

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        //Set defaults here
        //        self.fileName = ""
        self.date = Date.now
    }
}

// MARK: - Extension Debug

extension ColleEntity {
    public override var description: String {
        """

        COLLE:
           ID            : \(id)
           EleveID       : \(String(describing: eleve?.id))
           Date          : \(date.stringShortDate)
           Motif         : \(motifEnum.displayString)
           Motif descrip : '\(viewDescriptionMotif)'
           DURÉE         : \(duree)
           Consignée     : \(isConsignee.frenchString)
           Vérifiée      : \(isVerified.frenchString)
        """
    }
}
