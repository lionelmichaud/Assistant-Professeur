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

    @EnvironmentObject
    private var userContext: UserContext

    enum ViewMode: Int {
        case steps
        case planning
    }

    @State
    private var presentation: ViewMode = .steps

    @State
    private var isExportingPDF = false

    @State
    private var urlPDF: URL?

    private var title: String {
        switch presentation {
            case .steps:
                "Déroulement de la progression"
            case .planning:
                "Planning"
        }
    }

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
        .navigationTitle(title)
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
        ToolbarItemGroup(placement: .primaryAction) {
            Picker("Présentation", selection: $presentation) {
                Image(systemName: "list.bullet").tag(ViewMode.steps)
                Image(systemName: "chart.bar.fill").tag(ViewMode.planning)
            }
            .pickerStyle(.segmented)
        }

        // Exporter la View en PDF
        ToolbarItem(placement: .primaryAction) {
            Button {
                Task {
                    if let url = await renderedPDF() {
                        isExportingPDF = true
                        urlPDF = url
                    } else {
                        urlPDF = nil
                    }
                }
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
//            if let url = renderedPDF() {
//                ShareLink(item: url)
//            }
        }
    }

    private func renderedPDF() async -> URL? {
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
        guard let programId = navig.selectedProgramMngObjId,
              let program = ProgramEntity.byObjectId(MngObjID: programId)
        else {
            return nil
        }

        return ProgramPlanningGraphData(
            forProgram: program,
            schoolYear: userContext.prefs.viewSchoolYearPref
        )
    }
}

// struct ProgramTimeLine_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgramTimeLine()
//    }
// }
