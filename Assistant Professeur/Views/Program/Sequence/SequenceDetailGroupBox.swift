//
//  SequenceDetailGroupBox.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 25/01/2023.
//

import HelpersView
import SwiftUI

struct SequenceDetailGroupBox: View {
    @ObservedObject
    var sequence: SequenceEntity

    let withDetails: Bool

    @Environment(\.horizontalSizeClass)
    private var hClass

    @Environment(UserContext.self)
    private var userContext

    @State
    private var documentToBeViewed: DocumentEntity?

    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                HStack {
                    SequenceTag(
                        sequenceNumber: sequence.viewNumber,
                        font: hClass == .compact ? .body : .headline
                    )
                    Text(sequence.viewName)
                        .textSelection(.enabled)
                        .font(hClass == .compact ? .body : .title3)
                }
                if withDetails {
                    // note sur la séquence
                    if userContext.prefs.viewSequenceAnnotationEnabled && sequence.viewAnnotation.isNotEmpty {
                        AnnotationView(
                            annotation: sequence.viewAnnotation,
                            scrollable: false
                        )
                    }
                    
                    // Document
                    ForEach(sequence.documentsSortedByName) { document in
                        Button {
                            documentToBeViewed = document
                        } label: {
                            Label(
                                document.viewName,
                                systemImage: DocumentEntity.defaultImageName
                            )
                        }
                        .padding(.top, 4)
                    }
                    
                    // Durées / url
                    HStack {
                        DurationSquareView(
                            duration: sequence.durationWithoutMargin,
                            withMargin: true,
                            margin: Int(sequence.margePostSequence)
                        )
                        Spacer()
                        WebsiteView(url: sequence.url, showURL: false)
                    }
                    .padding(.top, 4)
                }
            }
            .font(hClass == .compact ? .callout : .body)
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

struct SequenceDetailGroupBox_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            SequenceDetailGroupBox(
                sequence: SequenceEntity.all().first!,
                withDetails: true
            )
                .environmentObject(NavigationModel(selectedSequenceMngObjId: SequenceEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")
            SequenceDetailGroupBox(
                sequence: SequenceEntity.all().first!,
                withDetails: true
            )
                .environmentObject(NavigationModel(selectedSequenceMngObjId: SequenceEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
