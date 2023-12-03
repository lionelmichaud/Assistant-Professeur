//
//  ActivityDetailGroupBox.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 27/01/2023.
//

import HelpersView
import SwiftUI

struct ActivityDetailGroupBox: View {
    @ObservedObject
    var activity: ActivityEntity

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
                    ActivityTag(
                        activityNumber: activity.viewNumber,
                        font: hClass == .compact ? .callout : .body
                    )
                    Text(activity.viewName)
                        .textSelection(.enabled)
                }

                // note sur le programme
                if userContext.prefs.viewActivityAnnotationEnabled && activity.viewAnnotation.isNotEmpty {
                    AnnotationView(
                        annotation: activity.viewAnnotation,
                        scrollable: false
                    )
                }

                // Document
                ForEach(activity.documentsSortedByName) { document in
                    Button {
                        documentToBeViewed = document
                    } label: {
                        Label(
                            document.viewName,
                            systemImage: document.destinationImageName
                        )
                    }
                    .padding(.top, 4)
                }

                // Durées / url
                HStack {
                    DurationSquareView(
                        duration: activity.duration,
                        withMargin: false,
                        margin: 0
                    )
                    Spacer()
                    WebsiteView(url: activity.url, showURL: false)
                }
                .padding(.top, 4)

                ActivityAllSymbols(
                    activity: activity,
                    showTitle: true
                )
                .padding(.top, 4)

                // Compétences disciplinaires associées
                DCompTagList(disciplineComps: activity.disciplineCompSortedByAcronym)
            }
            .font(hClass == .compact ? .callout : .body)
        }
        .padding(.horizontal)
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

// struct ActivityDetailGroupBox_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityDetailGroupBox()
//    }
// }
