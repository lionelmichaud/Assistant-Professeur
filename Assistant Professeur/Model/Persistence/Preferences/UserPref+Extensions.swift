//
//  UserPref+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 13/07/2023.
//

import CoreData
import Foundation
import HelpersView

extension UserPrefEntity {
    /// Wrapper of `interoperability`
    /// - Important: *Saves the context to the store after modification is done*
    var interoperabilityEnum: Interoperability {
        get {
            Interoperability(rawValue: Int(interoperability)) ?? .ecoleDirecte
        }
        set {
            self.interoperability = Int16(newValue.rawValue)
            try? UserPrefEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `nameDisplayOrder`
    /// - Important: *Saves the context to the store after modification is done*
    var nameDisplayOrderEnum: NameOrdering {
        get {
            NameOrdering(rawValue: Int(nameDisplayOrder)) ?? .nomPrenom
        }
        set {
            self.nameDisplayOrder = Int16(newValue.rawValue)
            try? UserPrefEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `nameSortOrder`
    /// - Important: *Saves the context to the store after modification is done*
    var nameSortOrderEnum: NameOrdering {
        get {
            NameOrdering(rawValue: Int(nameSortOrder)) ?? .nomPrenom
        }
        set {
            self.nameSortOrder = Int16(newValue.rawValue)
            try? UserPrefEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `margeInterSequence`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewMargeInterSequence: Int {
        get {
            Int(margeInterSequence)
        }
        set {
            self.margeInterSequence = Int16(newValue)
            try? UserPrefEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `schoolAnnotationEnabled`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewSchoolAnnotationEnabled: Bool {
        get {
            self.schoolAnnotationEnabled
        }
        set {
            self.schoolAnnotationEnabled = newValue
            try? UserPrefEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `classeAppreciationEnabled`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewClasseAppreciationEnabled: Bool {
        get {
            self.classeAppreciationEnabled
        }
        set {
            self.classeAppreciationEnabled = newValue
            try? UserPrefEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `classeAnnotationEnabled`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewClasseAnnotationEnabled: Bool {
        get {
            self.classeAnnotationEnabled
        }
        set {
            self.classeAnnotationEnabled = newValue
            try? UserPrefEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `programAnnotationEnabled`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewProgramAnnotationEnabled: Bool {
        get {
            self.programAnnotationEnabled
        }
        set {
            self.programAnnotationEnabled = newValue
            try? UserPrefEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `sequenceAnnotationEnabled`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewSequenceAnnotationEnabled: Bool {
        get {
            self.sequenceAnnotationEnabled
        }
        set {
            self.sequenceAnnotationEnabled = newValue
            try? UserPrefEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `activityAnnotationEnabled`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewActivityAnnotationEnabled: Bool {
        get {
            self.activityAnnotationEnabled
        }
        set {
            self.activityAnnotationEnabled = newValue
            try? UserPrefEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `horaire`
    /// - Important: *Saves the context to the store after modification is done*
    var viewHoraire: DailySchedulePref {
        get {
            getHoraire(fromString: horaire)
        }
        set {
            setHoraire(newValue)
            try? UserPrefEntity.saveIfContextHasChanged()
        }
    }

    /// Décode l'attribut `horaire` à partir d'une String `fromString`au format JSON.
    private func getHoraire(fromString: String?) -> DailySchedulePref {
        if let fromString {
            let data = Data(fromString.utf8)
            return (try? JSONDecoder().decode(DailySchedulePref.self, from: data)) ?? DailySchedulePref()
        } else {
            return DailySchedulePref()
        }
    }

    /// Modifie l'attribut `horaire` en encodant les étapes au format JSON.
    /// - Important: *Does NOT save the context to the store after modification is done*
    private func setHoraire(_ horaire: DailySchedulePref) {
        guard let data = try? JSONEncoder().encode(horaire),
              let string = String(data: data, encoding: .utf8) else {
            self.horaire = ""
            return
        }
        self.horaire = string
    }

    /// Wrapper of `schoolYear`
    /// - Important: *Saves the context to the store after modification is done*
    var viewSchoolYearPref: SchoolYearPref {
        get {
            getSchoolYearPref(fromString: schoolYear)
        }
        set {
            setSchoolYearPref(newValue)
            try? UserPrefEntity.saveIfContextHasChanged()
        }
    }

    /// Décode l'attribut `schoolYear` à partir d'une String `fromString`au format JSON.
    private func getSchoolYearPref(fromString: String?) -> SchoolYearPref {
        if let fromString {
            let data = Data(fromString.utf8)
            return (try? JSONDecoder().decode(SchoolYearPref.self, from: data)) ?? SchoolYearPref()
        } else {
            return SchoolYearPref()
        }
    }

    /// Modifie l'attribut `schoolYear` en encodant les étapes au format JSON.
    /// - Important: *Does NOT save the context to the store after modification is done*
    private func setSchoolYearPref(_ schoolYear: SchoolYearPref) {
        guard let data = try? JSONEncoder().encode(schoolYear),
              let string = String(data: data, encoding: .utf8) else {
            self.schoolYear = ""
            return
        }
        self.schoolYear = string
    }

    /// Wrapper of `eleve`
    /// - Important: *Saves the context to the store after modification is done*
    var viewElevePref: ElevePref {
        get {
            getElevePref(fromString: eleve)
        }
        set {
            setElevePref(newValue)
            try? UserPrefEntity.saveIfContextHasChanged()
        }
    }

    /// Décode l'attribut `eleve` à partir d'une String `fromString`au format JSON.
    private func getElevePref(fromString: String?) -> ElevePref {
        if let fromString {
            let data = Data(fromString.utf8)
            return (try? JSONDecoder().decode(ElevePref.self, from: data)) ?? ElevePref()
        } else {
            return ElevePref()
        }
    }

    /// Modifie l'attribut `eleve` en encodant les étapes au format JSON.
    /// - Important: *Does NOT save the context to the store after modification is done*
    private func setElevePref(_ eleve: ElevePref) {
        guard let data = try? JSONEncoder().encode(eleve),
              let string = String(data: data, encoding: .utf8) else {
            self.eleve = ""
            return
        }
        self.eleve = string
    }
}

// MARK: - Extension Core Data

extension UserPrefEntity {
    // MARK: - Type Computed Properties

    static var shared: UserPrefEntity {
        // Créer le record unique des préférences de l'utilisateur de l'appli s'il n'en existe pas encore.
        if let newlyCreated = createSharedIfDoesNotExist() {
            return newlyCreated
        }

        // S'il y a plusieurs records: garder seulement le plus ancien
        removeAllButTheOldest()
        return UserPrefEntity.allSortedbyCreationDate().first!
    }

    private static var byCreationDateNSSortDescriptor: [NSSortDescriptor] =
        [
            NSSortDescriptor(
                keyPath: \UserPrefEntity.creationDate,
                ascending: true
            )
        ]

    /// Requête pour toutes les préférences triées.
    ///
    /// Ordre de tri:
    ///   1. Date de création
    static var requestAllSortedbyCreationDate: NSFetchRequest<UserPrefEntity> {
        let request = UserPrefEntity.fetchRequest()
        request.sortDescriptors = UserPrefEntity.byCreationDateNSSortDescriptor
        return request
    }

    // MARK: - Type Methods

    /// Créer le record unique de l'utilisateur de l'appli s'il n'existe pas encore.
    static func initializeEntity() {
        // créer le record unique des préférences de l'utilisateur de l'appli
        createSharedIfDoesNotExist()
    }

    /// Créer le record unique de l'utilisateur de l'appli s'il n'existe pas encore.
    /// Retourne l'objet créé ou nil si l'objet existait déjà.
    @discardableResult
    private static func createSharedIfDoesNotExist() -> UserPrefEntity? {
        guard UserPrefEntity.cardinal() == 0 else {
            return nil
        }
        let userPref = UserPrefEntity.create()

        let elevePref = ElevePref()
        userPref.setElevePref(elevePref)

        let horairePref = DailySchedulePref()
        userPref.setHoraire(horairePref)

        let schoolYearPref = SchoolYearPref()
        userPref.setSchoolYearPref(schoolYearPref)

        try? UserPrefEntity.saveIfContextHasChanged()

        return userPref
    }

    /// Retourne toutes les entitées triées par date de création.
    private static func allSortedbyCreationDate() -> [UserPrefEntity] {
        do {
            return try UserPrefEntity
                .context
                .fetch(UserPrefEntity.requestAllSortedbyCreationDate)
        } catch {
            return []
        }
    }

    private static func removeAllButTheOldest() {
        let nbItemsToRemove = cardinal() - 1

        if nbItemsToRemove > 0 {
            let allItems = allSortedbyCreationDate()
            allItems[1 ..< allItems.endIndex].forEach { userPref in
                try? userPref.delete()
            }
            try? UserPrefEntity.saveIfContextHasChanged()
        }
    }

    /// Check the correctness and consistency of all database entities of this type.
    /// - Parameters:
    ///   - errorList: Liste des erreurs trouvées.
    static func checkConsistency(
        errorList: inout DataBaseErrorList,
        tryToRepair: Bool
    ) {
        if cardinal() == 0 {
            if tryToRepair {
                createSharedIfDoesNotExist()
            }
            if cardinal() == 0 {
                errorList.append(DataBaseError.some(
                    entity: Self.entity().name!,
                    name: "fichier inexistant et devrait exister",
                    id: nil
                ))
            }

        } else if cardinal() > 1 {
            if tryToRepair {
                removeAllButTheOldest()
            }
            if cardinal() > 1 {
                errorList.append(DataBaseError.some(
                    entity: Self.entity().name!,
                    name: "plusieurs fichiers préférence ont été trouvés",
                    id: nil
                ))
            }
        }
    }

    // MARK: - Methods

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set defaults here
        self.id = UUID()
        self.creationDate = Date.now
    }
}
