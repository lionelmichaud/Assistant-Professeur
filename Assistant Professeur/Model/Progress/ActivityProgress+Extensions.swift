//
//  ActivityProgress+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 15/02/2023.
//

import AppFoundation
import CoreData
import Foundation
import OSLog

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "ActivityProgressEntity"
)

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

    var status: ProgressStateEnum {
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

    /// Toggle l'attribut `isPrinted` de la progression
    /// - Important: *Saves the context to the store after modification is done*
    func toggleIsPrinted() {
        isPrinted.toggle()
        try? ActivityProgressEntity.saveIfContextHasChanged()
    }

    /// Toggle l'attribut `isDistributed` de la progression
    /// - Important: *Saves the context to the store after modification is done*
    func toggleIsDistributed() {
        isDistributed.toggle()
        try? ActivityProgressEntity.saveIfContextHasChanged()
    }

    /// Toggle l'attribut `isLoaded` de la progression
    /// - Important: *Saves the context to the store after modification is done*
    func toggleIsLoaded() {
        isLoaded.toggle()
        try? ActivityProgressEntity.saveIfContextHasChanged()
    }

    /// Wrapper of `evalStatus`
    /// - Important: *Does NOT save the context to the store after modification is done*
    var evalStatusEnum: EvalStateEnum {
        get {
            if let evalStatus {
                EvalStateEnum(rawValue: evalStatus) ?? .toBeCorrected
            } else {
                .toBeCorrected
            }
        }
        set {
            self.evalStatus = newValue.rawValue
        }
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
                .context
                .fetch(requestAllSortedByDisciplineLevelSegpa)
        } catch {
            return []
        }
    }

    /// Check the correctness and consistency of all database entities of this type.
    /// - Parameters:
    ///   - errorList: Liste des erreurs trouvées.
    static func checkConsistency(
        errorList: inout DataBaseErrorList,
        tryToRepair: Bool
    ) {
        func appendNoOwnerError(progress: ActivityProgressEntity) {
            let logString = "\(progress.activity?.viewName ?? "activity = nil") / \(progress.classe?.displayString ?? "classe  = nil")"
            errorList.append(DataBaseError.noOwner(
                entity: Self.entity().name!,
                name: logString,
                id: progress.id
            ))
            customLog.log(level: .error, "\(logString, privacy: .public)")
        }

        all().forEach { progress in
            if progress.classe == nil || progress.activity == nil {
                if tryToRepair {
                    do {
                        let logString = "trying to delete entity of type \(Self.entity().name!) : \(progress.activity?.viewName ?? "activity = nil") / \(progress.classe?.displayString ?? "classe  = nil")"
                        customLog.log(level: .error, "\(logString, privacy: .public)")
                        // la destruction est sauvegardée
                        try progress.delete()

                    } catch {
                        appendNoOwnerError(progress: progress)
                    }
                } else {
                    appendNoOwnerError(progress: progress)
                }
            }

            if !(0.0 ... 1.0).contains(progress.progress) {
                errorList.append(DataBaseError.outOfBound(
                    entity: Self.entity().name!,
                    name: "progress = \(progress.progress)",
                    attribute: "progress",
                    id: progress.id
                ))
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

    /// Tente de réparer le lien brisé.
    /// - Returns: true si la réparation a réussie
    /// - Warning: NA VA PAS FONCTIONNER
    func repairBrokenLinkToClass() -> Bool {
        var success = false

        guard let activity else {
            return false
        }

        ProgramManager
            .classesAssociatedTo(thisActivity: activity)
            .forEach { classe in
                #if DEBUG
                    print("**\(classe.school!.displayString)**: \(activity.viewName)")
                #endif
                self.classe = classe
                success = true
            }

        return success
    }
}

// MARK: - Extension Debug

public extension ActivityProgressEntity {
    override var description: String {
        """

        PROGRESSION:
           Classe    : \(String(describing: classe?.displayString))
           Séquence  : \(String(describing: activity?.sequence?.viewName))
           Activité  : \(String(describing: activity?.viewName))
           Imprimé   : \(isPrinted.frenchString)
           Distribué : \(isDistributed.frenchString)
           Chargé    : \(isLoaded.frenchString)
           Annotation: \(viewAnnotation)
           Status    : \(status)
           Progrès   : \(progress * 100.0) %
           Evaluation: \(evalStatusEnum.rawValue)
           Début     : \(startDate?.formatted(date: .abbreviated, time: .shortened) ?? "-")
           Fin       : \(endDate?.formatted(date: .abbreviated, time: .shortened) ?? "-")
        """
    }
}
