//
//  NavigationModel+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 03/06/2023.
//

import AppFoundation
import Foundation
import SwiftUI

extension NavigationModel {
    // MARK: - Types

    /// Onglets
    enum TabSelection: String, Hashable, Codable {
        case userSettings = "Réglages"
        case school = "Mes Etablissements"
        case classe = "Mes Classes"
        case eleve = "Mes Elèves"
        case warning = "Avertissements"
        case program = "Mes Progressions"
        case competence = "Les Compétences"

        var imageName: String {
            switch self {
                case .userSettings:
                    return "gear"
                case .school:
                    return SchoolEntity.defaultImageName
                case .classe:
                    return ClasseEntity.defaultImageName
                case .eleve:
                    return EleveEntity.defaultImageName
                case .warning:
                    return "hand.raised"
                case .program:
                    return ProgramEntity.defaultImageName
                case .competence:
                    return WCompChapterEntity.defaultImageName
            }
        }
    }

    /// Panneaux préférences
    enum PrefTabSelection: String, Hashable, Codable, PickableIdentifiableEnumP {
        case general
        case school
        case classe
        case eleve
        case program
        case sequence
        case activity
        case schoolYear

        var id: String { self.rawValue }

        var pickerString: String {
            switch self {
                case .general: return "Général"
                case .school: return "Établissements"
                case .classe: return "Classes"
                case .eleve: return "Élèves"
                case .program: return "Progressions"
                case .sequence: return "Séquences"
                case .activity: return "Activités"
                case .schoolYear: return "Année scolaire"
            }
        }
    }

    // MARK: - Methods

    /// Afficher la time-line du programme dans la colonne de droite (détail)
    func showProgramTimeLine() {
        selectedActivityMngObjId = nil
        programDetailColumnState = .showProgramSteps
    }

    /// Afficher la time-line de la séquence dans la colonne de droite (détail)
    func showSequenceTimeLine() {
        selectedActivityMngObjId = nil
        programDetailColumnState = .showSequenceSteps
    }

    /// Désélectionner la séquence et l'activité quand on change de programme
    func changeSelectedProgram() {
        selectedSequenceMngObjId = nil
        selectedActivityMngObjId = nil
        programDetailColumnState = nil
    }

    /// Désélectionner l'activité quand on change de séquence
    func changeSelectedSequence() {
        selectedActivityMngObjId = nil
        programDetailColumnState = nil
    }

    /// Afficher l'activité quand on en sélectionne une
    func showActivityDetails() {
        if selectedActivityMngObjId != nil {
            programDetailColumnState = .showActivityDetail
        }
    }

    /// Pop to School root view by clearing the stack
    func popToSchoolRootView() {
        schoolPath = []
    }

    /// Pop to Classe root view by clearing the stack
    func popToClasseRootView() {
        classPath = []
    }

    /// Pop to Programme root view by clearing the stack
    func popToProgramRootView() {
        selectedSequenceMngObjId = nil
        selectedActivityMngObjId = nil
        programDetailColumnState = nil

        programPath = []
    }

    /// Pop to Compétence root view by clearing the stack
    func popToCompetenceRootView() {
        selectedWorkedCompMngObjId = nil
        selectedDiscCompMngObjId = nil
        selectedDiscKnowMngObjId = nil

        competencePath.removeLast(competencePath.count)
    }

    func resetSelections() {
        selectedTab = .school
        selectedPrefTab = .general
        selectedWarningType = .observation
        selectedCompetenceType = .workedCompetencies

        selectedProgramMngObjId = nil
        selectedSequenceMngObjId = nil
        selectedActivityMngObjId = nil
        selectedObservMngObjId = nil
        selectedColleMngObjId = nil
        selectedEleveMngObjId = nil
        selectedClasseMngObjId = nil
        selectedSchoolMngObjId = nil
        selectedWorkedCompChapterMngObjId = nil
        selectedWorkedCompMngObjId = nil
        selectedDiscThemeMngObjId = nil
        selectedDiscSectionMngObjId = nil
        selectedDiscCompMngObjId = nil
        selectedDiscKnowMngObjId = nil

        filterObservation = false
        filterColle = false
        filterFlag = false

        popToSchoolRootView()
        popToClasseRootView()
    }

    /// Naviguer vers la page "Actualiser la progression" de la "Classe"
    @MainActor
    func navigateToProgressOf(thisClasse: ClasseEntity) async {
        // Changer d'onglet pour l'onglet Classe
        selectedTab = .classe
        // Sélectionner la Classe souhaitée
        selectedClasseMngObjId = thisClasse.objectID
        // ATTENTION: indispensable pour laisser le temps à la RunLoop de faire les choses dans l'ordre
        try? await Task.sleep(for: .seconds(0.1))
        // Naviguer jusqu'à l'actualisation de la progression de la Classe
        classPath = [.progress(thisClasse.id)]
    }

    /// Naviguer vers la page "Activité" de la "Séquence" du "Programme"
    @MainActor
    func navigateToActivity(
        program: ProgramEntity,
        sequence: SequenceEntity,
        activity: ActivityEntity
    ) async {
        selectedTab = .program
        try? await Task.sleep(for: .seconds(0.1))

        selectedProgramMngObjId = program.objectID
        try? await Task.sleep(for: .seconds(0.1))

        selectedSequenceMngObjId = sequence.objectID
        try? await Task.sleep(for: .seconds(0.1))

        if programPath.isNotEmpty {
            // Pop to root view by clearing the stack
            programPath.removeLast(programPath.count)
            programPath.append(sequence)
            try? await Task.sleep(for: .seconds(0.1))
        }

        selectedActivityMngObjId = activity.objectID
        try? await Task.sleep(for: .seconds(0.1))

        programDetailColumnState = .showActivityDetail
    }

    /// Pop to Tab's root view when the current tab is tapped again
    func tabSelection() -> Binding<NavigationModel.TabSelection> {
        Binding { // this is the get block
            self.selectedTab

        } set: { tappedTab in
            if tappedTab == self.selectedTab {
                // User tapped on the currently active tab icon => Pop to root/Scroll to top
                switch tappedTab {
                    case .school:
                        if self.schoolPath.isEmpty {
                            // User already on home view, scroll to top
                        } else {
                            // Pop to root view by clearing the stack
                            self.popToSchoolRootView()
                        }

                    case .classe:
                        if self.classPath.isEmpty {
                            // User already on home view, scroll to top
                        } else {
                            // Pop to root view by clearing the stack
                            self.popToClasseRootView()
                        }

                    case .program:
                        if self.programPath.isEmpty {
                            // User already on home view, scroll to top
                        } else {
                            // Pop to root view by clearing the stack
                            self.popToProgramRootView()
                        }

                    case .competence:
                        if self.competencePath.isEmpty {
                            // User already on home view, scroll to top
                        } else {
                            // Pop to root view by clearing the stack
                            self.popToCompetenceRootView()
                        }

                    default: break
                }
            }

            // Set the tab to the tabbed tab
            self.selectedTab = tappedTab
        }
    }
}
