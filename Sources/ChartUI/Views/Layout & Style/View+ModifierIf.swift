//
//  SwiftUIView.swift
//  
//
//  Created by Karim Nassar on 3/2/21.
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

extension View {

    typealias TransformIf<Content: View> = (Self) -> Content

    @ViewBuilder
    func modifier<True: View>(if condition: Bool, _ ifMod: TransformIf<True>) -> some View {
      if condition {
          ifMod(self)
      } else {
          self
      }
    }

    @ViewBuilder
    func modifier<True: View, False: View>(if condition: Bool, _ ifMod: TransformIf<True>, else elseMod: TransformIf<False>) -> some View {
      if condition {
          ifMod(self)
      } else {
          elseMod(self)
      }
    }

}
