//
//  SchoolBrowserView.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 15/04/2022.
//

import AppFoundation
import os
import SwiftUI
import UniformTypeIdentifiers

// import Files
// import FileAndFolder
import HelpersView

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "SchoolSidebarView"
)

enum FileImportOperation {
    case importTrombines
    case importModel
    case none

    var allowedContentTypes: [UTType] {
        switch self {
            case .importTrombines: return [.jpeg]
            case .importModel: return [.json, .pdf, .png, .jpeg]
            case .none: return []
        }
    }
}

enum FileExportOperation {
    case exportJsonModel(annexFileNames: [String])
    case exportCsvEleveList
    case exportCsvPrograms
    case none

    var urls: [URL] {
        switch self {
            case let .exportJsonModel(annexFileNames):
                return ImportExportManager.cachesURLsToShare(
                    fileNames: [
                        JsonImportExportMng.schoolsFileName,
                        JsonImportExportMng.programsFileName
                    ] + annexFileNames
                )

            case .exportCsvEleveList:
                return ImportExportManager.cachesURLsToShare(
                    fileNames: [
                        CsvImportExportMng.csvEleveListFileName
                    ]
                )

            case .exportCsvPrograms:
                return ImportExportManager.cachesURLsToShare(
                    fileNames: [
                        CsvImportExportMng.csvProgramListFileName
                    ]
                )

            case .none: return []
        }
    }
}

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
    private var fileImportOperation = FileImportOperation.none

    @State
    private var fileExportOperation = FileExportOperation.none

    @State
    private var isShowingDeleteConfirmDialog = false
    @State
    private var isShowingJsonImportConfirmDialog = false
    @State
    private var isShowingAppImportConfirmDialog = false
    @State
    private var isShowingImportTrombineDialog = false
    @State
    private var isShowingRepairDBDialog = false
    @State
    private var isImportingFile = false
    @State
    private var isExportingModel = false

    // MARK: - Computed Properties

    var body: some View {
        List(selection: $navigationModel.selectedSchoolId) {
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
            .emptyListPlaceHolder(schoolsSections) {
                EmptyListMessage(
                    symbolName: "building",
                    title: "Aucun établissement actuellement.",
                    message: "Les établissements ajoutés apparaîtront ici."
                )
            }
        }
        #if os(iOS)
        .navigationTitle("Établissements")
        #endif
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

        // Importer des fichiers JPEG pour les trombines
        // Importer des fichiers JSON pour le modèle
        .fileImporter(
            isPresented: $isImportingFile,
            allowedContentTypes: fileImportOperation.allowedContentTypes,
            allowsMultipleSelection: true
        ) { result in
            switch fileImportOperation {
                case .importModel:
                    // Importer des fichiers JSON pour le modèle
                    (
                        alertTitle,
                        alertMessage,
                        alertIsPresented
                    ) = JsonImportExportMng.importJsonData(
                        result: result,
                        resetNavigationData: { navigationModel.resetSelections() }
                    )

                case .importTrombines:
                    // Importer des fichiers JPEG pour les trombines
                    (
                        alertTitle,
                        alertMessage,
                        alertIsPresented
                    ) = ImageImportExportMng.importTrombinesImages(
                        result: result
                    )

                case .none:
                    break
            }
        }

        // Exporter des fichiers JSON pour le modèle
        .fileMover(
            isPresented: $isExportingModel,
            files: isExportingModel ? fileExportOperation.urls : []
        ) { _ in
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
                        Label(
                            "A propos",
                            systemImage: "info.circle"
                        )
                    }

                    // Edition des préférences utilisateur
                    Button {
                        isEditingPreferences = true
                    } label: {
                        Label(
                            "Préférences",
                            systemImage: "gear"
                        )
                    }

                    // Vérifier la cohérence de la base de donnée
                    Button {
                        checkAllUserData()
                    } label: {
                        Label(
                            "Vérifier la base de donnée",
                            systemImage: "checkmark.circle.trianglebadge.exclamationmark"
                        )
                    }
                }

                Menu("Importer") {
                    // Importer des fichiers JPEG pour le trombinoscope
                    Button(role: .destructive) {
                        isShowingImportTrombineDialog.toggle()
                    } label: {
                        Label(
                            "Importer des photos pour le trombinoscope",
                            systemImage: "person.crop.rectangle.stack.fill"
                        )
                    }

                    // Importer les données depuis des fichiers au format JSON
                    Button(role: .destructive) {
                        isShowingJsonImportConfirmDialog.toggle()
                    } label: {
                        Label(
                            "Importer les données depuis une archive",
                            systemImage: "square.and.arrow.down"
                        )
                    }

                    // Importer des fichiers depuis le Bundle Application
                    Button(role: .destructive) {
                        isShowingAppImportConfirmDialog.toggle()
                    } label: {
                        Label(
                            "Importer les données contenues dans l'Application",
                            systemImage: "square.and.arrow.down"
                        )
                    }
                }

                Menu("Exporter") {
                    // Exporter les données dans des fichiers au format JSON
                    Button {
                        let exportedFilesUrl = JsonImportExportMng.exportToJsonFiles()
                        fileExportOperation = .exportJsonModel(annexFileNames: exportedFilesUrl)
                        isExportingModel.toggle()
                    } label: {
                        Label(
                            "Archiver vos données vers des fichiers",
                            systemImage: "square.and.arrow.up"
                        )
                    }
                    // Exporter les données dans des fichiers au format CSV
                    Button {
                        CsvImportExportMng.exportEleves()
                        fileExportOperation = .exportCsvEleveList
                        isExportingModel.toggle()
                    } label: {
                        Label(
                            "Exporter les listes d'élèves au format CSV",
                            systemImage: "square.and.arrow.up"
                        )
                    }
                    if isPad() || isMac() {
                        Button {
                            CsvImportExportMng.exportPrograms()
                            fileExportOperation = .exportCsvPrograms
                            isExportingModel.toggle()
                        } label: {
                            Label(
                                "Exporter les programmes en CSV",
                                systemImage: "square.and.arrow.up"
                            )
                        }
                    }
                }

                Section {
                    // Effacer toutes les données utilisateur
                    Button(role: .destructive) {
                        isShowingDeleteConfirmDialog.toggle()
                    } label: {
                        Label(
                            "Supprimer toutes vos données",
                            systemImage: "trash"
                        )
                    }
                }

                #if targetEnvironment(simulator)
                    Section {
                        Button {
                            alertTitle = "Échec"
                            alertMessage = "L'effacement complet de la base de donnée a échoué"

                            withAnimation {
                                DataBaseManager.populateWithMockData(storeType: .inMemory)
                            }
                        } label: {
                            Text("Dev - Peupler la BDD").foregroundColor(.primary)
                        }
                    }
                #endif
            } label: {
                Image(systemName: "ellipsis.circle")
            }

            // Confirmation importation du modèle depuis des fichiers au format JSON
            .confirmationDialog(
                "Importation des données depuis une archive",
                isPresented: $isShowingJsonImportConfirmDialog,
                titleVisibility: .visible
            ) {
                Button("Importer", role: .destructive) {
                    withAnimation {
                        fileImportOperation = .importModel
                        isImportingFile.toggle()
                    }
                }
            } message: {
                Text("L'importation va remplacer vos données actuelles par celles contenues dans les fichiers importés.\n") +
                    Text("Cette action ne peut pas être annulée.")
            }

            // Confirmation importation de tous les fichiers depuis l'App
            .confirmationDialog(
                "Importation des données de l'Application",
                isPresented: $isShowingAppImportConfirmDialog,
                titleVisibility: .visible
            ) {
                Button("Importer", role: .destructive) {
                    withAnimation {
                        self.importFromApp()
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
                        fileImportOperation = .importTrombines
                        isImportingFile.toggle()
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
        var dataBaseErrorList = DataBaseErrorList()

        DataBaseManager.check(errorList: &dataBaseErrorList)
        #if DEBUG
            if dataBaseErrorList.isNotEmpty {
                print("Liste des \(dataBaseErrorList.count) erreurs trouvées:")
                dataBaseErrorList.forEach { error in
                    print(String(describing: error).withPrefix("   "))
                }
            }
        #endif

        if dataBaseErrorList.isNotEmpty {
            alertTitle = "Erreurs détectées"
            alertMessage = "La vérification de la base de donnée a trouvé \(dataBaseErrorList.count) erreurs"
            alertIsPresented = true
        } else {
            alertTitle = "Vérification terminée avec succès"
            alertMessage = "Aucune anomalie détectée."
            alertIsPresented = true
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
    private func importFromApp() {
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
