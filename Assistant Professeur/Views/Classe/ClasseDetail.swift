//
//  ClassDetail.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 20/04/2022.
//

import AppFoundation
import HelpersView
import SwiftUI

enum ClasseNavigationRoute: Hashable {
    case room(ClasseEntity)
    case liste(ClasseEntity)
    case trombinoscope(ClasseEntity)
    case groups(ClasseEntity)
    case exam(ClasseEntity, ExamEntity)

    static func == (lhs: ClasseNavigationRoute, rhs: ClasseNavigationRoute) -> Bool {
        switch (lhs, rhs) {
        case let (.room(classel), .room(classer)):
            return (classel.id == classer.id)

        case let (.liste(classel), .liste(classer)):
            return classel.id == classer.id

        case let (.trombinoscope(classel), .trombinoscope(classer)):
            return classel.id == classer.id

        case let (.groups(classel), .groups(classer)):
            return classel.id == classer.id

        case let (.exam(classel, examl), .exam(classer, examr)):
            return (classel.id == classer.id) &&
                (examl == examr)

        default: return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case let .room(classe):
            hasher.combine("room")
            hasher.combine(classe.id)
        case let .liste(classe):
            hasher.combine("liste")
            hasher.combine(classe.id)
        case let .trombinoscope(classe):
            hasher.combine("trombinoscope")
            hasher.combine(classe.id)
        case let .groups(classe):
            hasher.combine("groups")
            hasher.combine(classe.id)
        case let .exam(classe, exam):
            hasher.combine(classe.id)
            hasher.combine(exam.id)
        }
    }
}

struct ClasseDetail: View {
    @ObservedObject
    var classe: ClasseEntity

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    @Preference(\.interoperability)
    private var interoperability

    @Preference(\.classeAppreciationEnabled)
    private var classeAppreciationEnabled

    @Preference(\.classeAnnotationEnabled)
    private var classeAnnotationEnabled

    @Preference(\.eleveTrombineEnabled)
    private var eleveTrombineEnabled

    @State
    private var isShowingImportListeDialog = false

    @State
    private var importCsvFile = false

    @State
    private var isAddingNewExam = false

    @State
    private var alertTitle = ""

    @State
    private var alertMessage = ""

    @State
    private var alertIsPresented = false

    // MARK: - Computed Properties

    private var roomView: some View {
        return NavigationLink(value: ClasseNavigationRoute.room(classe)) {
            HStack {
                Label("Salle de classe", systemImage: "door.left.hand.open")
                    .fontWeight(.bold)
                if classe.hasAssociatedRoom {
                    Spacer()
                    Text(classe.room!.viewName)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var elevesListView: some View {
        NavigationLink(value: ClasseNavigationRoute.liste(classe)) {
            Label("Liste", systemImage: "list.bullet")
                .fontWeight(.bold)
        }
    }

    private var trombinoscopeView: some View {
        NavigationLink(value: ClasseNavigationRoute.trombinoscope(classe)) {
            Label("Trombinoscope", systemImage: "person.crop.square.fill")
                .fontWeight(.bold)
        }
    }

    private var groupsView: some View {
        NavigationLink(value: ClasseNavigationRoute.groups(classe)) {
            Label("Groupes", systemImage: "person.line.dotted.person.fill")
                .fontWeight(.bold)
        }
    }

    private var examsListView: some View {
        return Group {
            // ajouter une évaluation
            Button {
                isAddingNewExam = true
            } label: {
                Label("Ajouter une évaluation", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderless)

            // édition de la liste des examen
            ForEach(classe.allExams) { exam in
                NavigationLink(value: ClasseNavigationRoute.exam(classe, exam)) {
                    ClasseExamRow(exam: exam)
                }
            }
            .onDelete(perform: deleteItems)
        }

        func deleteItems(offsets: IndexSet) {
            withAnimation {
                offsets
                    .map { classe.allExams[$0] }
                    .forEach(managedObjectContext.delete)

                try? ExamEntity.saveIfContextHasChanged()
            }
        }
    }

    var body: some View {
        // TODO: - Remplacer par NavigationStack(path: $path) et garder la navigation vers les subview locale à cette View en utilisant @State private var path = NavigationPath()
        // https://swiftwithmajid.com/2022/10/05/mastering-navigationstack-in-swiftui-navigationpath/
        VStack {
            // nom
            ClasseNameGroupBox(classe: classe)

            List {
                // appréciation sur la classe
                if classeAppreciationEnabled {
                    AppreciationView(appreciation: $classe.viewAppreciation)
                }
                // annotation sur la classe
                if classeAnnotationEnabled {
                    AnnotationEditView(annotation: $classe.viewAnnotation)
                }

                roomView

                Section {
                    // édition de la liste des élèves
                    elevesListView

                    // trombinoscope
                    if eleveTrombineEnabled {
                        trombinoscopeView
                    }

                    // gestion des groupes
                    groupsView
                } header: {
                    Text("Elèves (\(classe.nbOfEleves))")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)
                }

                // édition de la liste des examens
                Section {
                    examsListView
                } header: {
                    Text("Evaluations (\(classe.nbOfExams))")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Importation des données
                // Importer une liste d'élèves d'une classe depuis un fichier CSV au format PRONOTE
                Button {
                    isShowingImportListeDialog.toggle()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .imageScale(.large)
                }
                // Confirmation de l'importation d'une liste d'élèves d'une classe
                .confirmationDialog(
                    "Importer une liste d'élèves",
                    isPresented: $isShowingImportListeDialog,
                    titleVisibility: .visible
                ) {
                    Button("Importer et ajouter") {
                        withAnimation {
                            importCsvFile = true
                        }
                    }
                    Button("Importer et remplacer", role: .destructive) {
                        withAnimation {
                            classe.allEleves.forEach { eleve in
                                try? eleve.delete()
                            }
                        }
                        importCsvFile = true
                    }
                } message: {
                    Text("La liste des élèves importée doit être au format CSV de \(interoperability == .proNote ? "PRONOTE" : "EcoleDirecte").\n") +
                        Text("Cette action ne peut pas être annulée.")
                }
            }
        }
        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {},
            message: { Text(alertMessage) }
        )
        // Importer un fichier CSV au format PRONOTE ou EcoleDirecte
        .fileImporter(
            isPresented: $importCsvFile,
            allowedContentTypes: [.commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            importCsvFiles(result: result)
        }
        #if os(iOS)
        .navigationTitle("Classe")
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onDisappear(perform: save)
        .sheet(isPresented: $isAddingNewExam) {
            NavigationStack {
                ExamCreatorModal(classe: classe)
            }
            .presentationDetents([.medium])
        }
    }

    // MARK: - Methods

    private func save() {
        try? ClasseEntity.saveIfContextHasChanged()
        // school.refresh()
    }

    private func importCsvFiles(result: Result<[URL], Error>) {
        switch result {
        case let .failure(error):
            print("Error selecting file: \(error.localizedDescription)")
            alertTitle = "Échec"
            alertMessage = "L'importation du fichier a échouée"
            alertIsPresented.toggle()

        case let .success(filesUrl):
            filesUrl.forEach { fileUrl in
                guard fileUrl.startAccessingSecurityScopedResource() else {
                    return
                }

                if let data = try? Data(contentsOf: fileUrl) {
                    do {
                        switch interoperability {
                        case .ecoleDirecte:
                            try CsvImporter()
                                .importElevesFromEcoleDirecte(
                                    from: data,
                                    dans: classe
                                )

                        case .proNote:
                            try CsvImporter()
                                .importElevesFromPRONOTE(
                                    from: data,
                                    dans: classe
                                )
                        }
                    } catch {
                        print("Error reading file \(error.localizedDescription)")
                        alertTitle = "Échec"
                        alertMessage = "L'importation du fichier a échouée"
                        alertIsPresented.toggle()
                    }
                }

                fileUrl.stopAccessingSecurityScopedResource()
            }
        }
    }
}

// struct ClassDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            NavigationStack {
//                ClasseDetail(classe: .constant(TestEnvir.classeStore.items.first!))
//                    .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPad mini (6th generation)")
//
//            NavigationStack {
//                ClasseDetail(classe: .constant(TestEnvir.classeStore.items.first!))
//                    .environmentObject(NavigationModel(selectedClasseId: TestEnvir.classeStore.items.first!.id))
//                    .environmentObject(TestEnvir.schoolStore)
//                    .environmentObject(TestEnvir.classeStore)
//                    .environmentObject(TestEnvir.eleveStore)
//                    .environmentObject(TestEnvir.colleStore)
//                    .environmentObject(TestEnvir.observStore)
//            }
//            .previewDevice("iPhone 13")
//        }
//    }
// }
