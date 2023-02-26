//
//  ActivityProgress+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 15/02/2023.
//

import CoreData
import Foundation

/// La progression d'une classe dans une activité scolaire
extension ActivityProgressEntity {
    // MARK: - Computed properties

    /// Wrapper of `progress`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewProgress: Double {
        get {
            return progress
        }
        set {
            self.progress = newValue
            try? ActivityProgressEntity
                .saveIfContextHasChanged()
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
            try? ActivityProgressEntity
                .saveIfContextHasChanged()
        }
    }

    var status: ProgressState {
        switch progress {
            case 0.0:
                return .notStarted
            case 1.0:
                return .completed
            case ..<0.0, 1.0...:
                return .invalid
            default:
                return .inProgress
        }
    }

    // MARK: - Methods

    /// Modifie l'attribut `progress`
    func setProgress(_ newProgress: Double) {
        self.progress = newProgress
    }
}

// MARK: - Extension Core Data

extension ActivityProgressEntity {
    // MARK: - Type Computed Properties

    static var byDisciplineLevelSegpaNSSortDescriptor: [NSSortDescriptor] =
    [
        NSSortDescriptor(
            keyPath: \ActivityProgressEntity.classe?.school?.level,
            ascending: false
        ),
        NSSortDescriptor(
            keyPath: \ActivityProgressEntity.classe?.school?.name,
            ascending: false
        ),
        NSSortDescriptor(
            keyPath: \ActivityProgressEntity.classe?.level,
            ascending: true
        ),
        NSSortDescriptor(
            keyPath: \ActivityProgressEntity.classe?.segpa,
            ascending: true
        )
    ]

    /// Requête pour toutes les progressions de classes triées.
    ///
    /// Ordre de tri:
    ///   1. Type d'établissement
    ///   2. Nom d'établissement
    ///   3. Niveau de la Classe
    ///   4. SGPA ou non
    static var requestAllSortedByDisciplineLevelSegpa: NSFetchRequest<ActivityProgressEntity> {
        let request = ActivityProgressEntity.fetchRequest()
        request.sortDescriptors = Self.byDisciplineLevelSegpaNSSortDescriptor
        return request
    }

    // MARK: - Type Methods

    static func allSortedByDisciplineLevelSegpa() -> [ActivityProgressEntity] {
        do {
            return try ActivityProgressEntity
                .viewContext
                .fetch(requestAllSortedByDisciplineLevelSegpa)
        } catch {
            return []
        }
    }

    static func checkConsistency(errorFound: inout Bool) {
        all().forEach { progress in
            guard progress.classe != nil else {
                errorFound = true
                return
            }
            guard progress.activity != nil else {
                errorFound = true
                return
            }
            guard 0 <= progress.progress && progress.progress <= 1 else {
                errorFound = true
                return
            }
        }
    }

    @discardableResult
    static func create(
        forClasse classe: ClasseEntity,
        forActivity activity: ActivityEntity
    ) -> ActivityProgressEntity {
        let progress = ActivityProgressEntity.create()
        progress.classe = classe
        progress.activity = activity
        return progress
    }

    // MARK: - Methods

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set defaults here
        self.id = UUID()
    }
}

// MARK: - Extension Debug

public extension ActivityProgressEntity {
    override var description: String {
        """

        PROGRESSION:
           Classe   : \(String(describing: classe?.displayString))
           Activité : \(String(describing: activity?.viewName))
           Progrès  : \(progress * 100.0) %
        """
    }
}
