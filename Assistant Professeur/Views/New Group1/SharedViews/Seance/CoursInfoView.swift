//
//  CoursInfoView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 04/01/2024.
//

import SwiftUI

struct CoursInfoView: View {
    let seance: Seance

    @EnvironmentObject
    private var navig: NavigationModel

    private var classe: ClasseEntity? {
        guard let schoolName = seance.schoolName,
              let classeName = seance.name else {
            return nil
        }
        return SchoolEntity.school(withName: schoolName)?.classe(withAcronym: classeName)
    }

    var body: some View {
        VStack(alignment: .leading) {
            // Pour chaque activité prévue pendant la séance
            ForEach(seance.activities) { activity in
                HStack(alignment: .center) {
                    VStack {
                        // Discipline
                        if let discipline = activity.sequence?.program?.disciplineEnum {
                            Text(discipline.acronym)
                                .foregroundColor(.secondary)
                        }
                        // Tags Séquence/Activité
                        HStack {
                            if let sequence = activity.sequence {
                                SequenceTagWithPopOver(sequence: sequence)
                            }
                            ActivityTag(activityNumber: activity.viewNumber)
                                // Naviguer vers l'activité pédagogique
                                .onTapGesture {
                                    if let sequence = activity.sequence,
                                       let program = sequence.program {
                                        DeepLinkManager.handleLink(
                                            navigateTo: .activity(
                                                program: program,
                                                sequence: sequence,
                                                activity: activity
                                            ),
                                            using: navig
                                        )
                                    }
                                }
                        }
                    }
                    Divider()

                    // Nom de l'activité / Documents utilisés
                    VStack(alignment: .leading) {
                        // Nom de l'activité
                        Text(activity.viewName)

                        // Documents de l'activité à distribuer aux élèves ou à stocker sur l'ENT
                        if activity.hasSomeDocumentForEleves || activity.hasSomeDocumentForENT,
                           let classe {
                            DocumentsForElevesView(
                                activity: activity,
                                classe: classe
                            )
                        }
                    }

                    Spacer()
                    ActivityAllSymbols(
                        activity: activity,
                        showTitle: false
                    )
                }
                if activity != seance.activities.last {
                    Divider()
                }
            }
        }
    }
}
