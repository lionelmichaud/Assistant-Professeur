//
//  ProgramManager.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/01/2023.
//

import AppFoundation
import Foundation
import OSLog
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "ProgramManager"
)

/// Gère les relations entre Program / Sequence / Activité / Classe
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
}

// MARK: - Références croisées Program / Sequence / Activité / Classe

extension ProgramManager {
    /// Retourne l'unique Programme qui doit être suivi par la `classe`.
    ///
    /// Les séquences sont triées
    /// - Returns: liste des Séquences qui doivent être suivies
    static func programAssociatedTo(
        thisClasse classe: ClasseEntity
    ) -> ProgramEntity? {
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
            return try ProgramEntity.context.fetch(request).first
        } catch {
            return nil
        }
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

    /// Retourne la liste des Classes qui doivent suivre le `program`
    /// - Warning: Les modifications ne sont pas auvegardées dans le contexte.
    /// - Parameter program: le programme pédagogique
    /// - Returns: liste des Classes qui doivent suivre le programme
    static func classesAssociatedTo(
        thisProgram program: ProgramEntity
    ) -> [ClasseEntity] {
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
        return classesAssociatedTo(thisProgram: program)
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
        return classesAssociatedTo(thisProgram: program)
    }
}

// MARK: - Détermination des périodes d'activité d'un Programme

extension ProgramManager {
    /// La période de vacance est entièrement inclue dans la dernière partie de la séquence
    fileprivate static func manageFullOverlap(
        sequence: SequenceEntity,
        sequenceInterval: DateInterval,
        intersection: DateInterval,
        sequencesData: inout [SequenceData]
    ) -> DateInterval {
        // Ajouter la partie 1ère partie de la séquence avant les vacances
        let premierePartie = DateInterval(
            start: sequenceInterval.start,
            end: intersection.start
        )
        sequencesData.append(
            SequenceData(
                name: sequence.viewName,
                number: sequence.viewNumber,
                serie: .activity,
                dateInterval: premierePartie
            )
        )
        // Calculer la durée restante de la séquence
        let dureeRestante = sequenceInterval.duration - premierePartie.duration
        // Créer une seconde partie de cette durée commencant à la fin de période de vacance
        let secondePartie = DateInterval(
            start: intersection.end,
            duration: dureeRestante
        )

        return secondePartie
    }

    /// La période de vacance recouvre la fin de la dernière partie de la séquence
    fileprivate static func manageSequenceEndOverlap(
        sequence: SequenceEntity,
        sequenceInterval: DateInterval,
        vacanceInterval: DateInterval,
        sequencesData: inout [SequenceData]
    ) -> DateInterval {
        // Ajouter la partie 1ère partie de la séquence avant les vacances
        let premierePartie = DateInterval(
            start: sequenceInterval.start,
            end: vacanceInterval.start
        )
        sequencesData.append(
            SequenceData(
                name: sequence.viewName,
                number: sequence.viewNumber,
                serie: .activity,
                dateInterval: premierePartie
            )
        )
        // Calculer la durée restante de la séquence
        let dureeRestante = sequenceInterval.duration - premierePartie.duration
        // Créer une seconde partie de cette durée commencant à la fin de période de vacance
        let secondePartie = DateInterval(
            start: vacanceInterval.end,
            duration: dureeRestante
        )

        return secondePartie
    }

    /// La période de vacance recouvre le début de la dernière partie de la séquence
    fileprivate static func manageSequenceStartOverlap(
        sequence _: SequenceEntity,
        sequenceInterval: DateInterval,
        intersection: DateInterval,
        sequencesData _: inout [SequenceData]
    ) -> DateInterval {
        // Décaler la séquence vers la droite de la durée de recouvement avec les vacances
        let timeShift = intersection.duration

        return sequenceInterval.formShift(by: timeShift)
    }

    /// Détermination des périodes d'activité d'une séquence en fonction
    /// du calendrier scolaire.
    /// - Parameters:
    ///   - sequence: Séquence pédagogique
    ///   - currentDate: Date/Heure de début de la séquence
    ///   - nbHeurePerWeek: Nombre dheures de cours en moyenne par semaine pour cette discipline
    ///   - schoolYear: Caractéristiques de l'année scolaire
    /// - Returns: Périodes d'activité d'une séquence
    /// - Precondition: Les vacances doivent être ordonnées par date croissante.
    static func getSequenceActivitiesPeriods(
        sequence: SequenceEntity,
        currentDate: inout Date,
        nbHeurePerWeek: Double,
        schoolYear: SchoolYearPref
    ) -> [SequenceData] {
        var sequenceData = [SequenceData]()

        // Calcul de la date de fin de la séquence sans vacance au milieu
        let nbHeures = sequence.durationWithMargin
        let nbWeeks = nbHeures / nbHeurePerWeek
        let duration = TimeInterval(nbWeeks * 7 * 24 * 60 * 60)
        let sequenceMinimumInterval = DateInterval(
            start: currentDate,
            duration: duration
        )
//        print("Séquence: \(sequence.viewNumber)")
//        print("  nbHeures: \(nbHeures)")
//        print("  nbWeeks : \(nbWeeks)")
//        print("  Début: \(sequenceMinimumInterval.start.formatted(date: .abbreviated, time: .shortened))")
//        print("  Fin  : \(sequenceMinimumInterval.end.formatted(date: .abbreviated, time: .shortened))")

        // Retirer les vacances de la séquence en segmentant la séquence
        // Note: les vacances doivent être ordonnées par date croissante
        var sequenceLastInterval = sequenceMinimumInterval
        schoolYear.vacances.forEach { vacance in
            // Si il y a un recouvrement entre la séquence et la période de vacance
            if let intersection =
                sequenceLastInterval
                    .intersection(with: vacance.interval) {
                let couple = (sequenceLastInterval, intersection)
                switch couple {
                    case let (sequenceInterval, intersection) where intersection == vacance.interval:
                        /// La période de vacance est entièrement inclue dans la dernière partie de la séquence
                        /// print("recouvrement complet de \(vacance.name)")
                        let secondePartie = manageFullOverlap(
                            sequence: sequence,
                            sequenceInterval: sequenceInterval,
                            intersection: intersection,
                            sequencesData: &sequenceData
                        )
                        // Itérer avec cette seconde partie pour la prochaine période de vacance
                        sequenceLastInterval = secondePartie

                    case let (sequenceInterval, intersection) where intersection.start == sequenceInterval.start:
                        /// La période de vacance recouvre le début de la dernière partie de la séquence
                        /// Note: on ne devrait jamais passer par là car la fin de la séquence précédente est forcément hors vacances scolaires
                        /// print("recouvrement du début de la séquence par \(vacance.name)")
                        let shiftedSequenceInterval = manageSequenceStartOverlap(
                            sequence: sequence,
                            sequenceInterval: sequenceInterval,
                            intersection: intersection,
                            sequencesData: &sequenceData
                        )
                        // Itérer avec cette seconde partie pour la prochaine période de vacance
                        sequenceLastInterval = shiftedSequenceInterval
                        customLog.log(
                            level: .debug,
                            "On ne devrait jamais passer par là car la fin de la séquence précédente est forcément hors vacances scolaires"
                        )

                    case let (sequenceInterval, intersection) where intersection.end == sequenceInterval.end:
                        /// La période de vacance recouvre la fin de la dernière partie de la séquence
                        /// print("recouvrement de la fin de la séquence par \(vacance.name)")
                        let secondePartie = manageSequenceEndOverlap(
                            sequence: sequence,
                            sequenceInterval: sequenceInterval,
                            vacanceInterval: vacance.interval,
                            sequencesData: &sequenceData
                        )
                        // Itérer avec cette seconde partie pour la prochaine période de vacance
                        sequenceLastInterval = secondePartie

                    default:
                        // aucun recouvrement
                        // Note: on ne devrait jamais passer par là car il y a recouvrement (if let)
                        // print("aucun recouvrement avec \(vacance.name)")
                        customLog.log(
                            level: .error,
                            "On ne devrait jamais passer par là car il y a recouvrement entre la séquence et les vacance (voir if)"
                        )
                }
            }
        }
        // Incrémente la date courante à la date de fin de la séquence
        currentDate = sequenceLastInterval.end

        sequenceData.append(
            SequenceData(
                name: sequence.viewName,
                number: sequence.viewNumber,
                serie: .activity,
                dateInterval: sequenceLastInterval
            )
        )
        sequenceData[0].isFirstInterval = true

        return sequenceData
    }

    /// Détermination des périodes d'activité des séquences d'un programme en fonction
    /// du calendrier scolaire.
    /// - Parameters:
    ///   - program: Programme annuel
    ///   - schoolYear: Caractéristiques de l'année scolaire
    /// - Returns: Périodes d'activité des séquences d'un programme
    /// - Precondition: Les vacances doivent être ordonnées par dates croissantes.
    static func getProgramSequencesPeriods(
        program: ProgramEntity,
        schoolYear: SchoolYearPref
    ) -> [SequenceData] {
        // Nombre de séances de cours par semaine
        let nbHeurePerWeek =
            program
                .disciplineEnum
                .nbHeurePerWeek(level: program.levelEnum)
        var sequencesData = [SequenceData]()

        // Date de début de l'année
        var currentDate = schoolYear.interval.start

        program.sequencesSortedByNumber.forEach { sequence in
            let sequenceData = getSequenceActivitiesPeriods(
                sequence: sequence,
                currentDate: &currentDate,
                nbHeurePerWeek: nbHeurePerWeek,
                schoolYear: schoolYear
            )
            sequencesData += sequenceData
        }

        // Tag le premier interval de la séquence
        if sequencesData.isNotEmpty {
            sequencesData[sequencesData.startIndex].isFirstInterval = true
        }

        // Tag le dernier interval de de la dernière séquence
        if sequencesData.isNotEmpty {
            sequencesData[sequencesData.endIndex - 1].isLastInterval = true
        }
        return sequencesData
    }

    /// Nombre de séances du `program` qui devraient être complétées à la `date`.
    static func nbOfSeanceSuposidlyCompleted(
        program: ProgramEntity,
        schoolYear: SchoolYearPref,
        atThisDate date: Date
    ) -> Double {
        // périodes d'activité des séquences du programme en fonction du calendrier scolaire
        let programSequencesPeriods = getProgramSequencesPeriods(
            program: program,
            schoolYear: schoolYear
        )
        guard let firstPeriod = programSequencesPeriods.first,
              date > firstPeriod.dateInterval.start else {
            // la date courante est antérieure à la date de début du programme
            return 0.0
        }

        // Recherche du numéro de la séquence théoriquement en cours à la `date`
        var lastCompletedSequenceNumber: Int = 0
        var idx = 0
        var iteratedPeriod = programSequencesPeriods[idx]
        var dateIsPastTheEndOfLastSequence = false
        // itérer sur les périodes jusqu'à ce que la date soit antérieure à la date de fin de la période
        while iteratedPeriod.dateInterval.end < date {
            lastCompletedSequenceNumber = iteratedPeriod.number - 1
            idx += 1
            if idx == programSequencesPeriods.endIndex {
                dateIsPastTheEndOfLastSequence = true
                break
            }
            iteratedPeriod = programSequencesPeriods[idx]
        }
        let currentSequenceNumber = lastCompletedSequenceNumber + 1

        // Cumuler le nb de séances de toutes les séquences entièrement complétées
        let sequencesInProgram = program.sequencesSortedByNumber
        let nbSeancesInFullyCompletedSequences: Double =
            sequencesInProgram
                .reduce(0.0) { nb, sequence in
                    if sequence.viewNumber <= lastCompletedSequenceNumber {
                        return nb + sequence.durationWithoutMargin
                    } else {
                        return nb
                    }
                }

        guard !dateIsPastTheEndOfLastSequence else {
            return nbSeancesInFullyCompletedSequences
        }

        // Ajouter le nb de séances complétées dans la séquence en cours
        //   Nombre de séances de cours par semaine
        let nbSeancePerWeek =
            program
                .disciplineEnum
                .nbHeurePerWeek(level: program.levelEnum)

        //   Cumuler la durée écoulée dans la Séquence en cours
        let nbSeanceInPartiallyCompletedSequence: Double =
            programSequencesPeriods
                .reduce(0.0) { (nb: Double, period: SequenceData) in
                    if period.number == currentSequenceNumber {
                        if period.dateInterval.end < date {
                            // La période est entièrement complétée
                            let nbWeek = Double(period.dateInterval.duration) / Double(7 * 24 * 60 * 60)
                            return nb + nbWeek * nbSeancePerWeek

                        } else if period.dateInterval.start < date {
                            // La période est en cours
                            let completedPart = DateInterval(
                                start: period.dateInterval.start,
                                end: date
                            )
                            let nbWeek = Double(completedPart.duration) / Double(7 * 24 * 60 * 60)
                            return nb + nbWeek * nbSeancePerWeek

                        } else {
                            // La période est à venir
                            return nb
                        }
                    } else {
                        return nb
                    }
                }

        return nbSeancesInFullyCompletedSequences + nbSeanceInPartiallyCompletedSequence
    }
}
