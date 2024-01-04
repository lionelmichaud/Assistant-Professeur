//
//  DocumentsForElevesView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/01/2024.
//

import SwiftUI

struct DocumentsForElevesView: View {
    let activity: ActivityEntity
    let classe: ClasseEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    @State
    private var isDocumentExpanded = false

    @State
    private var documentToBeViewed: DocumentEntity?

    var body: some View {
        DisclosureGroup(isExpanded: $isDocumentExpanded) {
            ForEach(activity.documentsSortedByName) { document in
                // N'afficher que les documents destinés aux élèves ou à l'ENT
                if document.isForEleve || document.isForENT {
                    Button {
                        documentToBeViewed = document
                    } label: {
                        Label(
                            document.viewName,
                            systemImage: document.destinationImageName
                        )
                        Spacer()
                    }
                    .padding(.top, 4)
                }
            }
        } label: {
            HStack {
                Text(hClass == .compact ? "Documents élèves" : "Documents destinés aux élèves")
                progressDocumentsSymbol(classe: classe, activity: activity)
            }
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

    @ViewBuilder
    func progressDocumentsSymbol(
        classe: ClasseEntity?,
        activity: ActivityEntity
    ) -> some View {
        Group {
            if let classe,
               let progress = ProgressClasseCoordinator.progressFor(thisActivity: activity, thisClasse: classe) {
                if activity.hasSomeDocumentForEleves && !progress.isPrinted {
                    // Documents pas déclarés comme tous imprimés par l'utilisateur
                    Image(systemName: DocumentEntity.forEleveImageName).tint(.red)
                }
                if activity.hasSomeDocumentForEleves && progress.isPrinted && !progress.isDistributed {
                    // Documents imprimés mais pas déclarés comme tous distribués par l'utilisateur
                    Image(systemName: "arrow.up.doc").tint(.red)
                }
                if activity.hasSomeDocumentForENT && !progress.isLoaded {
                    // Documents pas déclarés comme tous stockés sur l'ENT
                    Image(systemName: DocumentEntity.forEntImageName).tint(.red)
                }
            } else {
                EmptyView()
            }
        }
    }
}

// #Preview {
//    DocumentsForElevesView()
// }
