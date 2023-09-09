//
//  Classe+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/11/2022.
//

import CoreData
import os
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "ClasseEntity"
)

/// Une classe d'élèves
extension ClasseEntity {
    // MARK: - Computed properties

    /// Nom de l'image par défaut utilisée pour représenter un établissement
    static var defaultImageName: String {
        "person.3.sequence.fill"
    }

    /// Wrapper of `discipline`
    /// - Important: *Saves the context to the store after modification is done*
    var disciplineEnum: Discipline {
        get {
            if let discipline {
                return Discipline(rawValue: discipline) ?? .technologie
            } else {
                return .technologie
            }
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

    /// Nombre de documents importants dans l'établissement
    var nbOfDocuments: Int {
        Int(self.documentsCount)
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
    /// - Important: *Does NOT save the context to the store after modification is done*
    func setDiscipline(_ newDiscipline: Discipline) {
        self.discipline = newDiscipline.rawValue
    }

    /// Modifie l'attribut `level`
    /// - Important: *Does NOT save the context to the store after modification is done*
    func setLevel(_ newLevel: LevelClasse) {
        self.level = newLevel.rawValue
    }

    /// Modifie l'attribut `room`
    /// - Important: *Does NOT save the context to the store after modification is done*
    func setRoom(_ newRoom: RoomEntity) {
        guard let school = newRoom.school,
              school == self.school else {
            return
        }
        self.room = newRoom
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

extension ClasseEntity {
    // MARK: - Type Computed Properties

    static var bySchoolThenClasseLevelNumberNSSortDescriptor: [NSSortDescriptor] =
        [
            // school
            NSSortDescriptor(
                keyPath: \ClasseEntity.school?.level,
                ascending: true
            ),
            NSSortDescriptor(
                keyPath: \ClasseEntity.school?.name,
                ascending: true
            ),
            // classe
            NSSortDescriptor(
                keyPath: \ClasseEntity.level,
                ascending: false
            ),
            NSSortDescriptor(
                keyPath: \ClasseEntity.numero,
                ascending: true
            ),
            NSSortDescriptor(
                keyPath: \ClasseEntity.segpa,
                ascending: true
            )
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

    // MARK: - Computed Properties Sequences

    /// Retourne la liste des séquences suivies par une classe triée.
    ///
    /// Ordre de tri :
    ///   1. Numéro de Séquence
    var allFollowedSequencesSortedBySequenceNumber: [SequenceEntity] {
        let sortComparators = [
            SortDescriptor(\SequenceEntity.number, order: .forward)
        ]
        var seqSet = Set<SequenceEntity>()
        allProgresses.forEach { progress in
            if let seq = progress.activity?.sequence {
                seqSet.update(with: seq)
            }
        }
        return Array(seqSet)
            .sorted(using: sortComparators)
    }

    // MARK: - Computed Properties Progresses

    /// Nombre de progressions pour cette classe.
    var nbOfProgresses: Int {
        Int(progressCount)
    }

    /// Liste des progressions des classes pour cette classe non triées
    var allProgresses: [ActivityProgressEntity] {
        if let progresses {
            return (progresses.allObjects as! [ActivityProgressEntity])
        } else {
            return []
        }
    }

    /// Retourne la liste des progressions de la classe.
    /// Les progressions trouvées sont triées.
    ///
    /// Ordre de tri :
    ///   1. Numéro de Séquence
    ///   2. Numéro d'Activité
    var allProgressesSortedBySequenceActivityNumber: [ActivityProgressEntity] {
        let sortComparators = [
            SortDescriptor(\ActivityProgressEntity.activity?.sequence?.number, order: .forward),
            SortDescriptor(\ActivityProgressEntity.activity?.number, order: .forward)
        ]

        return allProgresses
            .sorted(using: sortComparators)
    }

    /// Retourne l'activité en cours de cette classe.
    ///
    /// Si plusieurs activités sont en cours dans plusieurs séquences différentes alors
    /// c'est l'activité de la séquence de plus petit numéro qui est retournée.
    var currentActivity: ActivityEntity? {
        let progresses = allProgressesSortedBySequenceActivityNumber
        for idx in progresses.indices {
            if progresses[idx].status == .inProgress {
                return progresses[idx].activity

            } else if idx > progresses.startIndex &&
                progresses[idx - 1].status == .completed &&
                progresses[idx].status == .notStarted {
                return progresses[idx].activity
            }
        }
        if progresses.allSatisfy({ $0.status == .notStarted }) {
            return progresses.first?.activity
        }
        return nil
    }

    // MARK: - Computed Properties Documents

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

    // MARK: - Computed Properties Groups

    /// Liste des élèves de la classe non triées
    var allGroups: [GroupEntity] {
        if let groups {
            return (groups.allObjects as! [GroupEntity])
        } else {
            return []
        }
    }

    /// Retourne la liste des groupes de la classe.
    /// Les groupes trouvés sont triés par numéro.
    ///
    /// Ordre de tri :
    ///   1. Numéro de groupe
    var allGroupsSortedByNumber: [GroupEntity] {
        let sortComparators = [
            SortDescriptor(\GroupEntity.number, order: .forward)
        ]

        return allGroups
            .sorted(using: sortComparators)
    }

    /// Retourne le groupe 0 d'élèves non affectés à un groupe.
    var groupOfUngroupedEleves: GroupEntity {
        if let foundGroup = self.allGroups.first(where: { $0.number == 0 }) {
            return foundGroup
        } else {
            customLog.log(
                level: .fault,
                "groupOfUngroupedEleves: le groupe 0 n'existe pas"
            )
            fatalError()
        }
    }

    // MARK: - Computed Properties Exams

    /// Liste des évaluations de la classe non triées
    var allExams: [ExamEntity] {
        if let exams {
            return (exams.allObjects as! [ExamEntity])
        } else {
            return []
        }
    }

    /// Liste des évaluations de la classe triés par date
    var examsSortedByDate: [ExamEntity] {
        let sortComparators =
            [
                SortDescriptor(\ExamEntity.dateExecuted, order: .reverse)
            ]
        return allExams.sorted(using: sortComparators)
    }

    // MARK: - Computed Properties Elèves

    /// Liste des élèves de la classe non triées
    var allEleves: [EleveEntity] {
        if let eleves {
            return (eleves.allObjects as! [EleveEntity])
        } else {
            return []
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

    // MARK: - Type Methods

    /// Créer une nouvelle classe et l'ajouter à l'établissement `school`
    /// - Important: Sauvegarder le Context.
    @discardableResult
    static func create( // swiftlint:disable:this function_parameter_count
        level: LevelClasse,
        numero: Int,
        segpa: Bool,
        discipline: Discipline,
        heures: Double,
        isFlagged: Bool,
        annotation: String = "",
        appreciation: String = "",
        dans school: SchoolEntity?
    ) -> ClasseEntity {
        let classe = ClasseEntity.create()
        // Etablissement d'appartenance.
        // mandatory
        classe.school = school

        // créer un Groupe 0 pour les élèves de la classe
        // n'appartenant à aucun groupe.
        // mandatory
        GroupEntity.create(numero: 0, dans: classe)

        classe.level = level.rawValue
        classe.numero = Int32(numero)
        classe.segpa = segpa
        classe.discipline = discipline.rawValue
        classe.heures = heures
        classe.isFlagged = isFlagged
        classe.annotation = annotation
        classe.appreciation = appreciation

        // Créer une progression pour chaque activité
        ProgramManager
            .activitiesAssociatedTo(thisClasse: classe)
            .forEach { activity in
                print("**\(activity.viewName)** pour \(classe.displayString)")
                ActivityProgressEntity.create(
                    forClasse: classe,
                    forActivity: activity
                )
            }

        try? ClasseEntity.saveIfContextHasChanged()
        return classe
    }

    /// Check the correctness and consistency of all database entities of this type.
    /// - Parameters:
    ///   - errorList: Liste des erreurs trouvées.
    static func checkConsistency(
        errorList: inout DataBaseErrorList,
        tryToRepair: Bool
    ) {
        all().forEach { classe in
            if classe.school == nil {
                if tryToRepair {
                    do {
                        // la destruction est sauvegardée
                        try classe.delete()
                    } catch {
                        errorList.append(DataBaseError.noOwner(
                            entity: Self.entity().name!,
                            name: classe.displayString,
                            id: classe.id
                        ))
                    }
                } else {
                    errorList.append(DataBaseError.noOwner(
                        entity: Self.entity().name!,
                        name: classe.displayString,
                        id: classe.id
                    ))
                }
            }

            if classe.segpa && classe.school?.levelEnum != .college {
                errorList.append(DataBaseError.internalInconsistency(
                    entity: Self.entity().name!,
                    name: classe.displayString,
                    attribute1: "segpa",
                    attribute2: "school",
                    id: classe.id
                ))
            }
        }
    }

    // MARK: - Methods

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set defaults here
        self.id = UUID()
    }

    // MARK: - Methods Progresses

    /// Retourne la liste des progresssions d'activités de la classe dans la séquence sélectionnée triée
    ///
    /// Ordre de tri des progressions:
    ///   1. Numéro d'activité
    func sortedProgressesInSequence(_ sequence: SequenceEntity) -> [ActivityProgressEntity] {
        let sortComparators = [
            SortDescriptor(\ActivityProgressEntity.activity?.number, order: .forward)
        ]

        return allProgressesSortedBySequenceActivityNumber
            .filter { progress in
                progress.activity?.sequence == sequence
            }
            .sorted(using: sortComparators)
    }

    /// Retourne la progression réelle (en % de temps) de la classe pour la séquence sélectionnée.
    func actualProgressInSequence(_ sequence: SequenceEntity) -> Double {
        let progressesInSequence = self.sortedProgressesInSequence(sequence)
        let nbOfSeanceInSequence = sequence.durationWithoutMargin
        let nbOfSeanceCompleted: Double = progressesInSequence.reduce(0.0) {
            $0 + $1.progress * ($1.activity?.duration ?? 0)
        }
        if nbOfSeanceInSequence == 0 {
            return 0
        } else {
            return nbOfSeanceCompleted / nbOfSeanceInSequence
        }
    }

    /// Retourne la progression réelle (en % de temps) de la classe dans le programme annuel.
    ///
    /// Return:
    /// * **nbOfSeanceActualyCompleted**: nombre de séance réellement complétées.
    /// * **nbOfSeanceInProgram**: nombre de séance totales contenus dans le programme.
    /// * **actualProgress**: avancement réel courant [0, 1].
    func actualProgressInProgram() ->
        (
            nbOfSeanceActualyCompleted: Double,
            nbOfSeanceInProgram: Double,
            actualProgress: Double // [0, 1]
        ) {
        let sequencesInProgram = self.allFollowedSequencesSortedBySequenceNumber
        let (nbOfSeanceInProgram, nbOfSeanceCompleted): (Double, Double) =
            sequencesInProgram
                .reduce((0.0, 0.0)) { nb, sequence in
                    (
                        nb.0 + sequence.durationWithoutMargin,
                        nb.1 + actualProgressInSequence(sequence) * sequence.durationWithoutMargin
                    )
                }
        var actualProgress = 0.0
        if nbOfSeanceInProgram != 0 {
            actualProgress = nbOfSeanceCompleted / nbOfSeanceInProgram
        }

        return (
            nbOfSeanceActualyCompleted: nbOfSeanceCompleted,
            nbOfSeanceInProgram: nbOfSeanceInProgram,
            actualProgress: actualProgress
        )
    }

    /// Retourne la progression théorique (en % de temps) de la classe dans le programme annuel à la date courante.
    ///
    /// Return:
    /// * **nbOfSeanceSuposidelyCompleted**: nombre de séance supposées complétées à la date courante.
    /// * **nbOfSeanceInProgram**: nombre de séance totales contenus dans le programme.
    /// * **theoricalProgress**: avancement théorique à la date courantet [0, 1].
    func theoricalProgressInProgram() ->
        (
            nbOfSeanceSuposidelyCompleted: Double,
            nbOfSeanceInProgram: Double,
            theoricalProgress: Double // [0, 1]
        ) {
        guard let program = ProgramManager.programAssociatedTo(thisClasse: self) else {
            customLog.log(
                level: .error,
                "Pas de programme associé à la classe \(self.displayString)"
            )
            return (
                nbOfSeanceSuposidelyCompleted: 0,
                nbOfSeanceInProgram: 0,
                theoricalProgress: 0
            )
        }

        // Nombre de séances qui devraient être complétées à la date courante
        let nbOfSeanceSuposidlyCompleted = ProgramManager.nbOfSeanceSuposidlyCompleted(
            program: program,
            schoolYear: UserPrefEntity.shared.viewSchoolYearPref,
            atThisDate: Date.now
        )

        let sequencesInProgram = self.allFollowedSequencesSortedBySequenceNumber
        let nbOfSeanceInProgram: Double =
            sequencesInProgram
                .reduce(0.0) { nb, sequence in
                    nb + sequence.durationWithoutMargin
                }

        //print(nbOfSeanceInProgram, nbOfSeanceSuposidlyCompleted)

        var theoricalProgress = 0.0
        if nbOfSeanceInProgram != 0 {
            theoricalProgress = nbOfSeanceSuposidlyCompleted / nbOfSeanceInProgram
        }

        return (
            nbOfSeanceSuposidelyCompleted: nbOfSeanceSuposidlyCompleted,
            nbOfSeanceInProgram: nbOfSeanceInProgram,
            theoricalProgress: theoricalProgress
        )
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
    ///   - searchString: caractères à rechercher dans les **noms/prénom/groupe/annotation/appréciation** à rechercher
    ///   - withObservation: si `true` alors ne conserver que les élèves avec des observation **non-consignées** OU **non-vérifiées**
    ///   - withColle: si `true` alors ne conserver que que les élèves avec des colles **non-consignées**
    ///   - withFlag: si `true` alors ne conserver que que les élèves **flagés**
    /// - Returns: Liste des élèves de la classe satisfaisant *au moins à l'un des critères* définis en paramètre
    func filteredElevesSortedByName(
        searchString: String,
        withObservation: Bool = false,
        withColle: Bool = false,
        withFlag: Bool = false
    ) -> [EleveEntity] {
        let sortComparators = UserPrefEntity.shared.nameSortOrderEnum == .nomPrenom ?
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
                lazy var nbObservWithActionToDo: Int = eleve.nbOfObservations(
                    isConsignee: false,
                    isVerified: false
                )

                lazy var nbColleWithActionToDo: Int = eleve.nbOfColles(isConsignee: false)

                return eleve.satisfiesTo(searchString: searchString) &&
                    ((!withObservation && !withColle && !withFlag) ||
                        (withObservation && (nbObservWithActionToDo > 0)) ||
                        (withColle && nbColleWithActionToDo > 0) ||
                        (withFlag && eleve.isFlagged))
            }
            .sorted(using: sortComparators)
    }

    /// Retourne la liste des élèves de la classe dont les nom ou prénom contiennent `searchString`.
    ///
    /// Les élèves trouvés sont triés en utilisant `sortOrder`.
    func filteredSortedEleves(
        searchString: String,
        sortOrder: [KeyPathComparator<EleveEntity>]
    ) -> [EleveEntity] {
        guard searchString.isNotEmpty else {
            return allEleves.sorted(using: sortOrder)
        }

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
        let sortComparators = UserPrefEntity.shared.nameSortOrderEnum == .nomPrenom ?
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
        isConsignee: Bool? = nil,
        isVerified: Bool? = nil
    ) -> Int {
        let eleves = allEleves
        var total = 0

        switch (isConsignee, isVerified) {
            case (nil, nil):
                eleves.forEach { eleve in
                    total += eleve.nbOfObservs
                }

            case let (.some(c), nil):
                eleves.forEach { eleve in
                    total += eleve.nbOfObservations(isConsignee: c)
                }

            case let (nil, .some(v)):
                eleves.forEach { eleve in
                    total += eleve.nbOfObservations(isVerified: v)
                }

            case let (.some(c), .some(v)):
                eleves.forEach { eleve in
                    total += eleve.nbOfObservations(
                        isConsignee: c,
                        isVerified: v
                    )
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
        isConsignee: Bool? = nil,
        isVerified: Bool? = nil
    ) -> [ObservEntity] {
        var observs = [ObservEntity]()

        self.elevesSortedByName
            .forEach { eleve in
                observs += eleve.sortedObservations(
                    isConsignee: isConsignee,
                    isVerified: isVerified
                )
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
        isConsignee: Bool? = nil,
        isVerified: Bool? = nil
    ) -> Int {
        let eleves = allEleves
        var total = 0
        switch (isConsignee, isVerified) {
            case (nil, nil):
                eleves.forEach { eleve in
                    total += eleve.nbOfColles
                }

            case let (.some(c), nil):
                eleves.forEach { eleve in
                    total += eleve.nbOfColles(isConsignee: c)
                }

            case let (nil, .some(v)):
                eleves.forEach { eleve in
                    total += eleve.nbOfColles(isVerified: v)
                }

            case let (.some(c), .some(v)):
                eleves.forEach { eleve in
                    total += eleve.nbOfColles(
                        isConsignee: c,
                        isVerified: v
                    )
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
        isConsignee: Bool? = nil,
        isVerified: Bool? = nil
    ) -> [ColleEntity] {
        var observs = [ColleEntity]()

        self.elevesSortedByName
            .forEach { eleve in
                observs += eleve.sortedColles(
                    isConsignee: isConsignee,
                    isVerified: isVerified
                )
            }

        return observs
    }
}

// MARK: - Extension Debug

public extension ClasseEntity {
    override var description: String {
        """

        CLASSE: \(displayString)
           ID      : \(String(describing: id))
           School  : \(String(describing: school?.displayString))
           Niveau  : \(levelString)
           Numéro  : \(numero)
           SEGPA   : \(segpa.frenchString)
           Flagged : \(isFlagged.frenchString)
           Appréciation : '\(viewAppreciation)'
           Annotation   : '\(viewAnnotation)'
           Discipline   : \(disciplineEnum)
           Heures       : \(heures)
           Nb élèves    : \(nbOfEleves)
           Nb documents : \(nbOfDocuments)
           RoomID  : \(String(describing: room))
           Examens : \(String(describing: examsSortedByDate).withPrefixedSplittedLines("     "))
           Eleves  : \(String(describing: elevesSortedByName).withPrefixedSplittedLines("     "))
        """
//        """
    }
}
