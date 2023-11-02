//
//  DocToBeLoadedGroupBox.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 02/11/2023.
//

import SwiftUI

struct DocToBeLoaded: Identifiable {
    var id = UUID()
    var classe: ClasseEntity
    var document: DocumentEntity
    var beforeDate: Date
}

struct DocToBeLoadedGroupBox: View {
    let docToLoad: DocToBeLoaded

    @State
    private var documentToBeViewed: DocumentEntity?

    @EnvironmentObject
    private var navig: NavigationModel

    @Environment(\.horizontalSizeClass)
    private var hClass

    var body: some View {
        GroupBox {
            if hClass == .regular {
                HStack {
                    // Classe - Discipline - Sequence - Activité
                    classeSequenceActivityView
                    Spacer()
                    // Document
                    documentView
                }
            } else {
                VStack(alignment: .leading) {
                    // Classe - Discipline - Sequence - Activité
                    classeSequenceActivityView
                    // Document
                    documentView
                }
                .horizontallyAligned(.leading)
            }

            HStack {
                Spacer()
                Text("Avant:")
                    .foregroundStyle(.secondary)
                Text(formattedDate(docToLoad.beforeDate))
            }
            .padding(.top, 2)
        }
        .font(.callout)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}

// MARK: - Subviews

extension DocToBeLoadedGroupBox {
    /// Classe - Discipline - Sequence - Activité
    private var classeSequenceActivityView: some View {
        HStack {
            // Classe
            Button {
                DeepLinkManager.handle(
                    navigateTo: .classeProgressUpdate(classe: docToLoad.classe),
                    using: navig
                )
            } label: {
                Text(docToLoad.classe.displayString)
            }
            .buttonStyle(.bordered)

            // Tags Séquence/Activité
            if let activity = docToLoad.document.activity,
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

    private var documentView: some View {
        Button {
            documentToBeViewed = docToLoad.document
        } label: {
            Text(docToLoad.document.viewName)
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

extension DocToBeLoadedGroupBox {
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
//    DocToBeLoadedGroupBox()
// }
