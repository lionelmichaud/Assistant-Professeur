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

    @Preference(\.programAnnotationEnabled)
    private var annotationEnabled

    @State
    private var isViewing = false

    var body: some View {
        GroupBox {
            Group {
                LabeledActivityView(activity: activity)
//                    .font(hClass == .compact ? .callout : .headline)
                    .bold()

                // note sur le programme
                if annotationEnabled && activity.viewAnnotation.isNotEmpty {
                    AnnotationView(
                        annotation: activity.viewAnnotation,
                        scrollable: true,
                        scrollHeight: 40
                    )
                }

                // Document
                if let document = activity.document {
                    Button {
                        isViewing.toggle()
                    } label: {
                        Label(document.viewName, systemImage: "doc.richtext")
                    }
                    .padding(.top, 4)
                }

                DurationView(duration: activity.duration, withMargin: false)
                    .padding(.top, 4)

                WebsiteView(url: activity.url, showURL: true)
                    .padding(.top, 4)

                ActivityAllSymbols(
                    activity: activity,
                    showTitle: true
                )
                .padding(.top, 4)
            }
            .font(hClass == .compact ? .callout : .body)
            .horizontallyAligned(.leading)
        }
        .padding(.horizontal)
        #if os(macOS)
        .sheet(isPresented: $isViewing) {
            NavigationStack {
                PdfDocumentViewer(document: activity.document!)
            }
        }
        #else
        .fullScreenCover(isPresented: $isViewing) {
            NavigationStack {
                PdfDocumentViewer(document: activity.document!)
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
