//
//  School+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/11/2022.
//

import CoreData
import Foundation
import HelpersView

/// Un établissement scolaire
extension SchoolEntity {
    // MARK: - Computed properties

    /// Nom de l'image par défaut utilisée pour représenter un établissement
    static let defaultImageName: String = LevelSchool.college.imageName

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

    /// Wrapper of `idENT`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewIdENT: String {
        get {
            self.idENT ?? ""
        }
        set {
            self.idENT = newValue.trimmed
            try? OwnerEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `idNetwork`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewIdNetwork: String {
        get {
            self.idNetwork ?? ""
        }
        set {
            self.idNetwork = newValue.trimmed
            try? OwnerEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `pwdENT`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewPwdENT: String {
        get {
            self.pwdENT ?? ""
        }
        set {
            self.pwdENT = newValue.trimmed
            try? OwnerEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `pwdNetwork`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewPwdNetwork: String {
        get {
            self.pwdNetwork ?? ""
        }
        set {
            self.pwdNetwork = newValue.trimmed
            try? OwnerEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `codeEntree`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewCodeEntree: String {
        get {
            self.codeEntree ?? ""
        }
        set {
            self.codeEntree = newValue.trimmed
            try? OwnerEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `codePhotocopie`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewCodePhotocopie: String {
        get {
            self.codePhotocopie ?? ""
        }
        set {
            self.codePhotocopie = newValue.trimmed
            try? OwnerEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `mailAddressSchool`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewMailAddressSchool: String {
        get {
            self.mailAddressSchool ?? ""
        }
        set {
            self.mailAddressSchool = newValue.trimmed
            try? OwnerEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `idMailSchool`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewIdMailSchool: String {
        get {
            self.idMailSchool ?? ""
        }
        set {
            self.idMailSchool = newValue.trimmed
            try? OwnerEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `pwdMailSchool`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewPwdMailSchool: String {
        get {
            self.pwdMailSchool ?? ""
        }
        set {
            self.pwdMailSchool = newValue.trimmed
            try? OwnerEntity.saveIfContextHasChanged()
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

extension SchoolEntity {
    // MARK: - Type Computed Properties

    static var byLevelNameNSSortDescriptor: [NSSortDescriptor] = [
        NSSortDescriptor(
            keyPath: \SchoolEntity.level,
            ascending: true
        ),
        NSSortDescriptor(
            keyPath: \SchoolEntity.name,
            ascending: true
        )
    ]

    /// Requête pour tous les établissements triées.
    ///
    /// Ordre de tri:
    ///   1. Niveau d'école
    ///   2. Nom de l'école
    static var requestAllSortedByLevelName: NSFetchRequest<SchoolEntity> {
        let request = SchoolEntity.fetchRequest()
        request.sortDescriptors = SchoolEntity.byLevelNameNSSortDescriptor
        return request
    }

    // MARK: - Type Methods

    /// Créer une nouvelle instance et la sauvegarder dans le context
    /// - Important: Sauvegarder le Context.
    @discardableResult
    static func create(
        name: String,
        level: LevelSchool,
        annotation: String = "",
        mailAddressSchool: String = "",
        urlMailSchool: URL? = nil,
        idMailSchool: String = "",
        pwdMailSchool: String = ""
    ) -> SchoolEntity {
        let school = SchoolEntity.create()
        school.name = name
        school.level = level.rawValue
        school.annotation = annotation

        school.mailAddressSchool = mailAddressSchool
        school.urlMailSchool = urlMailSchool
        school.idMailSchool = idMailSchool
        school.pwdMailSchool = pwdMailSchool

        try? SchoolEntity.saveIfContextHasChanged()
        return school
    }

    /// Retourne tous les établissements triées.
    ///
    /// Ordre de tri:
    ///   1. Niveau d'école
    ///   2. Nom de l'école
    static func allSortedByLevelName() -> [SchoolEntity] {
        do {
            return try SchoolEntity
                .context
                .fetch(SchoolEntity.requestAllSortedByLevelName)
        } catch {
            return []
        }
    }
    
    /// Retourne l'établissement ayant pour nom `name`.
    /// - Parameter name: Nom de l'établissement recherché.
    /// - Returns: `nil` si non trouvé.
    static func school(withName name: String) -> SchoolEntity? {
        Self.all().first { school in
            school.viewName == name
        }
    }
    
    /// Retourne le nombre d'heures de cours effectué pour l'ensemble des classe de cet établissement.
    var heures: Double {
        allClasses.sum(for: \.heures)
    }

    // MARK: - Computed Properties Bonus/Malus

    /// Bonus/Malus moyen de la classe
    var averageBonus: Double {
        guard self.nbOfClasses != 0 else {
            return 0
        }
        return self.allClasses.sum(for: \.averageBonus) / self.nbOfClasses.double()
    }

    /// Bonus/Malus minimum de la classe
    var minBonus: Int {
        guard self.nbOfClasses != 0 else {
            return 0
        }
        return self.allClasses.min(\.minBonus)
    }

    /// Bonus/Malus maximum de la classe
    var maxBonus: Int {
        guard self.nbOfClasses != 0 else {
            return 0
        }
        return self.allClasses.max(\.maxBonus)
    }

    // MARK: - Computed Properties Classes

    /// Nombre de classes dans l'établissement
    var nbOfClasses: Int {
        Int(self.classesCount)
    }

    /// Liste des classes de l'établissement non triées
    var allClasses: [ClasseEntity] {
        if let classes {
            return (classes.allObjects as! [ClasseEntity])
        } else {
            return []
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

    // MARK: - Computed Properties Elèves

    /// Nombre d'élèves dans l'établissement
    var nbOfEleves: Int {
        allClasses.sum(for: \.nbOfEleves)
    }

    // MARK: - Computed Properties Event

    /// Nombre d'événements dans l'établissement
    var nbOfEvents: Int {
        Int(self.eventsCount)
    }

    /// Liste des événements de l'établissement non triées
    var allEvents: [EventEntity] {
        if let events {
            return (events.allObjects as! [EventEntity])
        } else {
            return []
        }
    }

    /// Liste des événements importants de l'établissement triées par date
    var eventsSortedByDate: [EventEntity] {
        let sortComparators =
            [
                SortDescriptor(\EventEntity.date, order: .reverse)
            ]
        return allEvents.sorted(using: sortComparators)
    }

    // MARK: - Computed Properties Documents

    /// Nombre de documents importants dans l'établissement
    var nbOfDocuments: Int {
        Int(self.documentsCount)
    }

    /// Liste des documents importants de l'établissement non triées
    var allDocuments: [DocumentEntity] {
        if let documents {
            return (documents.allObjects as! [DocumentEntity])
        } else {
            return []
        }
    }

    /// Liste des documents importants de l'établissement triées par ordre alphabétique
    var documentsSortedByName: [DocumentEntity] {
        let sortComparators =
            [
                SortDescriptor(\DocumentEntity.docName, order: .forward)
            ]
        return allDocuments.sorted(using: sortComparators)
    }

    // MARK: - Computed Properties Rooms

    /// Nombre de salles de classes utilisées dans l'établissement
    var nbOfRooms: Int {
        Int(self.roomsCount)
    }

    /// Liste des salles de classe de l'établissement non triées
    var allRooms: [RoomEntity] {
        if let rooms {
            return (rooms.allObjects as! [RoomEntity])
        } else {
            return []
        }
    }

    /// Liste des salles de classe de l'établissement triées par ordre alphabétique
    var roomsSortedByName: [RoomEntity] {
        let sortComparators =
            [
                SortDescriptor(\RoomEntity.name, order: .forward)
            ]
        return allRooms.sorted(using: sortComparators)
    }

    // MARK: - Computed Properties Ressources

    /// Nombre de types de ressources différentes utilisées dans l'établissement
    var nbOfRessourceTypes: Int {
        Int(self.ressourcesCount)
    }

    /// Liste des ressources de l'établissement non triées
    var allRessources: [RessourceEntity] {
        if let ressources {
            return (ressources.allObjects as! [RessourceEntity])
        } else {
            return []
        }
    }

    /// Liste des ressources de l'établissement non triées par ordre alphabétique
    var ressourcesSortedByName: [RessourceEntity] {
        let sortComparators =
            [
                SortDescriptor(\RessourceEntity.name, order: .forward)
            ]
        return allRessources.sorted(using: sortComparators)
    }

    // MARK: - Methods

    func classe(withAcronym acronym: String) -> ClasseEntity? {
        allClasses.first { classe in
            classe.displayString == acronym
        }
    }

    /// Recherche si la classe existe déjà dans l'établissement
    /// - Parameters:
    ///   - classeLevel: niveau de la classe
    ///   - classeNumero: numéro dela classe
    ///   - classeIsSegpa: classe de SEGPA ou non
    /// - Returns: Vrai si la classe existe déjà dans l'établissement
    func exists(
        classeLevel: LevelClasse,
        classeNumero: Int,
        classeIsSegpa: Bool
    ) -> Bool {
        (self.classes?.allObjects as! [ClasseEntity])
            .contains {
                $0.levelEnum == classeLevel &&
                    $0.numero == classeNumero &&
                    $0.segpa == classeIsSegpa
            }
    }

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set defaults here
        //        self.fileName = ""
        self.id = UUID()
    }
}

// MARK: - Extension Debug

public extension SchoolEntity {
    override var description: String {
        """

        ETABLISSEMENT: \(displayString)
           ID         : \(String(describing: id))
           Niveau     : \(levelString)
           Nom        : \(viewName)
           Note       : \(viewAnnotation)
           Nb salles     : \(nbOfRooms)
           Nb classes    : \(nbOfClasses)
           Nb documents  : \(nbOfDocuments)
           Nb événments  : \(nbOfEvents)
           Nb ressources : \(nbOfRessourceTypes)
           Documents: \(String(describing: documentsSortedByName).withPrefixedSplittedLines("     "))
           Evénements: \(String(describing: eventsSortedByDate).withPrefixedSplittedLines("     "))
           Salles: \(String(describing: roomsSortedByName).withPrefixedSplittedLines("     "))
           Ressources: \(String(describing: ressourcesSortedByName).withPrefixedSplittedLines("     "))
           Classes: \(String(describing: classesSortedByLevelNumber).withPrefixedSplittedLines("     "))

           eMail établissement : \(viewIdMailSchool)
           URL webmail : \(String(describing: urlMailSchool?.absoluteString))
           Identifiant : \(viewIdMailSchool)
           Mot de passe: \(viewPwdMailSchool)
        """
    }
}
