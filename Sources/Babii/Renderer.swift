//
//  Renderer.swift
//  Babii
//
//  Created by matty on 2/12/25.
//

import Foundation
import GameController
import MetalKit

class Renderer: NSObject, MTKViewDelegate {
    let device: MTLDevice
    let depthState: MTLDepthStencilState
    let pipelineState: MTLRenderPipelineState
    let commandQueue: MTLCommandQueue
    var viewportSize = CGSize()
    var lastTime: TimeInterval = Date().timeIntervalSinceReferenceDate
    
    override init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Unable to get GPU")
        }
        
        self.device = device
        
        guard let library = try? device.makeDefaultLibrary(bundle: .module) else {
            fatalError("cannot get library")
        }
        
        let vertexFunc = library.makeFunction(name: "vertexShader")
        let fragmentFunc = library.makeFunction(name: "fragmentShader")
        
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .lessEqual
        depthDescriptor.isDepthWriteEnabled = true
        
        guard let depthState = device.makeDepthStencilState(descriptor: depthDescriptor) else {
            fatalError("cannot get depth state")
        }
        
        self.depthState = depthState
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.label = "Render Pipeline"
        pipelineStateDescriptor.vertexFunction = vertexFunc
        pipelineStateDescriptor.fragmentFunction = fragmentFunc
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineStateDescriptor.depthAttachmentPixelFormat = .depth32Float
        
        guard let pipelineState = try? device.makeRenderPipelineState(descriptor: pipelineStateDescriptor) else {
            fatalError("cannot make pipeline")
        }
        
        self.pipelineState = pipelineState
        
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("cannot make command queue")
        }
        
        self.commandQueue = commandQueue
         
        super.init()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewportSize.width = size.width
        viewportSize.height = size.height
    }
    
    func processInput() {
        let deltaTime = Date().timeIntervalSinceReferenceDate - lastTime
        lastTime = Date().timeIntervalSinceReferenceDate
        
    }
    
    func draw(in view: MTKView) {
        processInput()
        
//        let loader = MTKTextureLoader(device: device)
//        let sideTexture = try! loader.newTexture(name: "mc_grass", scaleFactor: 1.0, bundle: .main, options: [.origin: MTKTextureLoader.Origin.flippedVertically])
//        let topTexture = try! loader.newTexture(name: "mc_grass_top", scaleFactor: 1.0, bundle: .main)
        
        guard let renderPassDescriptor = view.currentRenderPassDescriptor, let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        commandBuffer.label = "MyCommand"
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        renderEncoder.label = "MyRenderEndcoder"
        
        renderEncoder.setDepthStencilState(depthState)
        
        renderEncoder.setViewport(MTLViewport(originX: 0.0,
                                              originY: 0.0,
                                              width: viewportSize.width,
                                              height: viewportSize.height,
                                              znear: 0.0,
                                              zfar: 1.0))
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        
        
//        renderEncoder.setFragmentTexture(sideTexture, index: 0)
//        renderEncoder.setFragmentTexture(topTexture, index: 1)
        
        renderEncoder.setFrontFacing(.counterClockwise)
        renderEncoder.setCullMode(.back)
//        renderEncoder.setTriangleFillMode(.lines)
        
        renderEncoder.endEncoding()
        if let currentDrawable = view.currentDrawable {
            commandBuffer.present(currentDrawable)
        }
        commandBuffer.commit()
    }
}
