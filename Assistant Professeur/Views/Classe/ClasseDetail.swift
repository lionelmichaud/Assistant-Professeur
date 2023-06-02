//
//  ClassDetail.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 20/04/2022.
//

import AppFoundation
import HelpersView
import SwiftUI

enum ClasseNavigationRoute: Hashable, Codable {
    case infos(ClasseEntity)
    case room(ClasseEntity)
    case liste(ClasseEntity)
    case trombinoscope(ClasseEntity)
    case groups(ClasseEntity)
    case exam(ClasseEntity, ExamEntity)
    case activity(ClasseEntity)
    case progress(ClasseEntity)

    static func == (lhs: ClasseNavigationRoute, rhs: ClasseNavigationRoute) -> Bool {
        switch (lhs, rhs) {
            case let (.infos(classel), .infos(classer)):
                return (classel.id == classer.id)

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

            case let (.activity(classel), .activity(classer)):
                return classel.id == classer.id

            case let (.progress(classel), .progress(classer)):
                return classel.id == classer.id

            default: return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
            case let .infos(classe):
                hasher.combine("infos")
                hasher.combine(classe.id)
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
            case let .activity(classe):
                hasher.combine("activity")
                hasher.combine(classe.id)
            case let .progress(classe):
                hasher.combine("progress")
                hasher.combine(classe.id)
        }
    }
}

struct ClasseDetail: View {
    @ObservedObject
    var classe: ClasseEntity

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    @Environment(\.horizontalSizeClass)
    private var hClass

    @EnvironmentObject
    private var pref: UserPreferences

    @State
    private var isShowingImportListeDialog = false

    @State
    private var isShowingClasseTimer = false

    @State
    private var randomEleve: EleveEntity?

    @State
    private var importCsvFile = false

    @State
    private var alertTitle = ""

    @State
    private var alertMessage = ""

    @State
    private var alertIsPresented = false

    // MARK: - Computed Properties

    var body: some View {
        // TODO: - Remplacer par NavigationStack(path: $path) et garder la navigation vers les subview locale à cette View en utilisant @State private var path = NavigationPath()
        // https://swiftwithmajid.com/2022/10/05/mastering-navigationstack-in-swiftui-navigationpath/
        VStack {
            // Groupe principal
            ClasseNameGroupBox(classe: classe)

            List {
                infosView

                // Section élèves
                Section {
                    // édition de la liste des élèves
                    elevesListView

                    // trombinoscope
                    if pref.eleve.trombineEnabled {
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

                // Section progression
                if let progresses = classe.progresses, progresses.count != 0 {
                    Section {
                        // Activité actuelle
                        currentActivityView

                        // Progression glogale
                        progressView
                    } header: {
                        Text("Progession")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                    }
                }

                // Section évaluations
                Section {
                    ExamListView(classe: classe)
                } header: {
                    Text("Evaluations (\(classe.nbOfExams))")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .fontWeight(.bold)
                }
            }
        }
        .toolbar(content: myToolBarContent)
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
            (
                alertTitle,
                alertMessage,
                alertIsPresented
            ) = CsvImportExportMng
                .importElevesListe(
                    for: classe,
                    interoperability: pref.interoperability,
                    result: result
                )
        }
        #if os(iOS)
        .navigationTitle("Classe")
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onDisappear {
            try? ClasseEntity.saveIfContextHasChanged()
        }
    }
}

// MARK: - Toolbar

extension ClasseDetail {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            ControlGroup {
                // Chronomètre de classe
                Button {
                    isShowingClasseTimer.toggle()
                } label: {
                    Image(systemName: "stopwatch")
                }
                .fullScreenCover(isPresented: $isShowingClasseTimer) {
                    NavigationStack {
                        if let schoolName = classe.school?.viewName {
                            ClasseTimerModal(
                                discipline: classe.disciplineEnum,
                                classeName: classe.displayString,
                                schoolName: schoolName
                            )
                        } else {
                            Text("Impossible d'affciehr le chronomètre")
                        }
                    }
                }

                // Tirer au sort un élève
                Button {
                    randomEleve = classe.elevesSortedByName.randomElement()
                } label: {
                    Image(systemName: "dice.fill")
                        .imageScale(.large)
                }
                .disabled(!pref.eleve.trombineEnabled)
                .popover(item: $randomEleve) { eleve in
                    TrombineView(eleve: eleve)
                        .scaledToFit()
                        .frame(minWidth: 200, minHeight: 250)
                    Text(eleve.displayName2lines(.prenomNom))
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .bold()
                        .padding(4)
                    if let group = eleve.group {
                        GroupCapsule(group: group)
                            .padding(.bottom)
                    }
                }

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
                    Text("La liste des élèves importée doit être au format CSV de \(pref.interoperability == .proNote ? "PRONOTE" : "EcoleDirecte").\n") +
                        Text("Cette action ne peut pas être annulée.")
                }
            }
        }
    }
}

// MARK: - Subviews

extension ClasseDetail {
    private var infosView: some View {
        NavigationLink(value: ClasseNavigationRoute.infos(classe)) {
            Label("Informations", systemImage: "info.circle")
                .fontWeight(.bold)
        }
    }

    private var currentActivityView: some View {
        NavigationLink(value: ClasseNavigationRoute.activity(classe)) {
            HStack {
                Label(hClass == .compact ? "Activité" : "Activité en cours", systemImage: "book.fill")
                    .fontWeight(.bold)
                if let activity = classe.currentActivity,
                   let sequence = activity.sequence {
                    let currentActivityProgress =
                        classe
                            .sortedProgressesInSequence(sequence)
                            .first(where: { $0.activity == activity })
                    Spacer()
                    if hClass == .compact {
                        Text("Seq \(sequence.viewNumber) - Act \(activity.viewNumber) (\(currentActivityProgress!.progress, format: .percent))")
                            .foregroundColor(.secondary)
                    } else {
                        Text("Séquence \(sequence.viewNumber) - Activité \(activity.viewNumber) (\(currentActivityProgress!.progress, format: .percent))")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    private var progressView: some View {
        NavigationLink(value: ClasseNavigationRoute.progress(classe)) {
            Label("Progression", systemImage: "books.vertical.fill")
                .fontWeight(.bold)
        }
    }

    private var elevesListView: some View {
        NavigationLink(value: ClasseNavigationRoute.liste(classe)) {
            Label("Liste d'appel", systemImage: "list.bullet")
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
}

struct ClassDetail_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            ClasseDetail(classe: ClasseEntity.all().first!)
                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")

            ClasseDetail(classe: ClasseEntity.all().first!)
                .environmentObject(NavigationModel(selectedClasseMngObjId: ClasseEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
