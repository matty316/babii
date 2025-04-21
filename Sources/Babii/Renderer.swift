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
    let pipelineState: MTLRenderPipelineState
    let commandQueue: MTLCommandQueue
    var lastTime: Double = CFAbsoluteTimeGetCurrent()
    let wireframe = false
    var scene: GameScene
    
    @MainActor
    override public init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Unable to get GPU")
        }
        
        self.device = device
        
        do {
            let library = try device.makeDefaultLibrary(bundle: .module)
            
            let vertexFunc = library.makeFunction(name: "vertexShader")
            let fragmentFunc = library.makeFunction(name: "fragmentShader")
            
            let depthDescriptor = MTLDepthStencilDescriptor()
            depthDescriptor.depthCompareFunction = .less
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
            pipelineStateDescriptor.vertexDescriptor = Self.vertexDescriptor()
            
            let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
            
            self.pipelineState = pipelineState
            
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
        renderEncoder.setRenderPipelineState(pipelineState)
       
        let currentTime = CFAbsoluteTimeGetCurrent()
        let deltaTime = Float(currentTime - lastTime)
        lastTime = currentTime
        scene.update(deltaTime: deltaTime)
        
        if wireframe {
            renderEncoder.setTriangleFillMode(.lines)
        }
        
        scene.render(renderEncoder: renderEncoder)
        
        renderEncoder.endEncoding()
        if let currentDrawable = view.currentDrawable {
            commandBuffer.present(currentDrawable)
        }
        commandBuffer.commit()
    }
    
    static func vertexDescriptor() -> MTLVertexDescriptor {
        let vertexDescriptor = MDLVertexDescriptor()
        var offset = 0
        vertexDescriptor.attributes[0] = MDLVertexAttribute(
          name: MDLVertexAttributePosition,
          format: .float3,
          offset: 0,
          bufferIndex: 0)
        offset += MemoryLayout<SIMD3<Float>>.stride

        vertexDescriptor.attributes[1] = MDLVertexAttribute(
          name: MDLVertexAttributeNormal,
          format: .float3,
          offset: offset,
          bufferIndex: 0)
        offset += MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.layouts[0]
          = MDLVertexBufferLayout(stride: offset)

        vertexDescriptor.attributes[2] = MDLVertexAttribute(
          name: MDLVertexAttributeTextureCoordinate,
          format: .float2,
          offset: 0,
          bufferIndex: 1)
        vertexDescriptor.layouts[1]
          = MDLVertexBufferLayout(stride: MemoryLayout<SIMD2<Float>>.stride)

        return MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)!
    }
}
