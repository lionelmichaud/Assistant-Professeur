//
//  EventEditor.swift
//  Cahier du Professeur
//
//  Created by Lionel MICHAUD on 24/10/2022.
//

import SwiftUI

struct EventEditor: View {
    @ObservedObject
    var event: EventEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    private var dateView: some View {
        HStack {
            Image(systemName: "calendar")
                .sfSymbolStyling()
                .foregroundColor(.accentColor)

            DatePicker("Date",
                       selection           : $event.viewDate,
                       displayedComponents : [.date])
            .labelsHidden()
            .environment(\.locale, Locale.init(identifier: "fr_FR"))
            Spacer()
        }
        .onChange(of: event.viewDate) { _ in
            try? EventEntity.saveIfContextHasChanged()
        }
    }

    var body: some View {
        let layout = hClass == .regular ?
        AnyLayout(HStackLayout()) : AnyLayout(VStackLayout())

        layout {
            if hClass == .regular {
                dateView
                    .frame(maxWidth: 175)
            } else {
                dateView
            }
            TextField("Événement", text: $event.viewName)
                .lineLimit(2...3)
                .font(hClass == .compact ? .callout : .body)
                .textFieldStyle(.roundedBorder)
                .onChange(of: event.viewName) { _ in
                    try? EventEntity.saveIfContextHasChanged()
                }
        }
    }
}

struct EventEditor_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
                EventEditor(event: EventEntity.all().first!)
            .padding()
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPad mini (6th generation)")

                EventEditor(event: EventEntity.all().first!)
            .padding()
            .environmentObject(NavigationModel(selectedSchoolMngObjId: SchoolEntity.all().first!.objectID))
            .environment(\.managedObjectContext, CoreDataManager.shared.context)
            .previewDevice("iPhone 13")
        }
    }
}
