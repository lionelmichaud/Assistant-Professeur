//
//  SchoolBrowserView.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 15/04/2022.
//

import HelpersView
import os
import SwiftUI
import UniformTypeIdentifiers

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "SchoolSidebarView"
)

struct SchoolSidebarView: View {
    @EnvironmentObject
    private var navigationModel: NavigationModel

    @EnvironmentObject
    private var cloudKitVM: CloudKitViewModel

    @SectionedFetchRequest<String, SchoolEntity>(
        fetchRequest: SchoolEntity.requestAllSortedByLevelName,
        sectionIdentifier: \.levelString,
        animation: .default
    )
    private var schoolsSections: SectionedFetchResults<String, SchoolEntity>

    @State
    var alertTitle = ""
    @State
    var alertMessage = ""
    @State
    private var alertIsPresented = false

    @State
    var isAddingNewSchool = false

    @State
    var isEditingPreferences = false

    @State
    var fileImportOperation = FileImportOperation.none
    @State
    var fileExportOperation = FileExportOperation.none

    @State
    var isShowingAbout = false
    @State
    var isShowingUrgencyTel = false
    @State
    var isShowingInfoPerso = false
    @State
    var isShowingDeleteConfirmDialog = false
    @State
    var isShowingJsonImportConfirmDialog = false
    @State
    var isShowingAppImportConfirmDialog = false
    @State
    var isShowingImportTrombineDialog = false
    @State
    var isShowingRepairDBDialog = false
    @State
    var isImportingFile = false
    @State
    var isExportingModel = false

    @State
    private var dataBaseErrorList = DataBaseErrorList()

    // MARK: - Computed Properties

    var body: some View {
        List(selection: $navigationModel.selectedSchoolMngObjId) {
            // pour chaque Type d'établissement
            ForEach(schoolsSections) { section in
                if section.isNotEmpty {
                    Section {
                        // pour chaque Etablissement
                        ForEach(section, id: \.objectID) { school in
                            SchoolBrowserRow(school: school)
//                                .badge(school.nbOfClasses)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    // supprimer l'établissement et tous ses descendants
                                    Button(role: .destructive) {
                                        withAnimation {
                                            if navigationModel.selectedSchoolMngObjId == school.objectID {
                                                navigationModel.selectedSchoolMngObjId = nil
                                            }
                                            // ATTENTION: à mettre en dernier
                                            try? school.delete()
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
                                                school.toggleLevel()
                                            }
                                        } label: {
                                            Label(
                                                school.levelEnum.next.displayString,
                                                systemImage: school.levelEnum.next.imageName
                                            )
                                        }
                                        .tint(school.levelEnum.next.imageColor)
                                    }
                                }
                        }
                    } header: {
                        Text(section.id + "s")
                            .style(.sectionHeader)
                    }
                }
            }
            .emptyListPlaceHolder(schoolsSections) {
                ContentUnavailableView(
                    "Aucun établissement actuellement...",
                    systemImage: SchoolEntity.defaultImageName,
                    description: Text("Les établissements ajoutés apparaîtront ici.")
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
            actions: {
                if dataBaseErrorList.isNotEmpty {
                    Button(role: .destructive) {
                        isShowingRepairDBDialog.toggle()
                    } label: {
                        Text("Tenter de réparer")
                    }
                }
            },
            message: { Text(alertMessage) }
        )

        .sheet(isPresented: $isShowingAbout) {
            AppVersionView()
                .presentationDetents([.large])
        }

        .sheet(isPresented: $isShowingUrgencyTel) {
            UrgencyTelView()
                .presentationDetents([.large])
        }

        .sheet(isPresented: $isShowingInfoPerso) {
            InfoPersoView()
                .presentationDetents([.large])
        }

        // Modal Sheet de gestion des Préférences
        .sheet(isPresented: $isEditingPreferences) {
            NavigationStack {
                SettingsView()
                    .environmentObject(navigationModel)
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
        ) { result in
            switch result {
                case let .failure(error):
                    customLog.log(
                        level: .fault,
                        "Error exporting JSON files: \(error.localizedDescription)"
                    )
                    alertTitle = "Échec"
                    alertMessage = "L'exportation des fichiers a échouée!"
                    alertIsPresented = true

                case .success:
                    alertTitle = "Exportation terminée."
                    alertMessage = ""
                    alertIsPresented = true
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

    /// Vérifier la cohérence de la base de données utilisateur
    func checkAllUserData() {
        dataBaseErrorList = DataBaseErrorList()
        DataBaseManager.check(
            errorList: &dataBaseErrorList,
            tryToRepair: false
        )
        if dataBaseErrorList.isNotEmpty {
            alertTitle = "Erreurs détectées"
            alertMessage = "La vérification de la base de donnée a trouvé \(dataBaseErrorList.count) erreurs."
            alertIsPresented = true
        } else {
            alertTitle = "Vérification terminée avec succès"
            alertMessage = "Aucune anomalie détectée."
            alertIsPresented = true
        }
    }

    /// Tenter de réparer la base de données utilisateur
    func tryToRepairUserData() {
        let countBefore = dataBaseErrorList.count
        dataBaseErrorList = DataBaseErrorList()
        DataBaseManager.check(
            errorList: &dataBaseErrorList,
            tryToRepair: true
        )
        let countAfter = dataBaseErrorList.count

        if dataBaseErrorList.isNotEmpty {
            alertTitle = "Erreurs détectées"
            alertMessage = "Il reste \(countAfter) erreurs.\n\(countAfter - countBefore) erreurs réparées."
            alertIsPresented = true
        } else {
            alertTitle = "Réparation terminée avec succès"
            alertMessage = "Aucune anomalie détectée."
            alertIsPresented = true
        }
    }

    /// Suppression de toutes les données utilisateur
    func clearAllUserData() {
        alertTitle = "Échec"
        alertMessage = "L'effacement complet de la base de donnée a échoué"

        navigationModel.resetSelections()
        DataBaseManager.clear(failed: &alertIsPresented)
    }

    /// Importer tous les fichiers JSON, JPEG et PNG depuis le Bundle Application
    func importFromApp() {
        // Copier les fichiers contenus dans le Bundle de l'application vers le répertoire Document de l'utilisateur
//        do {
//            try PersistenceManager().forcedImportAllFilesFromApp(fileExtensions: ["json", "jpg", "png", "pdf"])
//        } catch {
//            alertTitle = "Échec"
//            alertMessage = "L'importation des fichiers a échouée!"
//            // trigger second alert
//            DispatchQueue.main.async {
//                alertIsPresented.toggle()
//            }
//        }
//        do {
//            // Initialiser les objets du model à partir des fichiers JSON
//            try schoolStore.loadFromJSON(fromFolder: nil)
//            try classeStore.loadFromJSON(fromFolder: nil)
//            try eleveStore.loadFromJSON(fromFolder: nil)
//            try colleStore.loadFromJSON(fromFolder: nil)
//            try observStore.loadFromJSON(fromFolder: nil)
//        } catch {
//            alertTitle = "Échec"
//            alertMessage = "La lecture des fichiers importés a échouée!"
//            // trigger second alert
//            DispatchQueue.main.async {
//                alertIsPresented.toggle()
//            }
//        }
        // eleveStore.sort()
    }
}

struct SchoolSidebarView_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            NavigationStack {
                EmptyView()
                SchoolSidebarView()
            }
            .padding()
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPad mini (6th generation)")

            NavigationStack {
                EmptyView()
                SchoolSidebarView()
            }
            .padding()
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPhone 13")
        }
    }
}
