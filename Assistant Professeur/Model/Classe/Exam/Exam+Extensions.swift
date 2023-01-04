//
//  Exam+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/01/2023.
//

import Foundation
import CoreData

/// Un établissement scolaire
extension ExamEntity {

    // MARK: - Computed properties

    /// Wrapper of `sujet`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewSujet: String {
        get {
            self.sujet ?? ""
        }
        set {
            self.sujet = newValue
            try? ExamEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `dateExecuted`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewDateExecuted: Date {
        get {
            self.dateExecuted ?? Date.now
        }
        set {
            self.dateExecuted = newValue
            try? ExamEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `maxMark`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewMaxMark: Int {
        get {
            Int(self.maxMark)
        }
        set {
            self.maxMark = Int16(newValue)
            try? ExamEntity.saveIfContextHasChanged()
        }
    }

}

// MARK: - Extension Core Data

extension ExamEntity: ModelEntityP {

    // MARK: - Type Computed Properties

    // MARK: - Methods

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        //Set defaults here
        self.dateExecuted = Date.now
    }

}

// MARK: - Extension Debug

extension ExamEntity {
    public override var description: String {
        """

        EVALUATION: \(viewSujet)
           ID          : \(id)
           Date        : \(dateExecuted.stringShortDate)
           Noté sur    : \(maxMark)
           Coefficient : \(coef.formatted(.number.precision(.fractionLength(2))))
        """
    // Notes: \(String(describing: marks).withPrefixedSplittedLines("     "))
    }
}

