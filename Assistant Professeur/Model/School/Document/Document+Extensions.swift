//
//  Document+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/11/2022.
//

import Foundation
import CoreData

extension DocumentEntity {

    // MARK: - Computed properties

    /// Wrapper of `docName`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewName: String {
        get {
            self.docName ?? ""
        }
        set {
            self.docName = newValue
            try? DocumentEntity.saveIfContextHasChanged()
        }
    }

}

// MARK: - Extension Core Data

extension DocumentEntity: ModelEntityP {

    // MARK: - Computed properties

}
