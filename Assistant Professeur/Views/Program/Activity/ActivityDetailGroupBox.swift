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

    @ObservedObject
    private var pref = UserPrefEntity.shared

    @State
    private var documentToBeViewed: DocumentEntity?

    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                HStack {
                    ActivityTag(
                        activity: activity,
                        font: hClass == .compact ? .callout : .body
                    )
                    Text(activity.viewName)
                        .textSelection(.enabled)
                }

                // note sur le programme
                if pref.viewActivityAnnotationEnabled && activity.viewAnnotation.isNotEmpty {
                    AnnotationView(
                        annotation: activity.viewAnnotation,
                        scrollable: true,
                        scrollHeight: 40
                    )
                }

                // Document
                ForEach(activity.documentsSortedByName) { document in
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
                        duration: activity.duration,
                        withMargin: false
                    )
                    Spacer()
                    WebsiteView(url: activity.url, showURL: true)
                }
                .padding(.top, 4)

                ActivityAllSymbols(
                    activity: activity,
                    showTitle: true
                )
                .padding(.top, 4)

                // Compétences disciplinaires associées
                DCompTagList(disciplineComps: activity.allDisciplineCompetencies)
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
