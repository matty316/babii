//
//  Renderer.swift
//  Babii
//
//  Created by matty on 2/12/25.
//

import Foundation
import GameController
import MetalKit

public typealias ProcessInputClosure = ((TimeInterval, [GCKeyCode: Bool], SIMD2<Float>) -> ())

public class Renderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
    let depthState: MTLDepthStencilState
    let commandQueue: MTLCommandQueue
    var lastTime: Double = CFAbsoluteTimeGetCurrent()
    let wireframe = false
    var scene: GameScene
    var shadowTexture: MTLTexture?
    
    override public init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Unable to get GPU")
        }
        
        self.device = device
        
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .lessEqual
        depthDescriptor.isDepthWriteEnabled = true
        
        guard let depthState = device.makeDepthStencilState(descriptor: depthDescriptor) else {
            fatalError("cannot get depth state")
        }
        
        self.depthState = depthState
        self.scene = GameScene(device: device)
                    
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("cannot make command queue")
        }
        
        self.commandQueue = commandQueue
        
        self.shadowTexture = Self.makeTexture(size: CGSize(width: 2048, height: 2048), pixelFormat: .depth32Float, label: "Shadow Texture", storageMode: .private, usage: [.shaderRead, .renderTarget], device: device)
        
        super.init()
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        scene.update(size: size)
    }
    
    private static func makeTexture(size: CGSize, pixelFormat: MTLPixelFormat, label: String, storageMode: MTLStorageMode, usage: MTLTextureUsage, device: MTLDevice) -> MTLTexture? {
        let width = Int(size.width)
        let height = Int(size.height)
        
        guard width > 0 && height > 0 else { return nil }
        
        let desc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: pixelFormat, width: width, height: height, mipmapped: false)
        desc.storageMode = storageMode
        desc.usage = usage
        guard let texture = device.makeTexture(descriptor: desc) else {
            fatalError("Cannot create texture")
        }
        texture.label = label
        return texture
    }
    
    private func shadowRenderPass(commandBuffer: MTLCommandBuffer) {
        let descriptor = MTLRenderPassDescriptor()
        descriptor.depthAttachment.texture = shadowTexture
        descriptor.depthAttachment.loadAction = .clear
        descriptor.depthAttachment.storeAction = .store
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        
        renderEncoder.label = "Shadow Encoder"
        
        renderEncoder.setDepthStencilState(depthState)
        
    }
        
    public func draw(in view: MTKView) {
        guard let renderPassDescriptor = view.currentRenderPassDescriptor, let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        commandBuffer.label = "MyCommand"
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        renderEncoder.label = "MyRenderEndcoder"
        
        renderEncoder.setDepthStencilState(depthState)
        renderEncoder.setFrontFacing(.counterClockwise)
        renderEncoder.setCullMode(.back)
        
        let currentTime = CFAbsoluteTimeGetCurrent()
        let deltaTime = Float(currentTime - lastTime)
        lastTime = currentTime
        scene.update(deltaTime: deltaTime)
        
        if wireframe {
            renderEncoder.setTriangleFillMode(.lines)
        }
        
        scene.render(renderEncoder: renderEncoder, device: device)
        
        renderEncoder.endEncoding()
        if let currentDrawable = view.currentDrawable {
            commandBuffer.present(currentDrawable)
        }
        commandBuffer.commit()
    }
}
