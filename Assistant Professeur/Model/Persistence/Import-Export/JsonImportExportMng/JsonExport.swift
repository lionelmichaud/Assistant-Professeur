//
//  JsonExport.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 14/06/2023.
//

import Foundation
import os

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "JsonImportExportMng.Export"
)

/// Export vers des fichiers JSON
extension JsonImportExportMng {

    /// Exporter les données du Model vers des fichiers au format JSON.
    /// Exporter les fichiers annexes (PDF, JPEG, PNG...) des autres entités.
    ///
    /// Les classe d'objet tête de graphe sont exportées chacune dans un fichier qui lui est propre.
    /// - Les fichiers JSON sont enregistrés dans le dossier `cache`.
    /// - Les fichiers PDF, JPEG, PNG sont enregistrés dans le dossier `cache`.
    /// - Returns: La liste des noms de fichiers **annexes** exportés.
    static func exportToJsonFiles() -> [String] {
        // Exporter l'entité unique **OwnerEntity** vers un fichier au format JSON.
        exportOwnerToJson()
        // Exporter l'entité unique **UserPrefEntity** vers un fichier au format JSON.
        exportUserPrefToJson()
        // Exporter toutes les entités **SchoolEntity** et leurs descendants vers un fichier au format JSON.
        exportSchoolsToJson()
        // Exporter toutes les entités **ProgramEntity** et leurs descendants vers un fichier au format JSON.
        exportProgramsToJson()
        // Exporter toutes les entités **WCompChapterEntity** et leurs descendants vers un fichier au format JSON.
        exportWorkedCompetenciesToJson()
        // Exporter toutes les entités **DThemeEntity** et leurs descendants vers un fichier au format JSON.
        exportDisciplineThemesToJson()

        // Exporter les fichiers annexes (PDF, JPEG, PNG...) des autres entités.
        return exportedAnnexeFiles()
    }

    /// Exporter l'entité unique **OwnerEntity** vers un fichier au format JSON.
    ///
    /// Le fichier JSON est enregistré dans le dossier `cache`.
    private static func exportOwnerToJson() {
        let cachesUrl = URL.cachesDirectory
        cachesUrl.encode(
            OwnerEntity.all(),
            to: ownerFileName
        )
    }

    /// Exporter l'entité unique **UserPrefEntity** vers un fichier au format JSON.
    ///
    /// Le fichier JSON est enregistré dans le dossier `cache`.
    private static func exportUserPrefToJson() {
        let cachesUrl = URL.cachesDirectory
        cachesUrl.encode(
            UserPrefEntity.all(),
            to: userPrefFileName
        )
    }

    /// Exporter toutes les entités **SchoolEntity** et leurs descendants vers un fichier au format JSON.
    ///
    /// Le fichier JSON est enregistré dans le dossier `cache`.
    private static func exportSchoolsToJson() {
        let cachesUrl = URL.cachesDirectory
        cachesUrl.encode(
            SchoolEntity.all(),
            to: schoolsFileName
        )
    }

    /// Exporter toutes les entités **ProgramEntity** et leurs descendants vers un fichier au format JSON.
    ///
    /// Le fichier JSON est enregistré dans le dossier `cache`.
    private static func exportProgramsToJson() {
        let cachesUrl = URL.cachesDirectory
        cachesUrl.encode(
            ProgramEntity.all(),
            to: programsFileName
        )
    }

    /// Exporter toutes les entités **WCompChapterEntity** et leurs descendants vers un fichier au format JSON.
    ///
    /// Le fichier JSON est enregistré dans le dossier `cache`.
    private static func exportWorkedCompetenciesToJson() {
        let cachesUrl = URL.cachesDirectory
        cachesUrl.encode(
            WCompChapterEntity.all(),
            to: wCompetenciesFileName
        )
    }

    /// Exporter toutes les entités **DThemeEntity** et leurs descendants vers un fichier au format JSON.
    ///
    /// Le fichier JSON est enregistré dans le dossier `cache`.
    private static func exportDisciplineThemesToJson() {
        let cachesUrl = URL.cachesDirectory
        cachesUrl.encode(
            DThemeEntity.all(),
            to: dCompetenciesFileName
        )
    }

    /// Exporter les fichiers annexes (PDF, JPEG, PNG...) des entités.
    ///
    /// Les fichiers PDF, JPEG, PNG sont enregistrés dans le dossier `cache`.
    /// - Returns: La liste des noms de fichiers exportés.
    private static func exportedAnnexeFiles() -> [String] {
        var exportedFileNames = [String]()

        // Exporter les annexes PDF des Documents associés aux Schools
        exportedFileNames += exportedDocFiles()

        // Exporter les annexes PNG des plans de salle Rooms associés aux Schools
        exportedFileNames += exportedRoomFiles()

        // Exporter les annexes PNG des plans de salle Rooms associés aux Schools
        exportedFileNames += exportedTrombineFiles()

        return exportedFileNames
    }

    /// Exporter les annexes PDF des Documents associés aux Schools
    /// et retourner la liste des noms de fichiers exportés.
    ///
    /// Les fichiers PDF sont enregistrés dans le dossier `cache`.
    /// - Returns: La liste des noms de fichiers exportés.
    private static func exportedDocFiles() -> [String] {
        var exportedFileNames = [String]()
        let cachesUrl = URL.cachesDirectory

        DocumentEntity
            .all()
            .forEach { doc in
                guard let fileName = doc.uuidFileName else {
                    return
                }
                let fileUrl = cachesUrl.appending(component: fileName)
                do {
                    try doc.pdfData?.write(to: fileUrl)
                    exportedFileNames.append(fileName)
                } catch {}
            }
        return exportedFileNames
    }

    /// Exporter les annexes PNG des plans de salle Rooms associés aux Schools
    ///
    /// Les fichiers PNG sont enregistrés dans le dossier `cache`.
    /// - Returns: La liste des noms de fichiers exportés.
    private static func exportedRoomFiles() -> [String] {
        var exportedFileNames = [String]()
        let cachesUrl = URL.cachesDirectory

        RoomEntity
            .all()
            .forEach { room in
                guard let fileName = room.fileName else {
                    return
                }
                let fileUrl = cachesUrl.appending(component: fileName)
                do {
                    try ImageImportExportMng
                        .writeNativeImage(
                            image: room.viewNativeImage,
                            to: fileUrl
                        )
                    exportedFileNames.append(fileName)
                } catch {}
            }
        return exportedFileNames
    }

    /// Exporter les  Photos des Elèves
    ///
    /// Les fichiers Photos sont enregistrés dans le dossier `cache` au format PNG.
    /// - Returns: La liste des noms de fichiers exportés.
    private static func exportedTrombineFiles() -> [String] {
        var exportedFileNames = [String]()
        let cachesUrl = URL.cachesDirectory

        EleveEntity
            .all()
            .forEach { eleve in
                guard let fileName = eleve.fileName else {
                    return
                }
                let fileUrl = cachesUrl.appending(component: fileName)
                do {
                    try ImageImportExportMng
                        .writeNativeImage(
                            image: eleve.viewNativeImageTrombine,
                            to: fileUrl
                        )
                    exportedFileNames.append(fileName)
                } catch {}
            }
        return exportedFileNames
    }

}
