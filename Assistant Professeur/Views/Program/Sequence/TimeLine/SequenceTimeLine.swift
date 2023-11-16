//
//  SequenceTimeLine.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/02/2023.
//

import HelpersView
import SwiftUI

struct SequenceTimeLine: View {
    @EnvironmentObject
    private var navig: NavigationModel

    @State
    private var presentation: ViewMode = .steps

    @State
    private var isExportingPDF = false

    @State
    private var urlPDF: URL?

    // MARK: - Internal Type

    enum ViewMode {
        case steps
        case presentationSheet

        var title: String {
            switch self {
                case .steps:
                    "Déroulement de la séquence"
                case .presentationSheet:
                    "Présentation de la séquence"
            }
        }

        var image: Image {
            switch self {
                case .steps:
                    Image(systemName: "list.bullet")
                case .presentationSheet:
                    Image(systemName: "doc.text")
            }
        }
    }

    // MARK: - Computed Properties

    var body: some View {
        VStack {
            if let sequenceId = navig.selectedSequenceMngObjId {
                if let sequence = SequenceEntity.byObjectId(MngObjID: sequenceId) {
                    switch presentation {
                        case .steps:
                            SequenceStepperView(sequence: sequence)

                        case .presentationSheet:
                            SequencePresentationView(sequence: sequence)
                    }
                } else {
                    Text("Séquence introuvable")
                        .foregroundStyle(.secondary)
                        .font(.title2)
                }

            } else {
                ContentUnavailableView(
                    "Aucune séquence sélectionnée...",
                    systemImage: ProgramEntity.defaultImageName,
                    description: Text("Sélectionner une séquence pour en visualiser les séquences.")
                )
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

    private func renderedPDF() async -> URL? {
        if let sequenceId = navig.selectedSequenceMngObjId,
           let sequence = SequenceEntity.byObjectId(MngObjID: sequenceId) {
            switch presentation {
                case .steps:
                    break

                case .presentationSheet:
                    break
            }
        }
        return nil
    }
}

// MARK: Toolbar Content

extension SequenceTimeLine {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        // Choix du style de présentation
        ToolbarItemGroup(placement: .primaryAction) {
            Picker("Présentation", selection: $presentation) {
                ViewMode.steps.image.tag(ViewMode.steps)
                ViewMode.presentationSheet.image.tag(ViewMode.presentationSheet)
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
}

struct SequenceTimeLine_Previews: PreviewProvider {
    static var previews: some View {
        SequenceTimeLine()
    }
}
