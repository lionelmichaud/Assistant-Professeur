//
//  School+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/11/2022.
//

import Foundation
import CoreData

/// Un établissement scolaire
extension SchoolEntity {

    // MARK: - Computed properties

    /// Wrapper of `level`
    /// - Important: *Saves the context to the store after modification is done*
    var levelEnum: LevelSchool {
        get {
            if let level {
                return LevelSchool(rawValue: level) ?? .college
            } else {
                return .college
            }
        }
        set {
            self.level = newValue.rawValue
            try? SchoolEntity.saveIfContextHasChanged()
        }
    }

    /// Modifie l'attribut `level`
    func setLevel(_ newLevel: LevelSchool) {
        self.level = newLevel.rawValue
    }

    /// Toggle le niveau de l'établissement: Collège <=> Lycée
    /// - Important: *Saves the context to the store after modification is done*
    func toggleLevel() {
        levelEnum.toggle()
        try? SchoolEntity.saveIfContextHasChanged()
    }

    /// Wrapper of `name`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewName: String {
        get {
            self.name ?? ""
        }
        set {
            self.name = newValue
            try? SchoolEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `annotation`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewAnnotation: String {
        get {
            self.annotation ?? ""
        }
        set {
            self.annotation = newValue
            try? SchoolEntity.saveIfContextHasChanged()
        }
    }

    @objc
    var levelString: String {
        levelEnum.displayString
    }

    @objc
    var displayString: String {
        "\(levelEnum.displayString) \(viewName)"
    }

    @objc
    var classesLabel: String {
        if nbOfClasses == 0 {
            return "Aucune Classe"
        } else if nbOfClasses == 1 {
            return "1 Classe"
        } else {
            return "\(nbOfClasses) Classes"
        }
    }
}

// MARK: - Extension Core Data

extension SchoolEntity: ModelEntityP {

    // MARK: - Type Computed Properties

    static var byLevelNameNSSortDescriptor: [NSSortDescriptor] = [
        NSSortDescriptor(
            keyPath: \SchoolEntity.level,
            ascending: true),
        NSSortDescriptor(
            keyPath: \SchoolEntity.name,
            ascending: true)
    ]

    /// Requête pour tous les établissements triées.
    ///
    /// Ordre de tri:
    ///   1. Type d'école
    ///   2. Nom de l'école
    static var requestAllSortedByLevelName: NSFetchRequest<SchoolEntity> {
        let request = SchoolEntity.fetchRequest()
        request.sortDescriptors = SchoolEntity.byLevelNameNSSortDescriptor
        return request
    }

    // MARK: - Type Methods

    /// Créer une nouvelle instance et la sauvegarder dans le context
    @discardableResult
    static func create(
        name       : String,
        level      : LevelSchool,
        annotation : String = ""
    ) -> SchoolEntity {
        let school = SchoolEntity.create()
        school.name       = name
        school.level      = level.rawValue
        school.annotation = annotation

        try? SchoolEntity.saveIfContextHasChanged()
        return school
    }

    // MARK: - Computed Properties

    /// Nombre de classes dans l'établissement
    var nbOfClasses: Int {
        Int(self.classesCount)
    }

    /// Nombre d'événements dans l'établissement
    var nbOfEvents: Int {
        Int(self.eventsCount)
    }

    /// Nombre de documents importants dans l'établissement
    var nbOfDocuments: Int {
        Int(self.documentsCount)
    }

    /// Nombre de salles de classes utilisées dans l'établissement
    var nbOfRooms: Int {
        Int(self.roomsCount)
    }

    /// Nombre de types de ressources différentes utilisées dans l'établissement
    var nbOfRessourceTypes: Int {
        Int(self.ressourcesCount)
    }

    var heures: Double {
        allClasses.sum(for: \.heures)
    }

    /// Liste des classes de l'établissement non triées
    var allClasses: [ClasseEntity] {
        if let classes {
            return (classes.allObjects as! [ClasseEntity])
        } else {
            return [ ]
        }
    }

    /// Liste des événements de l'établissement non triées
    var allEvents: [EventEntity] {
        if let events {
            return (events.allObjects as! [EventEntity])
        } else {
            return [ ]
        }
    }

    /// Liste des ressources de l'établissement non triées
    var allRessources: [RessourceEntity] {
        if let ressources {
            return (ressources.allObjects as! [RessourceEntity])
        } else {
            return [ ]
        }
    }

    /// Liste des salles de classe de l'établissement non triées
    var allRooms: [RoomEntity] {
        if let rooms {
            return (rooms.allObjects as! [RoomEntity])
        } else {
            return [ ]
        }
    }

    /// Liste des documents importants de l'établissement non triées
    var allDocuments: [DocumentEntity] {
        if let documents {
            return (documents.allObjects as! [DocumentEntity])
        } else {
            return [ ]
        }
    }

    /// Liste des classes de l'établissement triées par niveau puis par numéro
    var classesSortedByLevelNumber: [ClasseEntity] {
        let sortComparators =
        [
            SortDescriptor(\ClasseEntity.level, order: .reverse),
            SortDescriptor(\ClasseEntity.numero, order: .forward),
            SortDescriptor(\ClasseEntity.segpa, order: .forward)
        ]
        return allClasses.sorted(using: sortComparators)
    }

    /// Liste des ressources de l'établissement non triées par ordre alphabétique
    var ressourcesSortedByName: [RessourceEntity] {
        let sortComparators =
        [
            SortDescriptor(\RessourceEntity.name, order: .forward),
        ]
        return allRessources.sorted(using: sortComparators)
    }

    /// Liste des événements importants de l'établissement triées par date
    var eventsSortedByDate: [EventEntity] {
        let sortComparators =
        [
            SortDescriptor(\EventEntity.date, order: .reverse),
        ]
        return allEvents.sorted(using: sortComparators)
    }

    /// Liste des salles de classe de l'établissement triées par ordre alphabétique
    var roomsSortedByName: [RoomEntity] {
        let sortComparators =
        [
            SortDescriptor(\RoomEntity.name, order: .forward),
        ]
        return allRooms.sorted(using: sortComparators)
    }

    /// Liste des documents importants de l'établissement triées par ordre alphabétique
    var documentsSortedByName: [DocumentEntity] {
        let sortComparators =
        [
            SortDescriptor(\DocumentEntity.docName, order: .forward),
        ]
        return allDocuments.sorted(using: sortComparators)
    }

    // MARK: - Methods

    /// Recherche si la classe existe déjà dans l'établissement
    /// - Parameters:
    ///   - classeLevel: niveau de la classe
    ///   - classeNumero: numéro dela classe
    ///   - classeIsSegpa: classe de SEGPA ou non
    /// - Returns: Vrai si la classe existe déjà dans l'établissement
    func exists(
        classeLevel   : LevelClasse,
        classeNumero  : Int,
        classeIsSegpa : Bool
    ) -> Bool {
        (self.classes?.allObjects as! [ClasseEntity])
            .contains {
                $0.levelEnum == classeLevel &&
                $0.numero == classeNumero &&
                $0.segpa == classeIsSegpa
            }
    }

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        //Set defaults here
        //        self.fileName = ""
//        self.fileDate = Date()
    }
}

// MARK: - Extension Debug

extension SchoolEntity {
    public override var description: String {
        """

        ETABLISSEMENT: \(displayString)
           ID         : \(id)
           Niveau     : \(levelString)
           Nom        : \(viewName)
           Note       : \(viewAnnotation)
           Nb salles     : \(nbOfRooms)
           Nb classes    : \(nbOfClasses)
           Nb documents  : \(nbOfDocuments)
           Nb événments  : \(nbOfEvents)
           Nb ressources : \(nbOfRessourceTypes)
        """
//           ClassesID: \(String(describing: classesID).withPrefixedSplittedLines("     "))
//           Evénements: \(String(describing: events).withPrefixedSplittedLines("     "))
//           Documents: \(String(describing: documents).withPrefixedSplittedLines("     "))
//           Salles: \(String(describing: rooms).withPrefixedSplittedLines("     "))
//           Ressources: \(String(describing: ressources).withPrefixedSplittedLines("     "))
//        """
    }
}
