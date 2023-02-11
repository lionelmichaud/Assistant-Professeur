//
//  Eleve+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/12/2022.
//

import CoreData
import Foundation
import SwiftUI
import UIKit

/// Un élève
extension EleveEntity {
    // MARK: - Type Properties

    @Preference(\.nameSortOrder)
    private static var nameSortOrder

    @Preference(\.nameDisplayOrder)
    private static var nameDisplayOrder

    // MARK: - Computed properties

    /// Wrapper of `trombine`
    /// - Important: *Saves the context to the store after modification is done*
    var viewUIImageTrombine: UIImage {
        get {
            if let trombine {
                return UIImage(data: trombine) ?? UIImage(systemName: "questionmark.square.dashed")!
            } else {
                return UIImage(systemName: "questionmark.square.dashed")!
            }
        }
        set {
            self.trombine = newValue.jpegData(compressionQuality: 1)
            try? EleveEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `trombine`
    /// - Important: *Saves the context to the store after modification is done*
    var viewImageTrombine: Image {
        if let trombine, let uiImage = UIImage(data: trombine) {
            return Image(uiImage: uiImage)
        } else {
            return Image(systemName: "questionmark.square.dashed")
        }
    }

    var hasImageTrombine: Bool {
        trombine != nil
    }

    /// Wrapper of `trouble`
    /// - Important: *Saves the context to the store after modification is done*
    var troubleEnum: TroubleDys {
        get {
            TroubleDys(rawValue: trouble) ?? .undefined
        }
        set {
            hasAddTime = newValue.additionalTime
            self.trouble = newValue.rawValue
            try? EleveEntity.saveIfContextHasChanged()
        }
    }

    /// True si l'élève souffre d'un trouble dysfonctionnel reconnu par un PAP
    var hasTrouble: Bool {
        troubleEnum != .none
    }

    /// Wrapper of `hasAddTime`
    /// - Important: *Saves the context to the store after modification is done*
    var viewHasAddTime: Bool {
        get {
            hasAddTime
        }
        set {
            self.hasAddTime = newValue
            try? EleveEntity.saveIfContextHasChanged()
        }
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
            self.familyName = newValue.trimmed.uppercased()
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
            self.givenName = newValue.trimmed
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

    @objc
    var displayName: String {
        switch EleveEntity.nameDisplayOrder {
            case .prenomNom:
                return "\(givenName ?? "") \(familyName ?? "")"
            case .nomPrenom:
                return "\(familyName ?? "") \(givenName ?? "")"
        }
    }

    @objc
    var sortName: String {
        switch EleveEntity.nameSortOrder {
            case .prenomNom:
                return "\(givenName ?? "") \(familyName ?? "")"
            case .nomPrenom:
                return "\(familyName ?? "") \(givenName ?? "")"
        }
    }

    var imageFileName: String? {
        guard var familyName = familyName, let givenName = givenName else {
            return nil
        }
        familyName = familyName.replacing(" ", with: "_")
        return familyName + "_" + givenName + ".jpg"
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
        Int(group?.number ?? 0)
    }

    // MARK: - Methods

    func isSameAs(_ eleve: EleveEntity) -> Bool {
        self.familyName == eleve.familyName &&
            self.givenName == eleve.givenName
    }

    /// Modifie l'attribut `sex`
    /// - Important: *Does NOT save the context to the store after modification is done*
    func setSex(_ newSex: Sexe) {
        self.sex = (newSex == .male)
    }

    /// Modifie l'attribut `trouble`
    /// - Important: *Does NOT save the context to the store after modification is done*
    func setTrouble(_ newTrouble: TroubleDys) {
        self.trouble = newTrouble.rawValue
    }

    /// Modifie l'attribut `seat`
    /// - Important: *Does NOT save the context to the store after modification is done*
    func setSeat(_ newSeat: SeatEntity) {
        guard let classe,
              let classes = newSeat.room?.allClasses,
              classes.contains(classe) else {
            return
        }
        self.seat = newSeat
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
                return group?.viewNumber == groupNum

            } else {
                // filtrage sur nom et prénom
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

extension EleveEntity {
    // MARK: - Type Computed Properties

    static var bySchoolNameClasseEleveFamilyNameNSSortDescriptor: [NSSortDescriptor] =
        [
            // school
            NSSortDescriptor(
                keyPath: \EleveEntity.classe?.school?.level,
                ascending: true
            ),
            NSSortDescriptor(
                keyPath: \EleveEntity.classe?.school?.name,
                ascending: true
            ),
            // classe
            NSSortDescriptor(
                keyPath: \EleveEntity.classe?.level,
                ascending: false
            ),
            NSSortDescriptor(
                keyPath: \EleveEntity.classe?.numero,
                ascending: true
            ),
            NSSortDescriptor(
                keyPath: \EleveEntity.classe?.segpa,
                ascending: true
            ),
            // name
            NSSortDescriptor(
                keyPath: \EleveEntity.familyName,
                ascending: true
            ),
            NSSortDescriptor(
                keyPath: \EleveEntity.givenName,
                ascending: true
            )
        ]

    static var bySchoolNameClasseEleveGivenNameNSSortDescriptor: [NSSortDescriptor] =
        [
            // school
            NSSortDescriptor(
                keyPath: \EleveEntity.classe?.school?.level,
                ascending: true
            ),
            NSSortDescriptor(
                keyPath: \EleveEntity.classe?.school?.name,
                ascending: true
            ),
            // classe
            NSSortDescriptor(
                keyPath: \EleveEntity.classe?.level,
                ascending: false
            ),
            NSSortDescriptor(
                keyPath: \EleveEntity.classe?.numero,
                ascending: true
            ),
            NSSortDescriptor(
                keyPath: \EleveEntity.classe?.segpa,
                ascending: true
            ),
            // name
            NSSortDescriptor(
                keyPath: \EleveEntity.givenName,
                ascending: true
            ),
            NSSortDescriptor(
                keyPath: \EleveEntity.familyName,
                ascending: true
            )
        ]

    static var bySchoolNameClasseGroupeEleveFamilyNameNSSortDescriptor: [NSSortDescriptor] =
        [
            // school
            NSSortDescriptor(
                keyPath: \EleveEntity.classe?.school?.level,
                ascending: true
            ),
            NSSortDescriptor(
                keyPath: \EleveEntity.classe?.school?.name,
                ascending: true
            ),
            // classe
            NSSortDescriptor(
                keyPath: \EleveEntity.classe?.level,
                ascending: false
            ),
            NSSortDescriptor(
                keyPath: \EleveEntity.classe?.numero,
                ascending: true
            ),
            NSSortDescriptor(
                keyPath: \EleveEntity.classe?.segpa,
                ascending: true
            ),
            // groupe
            NSSortDescriptor(
                keyPath: \EleveEntity.group?.number,
                ascending: true
            ),
            // name
            NSSortDescriptor(
                keyPath: \EleveEntity.familyName,
                ascending: true
            ),
            NSSortDescriptor(
                keyPath: \EleveEntity.givenName,
                ascending: true
            )
        ]

    static var bySchoolNameClasseGroupeEleveGivenNameNSSortDescriptor: [NSSortDescriptor] =
        [
            // school
            NSSortDescriptor(
                keyPath: \EleveEntity.classe?.school?.level,
                ascending: true
            ),
            NSSortDescriptor(
                keyPath: \EleveEntity.classe?.school?.name,
                ascending: true
            ),
            // classe
            NSSortDescriptor(
                keyPath: \EleveEntity.classe?.level,
                ascending: false
            ),
            NSSortDescriptor(
                keyPath: \EleveEntity.classe?.numero,
                ascending: true
            ),
            NSSortDescriptor(
                keyPath: \EleveEntity.classe?.segpa,
                ascending: true
            ),
            // groupe
            NSSortDescriptor(
                keyPath: \EleveEntity.group?.number,
                ascending: true
            ),
            // name
            NSSortDescriptor(
                keyPath: \EleveEntity.givenName,
                ascending: true
            ),
            NSSortDescriptor(
                keyPath: \EleveEntity.familyName,
                ascending: true
            )
        ]

    /// Requête pour tous les élèves triées.
    ///
    /// Ordre de tri:
    ///   1. Type d'école
    ///   2. Nom de l'école
    ///   3. Niveau de la Classe
    ///   4. Numéro de la Classe
    ///   5. Classe SGPA ou non
    ///   6. Numéro de groupe
    ///   7. Nom de l'élève
    static var requestAllSortedBySchoolNameClasseGroupeEleveName: NSFetchRequest<EleveEntity> {
        let request = EleveEntity.fetchRequest()
        if nameSortOrder == .nomPrenom {
            request.sortDescriptors =
                EleveEntity.bySchoolNameClasseGroupeEleveFamilyNameNSSortDescriptor
        } else {
            request.sortDescriptors =
                EleveEntity.bySchoolNameClasseGroupeEleveGivenNameNSSortDescriptor
        }
        return request
    }

    // MARK: - Type Methods

    /// Créer un nouvel élève et l'ajouter à la `classe`
    /// - Parameters:
    ///   - familyName: Nom de famille
    ///   - givenName: Prénom
    ///   - sex: Sexe
    ///   - classe: Classe  à laquelle ajouter l'élève créé
    /// - Returns: Le nouvel élève
    @discardableResult
    static func create(
        familyName: String,
        givenName: String,
        sex: Sexe,
        isFlagged: Bool = false,
        trouble: TroubleDys = .none,
        hasAddTime: Bool = false,
        annotation: String = "",
        appreciation: String = "",
        bonus: Int16 = 0,
        dans classe: ClasseEntity
    ) -> EleveEntity {
        let eleve = EleveEntity.create()
        // classe d'appartenance.
        // mandatory
        eleve.classe = classe

        // groupe d'appartenance.
        // mandatory
        eleve.group = classe.groupOfUngroupedEleves

        eleve.familyName = familyName
        eleve.givenName = givenName
        eleve.setSex(sex)
        eleve.isFlagged = isFlagged
        eleve.trouble = trouble.rawValue
        eleve.hasAddTime = hasAddTime
        eleve.annotation = annotation
        eleve.appreciation = appreciation
        eleve.bonus = bonus

        try? EleveEntity.saveIfContextHasChanged()

        return eleve
    }

    static func checkConsistency(errorFound: inout Bool) {
        all().forEach { eleve in
            guard eleve.classe != nil else {
                errorFound = true
                return
            }
        }
    }

    static func byName(
        familyName: String,
        givenName: String
    ) -> EleveEntity? {
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

    /// Requête pour tous les élèves appartenant au même établissement.
    ///
    /// Ordre de tri:
    ///   1. Niveau de la Classe
    ///   2. Numéro de la Classe
    ///   3. SGPA ou non
    ///   4. Nom / Prénom
    ///   5. Prénom / Nom
    static func requestAllFilteredSortedByName(
        dansSchoolId _: NSManagedObjectID,
        searchString _: String
    ) -> NSFetchRequest<EleveEntity> {
        let request = EleveEntity.fetchRequest()
        if nameSortOrder == .nomPrenom {
            request.sortDescriptors =
                EleveEntity.bySchoolNameClasseEleveFamilyNameNSSortDescriptor
        } else {
            request.sortDescriptors =
                EleveEntity.bySchoolNameClasseEleveGivenNameNSSortDescriptor
        }
        return request
    }

    // MARK: - Computed Properties

    /// Liste des élèves de la classe non triées
    var allColles: [ColleEntity] {
        if let colles {
            return (colles.allObjects as! [ColleEntity])
        } else {
            return []
        }
    }

    /// Liste des élèves de la classe non triées
    var allObservs: [ObservEntity] {
        if let observs {
            return (observs.allObjects as! [ObservEntity])
        } else {
            return []
        }
    }

    // MARK: - Methods

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set defaults here
        self.id = UUID()
    }

    func sortedObservations(
        isConsignee: Bool? = nil,
        isVerified: Bool? = nil
    ) -> [ObservEntity] {
        let sortComparators = [
            SortDescriptor(\ObservEntity.isConsignee, order: .forward),
            SortDescriptor(\ObservEntity.isVerified, order: .forward),
            SortDescriptor(\ObservEntity.date, order: .forward)
        ]

        return allObservs
            .filter { observ in
                observ.satisfies(
                    isConsignee: isConsignee,
                    isVerified: isVerified
                )
            }
            .sorted(using: sortComparators)
    }

    func nbOfObservations(
        isConsignee: Bool? = nil,
        isVerified: Bool? = nil
    ) -> Int {
        switch (isConsignee, isVerified) {
            case (nil, nil):
                return nbOfObservs

            case let (.some(c), nil):
                return self.allObservs
                    .reduce(into: 0) { partialResult, observ in
                        partialResult += (observ.isConsignee == c ? 1 : 0)
                    }

            case let (nil, .some(v)):
                return self.allObservs
                    .reduce(into: 0) { partialResult, observ in
                        partialResult += (observ.isVerified == v ? 1 : 0)
                    }

            case let (.some(c), .some(v)):
                return self.allObservs
                    .reduce(into: 0) { partialResult, observ in
                        partialResult += ((observ.isConsignee == c || observ.isVerified == v) ? 1 : 0)
                    }
        }
    }

    func sortedColles(
        isConsignee: Bool? = nil,
        isVerified: Bool? = nil
    ) -> [ColleEntity] {
        let sortComparators = [
            SortDescriptor(\ColleEntity.isConsignee, order: .forward),
            SortDescriptor(\ColleEntity.date, order: .forward)
        ]

        return allColles
            .filter { colle in
                colle.satisfies(
                    isConsignee: isConsignee,
                    isVerified: isVerified
                )
            }
            .sorted(using: sortComparators)
    }

    func nbOfColles(
        isConsignee: Bool? = nil,
        isVerified: Bool? = nil
    ) -> Int {
        switch (isConsignee, isVerified) {
            case (nil, nil):
                return nbOfColles

            case (.some(let c), nil):
                return self.allColles
                    .reduce(into: 0) { partialResult, colle in
                        partialResult += (colle.isConsignee == c ? 1 : 0)
                    }

            case (nil, let .some(v)):
                return self.allColles
                    .reduce(into: 0) { partialResult, colle in
                        partialResult += (colle.isVerified == v ? 1 : 0)
                    }

            case let (.some(c), .some(v)):
                return self.allColles
                    .reduce(into: 0) { partialResult, colle in
                        partialResult += ((colle.isConsignee == c || colle.isVerified == v) ? 1 : 0)
                    }
        }
    }
}

// MARK: - Extension Debug

public extension EleveEntity {
    override var description: String {
        """

        ELEVE: \(displayName)
           ID          : \(objectID)
           Classe      : \(String(describing: classe?.displayString))
           Groupe      : \(String(describing: group?.displayString))
           Sexe        : \(sexEnum.pickerString)
           Nom         : \(displayName)
           Flagged     : \(isFlagged.frenchString)
           Appréciation: \(viewAppreciation)
           Annotation  : \(viewAnnotation)
           Bonus       : \(viewBonus)
           Nb observs  : \(nbOfObservs)
           Nb colles   : \(nbOfColles)
        """
//    Observations: \(String(describing: observs).withPrefixedSplittedLines("     "))
//    Colles: \(String(describing: colles).withPrefixedSplittedLines("     "))
//        """
    }
}
