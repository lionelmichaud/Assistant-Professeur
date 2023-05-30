//
//  School+CoreDataClass.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 06/02/2023.
//

import CoreData
import Foundation

@objc(SchoolEntity)
public final class SchoolEntity: NSManagedObject, Codable, ModelEntityP {
    enum CodingKeys: CodingKey {
        case id, name, level, annotation
        case idENT, pwdENT, idNetwork, pwdNetwork
        case codeEntree, codePhotocopie
        case classes, documents, ressources, events, rooms
        case mailAddressSchool, urlMailSchool, idMailSchool, pwdMailSchool
    }

    /// Conformance to Decodable
    public required convenience init(from decoder: Decoder) throws {
        self.init(context: Self.context)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.level = try container.decode(String.self, forKey: .level)
        self.annotation = try container.decodeIfPresent(String.self, forKey: .annotation)

        // Accès à l'ENT
        self.idENT = try container.decodeIfPresent(String.self, forKey: .idENT)
        self.pwdENT = try container.decodeIfPresent(String.self, forKey: .pwdENT)

        // Accès au réseau de l'établissement
        self.idNetwork = try container.decodeIfPresent(String.self, forKey: .idNetwork)
        self.pwdNetwork = try container.decodeIfPresent(String.self, forKey: .pwdNetwork)

        // Codes d'accès
        self.codeEntree = try container.decodeIfPresent(String.self, forKey: .codeEntree)
        self.codePhotocopie = try container.decodeIfPresent(String.self, forKey: .codePhotocopie)

        // e-mail au sein de l'établissement
        self.mailAddressSchool = try container.decodeIfPresent(String.self, forKey: .mailAddressSchool)
        self.urlMailSchool = try container.decodeIfPresent(URL.self, forKey: .urlMailSchool)
        self.idMailSchool = try container.decodeIfPresent(String.self, forKey: .idMailSchool)
        self.pwdMailSchool = try container.decodeIfPresent(String.self, forKey: .pwdMailSchool)

        // Les rooms doivent être chargés AVANT les classes pour que les classes puissent
        // établir la connection avec les rooms. Voir RoomEntity.init(from decoder: Decoder)
        self.rooms = try container.decode(Set<RoomEntity>.self, forKey: .rooms) as NSSet
        self.classes = try container.decode(Set<ClasseEntity>.self, forKey: .classes) as NSSet
        self.documents = try container.decode(Set<DocumentEntity>.self, forKey: .documents) as NSSet
        self.ressources = try container.decode(Set<RessourceEntity>.self, forKey: .ressources) as NSSet
        self.events = try container.decode(Set<EventEntity>.self, forKey: .events) as NSSet
    }

    /// Conformance to Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(level, forKey: .level)
        try container.encodeIfPresent(annotation, forKey: .annotation)

        // Accès à l'ENT
        try container.encodeIfPresent(idENT, forKey: .idENT)
        try container.encodeIfPresent(pwdENT, forKey: .pwdENT)

        // Accès au réseau de l'établissement
        try container.encodeIfPresent(idNetwork, forKey: .idNetwork)
        try container.encodeIfPresent(pwdNetwork, forKey: .pwdNetwork)

        // Codes d'accès
        try container.encodeIfPresent(codeEntree, forKey: .codeEntree)
        try container.encodeIfPresent(codePhotocopie, forKey: .codePhotocopie)

        // e-mail au sein de l'établissement
        try container.encodeIfPresent(mailAddressSchool, forKey: .mailAddressSchool)
        try container.encodeIfPresent(urlMailSchool, forKey: .urlMailSchool)
        try container.encodeIfPresent(idMailSchool, forKey: .idMailSchool)
        try container.encodeIfPresent(pwdMailSchool, forKey: .pwdMailSchool)

        try container.encode(classes as! Set<ClasseEntity>, forKey: .classes)
        try container.encode(documents as! Set<DocumentEntity>, forKey: .documents)
        try container.encode(ressources as! Set<RessourceEntity>, forKey: .ressources)
        try container.encode(events as! Set<EventEntity>, forKey: .events)
        try container.encode(rooms as! Set<RoomEntity>, forKey: .rooms)
    }
}
