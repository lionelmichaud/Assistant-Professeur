//
//  SequenceEditorMODAL.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 25/01/2023.
//

import SwiftUI
import HelpersView

struct SequenceEditorModal: View {
    @ObservedObject
    var sequence: SequenceEntity

    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.horizontalSizeClass)
    private var hClass

    @EnvironmentObject
    private var pref: UserPrefEntity

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
                text : $sequence.name.bound,
                axis : .vertical
            )
            .lineLimit(5)
            .font(hClass == .compact ? .callout : .body)
            .textFieldStyle(.roundedBorder)
            .focused($focus, equals: .title)

            if pref.viewSequenceAnnotationEnabled {
                TextField(
                    "Annotation",
                    text : $sequence.annotation.bound,
                    axis : .vertical
                )
                .lineLimit(5)
                .font(hClass == .compact ? .callout : .body)
                .textFieldStyle(.roundedBorder)
                .focused($focus, equals: .annotation)
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

extension SequenceEditorModal {
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

struct SequenceEditorModal_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            SequenceEditorModal(sequence: SequenceEntity.all().first!)
                .padding()
                .environmentObject(NavigationModel(selectedSequenceMngObjId: SequenceEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")
            SequenceEditorModal(sequence: SequenceEntity.all().first!)
                .padding()
                .environmentObject(NavigationModel(selectedSequenceMngObjId: SequenceEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
