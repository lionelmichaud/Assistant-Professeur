//
//  SchoolSidebarToolbar.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 03/05/2023.
//

import SwiftUI
import AppFoundation

// MARK: SchoolSidebarView Toolbar Content

extension SchoolSidebarView {
    @ToolbarContentBuilder
    func myToolBarContent() -> some ToolbarContent {
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
            // Edition des préférences utilisateur
            Button {
                isEditingPreferences = true
            } label: {
                Label(
                    "Préférences",
                    systemImage: "gear"
                )
            }

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

            // Confirmation de tentative de réparation de la BDD
            .confirmationDialog(
                "Tentative de réparation de la base de donnée",
                isPresented: $isShowingRepairDBDialog,
                titleVisibility: .visible
            ) {
                Button("Réparer", role: .destructive) {
                    self.tryToRepairUserData()
                }
            } message: {
                Text("Cette action ne peut pas être annulée.") +
                    Text("Certaines erreurs ne seront peut-être pas réparées.") +
                    Text("Cela peut endommager un peu plus la base de données.")
            }
        }
    }
}
