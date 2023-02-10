//
//  Event+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/11/2022.
//

import CoreData
import Foundation

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

extension EventEntity {
    // MARK: - Type Methods

    @discardableResult
    static func create(
        dans school: SchoolEntity,
        date: Date = Date.now,
        withName name: String
    ) -> EventEntity {
        let event = EventEntity.create()
        // établissement d'appartenance.
        // mandatory
        event.school = school

        event.name = name
        event.date = date

        try? SchoolEntity.saveIfContextHasChanged()

        return event
    }

    static func checkConsistency(errorFound: inout Bool) {
        all().forEach { event in
            guard event.school != nil else {
                errorFound = true
                return
            }
        }
    }

    // MARK: - Methods

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set defaults here
        self.date = Date.now
        self.id = UUID()
    }
}

// MARK: - Extension Debug

public extension EventEntity {
    override var description: String {
        """

        EVENEMENT: \(viewName)
           Date   : \(date.stringShortDate)
        """
    }
}
