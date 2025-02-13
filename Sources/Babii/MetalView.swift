//
//  MetalView.swift
//  Babii
//
//  Created by matty on 2/12/25.
//

import SwiftUI
import MetalKit
import GameController

public struct MetalView: @unchecked Sendable {
    @State var renderer: RendererProtocol
    var processInput: ProcessInputClosure?
    
    public init(renderer: RendererProtocol = Renderer(), processInput: ProcessInputClosure? = nil) {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { _ in
            nil
        }
        self.renderer = renderer
        self.renderer.processInputClosure = processInput
    }
    
    @MainActor func setupView() -> MTKView {
        let view = MTKView()
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
        
        NotificationCenter.default.addObserver(forName: Notification.Name.GCKeyboardDidConnect, object: nil, queue: nil) { notification in
            let keyboard = notification.object as? GCKeyboard
            keyboard?.keyboardInput?.keyChangedHandler = { _, _, code, pressed in
                 renderer.keysPressed[code] = pressed
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name.GCMouseDidConnect, object: nil, queue: nil) { notification in
            let mouse = notification.object as? GCMouse
            
            mouse?.mouseInput?.mouseMovedHandler = { _, deltaX, deltaY in
                renderer.mouseDelta = [deltaX, deltaY]
            }
        }
        
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

