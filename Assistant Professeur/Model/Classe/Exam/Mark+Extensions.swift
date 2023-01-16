//
//  Mark+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 05/01/2023.
//

import Foundation
import CoreData
import AppFoundation

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

/// Un établissement scolaire
extension MarkEntity {

    // MARK: - Computed properties

    /// Wrapper of `markType`
    /// - Important: *Saves the context to the store after modification is done*
    var markTypeEnum: MarkEnum {
        get {
            MarkEnum(rawValue: self.markType) ?? .nonNote
        }
        set {
            if newValue == .note && newValue != markTypeEnum {
                self.mark = 0
            }
            self.markType = newValue.rawValue
            try? MarkEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `mark`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewMark: Double {
        get {
            self.mark
        }
        set {
            self.mark = newValue
            try? ExamEntity.saveIfContextHasChanged()
        }
    }
    
    // MARK: - Methods

    /// Modifie l'attribut `markType`
    func setmarkType(_ newMarkType: MarkEnum) {
        self.markType = newMarkType.rawValue
    }

}

// MARK: - Extension Core Data

extension MarkEntity: ModelEntityP {

    // MARK: - Type Computed Properties

    // MARK: - Type Methods

    @discardableResult
    static func create(
        pourEleve : EleveEntity,
        pourExam  : ExamEntity
    ) -> MarkEntity {
        let mark = MarkEntity.create()
        // Classe d'appartenance.
        // mandatory
        mark.eleve = pourEleve
        mark.exam  = pourExam

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
        }
    }

}

// MARK: - Extension Debug

extension MarkEntity {
    public override var description: String {
        """

        NOTE:
           Elève : \(String(describing: eleve?.displayName))
           Note  : \(mark)
           Type  : \(markTypeEnum.displayString)
        """
    }
}
