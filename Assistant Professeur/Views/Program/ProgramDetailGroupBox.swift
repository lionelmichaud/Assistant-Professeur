//
//  ProgramDetail.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/01/2023.
//

import HelpersView
import SwiftUI

struct ProgramDetailGroupBox: View {
    @ObservedObject
    var program: ProgramEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    @Environment(UserContext.self)
    private var userContext

    @State
    private var isViewing = false

    var body: some View {
        GroupBox {
            // Discipline - Niveau
            ProgramDisciplineLevel(program: program)
                .bold()
                .horizontallyAligned(.leading)

            // note sur le programme
            if userContext.prefs.viewProgramAnnotationEnabled && program.viewAnnotation.isNotEmpty {
                AnnotationView(
                    annotation: program.viewAnnotation,
                    scrollable: true,
                    scrollHeight: 40
                )
                .horizontallyAligned(.leading)
            }

            // Document
            if let document = program.document {
                Button {
                    isViewing.toggle()
                } label: {
                    Label(document.viewName, systemImage: DocumentEntity.defaultImageName)
                }
                .horizontallyAligned(.leading)
                .padding(.top, 4)
            }

            // Durées / url
            HStack {
                DurationView(duration: program.durationWithoutMargin, withMargin: false)
                Spacer()
                DurationView(duration: program.durationWithMargin, withMargin: true)
                Spacer()
                WebsiteView(url: program.url, showURL: false)
            }
            .padding(.top, 4)
        }
        .font(hClass == .compact ? .subheadline : .callout)
        #if os(macOS)
            .sheet(isPresented: $isViewing) {
                NavigationStack {
                    PdfDocumentViewer(document: program.document!)
                }
            }
        #else
                .fullScreenCover(isPresented: $isViewing) {
                    NavigationStack {
                        PdfDocumentViewer(document: program.document!)
                    }
                }
        #endif
    }
}

struct ProgramDetail_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            ProgramDetailGroupBox(program: ProgramEntity.all().first!)
                .padding()
                .environmentObject(NavigationModel(selectedProgramMngObjId: ProgramEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")
            ProgramDetailGroupBox(program: ProgramEntity.all().first!)
                .padding()
                .environmentObject(NavigationModel(selectedProgramMngObjId: ProgramEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
