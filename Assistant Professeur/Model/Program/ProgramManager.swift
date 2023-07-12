//
//  ProgramManager.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import AppFoundation
import Foundation
import SwiftUI

enum ProgramManager {
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
        SequenceEntity.context.delete(orderedSequences[index])
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
        ActivityEntity.context.delete(orderedActivities[index])
    }

    /// Retourne la liste des Séquences qui doivent être suivies par la `classe`.
    ///
    /// Les séquences sont triées
    /// - Returns: liste des Séquences qui doivent être suivies
    static func sequencesAssociatedTo(
        thisClasse classe: ClasseEntity
    ) -> [SequenceEntity] {
        let (discipline, level, segpa) = (
            classe.discipline,
            classe.level,
            classe.segpa
        )

        let request = ProgramEntity.requestAllSortedbyDisciplineLevelSegpa

        let predicate = NSPredicate(
            format: "%K = %@ AND %K = %@ AND %K = %@",
            #keyPath(ProgramEntity.discipline),
            discipline!,
            #keyPath(ProgramEntity.level),
            level!,
            #keyPath(ProgramEntity.segpa),
            segpa as NSNumber
        )

        request.predicate = predicate

        do {
            let programs = try ProgramEntity.context.fetch(request)
            let sequences =
                programs
                    .flatMap { program in
                        program.sequencesSortedByNumber
                    }
            return sequences
        } catch {
            return []
        }
    }

    /// Retourne la liste des Activités qui doivent être suivies par la `classe`.
    ///
    /// Les activités sont triées
    /// - Returns: liste des Activités qui doivent être suivies
    static func activitiesAssociatedTo(
        thisClasse classe: ClasseEntity
    ) -> [ActivityEntity] {
        sequencesAssociatedTo(thisClasse: classe)
            .flatMap { sequence in
                sequence.activitiesSortedByNumber
            }
    }

    /// Retourne la liste des Classes qui doivent suivre l'activité `sequence`
    /// - Warning: Les modifications ne sont pas auvegardées dans le contexte.
    /// - Parameter sequence: la séquence
    /// - Returns: liste des Classes qui doivent suivre la séquence
    static func classesAssociatedTo(
        thisSequence sequence: SequenceEntity
    ) -> [ClasseEntity] {
        guard let program = sequence.program else {
            return []
        }

        let (discipline, level, segpa) = (
            program.discipline,
            program.level,
            program.segpa
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
            let classes = try ClasseEntity.context.fetch(request)
            return classes
        } catch {
            return []
        }
    }

    /// Retourne la liste des Classes qui doivent suivre l'activité `activity`
    /// - Warning: Les modifications ne sont pas auvegardées dans le contexte.
    /// - Parameter activity: l'activité
    /// - Returns: liste des Classes qui doivent suivre l'activité
    static func classesAssociatedTo(
        thisActivity activity: ActivityEntity
    ) -> [ClasseEntity] {
        guard let program = activity.sequence?.program else {
            return []
        }

        let (discipline, level, segpa) = (
            program.discipline,
            program.level,
            program.segpa
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
            let classes = try ClasseEntity.context.fetch(request)
            return classes
        } catch {
            return []
        }
    }

    /// Déterminsation des périodes d'activité d'un programme en fonction
    /// du calendrier scolaire.
    /// - Parameters:
    ///   - program: Programme annuel
    ///   - schoolYear: Caractéristiques de l'année scolaire
    /// - Returns: Périodes d'activité d'un programme
    static func getProgramActivitiesPeriods(
        program: ProgramEntity,
        schoolYear: SchoolYearPref
    ) -> [ProgramPlanningGraphData.SequenceData] {
        let nbHeurePerWeek =
            program
                .disciplineEnum
                .nbHeurePerWeek(level: program.levelEnum)
        var sequencesData = [ProgramPlanningGraphData.SequenceData]()
        var currentDate = schoolYear.interval.start

        program.sequencesSortedByNumber.forEach { sequence in
            // Calcul de la date de fin de la séquence sans vacance au milieu
            let nbHeures = sequence.durationWithMargin
            let nbWeeks = Int((nbHeures / nbHeurePerWeek).rounded(.towardZero))
            let duration = TimeInterval(nbWeeks * 7 * 24 * 60 * 60)
//            let nbDays = Int(nbSeances.truncatingRemainder(dividingBy: NbSeancesPerWeek) * 7)
//            let endDate = (nbWeeks.weeks + nbDays.days).from(currentDate)
            let sequenceMinimumInterval = DateInterval(
                start: currentDate,
                duration: duration
            )
            print("Séquence: \(sequence.viewNumber)")
            print("  nbHeures: \(nbHeures)")
            print("  nbWeeks : \(nbWeeks)")
            print("  Début: \(sequenceMinimumInterval.start.formatted(date: .abbreviated, time: .shortened))")
            print("  Fin  : \(sequenceMinimumInterval.end.formatted(date: .abbreviated, time: .shortened))")

            // Incrément de la date courante à la date de fin de la séquence
            currentDate = sequenceMinimumInterval.end

//            var activityInterval = DateInterval(
//                start: sequence.viewNumber.months.from(Date.now)!,
//                end: (sequence.viewNumber + 1).months.from(Date.now)!
//            )
            sequencesData.append(
                ProgramPlanningGraphData.SequenceData(
                    name: sequence.viewName,
                    number: sequence.viewNumber,
                    serie: .activity,
                    dateInterval: sequenceMinimumInterval
                )
            )
        }

        return sequencesData
    }
}
