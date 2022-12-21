//
//  Event+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/11/2022.
//

import Foundation
import CoreData

extension EventEntity {
    @objc
    var viewName: String {
        get {
            self.name ?? ""
        }
        set {
            self.name = newValue
        }
    }

    @objc
    var viewDate: Date {
        get {
            self.date ?? Date.now
        }
        set {
            self.date = newValue
        }
    }
}

// MARK: - Extension Core Data

extension EventEntity: ModelEntityP {

    // MARK: - Methods

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        //Set defaults here
        self.date = Date.now
    }

}

// MARK: - Extension Debug

extension EventEntity {
    public override var description: String {
        """

        EVENEMENT: \(viewName)
           Date   : \(date.stringShortDate)
        """
    }
}
