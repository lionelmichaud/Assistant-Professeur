//
//  DocumentRow.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 02/11/2022.
//

import SwiftUI

struct DocumentRow: View {
    var document: Document

    @State
    private var isViewing = false

    var body: some View {
        HStack {
            Label(document.docName, systemImage: "doc.richtext")
            Spacer()
            Button("Voir") {
                isViewing.toggle()
            }
            .buttonStyle(.bordered)
        }
        // Modal: ajout d'une nouvelle classe
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
