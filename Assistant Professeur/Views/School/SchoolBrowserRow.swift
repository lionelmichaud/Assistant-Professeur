//
//  SchoolRow.swift
//  Cahier du Professeur (iOS)
//
//  Created by Lionel MICHAUD on 15/04/2022.
//

import HelpersView
import SwiftUI

struct SchoolBrowserRow: View {
    @ObservedObject
    var school: SchoolEntity

    var body: some View {
//        print(school.name)
//        print(school.level)
        HStack {
            Image(systemName: school.levelEnum == .lycee ? "building.2" : "building")
                .sfSymbolStyling()
                .foregroundColor(school.levelEnum == .lycee ? .mint : .orange)

            VStack(alignment: .leading, spacing: 5) {
                Text(school.displayString)
                    .fontWeight(.bold)

                HStack {
                    Text(school.classesLabel)
                    Spacer()
                    Text(school.heures == 0 ?
                        "Aucune heure" : "\(school.heures.formatted(.number.precision(.fractionLength(1)))) heures")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.trailing, 10)
    }
}

struct SchoolRow_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            List {
                SchoolBrowserRow(school: SchoolEntity.all().first!)
            }
            .padding()
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPad mini (6th generation)")

            List {
                SchoolBrowserRow(school: SchoolEntity.all().first!)
            }
            .padding()
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPhone 13")
        }
    }
}
