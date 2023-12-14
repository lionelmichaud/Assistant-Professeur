//
//  ImageImportExportMng.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 14/02/2023.
//

import Foundation
import HelpersView
import OSLog

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "ImageImportExportMng"
)

/// Export/Import vers/depuis des fichiers Image
enum ImageImportExportMng {
    // MARK: - IMPORT

    /// Importer un fichier image dans un format convertible en UIImage
    /// - Parameter result: résultat de la sélection des fichiers issue de fileImporter.
    /// - Returns: An initialized UIImage object, or nil if the method could not initialize the image from the loaded data.
    static func importImage(result: Result<[URL], Error>)
        -> (
            image: NativeImage?,
            alertTitle: String,
            alertMessage: String,
            alertIsPresented: Bool
        ) {
        var alertTitle = ""
        var alertMessage = ""
        var alertIsPresented = false
        var loadedImage: NativeImage?

        switch result {
            case let .failure(error):
                customLog.log(
                    level: .error,
                    "Error selecting file: \(error.localizedDescription)"
                )
                alertTitle = "Échec"
                alertMessage = "L'importation du fichier a échouée"
                alertIsPresented = true

            case let .success(filesUrl):
                if let theFileURL = filesUrl.first {
                    do {
                        if let image = try ImageImportExportMng
                            .loadNativeImage(from: theFileURL) {
                            loadedImage = image
                        } else {
                            customLog.log(
                                level: .error,
                                "Le contenu de l'image n'est pas lisible."
                            )
                            alertTitle = "Échec"
                            alertMessage = "Le contenu de l'image n'est pas lisible."
                            alertIsPresented = true
                        }

                    } catch {
                        customLog.log(
                            level: .error,
                            "L'importation du fichier a échouée."
                        )
                        alertTitle = "Échec"
                        alertMessage = "L'importation du fichier a échouée."
                        alertIsPresented = true
                    }
                }

                alertTitle = "Importation réussie"
                alertMessage = ""
                alertIsPresented = true
        }

        return (
            image: loadedImage,
            alertTitle: alertTitle,
            alertMessage: alertMessage,
            alertIsPresented: alertIsPresented
        )
    }

    /// Importer les fichiers image  pour le trombinoscope
    /// - Parameter filesUrl: URLs des fichiers sélectionnés
    static func importTrombinesImages(result: Result<[URL], Error>)
        -> (
            alertTitle: String,
            alertMessage: String,
            alertIsPresented: Bool
        ) {
        var alertTitle = ""
        var alertMessage = ""
        var alertIsPresented = false

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
                filesUrl.forEach { fileUrl in
                    do {
                        if let image = try ImageImportExportMng
                            .loadNativeImage(from: fileUrl) {
                            let urlFileNameWithExtension = fileUrl.lastPathComponent
                            let eleves = EleveEntity.all()

                            eleves.forEach { eleve in
                                let imageFileName = eleve.imageFileName
                                if imageFileName == urlFileNameWithExtension {
                                    eleve.viewNativeImageTrombine = image
                                }
                            }
                        } else {
                            customLog.log(
                                level: .fault,
                                "La convertion de certains des fichiers trombines a échouée"
                            )
                            alertTitle = "Échec"
                            alertMessage = "L'importation de certains fichiers a échouée!"
                            alertIsPresented = true
                        }

                    } catch {
                        customLog.log(
                            level: .fault,
                            "L'import des fichiers trombines a échoué: \(error.localizedDescription)"
                        )
                        alertTitle = "Échec"
                        alertMessage = "L'import de certains fichiers a échoué!"
                        alertIsPresented = true
                    }
                }
                
                alertTitle = "Import terminé"
                alertMessage = "\(filesUrl.count) fichiers importés"
                alertIsPresented = true
        }

        return (
            alertTitle: alertTitle,
            alertMessage: alertMessage,
            alertIsPresented: alertIsPresented
        )
    }

    /// Loads image data from a `fileUrl`  and converts it as UIImage.
    /// - Parameter fileUrl: fichier image
    /// - Returns: An initialized UIImage object, or nil if the method could not initialize the image from the loaded data.
    /// - Throws: si le contenu du fichier est ilisible
    static func loadNativeImage(from fileUrl: URL) throws -> NativeImage? {
        guard fileUrl.startAccessingSecurityScopedResource() else {
            return nil
        }
        do {
            let data = try Data(contentsOf: fileUrl)
            fileUrl.stopAccessingSecurityScopedResource()
            return NativeImage(data: data)
        } catch {
            fileUrl.stopAccessingSecurityScopedResource()
            throw error
        }
    }

    // MARK: - EXPORT

    /// Exports an image data to a `fileUrl`  and converts as PNG.
    /// - Parameter fileUrl: fichier image
    /// - Throws: si le contenu des data est impossible à enregistrer dans le fichier
    static func writeNativeImage(
        image: NativeImage,
        to fileUrl: URL
    ) throws {
        guard let pngData = image.pngData() else {
            return
        }
        try pngData.write(to: fileUrl)
    }
}
