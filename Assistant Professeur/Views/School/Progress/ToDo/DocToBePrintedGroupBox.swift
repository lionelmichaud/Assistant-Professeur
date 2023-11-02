//
//  DocToBePrintedGroupBox.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 02/11/2023.
//

import HelpersView
import SwiftUI

struct DocToBePrinted: Identifiable {
    var id = UUID()
    var classe: ClasseEntity
    var document: DocumentEntity
    var quantity: Int
    var beforeDate: Date
}

/// GrouepBox présentant un document à imprimer
/// dans un certain nombre d'exemplaires avant une certaine date
struct DocToBePrintedGroupBox: View {
    let docToPrint: DocToBePrinted

    @State
    private var documentToBeViewed: DocumentEntity?

    @EnvironmentObject
    private var navig: NavigationModel

    @Environment(\.horizontalSizeClass)
    private var hClass

    var body: some View {
        GroupBox {
            if hClass == .regular {
                VStack {
                    HStack {
                        // Classe - Discipline - Sequence - Activité
                        classeSequenceActivityView
                        Spacer()
                        navigateToActivityButton
                    }
                    // Document
                    documentView
                        .horizontallyAligned(.leading)
                        .padding(.top, 2)
                }
            } else {
                VStack(alignment: .leading) {
                    // Classe - Discipline - Sequence - Activité
                    HStack {
                        classeSequenceActivityView
                        Spacer()
                        navigateToActivityButton
                    }
                    // Document
                    documentView
                        .horizontallyAligned(.leading)
                        .padding(.top, 2)
                }
            }

            HStack {
                if docToPrint.quantity > 0 {
                    HStack {
                        Text("Nombre d'ex.:")
                            .foregroundStyle(.secondary)
                        Text("\(docToPrint.quantity, format: .number)")
                    }
                }
                Spacer()
                dateBeforeView
            }
            .padding(.top, 2)
        }
        .font(.callout)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}

// MARK: - Subviews

extension DocToBePrintedGroupBox {
    /// Classe - Discipline - Sequence - Activité
    private var classeSequenceActivityView: some View {
        HStack {
            // Classe
            Button {
                DeepLinkManager.handle(
                    navigateTo: .classeProgressUpdate(classe: docToPrint.classe),
                    using: navig
                )
            } label: {
                Text(docToPrint.classe.displayString)
            }
            .buttonStyle(.bordered)

            // Tags Séquence/Activité
            if let activity = docToPrint.document.activity,
               let sequence = activity.sequence,
               let discipline = sequence.program?.disciplineEnum {
                Text(discipline.acronym)
                    .foregroundColor(.secondary)
                SequenceTagWithPopOver(sequence: sequence)
                ActivityTag(activityNumber: activity.viewNumber)
                    // Naviguer vers l'activité pédagogique
                    .onTapGesture {
                        DeepLinkManager.handle(
                            navigateTo: .activity(
                                program: sequence.program!,
                                sequence: sequence,
                                activity: activity
                            ),
                            using: navig
                        )
                    }
            }
        }
    }

    private var navigateToActivityButton: some View {
        Group {
            if let activity = docToPrint.document.activity,
               let sequence = activity.sequence {
                Button {
                    DeepLinkManager.handle(
                        navigateTo: .activity(
                            program: sequence.program!,
                            sequence: sequence,
                            activity: activity
                        ),
                        using: navig
                    )
                } label: {
                    Label(
                        "Voir l'activité",
                        systemImage: "figure.walk.motion"
                    )
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var dateBeforeView: some View {
        HStack {
            Spacer()
            Text("Avant:")
                .foregroundStyle(.secondary)
            Text(formattedDate(docToPrint.beforeDate))
        }
    }

    private var documentView: some View {
        Button {
            documentToBeViewed = docToPrint.document
        } label: {
            Text(docToPrint.document.viewName)
        }
        #if os(macOS)
        .sheet(item: $documentToBeViewed) { doc in
            NavigationStack {
                PdfDocumentViewer(document: doc)
            }
        }
        #else
                .fullScreenCover(item: $documentToBeViewed) { doc in
                    NavigationStack {
                        PdfDocumentViewer(document: doc)
                    }
                }
        #endif
    }
}

// MARK: - Methods

extension DocToBePrintedGroupBox {
    private func formattedDate(_ date: Date) -> String {
        let delta = date.days(between: Date.now)
        switch delta {
            case 0:
                return "Aujourd'hui"

            case 1:
                return "Demain"

            case 2:
                return "Après-demain"

            case 3 ... 6:
                return "\(date.formatted(Date.FormatStyle().weekday(.wide))) prochain"

            default:
                return date
                    .formatted(Date.FormatStyle()
                        .weekday(.wide)
                        .day(.twoDigits)
                        .month(.twoDigits))
        }
    }
}

// #Preview {
//    DocToBePrintedGroupBox()
// }
