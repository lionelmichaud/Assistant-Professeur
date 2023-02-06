//
//  SchoolBrowserView.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 15/04/2022.
//

import os
import SwiftUI

// import Files
// import FileAndFolder
import HelpersView

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "SchoolSidebarView"
)

struct SchoolSidebarView: View {
    @EnvironmentObject
    private var navigationModel: NavigationModel

    @SectionedFetchRequest<String, SchoolEntity>(
        fetchRequest: SchoolEntity.requestAllSortedByLevelName,
        sectionIdentifier: \.levelString,
        animation: .default
    )
    private var schoolsSections: SectionedFetchResults<String, SchoolEntity>

    @State
    private var isAddingNewSchool = false

    @State
    private var isEditingPreferences = false

    @State
    private var isShowingAbout = false

    @State
    private var alertTitle = ""

    @State
    private var alertMessage = ""

    @State
    private var alertIsPresented = false

    @State
    private var isShowingDeleteConfirmDialog = false

    @State
    private var isShowingImportConfirmDialog = false
    @State
    private var isShowingImportTrombineDialog = false
    @State
    private var isShowingRepairDBDialog = false
    @State
    private var isImportingJpegFile = false

    // MARK: - Computed Properties

    var body: some View {
        List(selection: $navigationModel.selectedSchoolId) {
            if SchoolEntity.all().isEmpty {
                Text("Aucun établissement actuellement")
            }
            // pour chaque Type d'établissement
            ForEach(schoolsSections) { section in
                if section.isNotEmpty {
                    Section {
                        // pour chaque Etablissement
                        ForEach(section, id: \.objectID) { school in
                            SchoolBrowserRow(school: school)
                                .badge(school.nbOfClasses)

                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    // supprimer l'établissement et tous ses descendants
                                    Button(role: .destructive) {
                                        withAnimation {
                                            try? school.delete()
                                            if navigationModel.selectedSchoolId == school.objectID {
                                                navigationModel.selectedSchoolId = nil
                                            }
                                        }
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }

                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    // modifier le type de l'établissement
                                    if school.classesCount == 0 {
                                        Button {
                                            withAnimation {
                                                if school.classesCount == 0 {
                                                    school.toggleLevel()
                                                }
                                            }
                                        } label: {
                                            Label(
                                                school.levelEnum == .college ? "Lycée" : "Collège",
                                                systemImage: school.levelEnum == .college ? "building.2" : "building"
                                            )
                                        }
                                        .tint(school.levelEnum == .college ? .mint : .orange)
                                    }
                                }
                        }
                    } header: {
                        Text(section.id + "s")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                    }
                }
            }
        }
        .navigationTitle("Établissements")
        // .navigationViewStyle(.columns)
        .toolbar(content: myToolBarContent)

        .alert(
            alertTitle,
            isPresented: $alertIsPresented,
            actions: {},
            message: { Text(alertMessage) }
        )

        .sheet(isPresented: $isShowingAbout) {
            AppVersionView()
                .presentationDetents([.large])
        }

        // Modal Sheet de gestion des Préférences
        .sheet(isPresented: $isEditingPreferences) {
            NavigationStack {
                SettingsView()
            }
            .presentationDetents([.large])
        }

        // Modal Sheet de création d'un nouvel établissement
        .sheet(
            isPresented: $isAddingNewSchool
            // onDismiss: {}
        ) {
            NavigationStack {
                SchoolCreatorModal()
                    .presentationDetents([.medium])
            }
        }

        // Importer des fichiers JPEG
        .fileImporter(
            isPresented: $isImportingJpegFile,
            allowedContentTypes: [.jpeg],
            allowsMultipleSelection: true
        ) { result in
            importUserSelectedFiles(result: result)
        }
    }
}

// MARK: Toolbar Content

extension SchoolSidebarView {
    @ToolbarContentBuilder
    private func myToolBarContent() -> some ToolbarContent {
        // Ajouter un établissement
        ToolbarItemGroup(placement: .status) {
            Button {
                isAddingNewSchool = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Ajouter un établissement")
                    Spacer()
                }
            }
        }

        // Menu
        ToolbarItemGroup(placement: .automatic) {
            Menu {
                Section {
                    // A propos
                    Button {
                        isShowingAbout = true
                    } label: {
                        Label("A propos", systemImage: "info.circle")
                    }

                    // Edition des préférences utilisateur
                    Button {
                        isEditingPreferences = true
                    } label: {
                        Label("Préférences", systemImage: "gear")
                    }

                    // Exporter les fichiers JSON utilisateurs
                    // shareMenuItem
                    // Vérifier la cohérence de la base de donnée
                    Button {
                        checkAllUserData()
                    } label: {
                        Label("Vérifier la base de donnée", systemImage: "checkmark.circle.trianglebadge.exclamationmark")
                    }
                }

                Section {
                    // Importer des fichiers JPEG pour le trombinoscope
                    Button(role: .destructive) {
                        isShowingImportTrombineDialog.toggle()
                    } label: {
                        Label("Importer des photos du trombinoscope", systemImage: "person.crop.rectangle.stack.fill")
                    }

                    // Importer les fichiers JSON depuis le Bundle Application
                    Button(role: .destructive) {
                        isShowingImportConfirmDialog.toggle()
                    } label: {
                        Label("Importer les données de l'App", systemImage: "square.and.arrow.down")
                    }

                    // Effacer toutes les données utilisateur
                    Button(role: .destructive) {
                        isShowingDeleteConfirmDialog.toggle()
                    } label: {
                        Label("Supprimer toutes vos données", systemImage: "trash")
                    }
                }

                #if targetEnvironment(simulator)
                    Section {
                        Button {
                            alertTitle = "Échec"
                            alertMessage = "L'effacement complet de la base de donnée a échoué"

                            withAnimation {
                                DataBaseManager.populate(failed: &alertIsPresented)
                            }
                        } label: {
                            Text("Dev - Peupler la BDD").foregroundColor(.primary)
                        }
                    }
                #endif
            } label: {
                Image(systemName: "ellipsis.circle")
            }

            // Confirmation importation de tous les fichiers depuis l'App
            .confirmationDialog(
                "Importation des fichiers de l'App",
                isPresented: $isShowingImportConfirmDialog,
                titleVisibility: .visible
            ) {
                Button("Importer", role: .destructive) {
                    withAnimation {
                        self.import()
                    }
                }
            } message: {
                Text("L'importation va remplacer vos données actuelles par celles contenues dans l'Application.\n") +
                    Text("Cette action ne peut pas être annulée.")
            }

            // Confirmation importation des fichiers JPEG pour le trombinoscope
            .confirmationDialog(
                "Importer des photos d'élèves",
                isPresented: $isShowingImportTrombineDialog,
                titleVisibility: .visible
            ) {
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

            // Confirmation de Suppression de toutes vos données
            .confirmationDialog(
                "Suppression de toutes vos données",
                isPresented: $isShowingDeleteConfirmDialog,
                titleVisibility: .visible
            ) {
                Button("Supprimer", role: .destructive) {
                    withAnimation {
                        self.clearAllUserData()
                    }
                }
            } message: {
                Text("Cette action ne peut pas être annulée.")
            }
        }
    }
}

// MARK: Core Data

extension SchoolSidebarView {
    //    private var jsonURLsToShare: [URL] {
    //        ImportExportManager.documentsURLsToShare(fileNames: [".json"])
    //    }
    //
    //    private var shareMenuItem: some View {
    //        Group {
    //            if jsonURLsToShare.isNotEmpty {
    //                ShareLink("Exporter vos données",
    //                          items: jsonURLsToShare,
    //                          subject: Text("Cahier du professeur"),
    //                          message: Text("Base de données"))
    //            } else {
    //                EmptyView()
    //            }
    //        }
    //    }

    private func checkAllUserData() {
        alertTitle = "Échec"
        alertMessage = "La vérfication de la base de donnée a trouvé des erreurs"

        DataBaseManager.check(errorFound: &alertIsPresented)

        if alertIsPresented == false {
            alertTitle = "Vérification terminée"
            alertMessage = "Aucune anomalie détectée."
            alertIsPresented.toggle()
        }
    }

    /// Suppression de toutes les données utilisateur
    private func clearAllUserData() {
        alertTitle = "Échec"
        alertMessage = "L'effacement complet de la base de donnée a échoué"

        navigationModel.resetSelections()
        DataBaseManager.clear(failed: &alertIsPresented)
    }

    /// Importer tous les fichiers JSON, JPEG et PNG depuis le Bundle Application
    private func `import`() {
        // Copier les fichiers contenus dans le Bundle de l'application vers le répertoire Document de l'utilisateur
        do {
            //            try PersistenceManager().forcedImportAllFilesFromApp(fileExtensions: ["json", "jpg", "png", "pdf"])
        } catch {
            alertTitle = "Échec"
            alertMessage = "L'importation des fichiers a échouée!"
            // trigger second alert
            DispatchQueue.main.async {
                alertIsPresented.toggle()
            }
        }
        do {
            // Initialiser les objets du model à partir des fichiers JSON
            //            try schoolStore.loadFromJSON(fromFolder: nil)
            //            try classeStore.loadFromJSON(fromFolder: nil)
            //            try eleveStore.loadFromJSON(fromFolder: nil)
            //            try colleStore.loadFromJSON(fromFolder: nil)
            //            try observStore.loadFromJSON(fromFolder: nil)
        } catch {
            alertTitle = "Échec"
            alertMessage = "La lecture des fichiers importés a échouée!"
            // trigger second alert
            DispatchQueue.main.async {
                alertIsPresented.toggle()
            }
        }
        // eleveStore.sort()
    }

    /// Copier les fichiers  sélectionnés dans le dossier Document de l'application.
    /// - Parameter result: résultat de la sélection des fichiers issue de fileImporter.
    private func importUserSelectedFiles(result: Result<[URL], Error>) {
        switch result {
            case let .failure(error):
                customLog.log(
                    level: .fault,
                    "Error selecting file: \(error.localizedDescription)"
                )
                alertTitle = "Échec"
                alertMessage = "L'importation des fichiers a échouée!"
                alertIsPresented.toggle()

            case let .success(filesUrl):
                do {
                    try ImportExportManager.importTrombinesImages(filesUrl: filesUrl)

                } catch {
                    customLog.log(
                        level: .fault,
                        "L'importation des fichiers trombines a échouée: \(error.localizedDescription)"
                    )
                    alertTitle = "Échec"
                    alertMessage = "L'importation des fichiers a échoué!"
                    alertIsPresented.toggle()
                }
        }
    }
}

// struct SchoolSidebarView_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return Group {
//            SchoolSidebarView()
//                .environmentObject(NavigationModel(selectedSchoolId: TestEnvir.schoolStore.items.first!.id))
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//                .previewDevice("iPad mini (6th generation)")
//
//            SchoolSidebarView()
//                .environmentObject(NavigationModel(selectedSchoolId: TestEnvir.schoolStore.items.first!.id))
//                .environmentObject(TestEnvir.schoolStore)
//                .environmentObject(TestEnvir.classeStore)
//                .environmentObject(TestEnvir.eleveStore)
//                .environmentObject(TestEnvir.colleStore)
//                .environmentObject(TestEnvir.observStore)
//                .previewDevice("iPhone 13")
//        }
//    }
// }
