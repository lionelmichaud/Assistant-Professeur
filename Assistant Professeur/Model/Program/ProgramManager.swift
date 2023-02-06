//
//  ProgramManager.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import Foundation
import SwiftUI

struct ProgramManager {
    /// Déplacer la `sequence` à l'intérieur de la liste des séquences d'un `program`
    /// - Warning: Les modifications ne sont pas auvegardées dans le contexte.
    /// - Parameters:
    ///   - sequence: Séquence à déplacer
    ///   - program: Programme auquel appartient la séquence
    ///   - destination: destination de la séquence dans la liste
    static func move(
        sequence: SequenceEntity,
        de program: ProgramEntity,
        to destination: Int
    ) {
        let orderedSequences = program.sequencesSortedByNumber
        guard let indexSource = orderedSequences.firstIndex(of: sequence) else {
            return
        }
        if destination > indexSource {
            for idx in indexSource + 1 ... destination - 1 {
                orderedSequences[idx].number -= 1
            }
            sequence.number = Int16(destination)
        } else {
            for idx in destination ... indexSource - 1 {
                orderedSequences[idx].number += 1
            }
            sequence.number = Int16(destination + 1)
        }
    }

    /// Supprimer la `sequence` du `program` et
    /// re-numéroter les séquences restantes en conséquence.
    ///
    /// - Warning: Les modifications ne sont pas auvegardées dans le contexte.
    static func delete(
        sequence: SequenceEntity,
        de program: ProgramEntity
    ) {
        let orderedSequences = program.sequencesSortedByNumber
        guard let index = orderedSequences.firstIndex(of: sequence) else {
            return
        }

        // renuméroter les éléments restants
        if index < orderedSequences.endIndex {
            for idx in index + 1 ..< orderedSequences.endIndex {
                orderedSequences[idx].number -= 1
            }
        }

        // Supprimer l'élément
        SequenceEntity.viewContext.delete(orderedSequences[index])
    }

    /// Déplacer `activity` à l'intérieur de la liste des activités de la `sequence`
    /// - Warning: Les modifications ne sont pas auvegardées dans le contexte.
    /// - Parameters:
    ///   - activity: Activité à déplacer
    ///   - sequence: Séquence à laquelle appartient l'activité
    ///   - destination: destination de la séquence dans la liste
    static func move(
        activity: ActivityEntity,
        de sequence: SequenceEntity,
        to destination: Int
    ) {
        let orderedActivities = sequence.activitiesSortedByNumber
        guard let indexSource = orderedActivities.firstIndex(of: activity) else {
            return
        }
        if destination > indexSource {
            for idx in indexSource + 1 ... destination - 1 {
                orderedActivities[idx].number -= 1
            }
            activity.number = Int16(destination)
        } else {
            for idx in destination ... indexSource - 1 {
                orderedActivities[idx].number += 1
            }
            activity.number = Int16(destination + 1)
        }
    }

    /// Supprimer l'`activity` de la `sequence` et
    /// re-numéroter les activités restantes en conséquence.
    ///
    /// - Warning: Les modifications ne sont pas auvegardées dans le contexte.
    static func delete(
        activity: ActivityEntity,
        de sequence: SequenceEntity
    ) {
        let orderedActivities = sequence.activitiesSortedByNumber
        guard let index = orderedActivities.firstIndex(of: activity) else {
            return
        }

        // renuméroter les éléments restants
        if index < orderedActivities.endIndex {
            for idx in index + 1 ..< orderedActivities.endIndex {
                orderedActivities[idx].number -= 1
            }
        }

        // Supprimer l'élément
        ActivityEntity.viewContext.delete(orderedActivities[index])
    }

    /// Retourne la liste des Classes qui doivent suivre l'activité `activity`
    /// - Parameter activity: l'activité
    /// - Returns: liste des Classes qui doivent suivre l'activité
    static func classesAssociatedTo(
        thisActivity activity: ActivityEntity
    ) -> [ClasseEntity] {
        let (discipline, level, segpa) = (
            activity.sequence!.program!.discipline,
            activity.sequence!.program!.level,
            activity.sequence!.program!.segpa
        )
        let request = ClasseEntity.requestAllSortedbySchoolThenClasseLevelNumber

        let predicate = NSPredicate(
            format: "%K = %@ AND %K = %@ AND %K = %@",
            #keyPath(ClasseEntity.discipline),
            discipline!,
            #keyPath(ClasseEntity.level),
            level!,
            #keyPath(ClasseEntity.segpa),
            segpa as NSNumber
        )

        request.predicate = predicate

        do {
            let classes = try ClasseEntity.viewContext.fetch(request)
            print(classes)
            return classes
        } catch {
            return []
        }
    }
}
