//
//  Classe+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/11/2022.
//

import Foundation
import os
import CoreData

private let customLog = Logger(subsystem: "com.michaud.lionel.Assistant-Professeur",
                               category: "ClasseEntity")

/// Une classe d'élèves
extension ClasseEntity {

    // MARK: - Computed properties

    /// Wrapper of `discipline`
    /// - Important: *Saves the context to the store after modification is done*
    var disciplineEnum: Discipline {
        get {
            Discipline(rawValue: discipline) ?? .technologie
        }
        set {
            self.discipline = newValue.rawValue
            try? ClasseEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `level`
    /// - Important: *Saves the context to the store after modification is done*
    var levelEnum: LevelClasse {
        get {
            if let level {
                return LevelClasse(rawValue: level) ?? .n6ieme
            } else {
                return .n6ieme
            }
        }
        set {
            self.level = newValue.rawValue
            try? ClasseEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `segpa`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewSegpa: Bool {
        get {
            self.segpa
        }
        set {
            self.segpa = newValue
            try? ClasseEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `heures`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewHeures: Double {
        get {
            self.heures
        }
        set {
            self.heures = newValue
            try? ClasseEntity.saveIfContextHasChanged()
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
            try? ClasseEntity.saveIfContextHasChanged()
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
            try? ClasseEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `numero`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewNumero: Int {
        get {
            Int(self.numero)
        }
        set {
            self.numero = Int32(newValue)
            try? ClasseEntity.saveIfContextHasChanged()
        }
    }

    @objc
    var levelString: String {
        levelEnum.displayString
    }

    var hasAssociatedRoom: Bool {
        room != nil
    }

    /// Nombre d'élèves dans la Classe
    var nbOfEleves: Int {
        Int(elevesCount)
    }

    /// Nombre de groupes dans la Classe
    /// - Important: incluant le groupe 0 des élèves affectés à aucun groupe
    var nbOfGroups: Int {
        Int(groupCount)
    }

    /// Nombre d'évaluations de la Classe
    var nbOfExams: Int {
        Int(examsCount)
    }

    var elevesListLabel: String {
        if nbOfEleves == 0 {
            return "Aucun élève"
        } else if nbOfEleves == 1 {
            return "Liste de 1 élève"
        } else {
            return "Liste des \(nbOfEleves) élèves"
        }
    }

    var examsListLabel: String {
        if nbOfExams == 0 {
            return "Aucune Évaluation"
        } else if nbOfExams == 1 {
            return "1 Évaluation"
        } else {
            return "\(nbOfExams) Évaluations"
        }
    }

    var displayString: String {
        "\(levelEnum.displayString)\(numero)\(segpa ? "S" : "")"
    }

    // MARK: - Methods

    /// Modifie l'attribut `discipline`
    func setDiscipline(_ newDiscipline: Discipline) {
        self.discipline = newDiscipline.rawValue
    }

    /// Modifie l'attribut `level`
    func setLevel(_ newLevel: LevelClasse) {
        self.level = newLevel.rawValue
    }

    /// Toggle l'attribut `isFlagged` de la classe
    /// - Important: *Saves the context to the store after modification is done*
    func toggleFlag() {
        isFlagged.toggle()
        try? ClasseEntity.saveIfContextHasChanged()
    }

    /// Toggle l'attribut `segpa` de la classe
    /// - Important: *Saves the context to the store after modification is done*
    func toggleSegpa() {
        segpa.toggle()
        try? ClasseEntity.saveIfContextHasChanged()
    }
}

// MARK: - Extension Core Data

extension ClasseEntity: ModelEntityP {

    // MARK: - Type Properties

    @Preference(\.nameSortOrder)
    static private var nameSortOrder

    // MARK: - Type Computed Properties

    static var bySchoolThenClasseLevelNumberNSSortDescriptor: [NSSortDescriptor] =
    [
        // school
        NSSortDescriptor(
            keyPath: \ClasseEntity.school?.level,
            ascending: true),
        NSSortDescriptor(
            keyPath: \ClasseEntity.school?.name,
            ascending: true),
        // classe
        NSSortDescriptor(
            keyPath: \ClasseEntity.level,
            ascending: false),
        NSSortDescriptor(
            keyPath: \ClasseEntity.numero,
            ascending: true),
        NSSortDescriptor(
            keyPath: \ClasseEntity.segpa,
            ascending: true)
    ]

    /// Requête pour toutes les classes triées.
    ///
    /// Ordre de tri:
    ///   1. Type d'école
    ///   2. Nom de l'école
    ///   3. Niveau de la Classe
    ///   4. Numéro de la Classe
    ///   5. Classe SGPA ou non
    static var requestAllSortedbySchoolThenClasseLevelNumber: NSFetchRequest<ClasseEntity> {
        let request = ClasseEntity.fetchRequest()
        request.sortDescriptors = ClasseEntity.bySchoolThenClasseLevelNumberNSSortDescriptor
        return request
    }

    // MARK: - Computed Properties Groups

    /// Liste des élèves de la classe non triées
    var allGroups: [GroupEntity] {
        if let groups {
            return (groups.allObjects as! [GroupEntity])
        } else {
            return [ ]
        }
    }

    /// Liste des évaluations de lla classe non triées
    var allExams: [ExamEntity] {
        if let exams {
            return (exams.allObjects as! [ExamEntity])
        } else {
            return [ ]
        }
    }

    /// Retourne la liste des groupes de la classe.
    /// Les groupes trouvés sont triés par numéro.
    ///
    /// Ordre de tri :
    ///   1. Numéro de groupe
    var allGroupsSortedByNumber: [GroupEntity] {
        let sortComparators =
        [
            SortDescriptor(\GroupEntity.number, order: .forward),
        ]

        return allGroups
            .sorted(using: sortComparators)
    }

    var groupOfUngroupedEleves: GroupEntity {
        let foundGroup = self.allGroups.filter { group in
            group.number == 0
        }
        if foundGroup.isNotEmpty {
            return foundGroup.first!
        } else {
            customLog.log(level: .fault,
                          "groupOfUngroupedEleves: le groupe 0 n'existe pas")
            fatalError()
        }
    }

    // MARK: - Computed Properties Elèves

    /// Liste des élèves de la classe non triées
    var allEleves: [EleveEntity] {
        if let eleves {
            return (eleves.allObjects as! [EleveEntity])
        } else {
            return [ ]
        }
    }

    /// Liste des élèves de la classe triés par nom.
    ///
    /// Ordre de tri selon la préférence `.nameSortOrder`:
    ///   1. Nom / Prénom
    ///   2. Prénon / Nom
    var elevesSortedByName: [EleveEntity] {
        filteredElevesSortedByName(searchString: "")
    }

    // MARK: - Methods

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        //Set defaults here
        // self.group = ""
        //        self.fileDate = Date()
    }

    // MARK: - Type Methods

    @discardableResult
    static func create(
        level        : LevelClasse,
        numero       : Int,
        segpa        : Bool,
        discipline   : Discipline,
        heures       : Double,
        isFlagged    : Bool,
        annotation   : String = "",
        appreciation : String = "",
        dans school  : SchoolEntity?
    ) -> ClasseEntity {
        let classe = ClasseEntity.create()
        // Etablissement d'appartenance.
        // mandatory
        classe.school     = school

        // créer un Groupe 0 pour les élèves de la classe
        // n'appartenant à aucun groupe.
        // mandatory
        GroupEntity.create(numero: 0, dans: classe)

        classe.level        = level.rawValue
        classe.numero       = Int32(numero)
        classe.segpa        = segpa
        classe.discipline   = discipline.rawValue
        classe.heures       = heures
        classe.isFlagged    = isFlagged
        classe.annotation   = annotation
        classe.appreciation = appreciation

        try? ClasseEntity.saveIfContextHasChanged()
        return classe
    }

    static func checkConsistency(errorFound: inout Bool) {
        all().forEach { classe in
            guard classe.school != nil else {
                errorFound = true
                return
            }
        }
    }

    // MARK: - Méthodes Groupes

    func groupe(number: Int) -> GroupEntity {
        let groupes = allGroups
            .filter { groupe in
                groupe.number == Int16(number)
            }
        guard groupes.count == 1 else {
            customLog.log(level: .fault, "Aucun ou plusieur groupes d'élèves avec le même numéro n°\(number) dans la classe \(self.displayString)")
            fatalError()
        }
        return groupes.first!
    }

    // MARK: - Méthodes Elèves

    /// Retourne la liste des élèves de la classe satisfaisant *au moins à l'un des critères* définis en paramètre.
    /// Les élèves trouvés sont triés par nom.
    ///
    /// Ordre de tri selon la préférence `.nameSortOrder`:
    ///   1. Nom / Prénom
    ///   2. Prénon / Nom
    ///
    /// Si un critère vaut `false` alors on ne filtre pas sur ce critère.
    ///
    /// - Parameters:
    ///   - searchString: caractères à rechercher dnas les noms/prénom ou nombre à rechercher dans le n° de groupe
    ///   - filterObservation: si `true` alors ne conserver que les élèves avec des observation **non-consignées** OU **non-vérifiées**
    ///   - filterColle: si `true` alors ne conserver que que les élèves avec des colles **non-consignées**
    ///   - filterFlag: si `true` alors ne conserver que que les élèves **flagés**
    /// - Returns: Liste des élèves de la classe satisfaisant *au moins à l'un des critères* définis en paramètre
    func filteredElevesSortedByName(
        searchString      : String,
        filterObservation : Bool = false,
        filterColle       : Bool = false,
        filterFlag        : Bool = false
    ) -> [EleveEntity] {
        let sortComparators = ClasseEntity.nameSortOrder == .nomPrenom ?
        [
            SortDescriptor(\EleveEntity.familyName, order: .forward),
            SortDescriptor(\EleveEntity.givenName, order: .forward)
        ] :
        [
            SortDescriptor(\EleveEntity.givenName, order: .forward),
            SortDescriptor(\EleveEntity.familyName, order: .forward)
        ]

        return allEleves
            .filter { eleve in
                lazy var nbObservWithActionToDo : Int = {
                    eleve.nbOfObservations(isConsignee : false,
                                           isVerified  : false)
                }()

                lazy var nbColleWithActionToDo : Int = {
                    eleve.nbOfColles(isConsignee : false)
                }()

                return eleve.satisfiesTo(searchString: searchString) &&
                ((!filterObservation && !filterColle && !filterFlag) ||
                 (filterObservation && (nbObservWithActionToDo > 0)) ||
                 (filterColle && nbColleWithActionToDo > 0) ||
                 (filterFlag && eleve.isFlagged))
            }
            .sorted(using: sortComparators)
    }

    /// Retourne la liste des élèves de la classe dont les nom ou prénom contiennent `searchString`.
    ///
    /// Les élèves trouvés sont triés en utilisant `sortOrder`.
    func filteredSortedEleves(
        searchString : String,
        sortOrder    : [KeyPathComparator<EleveEntity>]
    ) -> [EleveEntity] {
        guard searchString.isNotEmpty else { return allEleves.sorted(using: sortOrder) }

        return allEleves
            .filter { eleve in
                eleve.satisfiesTo(searchString: searchString)
            }
            .sorted(using: sortOrder)
    }

    /// Retourne la liste des élèves de la classe qui n'ont pas de place assise.
    ///
    /// Les élèves trouvés sont triés en utilisant les péréférences `nameSortOrder`.
    func unseatedEleves() -> [EleveEntity] {
        let sortComparators = ClasseEntity.nameSortOrder == .nomPrenom ?
        [
            SortDescriptor(\EleveEntity.familyName, order: .forward),
            SortDescriptor(\EleveEntity.givenName, order: .forward)
        ] :
        [
            SortDescriptor(\EleveEntity.givenName, order: .forward),
            SortDescriptor(\EleveEntity.familyName, order: .forward)
        ]

        return allEleves
            .filter { eleve in
                eleve.seat == nil
            }
            .sorted(using: sortComparators)
    }

    // MARK: - Méthodes Observation

    /// Retourne le nombre de `ObservEntity` associées aux élèves de la classe
    /// qui satisfont aux critères: `isConsignee` et `isVerified`
    /// - Parameters:
    ///   - isConsignee: si `nil` on ne filtre pas, sinon on filtre sur la valeur booléenne
    ///   - isVerified: si `nil` on ne filtre pas, sinon on filtre sur la valeur booléenne
    /// - Returns: Nombre des `ObservEntity` associées aux élèves de la classe
    func nbOfObservations(
        isConsignee  : Bool? = nil,
        isVerified   : Bool? = nil
    ) -> Int {
        let eleves = allEleves
        var total = 0

        switch (isConsignee, isVerified) {
            case (nil, nil):
                eleves.forEach { eleve in
                    total += eleve.nbOfObservs
                }

            case let(.some(c), nil):
                eleves.forEach { eleve in
                    total += eleve.nbOfObservations(isConsignee: c)
                }

            case let(nil, .some(v)):
                eleves.forEach { eleve in
                    total += eleve.nbOfObservations(isVerified: v)
                }

            case let(.some(c), .some(v)):
                eleves.forEach { eleve in
                    total += eleve.nbOfObservations(isConsignee: c,
                                                    isVerified: v)
                }
        }
        return total
    }

    /// Retourne la liste des `ObservEntity` associées aux élèves de la classe
    /// qui satisfont aux critères: `isConsignee` et `isVerified`
    /// - Parameters:
    ///   - isConsignee: si `nil` on ne filtre pas, sinon on filtre sur la valeur booléenne
    ///   - isVerified: si `nil` on ne filtre pas, sinon on filtre sur la valeur booléenne
    /// - Returns: Liste des `ObservEntity` associées aux élèves de la classe
    func filteredSortedObservations(
        isConsignee : Bool? = nil,
        isVerified  : Bool? = nil
    ) -> [ObservEntity] {
        var observs = [ObservEntity]()

        self.elevesSortedByName
            .forEach { eleve in
                observs += eleve.sortedObservations(isConsignee: isConsignee,
                                                    isVerified: isVerified)
            }

        return observs
    }

    // MARK: - Méthodes Colles

    /// Retourne le nombre de `ColleEntity` associées aux élèves de la classe
    /// qui satisfont aux critères: `isConsignee` et `isVerified`
    /// - Parameters:
    ///   - isConsignee: si `nil` on ne filtre pas, sinon on filtre sur la valeur booléenne
    ///   - isVerified: si `nil` on ne filtre pas, sinon on filtre sur la valeur booléenne
    /// - Returns: Nombre des `ColleEntity` associées aux élèves de la classe
    func nbOfColles(
        isConsignee : Bool?  = nil,
        isVerified  : Bool?  = nil
    ) -> Int {
        let eleves = allEleves
        var total = 0
        switch (isConsignee, isVerified) {
            case (nil, nil):
                eleves.forEach { eleve in
                    total += eleve.nbOfColles
                }

            case let(.some(c), nil):
                eleves.forEach { eleve in
                    total += eleve.nbOfColles(isConsignee: c)
                }

            case let(nil, .some(v)):
                eleves.forEach { eleve in
                    total += eleve.nbOfColles(isVerified: v)
                }

            case let(.some(c), .some(v)):
                eleves.forEach { eleve in
                    total += eleve.nbOfColles(isConsignee: c,
                                              isVerified: v)
                }
        }
        return total
    }

    /// Retourne la liste des `ColleEntity` associées aux élèves de la classe
    /// qui satisfont aux critères: `isConsignee` et `isVerified`
    /// - Parameters:
    ///   - isConsignee: si `nil` on ne filtre pas, sinon on filtre sur la valeur booléenne
    ///   - isVerified: si `nil` on ne filtre pas, sinon on filtre sur la valeur booléenne
    /// - Returns: Liste des `ColleEntity` associées aux élèves de la classe
    func filteredSortedColles(
        isConsignee : Bool? = nil,
        isVerified  : Bool? = nil
    ) -> [ColleEntity] {
        var observs = [ColleEntity]()

        self.elevesSortedByName
            .forEach { eleve in
                observs += eleve.sortedColles(isConsignee: isConsignee,
                                              isVerified: isVerified)
            }

        return observs
    }
}

// MARK: - Extension Debug

extension ClasseEntity {
    public override var description: String {
        """

        CLASSE: \(displayString)
           ID      : \(id)
           School  : \(String(describing: school?.displayString))
           Niveau  : \(levelString)
           Numéro  : \(numero)
           SEGPA   : \(segpa.frenchString)
           Heures  : \(heures)
           Flagged : \(isFlagged.frenchString)
           Appréciation: '\(viewAppreciation)'
           Annotation  : '\(viewAnnotation)'
           Nb élèves   : \(elevesCount)
        """
//           RoomID  : \(String(describing: roomId))
//           Eleves  : \(String(describing: elevesID).withPrefixedSplittedLines("     "))
//           Examens : \(String(describing: exams).withPrefixedSplittedLines("     "))
//        """
    }
}
