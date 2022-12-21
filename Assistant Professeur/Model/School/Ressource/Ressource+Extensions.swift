//
//  Ressource+extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/12/2022.
//

import Foundation
import CoreData

extension RessourceEntity {
    @objc
    var viewName: String {
        get {
            self.name ?? ""
        }
        set {
            self.name = newValue
        }
    }
}

// MARK: - Extension Core Data

extension RessourceEntity: ModelEntityP {

    // MARK: - Methods

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        //Set defaults here
        // self.date = Date.now
    }

}

// MARK: - Extension Debug

extension RessourceEntity {
    public override var description: String {
        """

        RESSOURCE: \(viewName)
           Quantité   : \(quantity)
        """
    }
}
