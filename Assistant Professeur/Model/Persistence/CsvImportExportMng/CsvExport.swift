//
//  CsvExport.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 14/06/2023.
//

import Foundation
import os
import TabularData

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "CsvImportExportMng.Export"
)

/// EXPORT
extension CsvImportExportMng {
    static let csvEleveListFileName = "élèves.csv"
    static let csvProgramListFileName = "programmes.csv"
    static let csvWCompetencyListFileName = "compétances du socle.csv"
    static let csvDCompetencyListFileName = "compétances disciplinaires.csv"

    static func csvClasseGroupFileName(classe: ClasseEntity) -> String {
        (classe.school?.displayString ?? "") + "_" + classe.displayString + "_groupes.csv"
    }

    private static var csWritingOptions: CSVWritingOptions {
        CSVWritingOptions(
            includesHeader: true,
            nilEncoding: "",
            trueEncoding: "VRAI",
            falseEncoding: "FAUX",
            delimiter: ";"
        )
    }

    // MARK: - Export des Compétences

    /// Exporter les compétences
    static func exportCompetencies() {
        exportWCompetencies()
        exportDCompetencies()
    }

    /// Exporter les compétences du socle
    static func exportWCompetencies() {
        var total = DataFrame()
        WCompChapterEntity.allSortedbyCycleAcronymTitle()
            .forEach { chapter in
                let dataFrame = wCompChapterDataFrame(de: chapter)
                #if DEBUG
                    print(dataFrame)
                #endif
                if total.isEmpty {
                    total = dataFrame
                } else {
                    total.append(rowsOf: dataFrame)
                }
            }

        let cachesUrl = URL.cachesDirectory
        let fileUrl = cachesUrl.appending(component: csvWCompetencyListFileName)

        try? total.writeCSV(
            to: fileUrl,
            options: csWritingOptions
        )
    }

    /// Construit la table des éléments d'un chapitre de compétences du socle
    static func wCompChapterDataFrame(de chapter: WCompChapterEntity) -> DataFrame {
        // colonnes relatives au Chapitre
        func appendChapterToChapterColumns(chapter: WCompChapterEntity) {
            cycleColumn.append(chapter.cycleString)
            chapterAcronymColumn.append(chapter.viewAcronym)
            chapterDescripColumn.append(chapter.viewDescription)
        }

        // colonnes relatives à la compétence
        func appendCompetencyToCompetencyColumns(competency: WCompEntity?) {
            if let competency {
                compAcronymColumn.append(competency.viewAcronym)
                compDescripColumn.append(competency.viewDescription)
            } else {
                compAcronymColumn.append("aucune")
                compDescripColumn.append("aucune")
            }
        }
        var dataFrame = DataFrame()

        // colonnes relatives au Chapitre
        var cycleColumn = Column(
            ColumnID("Cycle", String.self),
            capacity: 4
        )
        var chapterAcronymColumn = Column(
            ColumnID("Élément Acronym", String.self),
            capacity: 4
        )
        var chapterDescripColumn = Column(
            ColumnID("Élément Description", String.self),
            capacity: 4
        )

        // colonnes relatives à la compétence
        var compAcronymColumn = Column(
            ColumnID("Compétence Acronym", String.self),
            capacity: 4
        )
        var compDescripColumn = Column(
            ColumnID("Compétence Description", String.self),
            capacity: 4
        ) // TODO: - Implémenter export CSV des Compétences

        let competencies = chapter.allWorkedCompetenciesSortedByNumber

        if competencies.isNotEmpty {
            competencies.forEach { competency in
                // colonnes relatives au Chapitre
                appendChapterToChapterColumns(chapter: chapter)

                // colonnes relatives à la compétence
                appendCompetencyToCompetencyColumns(competency: competency)
            }
        } else {
            // colonnes relatives au Chapitre
            appendChapterToChapterColumns(chapter: chapter)

            // colonnes VIDES relatives à la compétence
            appendCompetencyToCompetencyColumns(competency: nil)
        }

        // colonnes relatives au Chapitre
        dataFrame.append(column: cycleColumn)
        dataFrame.append(column: chapterAcronymColumn)
        dataFrame.append(column: chapterDescripColumn)

        // colonnes relatives à la compétence
        dataFrame.append(column: compAcronymColumn)
        dataFrame.append(column: compDescripColumn)

        return dataFrame
    }

    /// Exporter les compétences disciplinairs
    static func exportDCompetencies() {
        // TODO: - Implémenter export CSV des Compétences
        var total = DataFrame()
        DThemeEntity.allSortedbyDiscCycleTitle()
            .forEach { theme in
                let dataFrame = dCompThemeDataFrame(de: theme)
                #if DEBUG
                    print(dataFrame)
                #endif
                if total.isEmpty {
                    total = dataFrame
                } else {
                    total.append(rowsOf: dataFrame)
                }
            }

        let cachesUrl = URL.cachesDirectory
        let fileUrl = cachesUrl.appending(component: csvDCompetencyListFileName)

        try? total.writeCSV(
            to: fileUrl,
            options: csWritingOptions
        )
    }

    /// Construit la table des éléments d'un chapitre de compétences du socle
    static func dCompThemeDataFrame(de theme: DThemeEntity) -> DataFrame {
        // colonnes relatives au Thème
        func appendThemeToThemeColumns(theme: DThemeEntity) {
            disciplineColumn.append(theme.disciplineString)
            cycleColumn.append(theme.cycleString)
            themeAcronymColumn.append(theme.viewAcronym)
            themeDescriptionColumn.append(theme.viewDescription)
        }

        // colonnes relatives à la Section
        func appendSectionToSectionColumns(section: DSectionEntity?) {
            if let section {
                sectionAcronymColumn.append(section.viewAcronym)
                sectionDescriptionColumn.append(section.viewDescription)
            } else {
                sectionAcronymColumn.append("aucune")
                sectionDescriptionColumn.append("aucune")
            }
        }

        // colonnes relatives à la compétence
        func appendCompToCompColumns(competency: DCompEntity?) {
            if let competency {
                compAcronymColumn.append(competency.viewAcronym)
                compDescriptionColumn.append(competency.viewDescription)
            } else {
                compAcronymColumn.append("aucune")
                compDescriptionColumn.append("aucune")
            }
        }

        var dataFrame = DataFrame()

        // colonnes relatives au Thème
        var cycleColumn = Column(
            ColumnID("Cycle", String.self),
            capacity: 4
        )
        var disciplineColumn = Column(
            ColumnID("Discipline", String.self),
            capacity: 4
        )
        var themeAcronymColumn = Column(
            ColumnID("Thème Acronym", String.self),
            capacity: 4
        )
        var themeDescriptionColumn = Column(
            ColumnID("Thème Description", String.self),
            capacity: 4
        )
        // colonnes relatives à la Section
        var sectionAcronymColumn = Column(
            ColumnID("Section Acronym", String.self),
            capacity: 4
        )
        var sectionDescriptionColumn = Column(
            ColumnID("Section Description", String.self),
            capacity: 4
        )

        // colonnes relatives à la compétence
        var compAcronymColumn = Column(
            ColumnID("Compétence Acronym", String.self),
            capacity: 4
        )
        var compDescriptionColumn = Column(
            ColumnID("Compétence Description", String.self),
            capacity: 4
        )

        // colonnes relatives à la connaissance
        var KnowAcronymColumn = Column(
            ColumnID("Connaissance Acronym", String.self),
            capacity: 4
        )
        var KnowDescriptionColumn = Column(
            ColumnID("Connaissance Description", String.self),
            capacity: 4
        )

       let sections = theme.allSectionsSortedByNumber

        if sections.isNotEmpty {
            sections.forEach { section in
                let competencies = section.allCompetenciesSortedByNumber

                // colonnes relatives au programme
                if competencies.isNotEmpty {
                    competencies.forEach { competency in
                        // colonnes relatives au Thème
                        appendThemeToThemeColumns(theme: theme)

                        // colonnes relatives à la Section
                        appendSectionToSectionColumns(section: section)

                        // colonnes relatives à la Compétence
                        appendCompToCompColumns(competency: competency)
                    }
                } else {
                    // colonnes relatives au Thème
                    appendThemeToThemeColumns(theme: theme)

                    // colonnes relatives à la Section
                    appendSectionToSectionColumns(section: section)

                    // colonnes VIDES relatives à la Compétence
                    appendCompToCompColumns(competency: nil)
                }
            }
        } else {
            // colonnes relatives au Thème
            appendThemeToThemeColumns(theme: theme)

            // colonnes VIDES relatives à la Section
            appendSectionToSectionColumns(section: nil)

            // colonnes VIDES relatives à la Compétence
            appendCompToCompColumns(competency: nil)
        }

        // colonnes relatives au Thème
        dataFrame.append(column: cycleColumn)
        dataFrame.append(column: disciplineColumn)
        dataFrame.append(column: themeAcronymColumn)
        dataFrame.append(column: themeDescriptionColumn)

        // colonnes relatives à la Section
        dataFrame.append(column: sectionAcronymColumn)
        dataFrame.append(column: sectionDescriptionColumn)

        // colonnes relatives à la Compétence
        dataFrame.append(column: compAcronymColumn)
        dataFrame.append(column: compDescriptionColumn)

        return dataFrame
    }

    // MARK: - Export des Programmes

    /// Exporter la liste des Programmes
    static func exportPrograms() {
        var total = DataFrame()
        ProgramEntity.allSortedbyDisciplineLevelSegpa()
            .forEach { program in
                let dataFrame = programDataFrame(de: program)
                #if DEBUG
                    print(dataFrame)
                #endif
                if total.isEmpty {
                    total = dataFrame
                } else {
                    total.append(rowsOf: dataFrame)
                }
            }

        let cachesUrl = URL.cachesDirectory
        let fileUrl = cachesUrl.appending(component: csvProgramListFileName)

        try? total.writeCSV(
            to: fileUrl,
            options: csWritingOptions
        )
    }

    /// Construit la table des séquences d'un programme
    static func programDataFrame(de program: ProgramEntity) -> DataFrame {
        // colonnes relatives au programme
        func appendProgramToProgramColumns(program: ProgramEntity) {
            disciplineColumn.append(program.disciplineString)
            levelColumn.append(program.viewLevelEnum.pickerString)
            segpaColumn.append(program.viewSegpa)
            durationColumn.append(program.durationWithoutMargin)
            durationWithMarginColumn.append(program.durationWithMargin)
        }

        // colonnes relatives à la séquence
        func appendSequenceToSequenceColumns(sequence: SequenceEntity?) {
            if let sequence {
                seqNumColumn.append(sequence.viewNumber)
                seqNameColumn.append(sequence.viewName)
                seqDurationColumn.append(sequence.durationWithoutMargin)
                seqDurationWithMarginColumn.append(sequence.durationWithMargin)
            } else {
                seqNumColumn.append(0)
                seqNameColumn.append("aucune")
                seqDurationColumn.append(0.0)
                seqDurationWithMarginColumn.append(0.0)
            }
        }

        // colonnes relatives à l'activité
        func appendActivityToActivityColumns(activity: ActivityEntity?) {
            if let activity {
                actNumColumn.append(activity.viewNumber)
                actNameColumn.append(activity.viewName)
                actDurationColumn.append(activity.duration)
                actIsEvalSommativeColumn.append(activity.viewIsEvalSommative)
                actIsEvalFormativeColumn.append(activity.viewIsEvalFormative)
                actIsTpColumn.append(activity.viewIsTP)
                actIsProjectColumn.append(activity.isProject)
            } else {
                actNumColumn.append(0)
                actNameColumn.append("aucune")
                actDurationColumn.append(0.0)
                actIsEvalSommativeColumn.append(false)
                actIsEvalFormativeColumn.append(false)
                actIsTpColumn.append(false)
                actIsProjectColumn.append(false)
            }
        }

        var dataFrame = DataFrame()

        // colonnes relatives au programme
        var disciplineColumn = Column(
            ColumnID("Discipline", String.self),
            capacity: 4
        )
        var levelColumn = Column(
            ColumnID("Niveau", String.self),
            capacity: 4
        )
        var segpaColumn = Column(
            ColumnID("SEGPA", Bool.self),
            capacity: 4
        )
        var durationColumn = Column(
            ColumnID("Durée", Double.self),
            capacity: 4
        )
        var durationWithMarginColumn = Column(
            ColumnID("Durée avec marge", Double.self),
            capacity: 4
        )

        // colonnes relatives à la séquence
        var seqNumColumn = Column(
            ColumnID("Séquence numéro", Int.self),
            capacity: 4
        )
        var seqNameColumn = Column(
            ColumnID("Séquence nom", String.self),
            capacity: 4
        )
        var seqDurationColumn = Column(
            ColumnID("Séquence Durée", Double.self),
            capacity: 4
        )
        var seqDurationWithMarginColumn = Column(
            ColumnID("Séquence Durée avec marge", Double.self),
            capacity: 4
        )

        // colonnes relatives à l'activité
        var actNumColumn = Column(
            ColumnID("Activité numéro", Int.self),
            capacity: 4
        )
        var actNameColumn = Column(
            ColumnID("Activité nom", String.self),
            capacity: 4
        )
        var actDurationColumn = Column(
            ColumnID("Activité Durée", Double.self),
            capacity: 4
        )
        var actIsEvalSommativeColumn = Column(
            ColumnID("Activité Eval Sommative", Bool.self),
            capacity: 4
        )
        var actIsEvalFormativeColumn = Column(
            ColumnID("Activité Eval Formative", Bool.self),
            capacity: 4
        )
        var actIsTpColumn = Column(
            ColumnID("Activité TP", Bool.self),
            capacity: 4
        )
        var actIsProjectColumn = Column(
            ColumnID("Activité Projet", Bool.self),
            capacity: 4
        )

        let sequences = program.sequencesSortedByNumber

        if sequences.isNotEmpty {
            sequences.forEach { sequence in
                let activities = sequence.activitiesSortedByNumber

                // colonnes relatives au programme
                if activities.isNotEmpty {
                    activities.forEach { activity in
                        // colonnes relatives au programme
                        appendProgramToProgramColumns(program: program)

                        // colonnes relatives à la séquence
                        appendSequenceToSequenceColumns(sequence: sequence)

                        // colonnes relatives à l'activité
                        appendActivityToActivityColumns(activity: activity)
                    }
                } else {
                    // colonnes relatives au programme
                    appendProgramToProgramColumns(program: program)

                    // colonnes relatives à la séquence
                    appendSequenceToSequenceColumns(sequence: sequence)

                    // colonnes VIDES relatives à l'activité
                    appendActivityToActivityColumns(activity: nil)
                }
            }
        } else {
            // colonnes relatives au programme
            appendProgramToProgramColumns(program: program)

            // colonnes VIDES relatives à la séquence
            appendSequenceToSequenceColumns(sequence: nil)

            // colonnes VIDES relatives à l'activité
            appendActivityToActivityColumns(activity: nil)
        }

        // colonnes relatives au programme
        dataFrame.append(column: disciplineColumn)
        dataFrame.append(column: levelColumn)
        dataFrame.append(column: segpaColumn)
        dataFrame.append(column: durationColumn)
        dataFrame.append(column: durationWithMarginColumn)

        // colonnes relatives à la séquence
        dataFrame.append(column: seqNumColumn)
        dataFrame.append(column: seqNameColumn)
        dataFrame.append(column: seqDurationColumn)
        dataFrame.append(column: seqDurationWithMarginColumn)

        // colonnes relatives à l'activité
        dataFrame.append(column: actNumColumn)
        dataFrame.append(column: actNameColumn)
        dataFrame.append(column: actDurationColumn)
        dataFrame.append(column: actIsEvalSommativeColumn)
        dataFrame.append(column: actIsEvalFormativeColumn)
        dataFrame.append(column: actIsTpColumn)
        dataFrame.append(column: actIsProjectColumn)

        return dataFrame
    }

    // MARK: - Export des Elèves

    /// Exporter la liste des élèves de tous les établissemenets par classe et par groupe
    static func exportEleves() {
        var total = DataFrame()
        SchoolEntity.allSortedByLevelName()
            .forEach { school in
                school.classesSortedByLevelNumber
                    .forEach { classe in
                        let dataFrame = classeGroupsDataFrame(de: classe)
                        #if DEBUG
                            print(dataFrame)
                        #endif
                        if total.isEmpty {
                            total = dataFrame
                        } else {
                            total.append(rowsOf: dataFrame)
                        }
                    }
            }

        let cachesUrl = URL.cachesDirectory
        let fileUrl = cachesUrl.appending(component: csvEleveListFileName)

        try? total.writeCSV(
            to: fileUrl,
            options: csWritingOptions
        )
    }

    // MARK: - Export des Compétences

    /// Exporter la liste des élèves des groupes d'une classe
    static func exportGroups(de classe: ClasseEntity) {
        let groupsDataFrame = classeGroupsDataFrame(de: classe)

        let fileName = csvClasseGroupFileName(classe: classe)
        let cachesUrl = URL.cachesDirectory
        let fileUrl = cachesUrl.appending(component: fileName)

        try? groupsDataFrame.writeCSV(
            to: fileUrl,
            options: csWritingOptions
        )
    }

    /// Construit la table des élèves des groupes d'une classe
    static func classeGroupsDataFrame(de classe: ClasseEntity) -> DataFrame {
        var dataFrame = DataFrame()

        let schoolColumnID = ColumnID("Établissement", String.self)
        let classeColumnID = ColumnID("Classe", String.self)
        let groupeColumnID = ColumnID("Groupe", String.self)
        let eleveColumnID = ColumnID("Élève", String.self)
        //        let columnNames = [classeColumnID.name, groupeColumnID.name, eleveColumnID.name]

        var schoolColumn = Column(schoolColumnID, capacity: 1)
        var classeColumn = Column(classeColumnID, capacity: 15)
        var groupeColumn = Column(groupeColumnID, capacity: 15)
        var eleveColumn = Column(eleveColumnID, capacity: 15)

        let schoolName = classe.school?.displayString
        let classeName = classe.displayString

        classe.allGroups.forEach { group in
            group.allEleves.forEach { eleve in
                schoolColumn.append(schoolName)
                classeColumn.append(classeName)
                groupeColumn.append(group.displayString)
                eleveColumn.append(eleve.displayName)
            }
        }

        dataFrame.append(column: schoolColumn)
        dataFrame.append(column: classeColumn)
        dataFrame.append(column: groupeColumn)
        dataFrame.append(column: eleveColumn)

        return dataFrame
            .sorted(
                on: groupeColumnID,
                order: .ascending
            )
    }
}
