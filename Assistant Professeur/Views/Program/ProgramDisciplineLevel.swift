//
//  ProgramDisciplineLevel.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 23/01/2023.
//

import SwiftUI

struct ProgramDisciplineLevel: View {
    @ObservedObject
    var program: ProgramEntity

    var body: some View {
        HStack {
            Label(program.disciplineString, systemImage: "books.vertical")
            Label {
                Text(program.viewLevelEnum.pickerString + (program.segpa ? " Segpa" : ""))
            } icon : {
                Image(systemName: "person.3.sequence.fill")
                    .foregroundColor(program.viewLevelEnum.color)
            }
        }
    }
}

//struct ProgramDisciplineLevel_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgramDisciplineLevel()
//    }
//}
