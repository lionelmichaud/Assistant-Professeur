//
//  ProgramTimeLine.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 23/02/2023.
//

import SwiftUI

struct ProgramTimeLine: View {
    @EnvironmentObject
    private var navig: NavigationModel

    @ObservedObject
    private var pref = UserPrefEntity.shared

    enum ViewMode: Int {
        case steps
        case planning
    }

    @State
    private var presentation: ViewMode = .steps

    @State
    var isExportingPDF = false

    @State
    var urlPDF: URL?

    var body: some View {
        VStack {
            if let programId = navig.selectedProgramMngObjId {
                if let program = ProgramEntity.byObjectId(MngObjID: programId) {
                    switch presentation {
                        case .steps:
                            ProgramStepperView(
                                program: program,
                                forPdfExport: false
                            )
                        case .planning:
                            ProgramPlanningView(program: program)
                    }
                } else {
                    Text("Progression introuvable")
                        .foregroundStyle(.secondary)
                        .font(.title2)
                }

            } else {
                ContentUnavailableView(
                    "Aucune progression sélectionnée...",
                    systemImage: ProgramEntity.defaultImageName,
                    description: Text("Sélectionner une progression pour en visualiser les séquences.")
                )
            }
        }
        #if os(iOS)
        .navigationTitle("Déroulement de la progression")
        #endif
        .navigationBarTitleDisplayModeInline()
        .toolbar(content: myToolBarContent)

        // Exporter un fichier PDF
        .fileMover(
            isPresented: $isExportingPDF,
            file: urlPDF
        ) { _ in
        }
    }
}

// MARK: Toolbar Content

extension ProgramTimeLine {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        // Choix du style de présentation
        ToolbarItemGroup(placement: .automatic) {
            Picker("Présentation", selection: $presentation) {
                Image(systemName: "list.bullet").tag(ViewMode.steps)
                Image(systemName: "chart.bar.fill").tag(ViewMode.planning)
            }
            .pickerStyle(.segmented)
        }

        // Exporter la View en PDF
        ToolbarItem(placement: .automatic) {
            Button {
                if let url = renderedPDF() {
                    isExportingPDF = true
                    urlPDF = url
                } else {
                    urlPDF = nil
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
//            if let url = renderedPDF() {
//                ShareLink(item: url)
//            }
        }
    }

    private func renderedPDF() -> URL? {
        if let programId = navig.selectedProgramMngObjId {
            if let program = ProgramEntity.byObjectId(MngObjID: programId) {
                let cachesUrl = URL.cachesDirectory

                switch presentation {
                    case .steps:
                        let fileName = "Séquences de la Progression de \(program.disciplineString) classe de \(program.levelString).pdf"
                        let fileUrl = cachesUrl.appending(component: fileName)
                        if PdfViewConverter.renderAsPDF(
                            content: ProgramStepperView(
                                program: program,
                                forPdfExport: true
                            ),
                            to: fileUrl,
                            withProposedSize: .init(width: 1024, height: nil)
                        ) {
                            return fileUrl
                        } else {
                            return nil
                        }

                    case .planning:
                        let fileName = "Planning de la Progression de \(program.disciplineString) classe de \(program.levelString).pdf"
                        let fileUrl = cachesUrl.appending(component: fileName)
                        if PdfViewConverter.renderAsPDF(
                            content: ProgramPlanningPDF(
                                program: program,
                                data: chartDatum()
                            ),
                            to: fileUrl,
                            withProposedSize: .init(width: 1024, height: 1024)
                        ) {
                            return fileUrl
                        } else {
                            return nil
                        }
                }
            }
        }
        return nil
    }

    /// Fabrication des données du graphique
    private func chartDatum() -> ProgramPlanningGraphData? {
        if let programId = navig.selectedProgramMngObjId {
            if let program = ProgramEntity.byObjectId(MngObjID: programId) {
                // Initialiser les données avec l'année et les vacances scolaires
                var data = ProgramPlanningGraphData(schoolYear: pref.viewSchoolYearPref)

                // Calcul des périodes d'activité de chaque séquence du programme
                let programSequencesData = ProgramManager.getProgramSequencesPeriods(
                    program: program,
                    schoolYear: data.schoolYear
                )
                data.sequences += programSequencesData

                // Calcul des périodes de vacance de chaque séquence du programme
                program.sequencesSortedByNumber.forEach { sequence in
                    // Ajout des périodes de vacances de la Séquence
                    data.schoolYear.vacances.forEach { vacance in
                        data
                            .sequences
                            .append(
                                SequenceData(
                                    name: sequence.viewName,
                                    number: sequence.viewNumber,
                                    serie: .vacance,
                                    dateInterval: vacance.interval
                                )
                            )
                    }
                }
                return data
            }
        }
        return nil
    }
}

// struct ProgramTimeLine_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgramTimeLine()
//    }
// }
