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
    let vertexPipelineState: MTLRenderPipelineState
    let groundPipelineState: MTLRenderPipelineState
    let model3DPipelineState: MTLRenderPipelineState
    let commandQueue: MTLCommandQueue
    var lastTime: Double = CFAbsoluteTimeGetCurrent()
    let wireframe = false
    var scene: GameScene
    
    override public init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Unable to get GPU")
        }
        
        self.device = device
        
        do {
            let library = try device.makeDefaultLibrary(bundle: .main)
            
            let vertexFunc = library.makeFunction(name: "vertexShader")
            let fragmentFunc = library.makeFunction(name: wireframe ? "fragmentSolid" : "fragmentShader")
            
            let depthDescriptor = MTLDepthStencilDescriptor()
            depthDescriptor.depthCompareFunction = .lessEqual
            depthDescriptor.isDepthWriteEnabled = true
            
            guard let depthState = device.makeDepthStencilState(descriptor: depthDescriptor) else {
                fatalError("cannot get depth state")
            }
            
            self.depthState = depthState
            self.scene = GameScene(device: device)
            
            let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
            pipelineStateDescriptor.label = "Render Pipeline"
            pipelineStateDescriptor.vertexFunction = vertexFunc
            pipelineStateDescriptor.fragmentFunction = fragmentFunc
            pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            pipelineStateDescriptor.depthAttachmentPixelFormat = .depth32Float
            pipelineStateDescriptor.vertexDescriptor = Vertex.vertexDescriptor()
            
            let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
            
            self.vertexPipelineState = pipelineState
            
//            pipelineStateDescriptor.vertexDescriptor = scene.groundVertexDescriptor
            self.groundPipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
            
            pipelineStateDescriptor.vertexDescriptor = MTLVertexDescriptor.vertexDescriptor()
            self.model3DPipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
            
            guard let commandQueue = device.makeCommandQueue() else {
                fatalError("cannot make command queue")
            }
            
            self.commandQueue = commandQueue
        } catch {
            fatalError(error.localizedDescription)
        }
        super.init()
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        scene.update(size: size)
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
        
        scene.render(renderEncoder: renderEncoder, device: device, groundPipelineState: groundPipelineState, vertexPipelineState: vertexPipelineState, model3DPipelineState: model3DPipelineState)
        
        renderEncoder.endEncoding()
        if let currentDrawable = view.currentDrawable {
            commandBuffer.present(currentDrawable)
        }
        commandBuffer.commit()
    }
    
//    static func depthTexture() -> MTLTextureDescriptor {
//        
//    }
//    
//    static func msaaTexture() -> MTLTextureDescriptor {
//        
//    }
}
