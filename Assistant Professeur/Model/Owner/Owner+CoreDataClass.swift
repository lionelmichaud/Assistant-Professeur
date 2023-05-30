//
//  Owner+CoreDataClass.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/05/2023.
//

import CoreData
import Foundation

@objc(OwnerEntity)
public final class OwnerEntity: NSManagedObject, Codable, ModelEntityP {
    enum CodingKeys: CodingKey {
        case id, familyName, givenName, annotation, numen
        case mailAdressAcademy, urlMailAcademy, idMailAcademy, pwdMailAcademy
    }

    public required convenience init(from decoder: Decoder) throws {
        self.init(context: Self.context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.familyName = try container.decode(String.self, forKey: .familyName)
        self.givenName = try container.decode(String.self, forKey: .givenName)
        self.annotation = try container.decodeIfPresent(String.self, forKey: .annotation)
        self.numen = try container.decodeIfPresent(String.self, forKey: .numen)

        // e-mail académique
        self.mailAdressAcademy = try container.decodeIfPresent(String.self, forKey: .mailAdressAcademy)
        self.urlMailAcademy = try container.decodeIfPresent(URL.self, forKey: .urlMailAcademy)
        self.idMailAcademy = try container.decodeIfPresent(String.self, forKey: .idMailAcademy)
        self.pwdMailAcademy = try container.decodeIfPresent(String.self, forKey: .pwdMailAcademy)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(familyName, forKey: .familyName)
        try container.encode(givenName, forKey: .givenName)
        try container.encodeIfPresent(annotation, forKey: .annotation)
        try container.encodeIfPresent(numen, forKey: .numen)

        // e-mail académique
        try container.encodeIfPresent(mailAdressAcademy, forKey: .mailAdressAcademy)
        try container.encodeIfPresent(urlMailAcademy, forKey: .urlMailAcademy)
        try container.encodeIfPresent(idMailAcademy, forKey: .idMailAcademy)
        try container.encodeIfPresent(pwdMailAcademy, forKey: .pwdMailAcademy)
    }
}
