//
//  Classe+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/11/2022.
//

import Foundation
import CoreData

/// Une classe d'élèves
extension ClasseEntity {

    // MARK: - Computed properties

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

    /// Toggle l'attribut `segpa` de la classe
    /// - Important: *Saves the context to the store after modification is done*
    func toggleSegpa() {
        segpa.toggle()
        try? ClasseEntity.saveIfContextHasChanged()
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
        false
//        roomId != nil
    }

    /// Nombre d'élèves dans la Classe
    var nbOfEleves: Int {
        Int(elevesCount)
    }

    var nbOfExams: Int {
        0
//        exams.count
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

}

// MARK: - Extension Core Data

extension ClasseEntity: ModelEntityP {

    // MARK: - Type Properties

    @Preference(\.nameSortOrder)
    static private var nameSortOrder

    @Preference(\.nameDisplayOrder)
    static private var nameDisplayOrder

    // MARK: - Type Computed Properties

    static var bySchoolnameLevelNumberNSSortDescriptor: [NSSortDescriptor] = [
        NSSortDescriptor(
            keyPath: \ClasseEntity.school?.level,
            ascending: true),
        NSSortDescriptor(
            keyPath: \ClasseEntity.school?.name,
            ascending: true),
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

    /// Liste de toutes les classes triées.
    ///
    /// Ordre de tri:
    ///   1. Type d'école
    ///   2. Nom de l'école
    ///   3. Niveau de la Classe
    ///   4. Numéro de la Classe
    ///   5. SGPA ou non
    static var requestAllSortedBySchoolnameLevelNumber: NSFetchRequest<ClasseEntity> {
        let request = ClasseEntity.fetchRequest()
        request.sortDescriptors = ClasseEntity.bySchoolnameLevelNumberNSSortDescriptor
        return request
    }

    // MARK: - Computed Properties

    /// Liste des élèves de la classe triés par nom.
    ///
    /// Ordre de tri selon la préférence `.nameSortOrder`:
    ///   1. Nom / Prénom
    ///   2. Prénon / Nom
    var elevesSortedByName: [EleveEntity] {
        let sortComparators = ClasseEntity.nameSortOrder == .nomPrenom ?
        [
            SortDescriptor(\EleveEntity.familyName, order: .forward),
            SortDescriptor(\EleveEntity.givenName, order: .forward)
        ] :
        [
            SortDescriptor(\EleveEntity.givenName, order: .forward),
            SortDescriptor(\EleveEntity.familyName, order: .forward)
        ]

        return (self.eleves?.allObjects as! [EleveEntity])
            .sorted(using: sortComparators)
    }
}

// MARK: - Extension Debug

extension ClasseEntity {
    public override var description: String {
        """

        CLASSE: \(displayString)
           ID      : \(id)
           Niveau  : \(levelString)
           Numéro  : \(numero)
           SEGPA   : \(segpa.frenchString)
           Heures  : \(heures)
           Flagged : \(isFlagged.frenchString)
           Appréciation: \(viewAppreciation)
           Annotation  : \(viewAnnotation)
        """
//           SchoolID: \(String(describing: schoolId))
//           RoomID  : \(String(describing: roomId))
//           Eleves  : \(String(describing: elevesID).withPrefixedSplittedLines("     "))
//           Examens : \(String(describing: exams).withPrefixedSplittedLines("     "))
//        """
    }
}
