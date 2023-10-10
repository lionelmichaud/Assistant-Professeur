//
//  ActivityProgressView.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 05/02/2023.
//

import HelpersView
import SwiftUI

/// Progressions de toutes les classes de tous les établissement dans une activité donnée
struct ActivityProgressesView: View {
    @ObservedObject
    var activity: ActivityEntity

    private var progresses: [ActivityProgressEntity] {
        activity.allProgresses
    }

    /// Liste des établissements ayant des classes suivant cette activité
    private var schools: [SchoolEntity] {
        let sortComparators = [
            SortDescriptor(\SchoolEntity.level, order: .forward),
            SortDescriptor(\SchoolEntity.name, order: .forward)
        ]

        var schools = [SchoolEntity]()

        progresses.forEach { progress in
            if let school = progress.classe?.school,
               !schools.contains(school) {
                schools.append(school)
            }
        }
        return schools.sorted(using: sortComparators)
    }

    var body: some View {
        ForEach(schools) { school in
            ActivityProgresseView(school: school,
                                  activity: activity)
        }
        .emptyListPlaceHolder(schools) {
            Text("Aucune classe susceptible de suivre cette activité")
        }
    }
}

/// Progressions de toutes les classes d'un établissement dans une activité donnée
struct ActivityProgresseView: View {
    @ObservedObject
    var school: SchoolEntity

    @ObservedObject
    var activity: ActivityEntity

    @State
    private var isExpanded = true

    private var progresses: [ActivityProgressEntity] {
        activity.allProgresses
    }

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ForEach(sortedProgressesIn(school)) { progress in
                ActivityClassProgressView(progress: progress)
                    .listRowSeparatorTint(.secondary, edges: .bottom)
            }
        } label: {
            Text(school.displayString)
                .font(.callout)
                .foregroundColor(.secondary)
                .fontWeight(.bold)
        }
    }

    /// Retourne la liste des progresssions de classe triée pour l'activité et l'établissement sélectionnés
    ///
    /// Ordre de tri des progressions:
    ///   1. Niveau de la Classe
    ///   2. Classe SEGPA ou non
    ///   3. Numéro de la Classe
    private func sortedProgressesIn(_ school: SchoolEntity) -> [ActivityProgressEntity] {
        let sortComparators = [
            SortDescriptor(\ActivityProgressEntity.classe?.level, order: .forward),
            SortDescriptor(\ActivityProgressEntity.classe?.segpa, order: .forward),
            SortDescriptor(\ActivityProgressEntity.classe?.numero, order: .forward)
        ]

        return progresses
            .filter { progress in
                progress.classe?.school == school
            }
            .sorted(using: sortComparators)
    }
}

// struct ActivityProgressView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityProgressView()
//    }
// }
