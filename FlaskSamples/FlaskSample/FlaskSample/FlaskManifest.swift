//
//  FlaskManifest.swift
//  FlaskSample
//
//  Created by hassan uriostegui on 9/13/18.
//  Copyright © 2018 eonflux. All rights reserved.
//

import UIKit
import Flask

//Mark: - Global Reactive Substance Mixers

enum EnvMixers : SubstanceMixer {
    case Login
    case Logout
    case AsyncAction
}

enum NavMixers : SubstanceMixer {
    case Home
    case Settings
}

class Subs {
    
    static let app = AppSubstance()
    static let appReactive = AppReactiveSubstance()
}
