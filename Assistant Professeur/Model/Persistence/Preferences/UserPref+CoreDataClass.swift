//
//  UserPref+CoreDataClass.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 13/07/2023.
//

import CoreData
import Foundation

@objc(UserPrefEntity)
public final class UserPrefEntity: NSManagedObject, Codable, ModelEntityP {
    // MARK: - Codable conformance

    enum CodingKeys: CodingKey {
        case interoperability, nameDisplayOrder, nameSortOrder
        case schoolAnnotationEnabled
        case classeAppreciationEnabled, classeAnnotationEnabled
        case notificationsEnabled, eleve
        case programAnnotationEnabled
        case sequenceAnnotationEnabled, margeInterSequence
        case activityAnnotationEnabled
        case horaire
        case schoolYear
    }

    public required convenience init(from decoder: Decoder) throws {
        self.init(context: Self.context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.interoperability = try container.decode(Int16.self, forKey: .interoperability)
        self.nameDisplayOrder = try container.decode(Int16.self, forKey: .nameDisplayOrder)
        self.nameSortOrder = try container.decode(Int16.self, forKey: .nameSortOrder)
        self.notificationsEnabled = try container.decode(Bool.self, forKey: .notificationsEnabled)

        self.schoolAnnotationEnabled = try container.decode(Bool.self, forKey: .schoolAnnotationEnabled)

        self.classeAppreciationEnabled = try container.decode(Bool.self, forKey: .classeAppreciationEnabled)
        self.classeAnnotationEnabled = try container.decode(Bool.self, forKey: .classeAnnotationEnabled)

        self.eleve = try container.decode(String.self, forKey: .eleve)

        self.programAnnotationEnabled = try container.decode(Bool.self, forKey: .programAnnotationEnabled)
        self.sequenceAnnotationEnabled = try container.decode(Bool.self, forKey: .sequenceAnnotationEnabled)
        self.margeInterSequence = Int16(try container.decode(Int.self, forKey: .margeInterSequence))
        self.activityAnnotationEnabled = try container.decode(Bool.self, forKey: .activityAnnotationEnabled)

        self.horaire = try container.decode(String.self, forKey: .horaire)

        self.schoolYear = try container.decode(String.self, forKey: .schoolYear)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.interoperability, forKey: .interoperability)
        try container.encode(self.nameDisplayOrder, forKey: .nameDisplayOrder)
        try container.encode(self.nameSortOrder, forKey: .nameSortOrder)
        try container.encode(self.notificationsEnabled, forKey: .notificationsEnabled)

        try container.encode(self.schoolAnnotationEnabled, forKey: .schoolAnnotationEnabled)

        try container.encode(self.classeAppreciationEnabled, forKey: .classeAppreciationEnabled)
        try container.encode(self.classeAnnotationEnabled, forKey: .classeAnnotationEnabled)

        try container.encode(self.eleve, forKey: .eleve)

        try container.encode(self.programAnnotationEnabled, forKey: .programAnnotationEnabled)
        try container.encode(self.sequenceAnnotationEnabled, forKey: .sequenceAnnotationEnabled)
        try container.encode(self.margeInterSequence, forKey: .margeInterSequence)
        try container.encode(self.activityAnnotationEnabled, forKey: .activityAnnotationEnabled)

        try container.encode(self.horaire, forKey: .horaire)

        try container.encode(self.schoolYear, forKey: .schoolYear)
    }

}
