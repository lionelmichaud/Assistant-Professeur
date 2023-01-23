//
//  ProgramDetail.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/01/2023.
//

import SwiftUI
import HelpersView

struct ProgramDetailGroupBox: View {
    @ObservedObject
    var program: ProgramEntity

    @Environment(\.horizontalSizeClass)
    private var hClass

    @Preference(\.programAnnotationEnabled)
    private var annotationEnabled

    var body: some View {
        GroupBox {
            // Discipline - Niveau
            HStack {
                ProgramDisciplineLevel(program: program)
                Spacer()
            }

            // note sur le programme
            if annotationEnabled {
                HStack {
                    AnnotationView(
                        annotation   : program.viewAnnotation,
                        scrollable   : true,
                        scrollHeight : 40
                    )
                    Spacer()
                }
            }

            // url
            HStack {
                WebsiteView(url: program.url)
                    .padding(.top, 4)
                Spacer()
            }
        }
        .padding(.horizontal, 6)
    }
}

//struct ProgramDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgramDetail()
//    }
//}
