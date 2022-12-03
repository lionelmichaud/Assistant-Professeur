//
//  SchoolRow.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 15/04/2022.
//

import SwiftUI
import HelpersView

struct SchoolBrowserRow: View {
    let school: SchoolEntity

    var heures: Double {
        0
        //SchoolManager().heures(dans: school, classeStore: classeStore)
    }

    var body: some View {
        HStack {
            Image(systemName: school.niveau == .lycee ? "building.2" : "building")
                .sfSymbolStyling()
                .foregroundColor(school.niveau == .lycee ? .mint : .orange)

            VStack(alignment: .leading, spacing: 5) {
                Text(school.displayString)
                    .fontWeight(.bold)

                HStack {
                    Text(school.classesLabel)
                    Spacer()
                    Text(heures == 0 ? "Aucune heure" : "\(heures.formatted(.number.precision(.fractionLength(1)))) heures")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
       // .badge(school.nbOfClasses)
    }
}

//struct SchoolRow_Previews: PreviewProvider {
//    static var previews: some View {
//        TestEnvir.createFakes()
//        return SchoolBrowserRow(school: TestEnvir.schoolStore.items.first!)
//            .environmentObject(TestEnvir.schoolStore)
//            .environmentObject(TestEnvir.classeStore)
//            .environmentObject(TestEnvir.eleveStore)
//            .environmentObject(TestEnvir.colleStore)
//            .environmentObject(TestEnvir.observStore)
//
//    }
//}
