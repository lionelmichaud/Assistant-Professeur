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
            Label(document.viewName, systemImage: "doc.richtext")
            Spacer()
            Button("Voir") {
                isViewing.toggle()
            }
            .buttonStyle(.bordered)
        }
        // Modal: visualisation du document PDF
        .sheet(isPresented: $isViewing) {
            NavigationStack {
                PdfDocumentViewer(document: document)
            }
            .presentationDetents([.large])
        }
    }
}

//struct DocumentRow_Previews: PreviewProvider {
//    static var previews: some View {
//        DocumentRow()
//    }
//}
