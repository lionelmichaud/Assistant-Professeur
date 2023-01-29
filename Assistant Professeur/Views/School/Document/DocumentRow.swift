//
//  DocumentRow.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 02/11/2022.
//

import SwiftUI

struct DocumentRow: View {
    @ObservedObject
    var document: DocumentEntity

    @State
    private var isViewing = false

    var body: some View {
        HStack {
            Image(systemName: "doc.richtext")
                .sfSymbolStyling()
                .foregroundColor(.accentColor)
            TextField("Nom du document", text: $document.viewName)
                .textFieldStyle(.roundedBorder)
            Spacer(minLength: 12)
            Button("Voir") {
                isViewing.toggle()
            }
            .buttonStyle(.bordered)
        }
        // Modal: visualisation du document PDF
        .fullScreenCover(isPresented: $isViewing) {
            NavigationStack {
                PdfDocumentViewer(document: document)
            }
        }
    }
}

//struct DocumentRow_Previews: PreviewProvider {
//    static var previews: some View {
//        DocumentRow()
//    }
//}
