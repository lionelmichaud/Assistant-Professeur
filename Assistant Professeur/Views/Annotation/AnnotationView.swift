//
//  AnnotationView.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 17/06/2022.
//

import SwiftUI

struct AnnotationView: View {
    @Binding var annotation: String
    
    @Environment(\.horizontalSizeClass)
    private var hClass

    @State
    private var isExpanded = true

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            TextField(
                "Annotation",
                text : $annotation,
                axis : .vertical
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

struct AnnotationView_Previews: PreviewProvider {
    static var previews: some View {
        AnnotationView(annotation: .constant("Ceci est une annotation"))
    }
}
