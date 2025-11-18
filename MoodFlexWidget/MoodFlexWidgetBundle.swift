//
//  MoodFlexWidgetBundle.swift
//  MoodFlexWidget
//
//  Created by Mahshad Jafari on 18.11.25.
//

import WidgetKit
import SwiftUI

@main
struct MoodFlexWidgetBundle: WidgetBundle {
    var body: some Widget {
        MoodFlexWidget()
        MoodFlexWidgetControl()
        MoodFlexWidgetLiveActivity()
    }
}
