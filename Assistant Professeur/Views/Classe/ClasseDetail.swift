//
//  ClassDetail.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 20/04/2022.
//

import AppFoundation
import HelpersView
import SwiftUI
import TagKit

struct ClasseDetail: View {
    @ObservedObject
    var classe: ClasseEntity

    @Environment(\.managedObjectContext)
    private var managedObjectContext

    @EnvironmentObject
    private var pref: UserPrefEntity

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
                NavigationLink(value: ClasseNavigationRoute.infos(classe)) {
                    Label("Informations", systemImage: "info.circle")
                        .fontWeight(.bold)
                }

                // Section élèves
                EleveListSection(classe: classe)

                // Section progression
                ClasseProgressSection(classe: classe)

                // Section évaluations
                ExamListSection(classe: classe)
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
                    interoperability: pref.interoperabilityEnum,
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
                .disabled(!pref.viewElevePref.trombineEnabled)
                .popover(item: $randomEleve) { eleve in
                    ZStack(alignment: .bottom) {
                        TrombineView(eleve: eleve)
                            .scaledToFit()
                        // Légende basse: Points +/-
                        TrombinoscopeFooterView(eleve: eleve)
                    }
                    .frame(width: 200)
                    Text(eleve.displayName2lines(.prenomNom))
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .bold()
                        .padding(4)
                    if let group = eleve.group {
                        GroupTag(group: group, font: .body)
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
                    Text("La liste des élèves importée doit être au format CSV de \(pref.interoperabilityEnum == .proNote ? "PRONOTE" : "EcoleDirecte").\n") +
                        Text("Cette action ne peut pas être annulée.")
                }
            } label: {
                Label("Plus", systemImage: "ellipsis.circle")
            }
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
