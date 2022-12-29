//
//  ClassDetail.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 20/04/2022.
//

import SwiftUI
import AppFoundation
import HelpersView

enum ClasseNavigationRoute: Hashable {
    case room(ClasseEntity)
    case liste(ClasseEntity)
    case trombinoscope(ClasseEntity)
    case groups(ClasseEntity)
    case exam(ClasseEntity, UUID)

    static func == (lhs: ClasseNavigationRoute, rhs: ClasseNavigationRoute) -> Bool {
        switch (lhs, rhs) {
            case (.room(let classel), .room(let classer)):
                return (classel.id == classer.id)

            case (.liste(let classel), .liste(let classer)):
                return classel.id == classer.id

            case (.trombinoscope(let classel), .trombinoscope(let classer)):
                return classel.id == classer.id

            case (.groups(let classel), .groups(let classer)):
                return classel.id == classer.id

            case (.exam(let classel, let idl), .exam(let classer, let idr)):
                return (classel.id == classer.id) &&
                (idl == idr)

            default : return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
            case .room(let classe):
                hasher.combine("room")
                hasher.combine(classe.id)
            case .liste(let classe):
                hasher.combine("liste")
                hasher.combine(classe.id)
            case .trombinoscope(let classe):
                hasher.combine("trombinoscope")
                hasher.combine(classe.id)
            case .groups(let classe):
                hasher.combine("groups")
                hasher.combine(classe.id)
            case .exam(let classe, let id):
                hasher.combine(classe.id)
                hasher.combine(id)
        }
    }
}

struct ClasseDetail: View {
    @ObservedObject
    var classe: ClasseEntity

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

    // MARK: - Computed Properties

    private var roomView: some View {
        Text("roomView placeholder")
//        var school: School? {
//            guard let schoolId = classe.schoolId else {
//                return nil
//            }
//            return schoolStore.item(withID: schoolId)
//        }
//
//        var room: Room? {
//            guard let school, let roomId = classe.roomId else {
//                return nil
//            }
//            return RoomManager.room(withId: roomId, in: school)
//        }
//
//        var roomName: String {
//            room?.name ?? ""
//        }
//
//        return NavigationLink(value: ClasseNavigationRoute.room($classe)) {
//            HStack {
//                Text("Salle de classe")
//                    .fontWeight(.bold)
//                if classe.hasAssociatedRoom {
//                    Spacer()
//                    Text(roomName)
//                        .foregroundColor(.secondary)
//                }
//            }
//        }
    }

    private var elevesListView: some View {
        NavigationLink(value: ClasseNavigationRoute.liste(classe)) {
            Text("Liste")
                .fontWeight(.bold)
        }
    }

    private var trombinoscopeView: some View {
        Text("trombinoscopeView placeholder")
//        NavigationLink(value: ClasseNavigationRoute.trombinoscope($classe)) {
//            Text("Trombinoscope")
//                .fontWeight(.bold)
//        }
    }

    private var groupsView: some View {
        Text("groupsView placeholder")
//        NavigationLink(value: ClasseNavigationRoute.groups($classe)) {
//            Text("Groupes")
//                .fontWeight(.bold)
//        }
    }

    private var examsListView: some View {
        Text("examsListView placeholder")
//        Group {
//            // ajouter une évaluation
//            Button {
//                isAddingNewExam = true
//            } label: {
//                Label("Ajouter une évaluation", systemImage: "plus.circle.fill")
//            }
//            .buttonStyle(.borderless)
//
//            // édition de la liste des examen
//            ForEach($classe.exams) { $exam in
//                NavigationLink(value: ClasseNavigationRoute.exam($classe, exam.id)) {
//                    ClasseExamRow(exam: exam)
//                }
//                .swipeActions {
//                    // supprimer une évaluation
//                    Button(role: .destructive) {
//                        withAnimation {
//                            classe.exams.removeAll {
//                                $0.id == exam.id
//                            }
//                        }
//                    } label: {
//                        Label("Supprimer", systemImage: "trash")
//                    }
//                }
//            }
//        }
    }

    var body: some View {
        // TODO: - Rempacer par NavigationStack(path: $path) et garder la navigation vers les subview locale à cette View en utilisant @State private var path = NavigationPath()
        // https://swiftwithmajid.com/2022/10/05/mastering-navigationstack-in-swiftui-navigationpath/
        VStack {
            /// nom
            ClasseNameGroupBox(classe: classe)

            List {
                roomView

                /// appréciation sur la classe
                if classeAppreciationEnabled {
                    AppreciationView(appreciation: $classe.viewAppreciation)
                }
                /// annotation sur la classe
                if classeAnnotationEnabled {
                    AnnotationView(annotation: $classe.viewAnnotation)
                }

                Section {
                    /// édition de la liste des élèves
                    elevesListView

                    /// trombinoscope
                    if eleveTrombineEnabled {
                        trombinoscopeView
                    }

                    /// gestion des groupes
                    groupsView
                } header: {
                    Text("Elèves (\(classe.nbOfEleves))")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)
                }

                /// édition de la liste des examens
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
                /// Importation des données
                /// Importer une liste d'élèves d'une classe depuis un fichier CSV au format PRONOTE
                Button {
                    isShowingImportListeDialog.toggle()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                        .imageScale(.large)
                }
                /// Confirmation de l'importation d'une liste d'élèves d'une classe
                .confirmationDialog("Importer une liste d'élèves",
                                    isPresented     : $isShowingImportListeDialog,
                                    titleVisibility : .visible) {
                    Button("Importer et ajouter") {
                        withAnimation {
                            importCsvFile = true
                        }
                    }
                    Button("Importer et remplacer", role: .destructive) {
                        withAnimation {
//                            ClasseManager().retirerTousLesEleves(deClasse    : &classe,
//                                                                 eleveStore  : eleveStore,
//                                                                 observStore : observStore,
//                                                                 colleStore  : colleStore)
                        }
                        importCsvFile = true
                    }
                } message: {
                    Text("La liste des élèves importée doit être au format CSV de \(interoperability == .proNote ? "PRONOTE" : "EcoleDirecte").\n") +
                    Text("Cette action ne peut pas être annulée.")
                }
            }
        }
//        .alert(item: $alertItem, content: newAlert)
//        /// Importer un fichier CSV au format PRONOTE ou EcoleDirecte
//        .fileImporter(isPresented             : $importCsvFile,
//                      allowedContentTypes     : [.commaSeparatedText],
//                      allowsMultipleSelection : false) { result in
//            importCsvFiles(result: result)
//        }
        #if os(iOS)
        .navigationTitle("Classe")
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onDisappear(perform: save)
        .sheet(isPresented: $isAddingNewExam) {
            NavigationStack {
                Text("placeholder")
//                ExamCreator(elevesId: classe.elevesID) { newExam in
//                    /// Ajouter une nouvelle évaluation
//                    withAnimation {
//                        classe.exams.insert(newExam, at: 0)
//                    }
//                }
            }
            .presentationDetents([.medium])
        }
    }

    // MARK: - Methods

    private func save() {
        try? ClasseEntity.saveIfContextHasChanged()
        //school.refresh()
    }

    private func importCsvFiles(result: Result<[URL], Error>) {
//        switch result {
//            case .failure(let error):
//                self.alertItem = AlertItem(title         : Text("Échec"),
//                                           message       : Text("L'importation du fichier a échouée"),
//                                           dismissButton : .default(Text("OK")))
//                print("Error selecting file: \(error.localizedDescription)")
//
//            case .success(let filesUrl):
//                filesUrl.forEach { fileUrl in
//                    guard fileUrl.startAccessingSecurityScopedResource() else { return }
//
//                    if let data = try? Data(contentsOf: fileUrl) {
//                        do {
//                            var eleves = [Eleve]()
//
//                            switch interoperability {
//                                case .ecoleDirecte:
//                                    eleves = try CsvImporter().importElevesFromEcoleDirecte(from: data)
//
//                                case .proNote:
//                                    eleves = try CsvImporter().importElevesFromPRONOTE(from: data)
//                            }
//
//                            for idx in eleves.startIndex...eleves.endIndex-1 {
//                                withAnimation {
//                                    ClasseManager()
//                                        .ajouter(eleve      : &eleves[idx],
//                                                 aClasse    : &classe,
//                                                 eleveStore : eleveStore)
//                                }
//                            }
//                        } catch let error {
//                            self.alertItem = AlertItem(title         : Text("Échec"),
//                                                       message       : Text("L'importation du fichier a échouée"),
//                                                       dismissButton : .default(Text("OK")))
//                            print("Error reading file \(error.localizedDescription)")
//                        }
//                    }
//
//                    fileUrl.stopAccessingSecurityScopedResource()
//                }
//        }
    }
}

//struct ClassDetail_Previews: PreviewProvider {
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
//}
