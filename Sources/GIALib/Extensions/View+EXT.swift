//
//  File.swift
//  
//
//  Created by admin on 13.03.2024.
//

import SwiftUI

extension View {
    public func formBack() -> some View {
        if #available(iOS 16.0, *) {
            return scrollContentBackground(.hidden)
        } else {
            return onAppear()
        }
    }
    
    public func paintTop() -> some View {
        if #available(iOS 16.0, *) {
            return toolbarBackground(Color.teal)
        } else {
            return onAppear()
        }
    }
    
    public func changeRootViewController(with viewController: UIViewController) {
        DispatchQueue.main.async {
            let window = UIApplication.shared.connectedScenes.flatMap { ($0 as? UIWindowScene)?.windows ?? [] }.first { $0.isKeyWindow }
            window?.rootViewController = viewController
            window?.makeKeyAndVisible()
            UIView.transition(with: window ?? UIWindow(), duration: 0.2, options: .transitionCrossDissolve, animations: {}, completion: { complete in
                
            })
        }
    }
    
    public func placeholder(
        _ text: String,
        when shouldShow: Bool,
        alignment: Alignment = .leading) -> some View {
            
            placeholder(when: shouldShow, alignment: alignment) { Text(text).foregroundColor(.gray) }
        }
    
    
    public func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }

}

extension Image {
    public func backgroundImage() -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .ignoresSafeArea(.all)
    }
}
