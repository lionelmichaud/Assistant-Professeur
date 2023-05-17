//
//  Exam+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/01/2023.
//

import CoreData
import SwiftUI

/// Un établissement scolaire
extension ExamEntity {
    // MARK: - Computed properties

    /// Wrapper of `examType`
    /// - Important: *Saves the context to the store after modification is done*
    var examTypeEnum: ExamTypeEnum {
        get {
            if let examType {
                return ExamTypeEnum(rawValue: examType) ?? .global
            } else {
                return .global
            }
        }
        set {
            self.examType = newValue.rawValue
            try? ExamEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `sujet`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewSujet: String {
        get {
            self.sujet ?? ""
        }
        set {
            self.sujet = newValue
            try? ExamEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `dateExecuted`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewDateExecuted: Date {
        get {
            self.dateExecuted ?? Date.now
        }
        set {
            self.dateExecuted = newValue
            try? ExamEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `maxMark`
    /// - Warning: > 0
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewMaxMark: Int {
        get {
            switch self.examTypeEnum {
                case .global:
                    return Int(self.maxMark)
                case .multiStep:
                    return viewSteps.sum(for: \.points)
            }
        }
        set {
            self.maxMark = Int16(newValue)
            try? ExamEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `coef`
    /// - Warning: > 0
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewCoef: Double {
        get {
            self.coef
        }
        set {
            self.coef = newValue
            try? ExamEntity.saveIfContextHasChanged()
        }
    }

    /// Nombre de notes de cette évaluation.
    /// En principe, autant que d'élèves dans la classe associée à cette évaluation.
    var nbOfMarks: Int {
        Int(marksCount)
    }

    // MARK: - Methods

    /// Modifie l'attribut `examType`
    /// - Important: *Does NOT save the context to the store after modification is done*
    func setExamTypeEnum(_ newExamType: ExamTypeEnum) {
        self.examType = newExamType.rawValue
    }

    /// Modifie l'attribut `examType`
    /// - Important: *Does NOT save the context to the store after modification is done*
    func setSujet(_ sujet: String) {
        self.sujet = sujet
    }

    /// Modifie l'attribut `dateExecuted`
    /// - Important: *Does NOT save the context to the store after modification is done*
    func setDateExecuted(_ date: Date) {
        self.dateExecuted = date
    }

    /// Modifie l'attribut `coef`
    /// - Important: *Does NOT save the context to the store after modification is done*
    func setCoef(_ coef: Double) {
        self.coef = coef
    }

    /// Alouer une note à un élève pour une évaluation globale
    /// - Parameters:
    ///   - eleve: élève
    ///   - markType: type de note
    ///   - mark: la valeur de la note si `markType` ==  `.note`
    func setGlobalMark(
        of eleve: EleveEntity,
        markType: MarkEnum,
        mark: Double? = nil
    ) {
        guard self.examTypeEnum == .global else {
            return
        }

        let m = self.allMarks.first { mark in
            mark.eleve == eleve
        }

        m?.setMarkType(markType)
        if markType == .note, let mark {
            m?.setMark(mark)
        }

        try? MarkEntity.saveIfContextHasChanged()
    }

    /// Alouer une note à un élève pour une évaluation échelonnée
    /// - Parameters:
    ///   - eleve: élève
    ///   - markType: type de note
    ///   - mark: la valeur de la note si `markType` ==  `.note`
    func setSteppedMark(
        of eleve: EleveEntity,
        markType: MarkEnum,
        marks: [Double]? = nil
    ) {
        guard examTypeEnum == .multiStep else {
            return
        }
        guard markType != .note || nbOfSteps == marks?.count else {
            return
        }

        let m = allMarks.first { mark in
            mark.eleve == eleve
        }

        m?.setMarkType(markType)
        if markType == .note, let marks {
            m?.setStepsMarks(marks)
        }

        try? MarkEntity.saveIfContextHasChanged()
    }
}

// MARK: - Extension Notes Echelonnées

extension ExamEntity {
    // MARK: - Properties

    /// Wrapper of `steps`
    /// - Important: *Saves the context to the store after modification is done*
    var viewSteps: StepsArray {
        get {
            switch self.examTypeEnum {
                case .global:
                    return []
                case .multiStep:
                    return getSteps(fromString: steps)
            }
        }
        set {
            setSteps(newValue)
            try? ExamEntity.saveIfContextHasChanged()
        }
    }

    /// Décode l'attribut `steps` à partir d'une String `fromString`au format JSON.
    func getSteps(fromString stepString: String?) -> StepsArray {
        if let stepString {
            let data = Data(stepString.utf8)
            return (try? JSONDecoder().decode(StepsArray.self, from: data)) ?? []
        } else {
            return []
        }
    }

    /// Modifie l'attribut `steps` en encodant les étapes au format JSON.
    /// - Important: *Does NOT save the context to the store after modification is done*
    func setSteps(_ steps: StepsArray) {
        guard let data = try? JSONEncoder().encode(steps),
              let string = String(data: data, encoding: .utf8) else {
            self.steps = ""
            return
        }
        self.steps = string
    }

    /// Nombre d'étapes de cette évaluation.
    var nbOfSteps: Int {
        viewSteps.count
    }

    /// Créer une nouvelle évaluation **globale** pour une classe d'élèves
    ///
    /// Crée une note par défaut pour chaque élève de la classe.
    /// - Parameter classe: Classe pour laquelle l'évaluation est créée
    /// - Returns: L'évaluation créée.
    ///
    /// - Important: The context has changes and **is commited**
    @discardableResult
    static func createGlobalExam(
        sujet: String = "",
        coef: Double = 1.0,
        maxMark: Int = 20,
        dateExecuted: Date = Date.now,
        pour classe: ClasseEntity
    ) -> ExamEntity {
        let exam = ExamEntity.create()
        exam.classe = classe

        exam.setExamTypeEnum(.global)
        exam.setSujet(sujet)
        exam.setCoef(coef)
        exam.setDateExecuted(dateExecuted)
        exam.maxMark = Int16(maxMark)

        // Créer une note pour chaque élève auquel s'applique cette évaluation
        let eleves = classe.allEleves
        eleves.forEach { eleve in
            MarkEntity.create(pourEleve: eleve, pourExam: exam)
        }

        try? ExamEntity.saveIfContextHasChanged()

        return exam
    }

    /// Créer une nouvelle évaluation **échelonnée** pour une classe d'élèves
    ///
    /// Crée une note par défaut pour chaque élève de la classe.
    /// - Parameter classe: Classe pour laquelle l'évaluation est créée
    /// - Returns: L'évaluation créée.
    ///
    /// - Important: The context has changes and **is commited**
    @discardableResult
    static func createSteppedExam(
        sujet: String = "",
        coef: Double = 1.0,
        examSteps: [ExamStep] = [],
        dateExecuted: Date = Date.now,
        pour classe: ClasseEntity
    ) -> ExamEntity {
        let exam = ExamEntity.create()
        exam.classe = classe

        exam.setExamTypeEnum(.multiStep)
        exam.setSujet(sujet)
        exam.setCoef(coef)
        exam.setDateExecuted(dateExecuted)
        exam.setSteps(examSteps)
        // la note maxi est la somme des points maxi de chaque étape
        exam.maxMark = Int16(examSteps.sum(for: \.points))

        let eleves = classe.allEleves
        eleves.forEach { eleve in
            MarkEntity.create(pourEleve: eleve, pourExam: exam)
        }

        try? ExamEntity.saveIfContextHasChanged()

        return exam
    }
}

// MARK: - Extension Core Data

extension ExamEntity {
    // MARK: - Type Properties

    static var pref: ObservedObject<UserPreferences>.Wrapper!

    // MARK: - Type Methods

    /// Check the correctness and consistency of all database entities of this type.
    /// - Parameters:
    ///   - errorList: Liste des erreurs trouvées.
    static func checkConsistency(
        errorList: inout DataBaseErrorList,
        tryToRepair: Bool
    ) {
        all().forEach { exam in
            if exam.classe == nil {
                if tryToRepair {
                    do {
                        // la destruction est sauvegardée
                        try exam.delete()
                    } catch {
                        errorList.append(DataBaseError.noOwner(
                            entity: Self.entity().name!,
                            name: exam.viewSujet,
                            id: exam.id
                        ))
                    }
                } else {
                    errorList.append(DataBaseError.noOwner(
                        entity: Self.entity().name!,
                        name: exam.viewSujet,
                        id: exam.id
                    ))
                }
            }

            if exam.viewMaxMark.isNOZ {
                errorList.append(DataBaseError.outOfBound(
                    entity: Self.entity().name!,
                    name: exam.viewSujet,
                    attribute: "maxMark",
                    id: exam.id
                ))
            }
            if exam.viewCoef.isNOZ {
                errorList.append(DataBaseError.outOfBound(
                    entity: Self.entity().name!,
                    name: exam.viewSujet,
                    attribute: "coef",
                    id: exam.id
                ))
            }
        }
    }

    // MARK: - Computed Properties

    /// Liste des notes de l'évaluation non triées
    var allMarks: [MarkEntity] {
        if let marks {
            return (marks.allObjects as! [MarkEntity])
        } else {
            return []
        }
    }

    /// Liste des notes des élèves de la classe triése par nom des élèves.
    ///
    /// Ordre de tri selon la préférence `.nameSortOrder`:
    ///   1. Nom / Prénom
    ///   2. Prénon / Nom
    var marksSortedByEleveName: [MarkEntity] {
        sortedMarksByEleveName(searchString: "")
    }

    // MARK: - Methods

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set defaults here
        self.id = UUID()
    }

    /// Retourne la liste des notes des élèves de la classe satisfaisant *au moins à l'un des critères* définis en paramètre.
    /// Les notes sont triées par nom de l'élève associé.
    ///
    /// Ordre de tri selon la préférence `.nameSortOrder`:
    ///   1. Nom / Prénom
    ///   2. Prénon / Nom
    ///
    /// - Parameters:
    ///   - searchString: caractères à rechercher dans les noms/prénom ou nombre à rechercher dans le n° de groupe
    /// - Returns: Liste des notes des élèves de la classe satisfaisant *au moins à l'un des critères* définis en paramètre
    func sortedMarksByEleveName(searchString: String = "") -> [MarkEntity] {
        let sortComparators = ExamEntity.pref.nameSortOrder.wrappedValue == .nomPrenom ?
            [
                SortDescriptor(\MarkEntity.eleve?.familyName, order: .forward),
                SortDescriptor(\MarkEntity.eleve?.givenName, order: .forward)
            ] :
            [
                SortDescriptor(\MarkEntity.eleve?.givenName, order: .forward),
                SortDescriptor(\MarkEntity.eleve?.familyName, order: .forward)
            ]

        return allMarks
            .filter { mark in
                if let eleve = mark.eleve {
                    return eleve.satisfiesTo(searchString: searchString)
                } else {
                    return false
                }
            }
            .sorted(using: sortComparators)
    }
}

// MARK: - Extension Debug

public extension ExamEntity {
    override var description: String {
        """

        EVALUATION: \(viewSujet)
           ID          : \(String(describing: id))
           Date        : \(dateExecuted.stringShortDate)
           Noté sur    : \(maxMark)
           Coefficient : \(coef.formatted(.number.precision(.fractionLength(2))))
           Nombre de notes : \(nbOfMarks)
           Notes: \(String(describing: sortedMarksByEleveName()).withPrefixedSplittedLines("     "))
        """
    }
}
