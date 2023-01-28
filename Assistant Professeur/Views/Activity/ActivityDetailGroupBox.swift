//
//  ActivityDetailGroupBox.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 27/01/2023.
//

import SwiftUI
import HelpersView

struct ActivityDetailGroupBox: View {
    @ObservedObject
    var activity : ActivityEntity
    
    @Environment(\.horizontalSizeClass)
    private var hClass
    
    @Preference(\.programAnnotationEnabled)
    private var annotationEnabled
    
    var body: some View {
        GroupBox {
            Label {
                Text(activity.viewName)
            } icon: {
                Image(systemName: "\(activity.viewNumber).circle")
                    .font(.body)
            }
            .horizontallyAligned(.leading)
            
            // note sur le programme
            if annotationEnabled && activity.viewAnnotation.isNotEmpty {
                AnnotationView(
                    annotation   : activity.viewAnnotation,
                    scrollable   : true,
                    scrollHeight : 40
                )
                .horizontallyAligned(.leading)
            }
            
            DurationView(duration: activity.duration, withMargin: false)
                .horizontallyAligned(.leading)
            
            WebsiteView(url: activity.url,showURL: true)
                .horizontallyAligned(.leading)
                .padding(.top)
            
            if activity.isEval {
                Label {
                    Text("Cette activité est une évaluation")
                } icon: {
                    Image(systemName: "doc.plaintext")
                        .font(.body)
                }
                .horizontallyAligned(.leading)
                .padding(.top)
            }
        }
        .font(hClass == .compact ? .subheadline : .callout)
        .padding(.horizontal)
    }
}

//struct ActivityDetailGroupBox_Previews: PreviewProvider {
//    static var previews: some View {
//        ActivityDetailGroupBox()
//    }
//}
