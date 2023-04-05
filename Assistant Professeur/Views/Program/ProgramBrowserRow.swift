//
//  ProgramBrowserRow.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/01/2023.
//

import SwiftUI

struct ProgramBrowserRow: View {
    @ObservedObject
    var program: ProgramEntity

    var body: some View {
        HStack {
            Image(systemName: "person.3.sequence.fill")
                .sfSymbolStyling()
                .foregroundColor(program.viewLevelEnum.color)
            Text(program.viewLevelEnum.pickerString + (program.segpa ? " Segpa" : ""))
                .fontWeight(.bold)
        }
    }
}

struct ProgramBrowserRow_Previews: PreviewProvider {
    static func initialize() {
        DataBaseManager.populateWithMockData(storeType: .inMemory)
    }

    static var previews: some View {
        initialize()
        return Group {
            ProgramBrowserRow(program: ProgramEntity.all().first!)
                .padding()
                .environmentObject(NavigationModel(selectedProgramMngObjId: ProgramEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPad mini (6th generation)")
            ProgramBrowserRow(program: ProgramEntity.all().first!)
                .padding()
                .environmentObject(NavigationModel(selectedProgramMngObjId: ProgramEntity.all().first!.objectID))
                .environment(\.managedObjectContext, CoreDataManager.shared.context)
                .previewDevice("iPhone 13")
        }
    }
}
