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

    @Environment(\.horizontalSizeClass)
    private var hClass

    @Preference(\.programAnnotationEnabled)
    private var annotationEnabled

    @State
    private var isViewing = false

    var body: some View {
        GroupBox {
            Group {
                LabeledSequenceView(sequence: sequence)
                    .font(hClass == .compact ? .callout : .headline)
                    .bold()

                // note sur le programme
                if annotationEnabled && sequence.viewAnnotation.isNotEmpty {
                    AnnotationView(
                        annotation: sequence.viewAnnotation,
                        scrollable: true,
                        scrollHeight: 40
                    )
                }

                // Document
                if let document = sequence.document {
                    Button {
                        isViewing.toggle()
                    } label: {
                        Label(document.viewName, systemImage: "doc.richtext")
                    }
                    .padding(.top, 4)
                }

                // Durées / url
                HStack {
                    DurationView(duration: sequence.durationWithoutMargin, withMargin: false)
                        .padding(.trailing)
                    DurationView(duration: sequence.durationWithMargin, withMargin: true)
                        .padding(.trailing)
                    WebsiteView(url: sequence.url)
                    Spacer()
                }
            }
            .font(hClass == .compact ? .callout : .body)
            .horizontallyAligned(.leading)
        }
        .padding(.horizontal)
        #if os(macOS)
        .sheet(isPresented: $isViewing) {
            NavigationStack {
                PdfDocumentViewer(document: sequence.document!)
            }
        }
        #else
        .fullScreenCover(isPresented: $isViewing) {
            NavigationStack {
                PdfDocumentViewer(document: sequence.document!)
            }
        }
        #endif
    }
}

// struct SequenceDetailGroupBox_Previews: PreviewProvider {
//    static var previews: some View {
//        SequenceDetailGroupBox()
//    }
// }
