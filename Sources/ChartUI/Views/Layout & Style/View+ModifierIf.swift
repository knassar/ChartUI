//
//  SwiftUIView.swift
//  
//
//  Created by Karim Nassar on 3/2/21.
//  Copyright © 2021 by Karim Nassar. All rights reserved.
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
