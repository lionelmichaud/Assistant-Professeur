//
//  Mark+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 05/01/2023.
//

import AppFoundation
import CoreData
import Foundation

enum MarkEnum: Int16, Codable {
    case nonNote
    case note
    case absent
    case disp
    case nonRendu
    case inapt
    case nonSignificatif
}

extension MarkEnum: PickableEnumP {
    public var pickerString: String {
        switch self {
            case .nonNote:
                return "Non noté"
            case .note:
                return "Noté"
            case .absent:
                return "Absent"
            case .disp:
                return "Dispensé"
            case .nonRendu:
                return "Non rendu"
            case .inapt:
                return "Inapte"
            case .nonSignificatif:
                return "Non significative"
        }
    }
}

/// Une note d'évaluation
extension MarkEntity {
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

    /// Wrapper of `markType`
    /// - Important: *Saves the context to the store after modification is done*
    var markTypeEnum: MarkEnum {
        get {
            MarkEnum(rawValue: self.markType) ?? .nonNote
        }
        set {
            if newValue == .note && newValue != markTypeEnum {
                self.mark = 0
                for idx in self.viewStepsMarks.indices {
                    self.viewStepsMarks[idx] = 0.0
                }
            }
            self.markType = newValue.rawValue
            try? MarkEntity.saveIfContextHasChanged()
        }
    }

    /// Retourne la note obtenue par un élève `mark.eleve` à
    /// un examen `mark.exam`.
    ///
    /// Si la note est **échelonnée**, retourne la somme des notes obtenues
    /// à chaque étape.
    ///
    /// Wrapper of `mark`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewMark: Double {
        get {
            switch self.examTypeEnum {
                case .global:
                    return self.mark
                case .multiStep:
                    return viewStepsMarks.sum()
            }
        }
        set {
            self.mark = newValue
            try? ExamEntity.saveIfContextHasChanged()
        }
    }

    // MARK: - Methods

    /// Modifie l'attribut `mark`
    func setMark(_ newMark: Double) {
        self.mark = newMark
    }

    /// Modifie l'attribut `markType`
    func setMarkType(_ newMarkType: MarkEnum) {
        self.markType = newMarkType.rawValue
    }

    /// Modifie l'attribut `examType`
    /// - Important: *Does NOT save the context to the store after modification is done*
    func setExamTypeEnum(_ newExamType: ExamTypeEnum) {
        self.examType = newExamType.rawValue
    }
}

// MARK: - Extension Core Data

extension MarkEntity: ModelEntityP {
    // MARK: - Type Computed Properties

    // MARK: - Type Methods

    @discardableResult
    static func create(
        pourEleve: EleveEntity,
        pourExam: ExamEntity
    ) -> MarkEntity {
        let mark = MarkEntity.create()
        // Classe d'appartenance.
        // mandatory
        mark.eleve = pourEleve
        mark.exam = pourExam

        try? MarkEntity.saveIfContextHasChanged()
        return mark
    }

    static func checkConsistency(errorFound: inout Bool) {
        all().forEach { mark in
            guard mark.eleve != nil else {
                errorFound = true
                return
            }
            guard mark.exam != nil else {
                errorFound = true
                return
            }
            // note échelonnée si exam échelonné
            guard mark.examTypeEnum == mark.exam?.examTypeEnum else {
                errorFound = true
                return
            }
            // si note échelonnée alors une note pour un step
            guard mark.nbOfSteps == mark.exam?.nbOfSteps else {
                errorFound = true
                return
            }
        }
    }

    // MARK: - Methods

    @discardableResult
    static func createGlobalMark(
        of eleve: EleveEntity,
        for exam: ExamEntity
    ) -> MarkEntity {
        let mark = MarkEntity.create()
        mark.setExamTypeEnum(.global)
        mark.eleve = eleve
        mark.exam = exam
        return mark
    }

    @discardableResult
    static func createSteppedMark(
        of eleve: EleveEntity,
        for exam: ExamEntity
    ) -> MarkEntity {
        let mark = MarkEntity.create()
        mark.setExamTypeEnum(.multiStep)
        mark.eleve = eleve
        mark.exam = exam

        // initialiser les notes de chaque étapes de l'évaluation
        let nbOfSteps = exam.viewSteps.count
        mark.viewStepsMarks = [Double].init(repeating: 0.0, count: nbOfSteps)

        return mark
    }

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set defaults here
        self.id = UUID()
    }
}

// MARK: - Extension Notes Echelonnées

extension MarkEntity {
    /// Wrapper of `steps`: [note] avec note dans [0.0, exam.step.points]
    /// - Important: *Saves the context to the store after modification is done*
    var viewStepsMarks: [Double] {
        get {
            switch self.examTypeEnum {
                case .global:
                    return []
                case .multiStep:
                    if let steps {
                        let data = Data(steps.utf8)
                        return (try? JSONDecoder().decode([Double].self, from: data)) ?? []
                    } else {
                        return []
                    }
            }
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue),
                  let string = String(data: data, encoding: .utf8) else {
                self.steps = ""
                return
            }
            self.steps = string
            try? MarkEntity.saveIfContextHasChanged()
        }
    }

    /// Modifie l'attribut `steps`: [note] avec note dans [0.0, 1.0]
    /// - Important: *Does NOT save the context to the store after modification is done*
    func setStepsMarks(_ steps: [Double]) {
        guard let data = try? JSONEncoder().encode(steps),
              let string = String(data: data, encoding: .utf8) else {
            self.steps = ""
            return
        }
        self.steps = string
    }

    /// Nombre d'étapes de cette évaluation.
    var nbOfSteps: Int? {
        viewStepsMarks.count
    }
}

// MARK: - Extension Debug

public extension MarkEntity {
    override var description: String {
        """

        NOTE:
           Elève : \(String(describing: eleve?.displayName))
           Note  : \(mark)
           Type  : \(markTypeEnum.displayString)
        """
    }
}
