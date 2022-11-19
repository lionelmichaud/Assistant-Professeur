//
//  SchoolBrowserView.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 15/04/2022.
//

import SwiftUI
import Files
import FileAndFolder
import HelpersView

struct SchoolSidebarView: View {
    @EnvironmentObject private var navigationModel : NavigationModel
    @EnvironmentObject private var schoolStore : SchoolStore
    @EnvironmentObject private var classeStore : ClasseStore
    @EnvironmentObject private var eleveStore  : EleveStore
    @EnvironmentObject private var colleStore  : ColleStore
    @EnvironmentObject private var observStore : ObservationStore

    @State
    private var isAddingNewEtab = false
    @State
    private var isEditingPreferences = false
    @State
    private var alertItem: AlertItem?
    @State
    private var isShowingImportConfirmDialog = false
    @State
    private var isShowingDeleteConfirmDialog = false
    @State
    private var isShowingImportTrombineDialog = false
    @State
    private var isShowingRepairDBDialog = false
    @State
    private var isShowingAbout = false
    @State
    private var isImportingJpegFile = false
    @State
    private var progress = 0.0
    @State
    private var isProgressing = false

    // MARK: - Computed Properties

    private var jsonURLsToShare: [URL] {
        ImportExportManager.documentsURLsToShare(fileNames: [".json"])
    }

    private var shareMenuItem: some View {
        Group {
            if jsonURLsToShare.isNotEmpty {
                ShareLink("Exporter vos données",
                          items: jsonURLsToShare,
                          subject: Text("Cahier du professeur"),
                          message: Text("Base de données"))
            } else {
                EmptyView()
            }
        }
    }

    var body: some View {
        if progress > 0.0 {
            ProgressView(value: progress)
        }
        if isProgressing {
            ProgressView()
        }
        List(selection: $navigationModel.selectedSchoolId) {
            if schoolStore.items.isEmpty {
                Text("Aucun établissement actuellement")
            }
            /// pour chaque Type d'établissement
            ForEach(NiveauSchool.allCases) { niveau in
                if !schoolStore.sortedSchools(niveau: niveau).isEmpty {
                    Section {
                        /// pour chaque Etablissement
                        ForEach(schoolStore.sortedSchools(niveau: niveau)) { $school in
                            SchoolBrowserRow(school: school)
                                .swipeActions {
                                    // supprimer l'établissement
                                    Button(role: .destructive) {
                                        withAnimation {
                                            schoolStore.deleteSchool(school,
                                                                     classeStore : classeStore,
                                                                     eleveStore  : eleveStore,
                                                                     observStore : observStore,
                                                                     colleStore  : colleStore)
                                        }
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }

                                    // modifier le type de l'établissement
                                    if school.nbOfClasses == 0 {
                                        Button {
                                            withAnimation {
                                                if school.niveau == .college {
                                                    school.niveau = .lycee
                                                } else {
                                                    school.niveau = .college
                                                }
                                            }
                                        } label: {
                                            Label(school.niveau == .college ? "Lycée" : "Collège",
                                                  systemImage: school.niveau == .college ?  "building.2" : "building")
                                        }.tint(school.niveau == .college ? .mint : .orange)
                                    }
                                }
                        }
                    } header: {
                        Text(niveau.displayString)
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                    }
                }
            }

            #if targetEnvironment(simulator)
            Button {
                TestEnvir.populateWithFakes(
                    schoolStore : schoolStore,
                    classeStore : classeStore,
                    eleveStore  : eleveStore,
                    observStore : observStore,
                    colleStore  : colleStore)
            } label: {
                Text("Test").foregroundColor(.primary)
            }
            #endif
        }
        .navigationTitle("Établissements")
        //.navigationViewStyle(.columns)
        .toolbar(content: myToolBarContent)

        .sheet(isPresented: $isShowingAbout) {
            NavigationStack {
                AppVersionView()
            }
            .presentationDetents([.large])
        }

        .sheet(isPresented: $isEditingPreferences) {
            NavigationStack {
                SettingsView()
            }
            .presentationDetents([.large])
        }

        .sheet(isPresented: $isAddingNewEtab) {
            NavigationStack {
                SchoolCreator { school in
                    schoolStore.add(school)
                }
            }
            .presentationDetents([.medium])
        }
        /// Importer des fichiers JPEG
        .fileImporter(isPresented             : $isImportingJpegFile,
                      allowedContentTypes     : [.jpeg],
                      allowsMultipleSelection : true) { result in
            importUserSelectedFiles(result: result)
        }
                      .alert(item: $alertItem, content: newAlert)
    }

    // MARK: - Methods

    @ToolbarContentBuilder
    func myToolBarContent() -> some ToolbarContent {
        /// Ajouter un établissement
        ToolbarItemGroup(placement: .status) {
            Button {
                isAddingNewEtab = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Ajouter un établissement")
                    Spacer()
                }
            }
        }

        /// Menu
        ToolbarItemGroup(placement: .automatic) {
            Menu {
                /// A propos
                Button {
                    isShowingAbout = true
                } label: {
                    Label("A propos", systemImage: "info.circle")
                }

                /// Edition des préférences utilisateur
                Button {
                    isEditingPreferences = true
                } label: {
                    Label("Préférences", systemImage: "gear")
                }

                /// Exporter les fichiers JSON utilisateurs
                shareMenuItem

                /// Importer des fichiers JPEG pour le trombinoscope
                Button {
                    isShowingImportTrombineDialog.toggle()
                } label: {
                    Label("Importer des photos du trombinoscope", systemImage: "person.crop.rectangle.stack.fill")
                }

                /// Importer les fichiers JSON depuis le Bundle Application
                Button(role: .destructive) {
                    isShowingImportConfirmDialog.toggle()
                } label: {
                    Label("Importer les données de l'App", systemImage: "square.and.arrow.down")
                }

                /// Reconstruire la BDD
                Button(role: .destructive) {
                    isShowingRepairDBDialog.toggle()
                } label: {
                    Label("Réparer la base de donnée", systemImage: "wrench.adjustable")
                }

                /// Effacer toutes les données utilisateur
                Button(role: .destructive) {
                    isShowingDeleteConfirmDialog.toggle()
                } label: {
                    Label("supprimer toutes vos données", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }

            /// Confirmation importation de tous les fichiers depuis l'App
            .confirmationDialog("Importation des fichiers de l'App",
                                isPresented: $isShowingImportConfirmDialog,
                                titleVisibility : .visible) {
                Button("Importer", role: .destructive) {
                    withAnimation {
                        self.import()
                    }
                }
            } message: {
                Text("L'importation va remplacer vos données actuelles par celles contenues dans l'Application.\n") +
                Text("Cette action ne peut pas être annulée.")
            }

            /// Confirmation importation des fichiers JPEG pour le trombinoscope
            .confirmationDialog("Importer des photos d'élèves",
                                isPresented     : $isShowingImportTrombineDialog,
                                titleVisibility : .visible) {
                Button("Importer") {
                    withAnimation {
                        isImportingJpegFile = true
                    }
                }
            } message: {
                Text("Les photos importées doivent être au format JPEG ") +
                Text("et être nommées NOM_Prénom.jpg.\n") +
                Text("Cette action ne peut pas être annulée.")
            }

            /// Confirmation de Suppression de toutes vos données
            .confirmationDialog("Suppression de toutes vos données",
                                isPresented: $isShowingDeleteConfirmDialog,
                                titleVisibility : .visible) {
                Button("Supprimer", role: .destructive) {
                    withAnimation {
                        self.clearAllUserData()
                    }
                }
            } message: {
                Text("Cette action ne peut pas être annulée.")
            }

            /// Confirmation de la réparation de la base de données
            .confirmationDialog("Réparation de la base de données",
                                isPresented: $isShowingRepairDBDialog,
                                titleVisibility : .visible) {
                Button("Réparer", role: .destructive) {
                    withAnimation {
                        self.repairDataBase()
                    }
                }
            } message: {
                Text("Cette opération peut prendre plusieurs minutes.\n") +
                Text("Cette action ne peut pas être annulée.")
            }
        }
    }

    /// Importer tous les fichiers JSON, JPEG et PNG depuis le Bundle Application
    private func `import`() {
        // Copier les fichiers contenus dans le Bundle de l'application vers le répertoire Document de l'utilisateur
        do {
            try PersistenceManager().forcedImportAllFilesFromApp(fileExtensions: ["json", "jpg", "png", "pdf"])
        } catch {
            /// trigger second alert
            DispatchQueue.main.async {
                self.alertItem = AlertItem(title: Text("Erreur"),
                                           message: Text("L'importation des fichiers a échouée!"),
                                           dismissButton: .default(Text("OK")))
            }
        }
        do {
            // Initialiser les objets du model à partir des fichiers JSON
            try schoolStore.loadFromJSON(fromFolder: nil)
            try classeStore.loadFromJSON(fromFolder: nil)
            try eleveStore.loadFromJSON(fromFolder: nil)
            try colleStore.loadFromJSON(fromFolder: nil)
            try observStore.loadFromJSON(fromFolder: nil)
        } catch {
            /// trigger second alert
            DispatchQueue.main.async {
                self.alertItem = AlertItem(title         : Text("Erreur"),
                                           message       : Text("La lecture des fichiers importés a échouée!"),
                                           dismissButton : .default(Text("OK")))
            }
        }
        eleveStore.sort()
    }

    /// Suppression de toutes les données utilisateur
    private func clearAllUserData() {
        //        DispatchQueue.global(qos: .background).async {
        let nbSteps = 6.0
        progress = 0.0

        schoolStore.clear()
        //        DispatchQueue.main.async {
        progress += 1.0/nbSteps
        //        }
        //        sleep(1)
        classeStore.clear()
        progress += 1.0/nbSteps
        eleveStore.clear()
        progress += 1.0/nbSteps
        colleStore.clear()
        progress += 1.0/nbSteps
        observStore.clear()
        progress += 1.0/nbSteps
        Trombinoscope.deleteAllTrombines()
        progress += 1.0/nbSteps
        progress = 0.0
        //        }
    }

    /// Copier les fichiers  sélectionnés dans le dossier Document de l'application.
    /// - Parameter result: résultat de la sélection des fichiers issue de fileImporter.
    private func importUserSelectedFiles(result: Result<[URL], Error>) {
        switch result {
            case .failure(let error):
                self.alertItem = AlertItem(title         : Text("Échec"),
                                           message       : Text("L'importation des fichiers a échoué"),
                                           dismissButton : .default(Text("OK")))
                print("Error selecting file: \(error.localizedDescription)")

            case .success(let filesUrl):
                do {
                    try ImportExportManager.importURLsToDocumentsFolder(filesUrl             : filesUrl,
                                                                        importIfAlreadyExist : true)

                } catch {
                    self.alertItem = AlertItem(title         : Text("Échec"),
                                               message       : Text("L'importation des fichiers a échoué"),
                                               dismissButton : .default(Text("OK")))
                }
        }
    }

    private func repairDataBase() {
        isProgressing.toggle()
        let success = PersistenceManager.repairDataBase(schoolStore: schoolStore,
                                                        classeStore: classeStore,
                                                        eleveStore : eleveStore,
                                                        colleStore : colleStore,
                                                        observStore: observStore)
        isProgressing.toggle()
        if !success {
            self.alertItem = AlertItem(title: Text("Erreur"),
                                       message: Text("La base de donnée n'a pas pu être complètement réparée !"),
                                       dismissButton: .default(Text("OK")))
        } else {
            self.alertItem = AlertItem(title: Text(""),
                                       message: Text("La base de donnée est réparée"),
                                       dismissButton: .default(Text("OK")))
        }
    }
}

struct SchoolSidebarView_Previews: PreviewProvider {
    static var previews: some View {
        TestEnvir.createFakes()
        return Group {
            SchoolSidebarView()
                .environmentObject(NavigationModel(selectedSchoolId: TestEnvir.schoolStore.items.first!.id))
                .environmentObject(TestEnvir.schoolStore)
                .environmentObject(TestEnvir.classeStore)
                .environmentObject(TestEnvir.eleveStore)
                .environmentObject(TestEnvir.colleStore)
                .environmentObject(TestEnvir.observStore)
                .previewDevice("iPad mini (6th generation)")

            SchoolSidebarView()
                .environmentObject(NavigationModel(selectedSchoolId: TestEnvir.schoolStore.items.first!.id))
                .environmentObject(TestEnvir.schoolStore)
                .environmentObject(TestEnvir.classeStore)
                .environmentObject(TestEnvir.eleveStore)
                .environmentObject(TestEnvir.colleStore)
                .environmentObject(TestEnvir.observStore)
                .previewDevice("iPhone 13")
        }
    }
}
