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
    @State var renderer = Renderer()
    
    public init() {}
    
    @MainActor func setupView() -> MTKView {
        let view = MTKView()

        view.device = MTLCreateSystemDefaultDevice()
        view.preferredFramesPerSecond = 60
        view.enableSetNeedsDisplay = true
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

