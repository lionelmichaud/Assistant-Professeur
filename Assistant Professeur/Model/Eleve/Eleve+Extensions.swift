//
//  Eleve+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/12/2022.
//

import Foundation
import CoreData


/// Un élève
extension EleveEntity {

    // MARK: - Type Properties

    @Preference(\.nameSortOrder)
    static private var nameSortOrder

    @Preference(\.nameDisplayOrder)
    static private var nameDisplayOrder

    // MARK: - Computed properties

    /// Wrapper of `trouble`
    /// - Important: *Saves the context to the store after modification is done*
    var troubleEnum: TroubleDys {
        get {
            TroubleDys(rawValue: trouble) ?? .undefined
        }
        set {
            self.trouble = newValue.rawValue
            try? EleveEntity.saveIfContextHasChanged()
        }
    }

    /// True si l'élève souffre d'un trouble dysfonctionnel reconnu par un PAP
    var hasTrouble: Bool {
        troubleEnum != .none
    }

    /// Wrapper of `sex`
    /// - Important: *Saves the context to the store after modification is done*
    var sexEnum: Sexe {
        get {
            return sex ? .male : .female
        }
        set {
            self.sex = (newValue == .male)
            try? EleveEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `familyName`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewFamilyName: String {
        get {
            self.familyName ?? ""
        }
        set {
            self.familyName = newValue
            try? EleveEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `givenName`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewGivenName: String {
        get {
            self.givenName ?? ""
        }
        set {
            self.givenName = newValue
            try? EleveEntity.saveIfContextHasChanged()
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
            try? EleveEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `appreciation`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewAppreciation: String {
        get {
            self.appreciation ?? ""
        }
        set {
            self.appreciation = newValue
            try? EleveEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `bonus`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewBonus: Int {
        get {
            Int(self.bonus)
        }
        set {
            self.bonus = Int16(newValue)
            try? EleveEntity.saveIfContextHasChanged()
        }
    }

    var displayName : String {
        switch EleveEntity.nameDisplayOrder {
            case .prenomNom:
                return "\(givenName ?? "") \(familyName ?? "")"
            case .nomPrenom:
                return "\(familyName ?? "") \(givenName ?? "")"
        }
    }

    var sortName : String {
        switch EleveEntity.nameSortOrder {
            case .prenomNom:
                return "\(givenName ?? "") \(familyName ?? "")"
            case .nomPrenom:
                return "\(familyName ?? "") \(givenName ?? "")"
        }
    }

    var additionalTimeInt: Int {
        hasAddTime ? 0 : 1
    }

    /// Nombre d'observations de l'élève
    var nbOfObservs: Int {
        Int(observsCount)
    }

    /// Nombre de colles de l'élève
    var nbOfColles: Int {
        Int(collesCount)
    }

    var groupInt: Int {
        0 // group == nil ? 0 : group!
    }

    // MARK: - Methods

    func isSameAs(_ eleve: EleveEntity) -> Bool {
        self.familyName == eleve.familyName &&
        self.givenName == eleve.givenName
    }

    /// Modifie l'attribut `sex`
    func setSex(_ newSex: Sexe) {
        self.sex = (newSex == .male)
    }

    /// Modifie l'attribut `trouble`
    func setTrouble(_ newTrouble: TroubleDys) {
        self.trouble = newTrouble.rawValue
    }

    /// Toggle l'attribut `isFlagged` de la classe
    /// - Important: *Saves the context to the store after modification is done*
    func toggleFlag() {
        isFlagged.toggle()
        try? EleveEntity.saveIfContextHasChanged()
    }

    func displayName(_ order: NameOrdering = .prenomNom) -> String {
        switch order {
            case .prenomNom:
                return "\(givenName ?? "") \(familyName ?? "")"
            case .nomPrenom:
                return "\(familyName ?? "") \(givenName ?? "")"
        }
    }

    func displayName2lines(_ order: NameOrdering = .prenomNom) -> String {
        switch order {
            case .prenomNom:
                return "\(givenName ?? "")\n\(familyName ?? "")"
            case .nomPrenom:
                return "\(familyName ?? "")\n\(givenName ?? "")"
        }
    }

    func satisfiesTo(searchString: String) -> Bool {
        if searchString.isNotEmpty {
            if searchString.containsOnlyDigits {
                // filtrage sur numéro de groupe
                let groupNum = Int(searchString)!
                return false
                //                        return eleve.group == groupNum

            } else {
                let string = searchString.lowercased()
                return familyName!.lowercased().contains(string) ||
                givenName!.lowercased().contains(string)
            }
        } else {
            return true
        }
    }

}

// MARK: - Extension Core Data

extension EleveEntity: ModelEntityP {

    // MARK: - Type Computed Properties

    static var byClasseNameNSSortDescriptor: [NSSortDescriptor] = [
        NSSortDescriptor(
            keyPath: \EleveEntity.classe?.school?.level,
            ascending: true),
        NSSortDescriptor(
            keyPath: \EleveEntity.classe?.school?.name,
            ascending: true),
        NSSortDescriptor(
            keyPath: \EleveEntity.classe?.level,
            ascending: false),
        NSSortDescriptor(
            keyPath: \EleveEntity.classe?.numero,
            ascending: true),
        NSSortDescriptor(
            keyPath: \EleveEntity.sortName,
            ascending: true)
    ]

    // MARK: - Type Methods

    static func byName(familyName: String,
                       givenName: String) -> EleveEntity? {
        all()
            .first {
                $0.familyName == familyName &&
                $0.givenName == givenName
            }
    }

    static func byObjectIdentifier(objectID: EleveEntity.ID) -> EleveEntity? {
        all()
            .first { $0.id == objectID }
    }

    static func byObjectIdentifier(objectIDs: Set<EleveEntity.ID>) -> [EleveEntity] {
        all()
            .filter { entity in
                objectIDs.contains { $0 == entity.id }
            }
    }

    /// Liste de tous les élèves appartenant au même établissement.
    ///
    /// Ordre de tri:
    ///   1. Niveau de la Classe
    ///   2. Numéro de la Classe
    ///   3. SGPA ou non
    ///   4. Nom / Prénom
    ///   5. Prénom / Nom
    static func requestFilteredSortedByName(
        dansSchoolId: NSManagedObjectID,
        searchString: String
    ) -> NSFetchRequest<EleveEntity> {
        let request = EleveEntity.fetchRequest()
        request.sortDescriptors = EleveEntity.byClasseNameNSSortDescriptor
        return request
    }

    // MARK: - Computed Properties

    /// Liste des élèves de la classe non triées
    var allColles: [ColleEntity] {
        (self.colles?.allObjects as! [ColleEntity])
    }

    /// Liste des élèves de la classe non triées
    var allObservs: [ObservEntity] {
        (self.observs?.allObjects as! [ObservEntity])
    }

    // MARK: - Methods

    func sortedObservations(isConsignee : Bool? = nil,
                            isVerified  : Bool? = nil) -> [ObservEntity] {
        let sortComparators = [
            SortDescriptor(\ObservEntity.isConsignee, order: .forward),
            SortDescriptor(\ObservEntity.isVerified, order: .forward),
            SortDescriptor(\ObservEntity.date, order: .forward)
        ]

        return allObservs
            .filter { observ in
                observ.satisfies(isConsignee: isConsignee,
                                 isVerified: isVerified)
            }
            .sorted(using: sortComparators)
    }

    func nbOfObservations(
        isConsignee  : Bool? = nil,
        isVerified   : Bool? = nil
    ) -> Int {
        switch (isConsignee, isVerified) {
            case (nil, nil):
                return nbOfObservs

            case let(.some(c), nil):
                return self.allObservs
                    .reduce(into: 0) { partialResult, observ in
                        partialResult += (observ.isConsignee == c ? 1 : 0)
                    }

            case let(nil, .some(v)):
                return self.allObservs
                    .reduce(into: 0) { partialResult, observ in
                        partialResult += (observ.isVerified == v ? 1 : 0)
                    }

            case let(.some(c), .some(v)):
                return self.allObservs
                    .reduce(into: 0) { partialResult, observ in
                        partialResult += ((observ.isConsignee == c || observ.isVerified == v) ? 1 : 0)
                    }
        }
    }

    func sortedColles(isConsignee : Bool? = nil,
                      isVerified  : Bool? = nil) -> [ColleEntity] {
        let sortComparators = [
            SortDescriptor(\ColleEntity.isConsignee, order: .forward),
            SortDescriptor(\ColleEntity.date, order: .forward)
        ]

        return allColles
            .filter { colle in
                colle.satisfies(isConsignee: isConsignee,
                                isVerified: isVerified)
            }
            .sorted(using: sortComparators)
    }

    func nbOfColles(
        isConsignee : Bool?  = nil,
        isVerified  : Bool?  = nil
    ) -> Int {
        switch (isConsignee, isVerified) {
            case (nil, nil):
                return nbOfColles

            case (.some(let c), nil):
                return self.allColles
                    .reduce(into: 0) { partialResult, colle in
                        partialResult += (colle.isConsignee == c ? 1 : 0)
                    }

            case (nil, .some(let v)):
                return self.allColles
                    .reduce(into: 0) { partialResult, colle in
                        partialResult += (colle.isVerified == v ? 1 : 0)
                    }

            case (.some(let c), .some(let v)):
                return self.allColles
                    .reduce(into: 0) { partialResult, colle in
                        partialResult += ((colle.isConsignee == c || colle.isVerified == v) ? 1 : 0)
                    }
        }
    }
}

// MARK: - Extension Debug

extension EleveEntity {
    public override var description: String {
        """

        ELEVE: \(displayName)
           ID          : \(id)
           Classe      : \(String(describing: classe?.displayString))
           Sexe        : \(sexEnum.pickerString)
           Nom         : \(displayName)
           Flagged     : \(isFlagged.frenchString)
           Appréciation: \(viewAppreciation)
           Annotation  : \(viewAnnotation)
           Bonus       : \(viewBonus)
           Nb observs  : \(nbOfObservs)
           Nb colles   : \(nbOfColles)
        """
//           Groupe: \(String(describing: group))
//           Observations: \(String(describing: observsID).withPrefixedSplittedLines("     "))
//           Colles: \(String(describing: collesID).withPrefixedSplittedLines("     "))
//        """
    }
}
