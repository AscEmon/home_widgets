//
//  MyHomeWidgetBundle.swift
//  MyHomeWidget
//
//  Created by Sayed on 2/9/25.
//

import WidgetKit
import SwiftUI

@main
struct MyHomeWidgetBundle: WidgetBundle {
    var body: some Widget {
        MyHomeWidget()
        MyHomeWidgetControl()
        MyHomeWidgetLiveActivity()
    }
}
