//
//  ConnectToWCompModal.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 17/06/2023.
//

import CoreData
import HelpersView
import SwiftUI

/// Dialogue modal de connection d'une Compétence Disciplinaire avec des Compétences Travaillées
struct ConnectToWCompModal: View {
    @ObservedObject
    var competency: DCompEntity

    @State
    private var selectedWComp: WCompEntity = .all().first!

    @State
    private var selectedWCompChapter: WCompChapterEntity = .all().first!

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var wChapters = [WCompChapterEntity]()

    @State
    private var selectedCompsObjId = Set<NSManagedObjectID>()

    private var cycle: Cycle? {
        competency.section?.theme?.cycleEnum
    }

    var body: some View {
        Group {
            if let cycle {
                List(selection: $selectedCompsObjId) {
                    ForEach(wChapters) { wChapter in
                        ChapterDisclosure(
                            wChapter: wChapter
                        )
                    }
                    .emptyListPlaceHolder(wChapters) {
                        EmptyListMessage(
                            symbolName: WCompChapterEntity.defaultImageName,
                            title: "Aucun élément du socle de compétences actuellement.",
                            message: "Les éléments du socle de compétences ajoutés apparaîtront ici.",
                            showAsGroupBox: true
                        )
                    }
                }
                .listStyle(.sidebar)
                .task {
                    wChapters = WCompChapterEntity
                        .sortedbyCycleAcronymTitle(forCycle: cycle)
                }
            } else {
                EmptyView()
            }
        }
        #if os(iOS)
        .navigationTitle("Compétences travaillées associées")
        #endif
        .navigationBarTitleDisplayModeInline()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    DCompEntity.rollback()
                    dismiss()
                }
            }
            if selectedCompsObjId.isNotEmpty {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Associer") {
                        let wComps = selectedCompsObjId.compactMap { wCompObjectId in
                            WCompEntity.byObjectId(MngObjID: wCompObjectId)
                        }
                        let setOfWcomps = NSSet(array: wComps)
                        competency.addToWorkedCompetencies(setOfWcomps)

                        try? DCompEntity.saveIfContextHasChanged()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ChapterDisclosure: View {
    @ObservedObject
    var wChapter: WCompChapterEntity

    @State
    private var isExpanded: Bool = true

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded.animation()) {
            ForEach(wChapter.allWorkedCompetenciesSortedByNumber, id: \.objectID) { wComp in
                HStack {
                    Text(wComp.viewAcronym)
                        .fontWeight(.bold) +
                        Text(". ") +
                        Text(wComp.viewDescription)
                        .foregroundColor(.secondary)
                }
            }
        } label: {
            HStack {
                Text(wChapter.viewAcronym)
                    .fontWeight(.bold) +
                    Text(". ") +
                    Text(wChapter.viewDescription)
                    .foregroundColor(.secondary)
            }
            .lineLimit(5)
            .horizontallyAligned(.leading)
        }
    }
}

// struct ConnectToWCompModal_Previews: PreviewProvider {
//    static var previews: some View {
//        ConnectToWCompModal()
//    }
// }
