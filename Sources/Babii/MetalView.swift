//
//  MetalView.swift
//  Babii
//
//  Created by matty on 2/12/25.
//

import SwiftUI
import MetalKit
import GameController

public struct MetalView: View {
    @State var view = MTKView()
    @State var renderer: Renderer?
    
    public init() {
        self.renderer = Renderer(view: view)
    }
    
    @MainActor func setupView() -> MTKView {
        view.preferredFramesPerSecond = 60
        view.enableSetNeedsDisplay = true
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Unable to get a GPU")
        }
        
        view.device = device
        view.framebufferOnly = false
        view.drawableSize = view.frame.size
        view.depthStencilPixelFormat = .depth32Float
        view.isPaused = false
        view.delegate = renderer
        
        return view
    }
    
    func update() {}
}

#if os(iOS)
extension MetalView: UIViewRepresentable {
    public func makeUIView(context: Context) -> some UIView {
        setupView()
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        update()
    }
}
#elseif os(macOS)
extension MetalView: NSViewRepresentable {
    public func makeNSView(context: Context) -> some NSView {
        setupView()
    }
    
    public func updateNSView(_ nsView: NSViewType, context: Context) {
        update()
    }
}
#endif

#Preview {
    MetalView()
}

