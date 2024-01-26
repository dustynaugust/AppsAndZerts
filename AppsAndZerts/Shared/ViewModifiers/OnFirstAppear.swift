//
//  OnFirstAppear.swift
//  AppsAndZerts
//
//  Created by Dustyn August on 1/24/24.
//

import SwiftUI

struct OnFirstAppearModifier: ViewModifier {
    @State private var didAppear = false
    
    private let action: (() -> Void)
    
    init(
        perform action: @escaping (() -> Void)
    ) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content.onAppear {
            guard !didAppear else { return }
            
            didAppear = true
            action()
        }
    }
}

extension View {
    func onFirstAppear(
        perform action: @escaping (() -> Void)
    ) -> some View {
        modifier(OnFirstAppearModifier(perform: action))
    }
}
