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
            ProgramDisciplineLevel(program: program)
                .bold()
                .horizontallyAligned(.leading)

            // note sur le programme
            if annotationEnabled && program.viewAnnotation.isNotEmpty {
                AnnotationView(
                    annotation   : program.viewAnnotation,
                    scrollable   : true,
                    scrollHeight : 40
                )
                .horizontallyAligned(.leading)
            }

            // Durées / url
            HStack {
                DurationView(duration: program.durationWithoutMargin, withMargin: false)
                Spacer()
                DurationView(duration: program.durationWithMargin, withMargin: true)
                Spacer()
                WebsiteView(url: program.url)
            }
            .padding(.top, 4)
        }
        .font(hClass == .compact ? .subheadline : .callout)
        .padding(.horizontal)
    }
}

//struct ProgramDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgramDetail()
//    }
//}
