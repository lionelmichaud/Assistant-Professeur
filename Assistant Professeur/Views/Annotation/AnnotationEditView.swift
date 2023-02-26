//
//  AnnotationView.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 17/06/2022.
//

import SwiftUI

struct AnnotationView: View {
    private var annotation: String
    private var scrollable: Bool
    private var scrollHeight: Int

    var body: some View {
        HStack {
            Image(systemName: "note.text")
            if scrollable {
                ScrollView(.vertical, showsIndicators: true) {
                    Text(annotation)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxHeight: CGFloat(scrollHeight))

            } else {
                Text(annotation)
                    .lineLimit(5)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }

    init(
        annotation: String,
        scrollable: Bool = false,
        scrollHeight: Int = 100
    ) {
        self.annotation = annotation
        self.scrollable = scrollable
        self.scrollHeight = scrollHeight
    }
}

struct AnnotationEditView: View {
    @Binding
    var annotation: String

    @Environment(\.horizontalSizeClass)
    private var hClass

    @State
    private var isExpanded = true

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            TextField(
                "Annotation",
                text: $annotation,
                axis: .vertical
            )
            .lineLimit(5)
            .font(hClass == .compact ? .callout : .body)
            .textFieldStyle(.roundedBorder)
            .onChange(of: annotation) { newValue in
                isExpanded = newValue.isNotEmpty
            }
        } label: {
            HStack {
                Label("Annotation", systemImage: "note.text")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text(annotation.truncate(to: 20, addEllipsis: true))
                    .foregroundColor(.secondary)
            }
        }
        .listRowSeparator(.hidden)
        .onAppear {
            isExpanded = annotation.isNotEmpty
        }
    }
}

struct AnnotationEditView_Previews: PreviewProvider {
    static var previews: some View {
        AnnotationEditView(annotation: .constant("Ceci est une annotation"))
    }
}
