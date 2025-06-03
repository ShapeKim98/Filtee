//
//  ImageProcessor.swift
//  Filtee
//
//  Created by 김도형 on 6/2/25.
//

@preconcurrency import Metal
@preconcurrency import MetalKit

actor ImageFilterProcessor: NSObject {
    private let device: MTLDevice
    private let textureLoader: MTKTextureLoader
    private var inputTexture: MTLTexture?
    private var filterParams: FilterValuesModel
    
    let vertexBuffer: MTLBuffer
    let pipelineState: MTLRenderPipelineState
    let commandQueue: MTLCommandQueue
    var outputTexture: MTLTexture?
    
    var filteredTextureStack: [MTLTexture] = []
    var nextTextureStack: [MTLTexture] = []
    
    init(device: MTLDevice?, image: UIImage) throws {
        guard let device,
              let commandQueue = device.makeCommandQueue(),
              let library = device.makeDefaultLibrary()
        else { throw NSError(domain: "MetalSetup", code: -1, userInfo: nil) }
        self.device = device
        self.commandQueue = commandQueue
        self.filterParams = FilterValuesModel()
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "filterFragment")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        self.textureLoader = MTKTextureLoader(device: device)
        
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "ImageProcessing", code: -1, userInfo: nil)
        }
        let texture = try textureLoader.newTexture(
            cgImage: cgImage,
            options: nil
        )
        self.inputTexture = texture
        self.outputTexture = texture
        filteredTextureStack.append(texture)
        
        let vertices: [Float] = [
            -1, -1, 0, 1,  // 왼쪽 아래: 위치 (-1, -1), 텍스처 (0, 1)
             1, -1, 1, 1,  // 오른쪽 아래: 위치 (1, -1), 텍스처 (1, 1)
            -1,  1, 0, 0,  // 왼쪽 위: 위치 (-1, 1), 텍스처 (0, 0)
             1,  1, 1, 0   // 오른쪽 위: 위치 (1, 1), 텍스처 (1, 0)
        ]
        guard let buffer = device.makeBuffer(
            bytes: vertices,
            length: vertices.count * MemoryLayout<Float>.size,
            options: []
        ) else { throw NSError(domain: "VertexBufferCreation", code: -1, userInfo: nil) }
        self.vertexBuffer = buffer
        
        super.init()
    }
    
    @Sendable
    func updateImage(filterValues: FilterValuesModel) async throws {
        guard let inputTexture = inputTexture else {
            throw NSError(domain: "NoInputTexture", code: -1, userInfo: nil)
        }
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm,
            width: inputTexture.width,
            height: inputTexture.height,
            mipmapped: false
        )
        textureDescriptor.usage = [.renderTarget, .shaderRead, .shaderWrite]
        guard let newOutputTexture = device.makeTexture(
            descriptor: textureDescriptor
        ) else { throw NSError(domain: "TextureCreation", code: -1, userInfo: nil) }
        
        // 필터 적용
        try await applyFilters(
            inputTexture: inputTexture,
            outputTexture: newOutputTexture,
            filterValues: filterValues
        )
        
        self.outputTexture = newOutputTexture
        self.filterParams = filterValues
    }
    
    private func applyFilters(
        inputTexture: MTLTexture,
        outputTexture: MTLTexture,
        filterValues: FilterValuesModel
    ) async throws {
        let renderPassDescriptor = MTLRenderPassDescriptor()
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            throw NSError(domain: "CommandBuffer", code: -1, userInfo: nil)
        }
        
        renderPassDescriptor.colorAttachments[0].texture = outputTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)
        
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(
            descriptor: renderPassDescriptor
        ) else { throw NSError(domain: "RenderEncoder", code: -1, userInfo: nil) }
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setFragmentTexture(inputTexture, index: 0)
        
        // 샘플러 설정
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        guard let samplerState = device.makeSamplerState(
            descriptor: samplerDescriptor
        ) else { throw NSError(domain: "SamplerCreation", code: -1, userInfo: nil) }
        renderEncoder.setFragmentSamplerState(samplerState, index: 0)
        
        // 필터 값 버퍼
        var params = filterValues
        renderEncoder.setFragmentBuffer(
            device.makeBuffer(
                bytes: &params,
                length: MemoryLayout<FilterValuesModel>.size,
                options: []
            ),
            offset: 0,
            index: 1
        )
        
        // 해상도 버퍼
        var resolution = SIMD2<Float>(
            Float(inputTexture.width),
            Float(inputTexture.height)
        )
        renderEncoder.setFragmentBytes(
            &resolution,
            length: MemoryLayout<SIMD2<Float>>.size,
            index: 2
        )
        
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
        
        return try await withCheckedThrowingContinuation { continuation in
            commandBuffer.addCompletedHandler { buffer in
                if let error = buffer.error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
            commandBuffer.commit()
        }
    }
    
    func pushFilteredTexture() {
        guard let outputTexture = outputTexture else { return }
        filteredTextureStack.append(outputTexture)
    }
    
    func popFilteredTexture() {
        guard let outputTexture = filteredTextureStack.popLast() else {
            return
        }
        nextTextureStack.append(outputTexture)
        self.outputTexture = filteredTextureStack.last
    }
    
    func popNextTexture() {
        guard let outputTexture = nextTextureStack.popLast() else {
            return
        }
        filteredTextureStack.append(outputTexture)
        self.outputTexture = outputTexture
    }
}
