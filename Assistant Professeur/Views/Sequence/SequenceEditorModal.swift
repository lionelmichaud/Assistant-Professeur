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

    @Preference(\.programAnnotationEnabled)
    private var annotationEnabled

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

    @State
    private var alertTitle = ""

    @State
    private var alertMessage = ""

    @State
    private var alertIsPresented = false

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

            if annotationEnabled {
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

            if let document = sequence.document {
                HStack(spacing: 5) {
                    // afficher le nom du document
                    DocumentRow(
                        document: document,
                        saveChanges: false
                    )

                    // supprimer le document
                    Button(role: .destructive) {
                        DocumentEntity.viewContext.delete(document)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                // ajouter un document
                Button {
                    isImportingPdfFile.toggle()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Ajouter un document")
                    }
                }
                .buttonStyle(.borderless)
            }

            WebsiteEditView(website: $sequence.url)
        }
        .onSubmit {
            focus?.moveToNext()
        }
        .onAppear {
            focus = .title
        }
        // Importer des fichiers PDF
        .fileImporter(
            isPresented: $isImportingPdfFile,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            (
                alertTitle,
                alertMessage,
                alertIsPresented
            ) = ImportExportManager.importUserSelectedFiles(
                result: result
            ) { data, fileName in
                DocumentEntity.create(
                    forSequence: sequence,
                    withData: data,
                    withName: fileName
                )
            }
        }
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: { },
            message: { Text(alertMessage) }
        )
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

//struct SequenceEditorModal_Previews: PreviewProvider {
//    static var previews: some View {
//        SequenceEditorModal()
//    }
//}
