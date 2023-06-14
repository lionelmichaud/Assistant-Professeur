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

    let saveChanges: Bool

    @State
    private var isViewing = false

    var body: some View {
        HStack {
            Image(systemName: DocumentEntity.defaultImageName)
                .sfSymbolStyling()
                .foregroundColor(.accentColor)
            TextField(
                "Nom du document",
                text: saveChanges ? $document.viewName : $document.docName.bound
            )
            .textFieldStyle(.roundedBorder)
            Spacer(minLength: 12)
            Button {
                isViewing.toggle()
            } label: {
                Image(systemName: "eye")
            }
            .buttonStyle(.bordered)
        }
        // Modal: visualisation du document PDF
        #if os(macOS)
        .sheet(isPresented: $isViewing) {
            NavigationStack {
                PdfDocumentViewer(document: document)
            }
        }
        #else
                .fullScreenCover(isPresented: $isViewing) {
                    NavigationStack {
                        PdfDocumentViewer(document: document)
                    }
                }
        #endif
    }
}

struct DocumentRow_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            DocumentRow(
                document: DocumentEntity.all().first!,
                saveChanges: false
            )
            .padding()
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPad mini (6th generation)")

            DocumentRow(
                document: DocumentEntity.all().first!,
                saveChanges: false
            )
            .padding()
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPhone 13")
        }
    }
}
