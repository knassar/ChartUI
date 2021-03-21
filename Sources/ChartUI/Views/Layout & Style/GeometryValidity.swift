//
//  GeometryValidity.swift
//  ChartUI
//
//  Created by Karim Nassar on 2/20/21.
//  Copyright © 2019 HungryMelonStudios LLC. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//      http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SwiftUI

extension CGPoint {

    var isValid: Bool {
        x.isValid && y.isValid
    }

    static let invalid = CGPoint(x: CGFloat.nan, y: .nan)

}

extension CGSize {

    var isValid: Bool {
        width.isValid && height.isValid
    }

    static let invalid = CGSize(width: CGFloat.nan, height: .nan)

}

extension CGRect {

    var isValid: Bool {
        origin.isValid && size.isValid
    }

    static let invalid = CGRect(origin: .invalid, size: .invalid)

}

extension Angle {

    var isValid: Bool {
        !degrees.isNaN
    }

    static let invalid = Angle(degrees: .nan)

}

extension CGFloat {

    var isValid: Bool {
        !self.isNaN
    }

}

