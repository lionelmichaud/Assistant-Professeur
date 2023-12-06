//
//  ProgramTimeLine.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 23/02/2023.
//

import AppFoundation
import HelpersView
import SwiftUI

struct ProgramTimeLine: View {
    @ObservedObject
    var program: ProgramEntity

    @EnvironmentObject
    private var navig: NavigationModel

    @Environment(UserContext.self)
    private var userContext

    @State
    private var presentation: ViewMode = .steps

    @State
    private var isExportingPDF = false

    @State
    private var urlPDF: URL?

    /// Create an instance of your tip content.
    var programPlanningTip = ProgramPlanningTip()

    // MARK: - Internal Type

    enum ViewMode {
        case steps
        case planning

        var title: String {
            switch self {
                case .steps:
                    "Déroulement"
                case .planning:
                    "Planning"
            }
        }

        var image: Image {
            switch self {
                case .steps:
                    Image(systemName: "list.bullet")
                case .planning:
                    Image(systemName: "chart.bar.doc.horizontal")
            }
        }
    }

    // MARK: - Computed Properties

    var body: some View {
        VStack {
            switch presentation {
                case .steps:
                    ProgramStepperView(
                        program: program,
                        forPdfExport: false
                    )
                case .planning:
                    ProgramPlanningView(program: program)
            }
        }
        #if os(iOS)
        .navigationTitle(presentation.title)
        #endif
        .navigationBarTitleDisplayModeInline()
        .toolbar(content: myToolBarContent)

        // Exporter un fichier PDF
        .fileMover(
            isPresented: $isExportingPDF,
            file: urlPDF
        ) { _ in }
    }
}

// MARK: Toolbar Content

extension ProgramTimeLine {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        // Choix du style de présentation
        ToolbarItemGroup(placement: .primaryAction) {
            Picker("Présentation", selection: $presentation) {
                ViewMode.steps.image.tag(ViewMode.steps)
                ViewMode.planning.image.tag(ViewMode.planning)
            }
            .pickerStyle(.segmented)
            .popoverTip(programPlanningTip)
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
        }
    }

    private func renderedPDF() async -> URL? {
        let cachesUrl = URL.cachesDirectory
        switch presentation {
            case .steps:
                let fileName = "Séquences de la Progression de \(program.disciplineString) classe de \(program.levelString).pdf"
                let fileUrl = cachesUrl.appending(component: fileName)
                if PdfViewConverter.renderAsPDF(
                    content: ProgramStepperView(
                        program: program,
                        forPdfExport: true
                    ).environment(userContext),
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
                    ).environment(userContext),
                    to: fileUrl,
                    withProposedSize: .init(width: 1024, height: 1024)
                ) {
                    return fileUrl
                } else {
                    return nil
                }
        }
    }

    /// Fabrication des données du graphique
    private func chartDatum() -> ProgramPlanningGraphData? {
        ProgramPlanningGraphData(
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
