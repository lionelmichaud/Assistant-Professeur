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

    @Environment(\.horizontalSizeClass)
    private var hClass

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: DocumentEntity.defaultImageName)
                    .sfSymbolStyling()
                    .foregroundColor(.accentColor)
                TextField(
                    "Nom du document",
                    text: saveChanges ? $document.viewName : $document.docName.bound
                )
                .textFieldStyle(.roundedBorder)
            }
            HStack {
                Toggle(
                    isOn: saveChanges ? $document.viewIsForEleve : $document.unsavedIsForEleve,
                    label: {
                        if hClass == .compact {
                            Label("Elèves", systemImage: DocumentEntity.forEleveImageName)
                                .labelStyle(.iconOnly)
                        } else {
                            Label("Doc. Elèves", systemImage: DocumentEntity.forEleveImageName)
                        }
                    }
                )

                Toggle(
                    isOn: saveChanges ? $document.viewIsForENT : $document.unsavedIsForENT,
                    label: {
                        if hClass == .compact {
                            Label("ENT", systemImage: DocumentEntity.forEntImageName)
                                .labelStyle(.iconOnly)
                        } else {
                            Label("Ressource ENT", systemImage: DocumentEntity.forEntImageName)
                        }
                    }
                )

                Toggle(
                    isOn: saveChanges ? $document.viewIsForTeacher : $document.unsavedIsForTeacher,
                    label: {
                        if hClass == .compact {
                            Label("Prof.", systemImage: DocumentEntity.forTeacherImageName)
                                .labelStyle(.iconOnly)
                        } else {
                            Label("Professeur seul.", systemImage: DocumentEntity.forTeacherImageName)
                        }
                    }
                )

                Spacer()

                Button {
                    isViewing.toggle()
                } label: {
                    Image(systemName: "eye")
                }
                .buttonStyle(.bordered)
            }
            .toggleStyle(.button)
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
