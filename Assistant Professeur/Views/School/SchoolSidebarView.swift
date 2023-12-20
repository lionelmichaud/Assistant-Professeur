//
//  SchoolBrowserView.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 15/04/2022.
//

import HelpersView
import OSLog
import SwiftUI
import UniformTypeIdentifiers

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "SchoolSidebarView"
)

struct SchoolSidebarView: View {
    // MARK: - Internal Types

    enum Sheet: String, Identifiable {
        case showAbout, showingUrgencyTel
        case showingInfoPerso, editingPreferences
        case addingNewSchool

        var id: String { rawValue }
    }

    @State
    var presentedSheet: Sheet?

    @EnvironmentObject
    private var navigationModel: NavigationModel

    @Environment(Authentication.self)
    var authentication

    @Environment(UserContext.self)
    private var userContext

    @Environment(Store.self)
    var store

    @SectionedFetchRequest<String, SchoolEntity>(
        fetchRequest: SchoolEntity.requestAllSortedByLevelName,
        sectionIdentifier: \.levelString,
        animation: .default
    )
    private var schoolsSections: SectionedFetchResults<String, SchoolEntity>

    @State
    var alertInfo = AlertInfo()

    @State
    var fileImportOperation = FileImportOperation.none
    @State
    var fileExportOperation = FileExportOperation.none

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

    var owner: OwnerEntity? {
        guard let userIdentifier = authentication.userCredentials?.userIdentifier else {
            return nil
        }
        return OwnerEntity.byUserIdentifier(userIdentifier: userIdentifier)
    }

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
            alertInfo.title,
            isPresented: $alertInfo.isPresented,
            actions: {
                if dataBaseErrorList.isNotEmpty {
                    // Erreur détectée lors de la vérification de la base de données
                    Button(role: .destructive) {
                        isShowingRepairDBDialog.toggle()
                    } label: {
                        Text("Tenter de réparer")
                    }

                } else if (SchoolEntity.cardinal() >= 1) &&
                    !store.isPurchased(service: .unlocked) &&
                    !store.isPurchased(service: .pro) {
                    // Afficher le Magazin pour acheter la version sans limite
                    Button {
                        store.isShowingStore = true
                    } label: {
                        Text("Magazin")
                    }
                }
            },
            message: { Text(alertInfo.message) }
        )

        // Préférences
        .sheet(item: $presentedSheet) { sheet in
            switch sheet {
                case .showAbout:
                    AppVersionView()
                        .presentationDetents([.large])

                case .showingUrgencyTel:
                    UrgencyTelView()
                        .presentationDetents([.large])

                case .showingInfoPerso:
                    if let owner {
                        InfoPersoView(
                            owner: owner
                        )
                        .presentationDetents([.large])
                    } else {
                        ContentUnavailableView(
                            "Impossible de trouver le propriétaire des données. Attendre la fin de la synchronisation avec iCloud.",
                            systemImage: "arrow.triangle.2.circlepath.icloud"
                        )
                    }

                case .editingPreferences:
                    NavigationStack {
                        SettingsView()
                            .environmentObject(navigationModel)
                            .environment(userContext)
                    }
                    .presentationDetents([.large])

                case .addingNewSchool:
                    NavigationStack {
                        SchoolCreatorModal()
                            .presentationDetents([.medium])
                    }
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
                        alertInfo.title,
                        alertInfo.message,
                        alertInfo.isPresented
                    ) = JsonImportExportMng.importJsonData(
                        result: result,
                        resetNavigationData: { navigationModel.resetSelections() }
                    )

                case .importTrombines:
                    // Importer des fichiers JPEG pour les trombines
                    (
                        alertInfo.title,
                        alertInfo.message,
                        alertInfo.isPresented
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
                    alertInfo.title = "Échec"
                    alertInfo.message = "L'export des fichiers a échoué!"
                    alertInfo.isPresented = true

                case .success:
                    alertInfo.title = "Export terminé."
                    alertInfo.message = ""
                    alertInfo.isPresented = true
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
            alertInfo.title = "Erreurs détectées"
            alertInfo.message = "La vérification de la base de donnée a trouvé \(dataBaseErrorList.count) erreurs."
            alertInfo.isPresented = true
        } else {
            alertInfo.title = "Vérification terminée avec succès"
            alertInfo.message = "Aucune anomalie détectée."
            alertInfo.isPresented = true
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
            alertInfo.title = "Erreurs détectées"
            alertInfo.message = "Il reste \(countAfter) erreurs.\n\(countAfter - countBefore) erreurs réparées."
            alertInfo.isPresented = true
        } else {
            alertInfo.title = "Réparation terminée avec succès"
            alertInfo.message = "Aucune anomalie détectée."
            alertInfo.isPresented = true
        }
    }

    /// Suppression de toutes les données utilisateur
    func clearAllUserData() {
        alertInfo.title = "Échec"
        alertInfo.message = "L'effacement complet de la base de donnée a échoué"

        navigationModel.resetSelections()
        DataBaseManager.clear(failed: &alertInfo.isPresented)
    }

    /// Importer tous les fichiers JSON, JPEG et PNG depuis le Bundle Application
    func importFromApp() {
        // Copier les fichiers contenus dans le Bundle de l'application vers le répertoire Document de l'utilisateur
//        do {
//            try PersistenceManager().forcedImportAllFilesFromApp(fileExtensions: ["json", "jpg", "png", "pdf"])
//        } catch {
//            alertInfo.title = "Échec"
//            alertInfo.message = "L'importation des fichiers a échouée!"
//            // trigger second alert
//            DispatchQueue.main.async {
//                alertInfo.isPresented.toggle()
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
//            alertInfo.title = "Échec"
//            alertInfo.message = "La lecture des fichiers importés a échouée!"
//            // trigger second alert
//            DispatchQueue.main.async {
//                alertInfo.isPresented.toggle()
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
