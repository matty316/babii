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

public protocol RendererProtocol: MTKViewDelegate {
    var processInputClosure: ProcessInputClosure? { get set }
    var keysPressed: [GCKeyCode: Bool] { get set }
    var mouseDelta: SIMD2<Float> { get set }
}

public class Renderer: NSObject, RendererProtocol {
    let device: MTLDevice
    let depthState: MTLDepthStencilState
    let pipelineState: MTLRenderPipelineState
    let commandQueue: MTLCommandQueue
    var viewportSize: SIMD2<UInt32> = [0, 0]
    var lastTime: TimeInterval = Date().timeIntervalSinceReferenceDate
    let vertices: [Vertex]
    public var keysPressed = [GCKeyCode: Bool]()
    public var mouseDelta: SIMD2<Float> = [0, 0]
    var camera = Camera(cameraType: .fps)
    var lastDelta: SIMD2<Float> = [0, 0]
    let cullBackFaces: Bool
    
    public var processInputClosure: ProcessInputClosure?
    
    public init(vertices: [Vertex] = Vertices.triangle, cullBackFaces: Bool = false) {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Unable to get GPU")
        }
        
        self.device = device
        
        do {
            let library = try device.makeDefaultLibrary(bundle: .module)
            
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
            
            let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
            
            self.pipelineState = pipelineState
            
            guard let commandQueue = device.makeCommandQueue() else {
                fatalError("cannot make command queue")
            }
            
            self.commandQueue = commandQueue
        } catch {
            fatalError(error.localizedDescription)
        }
         
        self.vertices = vertices
        self.cullBackFaces = cullBackFaces
        super.init()
    }
    
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewportSize.x = UInt32(size.width)
        viewportSize.y = UInt32(size.height)
    }
    
    func processInput() {
        let deltaTime = Date().timeIntervalSinceReferenceDate - lastTime
        lastTime = Date().timeIntervalSinceReferenceDate
        processInputClosure?(deltaTime, keysPressed, mouseDelta)
        
        if keysPressed[.keyW] == true {
            camera.processKeyboardMovement(direction: .forward, deltaTime: deltaTime)
        }
        if keysPressed[.keyS] == true {
            camera.processKeyboardMovement(direction: .backward, deltaTime: deltaTime)
        }
        if keysPressed[.keyA] == true {
            camera.processKeyboardMovement(direction: .left, deltaTime: deltaTime)
        }
        if keysPressed[.keyD] == true {
            camera.processKeyboardMovement(direction: .right, deltaTime: deltaTime)
        }
        if keysPressed[.escape] == true {
            exit(0)
        }
        
        let delta = lastDelta
        
        if abs(mouseDelta.x - delta.x) + abs(mouseDelta.y - delta.y) > 0.0001 {
            camera.processMouseMovement(mouseDelta: mouseDelta)
            lastDelta = mouseDelta
        }
    }
        
    public func draw(in view: MTKView) {
        processInput()
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
                                              width: Double(viewportSize.x),
                                              height: Double(viewportSize.y),
                                              znear: 0.0,
                                              zfar: 1.0))
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        renderEncoder.setVertexBytes(vertices, length: MemoryLayout<Vertex>.stride * vertices.count, index: 0)
        
        let viewMatrix = camera.view
        let projection = perspective(fovyRadians: radians(from: camera.zoom), aspect: Float(viewportSize.x) / Float(viewportSize.y), nearZ: 0.1, farZ: 100)
        let translation = translation(vector: [0, 0, 0])
        let rotation = rotation(angle: radians(from: 45), vector: [0, 1, 0])
        let model = simd_mul(translation, rotation)
        
        var transformation = Transformation(model: model, view: viewMatrix, projection: projection)
        
        renderEncoder.setVertexBytes(&transformation, length: MemoryLayout<Transformation>.stride, index: 1)
        
        if cullBackFaces {
            renderEncoder.setFrontFacing(.counterClockwise)
            renderEncoder.setCullMode(.back)
        }
//        renderEncoder.setTriangleFillMode(.lines)
        
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        
        renderEncoder.endEncoding()
        if let currentDrawable = view.currentDrawable {
            commandBuffer.present(currentDrawable)
        }
        commandBuffer.commit()
    }
}
