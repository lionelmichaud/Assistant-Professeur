//
//  SequenceModalView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 10/11/2023.
//

import HelpersView
import SwiftUI

struct SequenceModalView: View {
    @ObservedObject
    var sequence: SequenceEntity

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.horizontalSizeClass)
    private var hClass

    @EnvironmentObject
    private var userContext: UserContext

    /// Focused filed manager
    enum FocusableField: Hashable {
        case title
        case annotation
        case none

        mutating func moveToNext() {
            switch self {
                case .title:
                    self = .annotation
                case .annotation:
                    self = .none
                case .none:
                    self = .none
            }
        }
    }

    @FocusState
    private var focus: FocusableField?

    @State
    private var isImportingPdfFile = false

    var body: some View {
        Form {
            TextField(
                "Titre",
                text: $sequence.name.bound,
                axis: .vertical
            )
            .lineLimit(5)
            .font(hClass == .compact ? .callout : .body)
            .textFieldStyle(.roundedBorder)
            .focused($focus, equals: .title)

            if userContext.prefs.viewSequenceAnnotationEnabled {
                TextField(
                    "Annotation",
                    text: $sequence.annotation.bound,
                    axis: .vertical
                )
                .lineLimit(5)
                .font(hClass == .compact ? .callout : .body)
                .textFieldStyle(.roundedBorder)
                .focused($focus, equals: .annotation)
            }

            // marge post-séquence
            Stepper(
                value: $sequence.margePostSequence,
                in: 0 ... 3,
                step: 1
            ) {
                HStack {
                    Text("Marge post-séquence")
                    Spacer()
                    Text("\(sequence.margePostSequence) séances")
                        .foregroundColor(.secondary)
                }
            }

            // édition de la liste des documents utiles
            SequenceDocumentList(sequence: sequence)

            WebsiteEditView(website: $sequence.url)
        }
        .onSubmit {
            focus?.moveToNext()
        }
        .onAppear {
            focus = .title
        }
        #if os(iOS)
        .navigationTitle("Séquence")
        #endif
        .navigationBarTitleDisplayModeInline()
        .toolbar(content: myToolBarContent)
    }
}

// MARK: Toolbar Content

extension SequenceModalView {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Annuler") {
                SequenceEntity.rollback()
                dismiss()
            }
        }

        ToolbarItem(placement: .confirmationAction) {
            Button("Ok") {
                withAnimation {
                    try? SequenceEntity.saveIfContextHasChanged()
                }
                dismiss()
            }
        }
    }
}

// #Preview {
//    SequenceModalView()
// }

//struct SequenceEditorModal_Previews: PreviewProvider {
//    static func initialize() {
//        DataBaseManager.populateWithMockData(storeType: .inMemory)
//    }
//
//    static var previews: some View {
//        initialize()
//        return Group {
//            SequenceEditorModal(sequence: SequenceEntity.all().first!)
//                .padding()
//                .environmentObject(NavigationModel(selectedSequenceMngObjId: SequenceEntity.all().first!.objectID))
//                .environment(\.managedObjectContext, CoreDataManager.shared.context)
//                .previewDevice("iPad mini (6th generation)")
//            SequenceEditorModal(sequence: SequenceEntity.all().first!)
//                .padding()
//                .environmentObject(NavigationModel(selectedSequenceMngObjId: SequenceEntity.all().first!.objectID))
//                .environment(\.managedObjectContext, CoreDataManager.shared.context)
//                .previewDevice("iPhone 13")
//        }
//    }
//}
