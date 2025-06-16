//
//  ImageProcessor.swift
//  Filtee
//
//  Created by 김도형 on 6/2/25.
//

@preconcurrency import Metal
@preconcurrency import MetalKit

final class ImageFilterProcessor: NSObject {
    private let device: MTLDevice
    private let textureLoader: MTKTextureLoader
    var inputTexture: MTLTexture?
    private var filterParams: FilterValuesModel
    
    let vertexBuffer: MTLBuffer
    let pipelineState: MTLRenderPipelineState
    let commandQueue: MTLCommandQueue
    var outputTexture: MTLTexture?
    
    init(device: MTLDevice?, image: CGImage?) throws {
        guard let device,
              let commandQueue = device.makeCommandQueue(),
              let library = device.makeDefaultLibrary(),
              let image
        else { throw NSError(domain: "MetalSetup", code: -1, userInfo: nil) }
        self.device = device
        self.commandQueue = commandQueue
        self.filterParams = FilterValuesModel()
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        pipelineDescriptor.fragmentFunction = library.makeFunction(name: "filterFragment")
        pipelineDescriptor.colorAttachments[0].pixelFormat = .rgba16Float
        self.pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        self.textureLoader = MTKTextureLoader(device: device)
        
        let texture = try textureLoader.newTexture(
            cgImage: image,
            options: nil
        )
        self.inputTexture = texture
        self.outputTexture = texture
        
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
    
    private func setupRenderEncoder(
        _ renderEncoder: MTLRenderCommandEncoder,
        inputTexture: MTLTexture,
        filterValues: FilterValuesModel,
        resolution: SIMD2<Float>,
        drawableSize: SIMD2<Float>,
        isPreview: Bool
    ) {
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setFragmentTexture(inputTexture, index: 0)
        
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        guard let samplerState = device.makeSamplerState(descriptor: samplerDescriptor) else {
            renderEncoder.endEncoding()
            fatalError("Failed to create sampler state")
        }
        renderEncoder.setFragmentSamplerState(samplerState, index: 0)
        
        var filterValues = filterValues
        renderEncoder.setFragmentBuffer(
            device.makeBuffer(bytes: &filterValues, length: MemoryLayout<FilterValuesModel>.size, options: []),
            offset: 0,
            index: 1
        )
        
        var resolution = resolution
        renderEncoder.setFragmentBytes(
            &resolution,
            length: MemoryLayout<SIMD2<Float>>.size,
            index: 2
        )
        
        var drawableSize = drawableSize
        renderEncoder.setFragmentBytes(
            &drawableSize,
            length: MemoryLayout<SIMD2<Float>>.size,
            index: 3
        )
        
        var isPreview = isPreview
        renderEncoder.setFragmentBytes(&isPreview, length: MemoryLayout<Bool>.size, index: 4)
        
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
    }
    
    func updateInputTexture(_ image: CGImage) async throws {
        inputTexture = try await textureLoader.newTexture(
            cgImage: image,
            options: nil
        )
    }
    
    func renderToView(
        drawableSize: CGSize,
        renderPassDescriptor: MTLRenderPassDescriptor,
        commandBuffer: MTLCommandBuffer,
        filterValues: FilterValuesModel
    ) async throws {
        guard let inputTexture,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(
                descriptor: renderPassDescriptor
              )
        else { throw NSError(domain: "RenderSetup", code: -1, userInfo: nil) }
        
        let resolution = SIMD2<Float>(Float(inputTexture.width), Float(inputTexture.height))
        let drawableSizeFloat = SIMD2<Float>(Float(drawableSize.width), Float(drawableSize.height))
        
        setupRenderEncoder(
            renderEncoder,
            inputTexture: inputTexture,
            filterValues: filterValues,
            resolution: resolution,
            drawableSize: drawableSizeFloat,
            isPreview: true
        )
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
    }
    
    func filteredImage(
        filterValues: FilterValuesModel
    ) async throws -> CGImage {
        guard let inputTexture else {
            throw NSError(domain: "InputTextureMissing", code: -1, userInfo: nil)
        }
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .rgba16Float,
            width: inputTexture.width,
            height: inputTexture.height,
            mipmapped: false
        )
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        guard let outputTexture = device.makeTexture(descriptor: textureDescriptor) else {
            throw NSError(domain: "OutputTextureCreation", code: -1, userInfo: nil)
        }
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = outputTexture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)
        
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(
                descriptor: renderPassDescriptor
              )
        else {
            throw NSError(domain: "CommandBufferCreation", code: -1, userInfo: nil)
        }
        
        let resolution = SIMD2<Float>(Float(inputTexture.width), Float(inputTexture.height))
        let drawableSizeFloat = SIMD2<Float>(Float(inputTexture.width), Float(inputTexture.height))
        
        setupRenderEncoder(
            renderEncoder,
            inputTexture: inputTexture,
            filterValues: filterValues,
            resolution: resolution,
            drawableSize: drawableSizeFloat,
            isPreview: false
        )
        
        renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        renderEncoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        guard let ciImage = CIImage(mtlTexture: outputTexture, options: nil) else {
            throw NSError(domain: "CIImageCreation", code: -1, userInfo: nil)
        }
        
        let context = CIContext()
        let extent = ciImage.extent
        
        // 변환 적용
        let flippedImage = ciImage.oriented(.downMirrored)
        
        guard let cgImage = context.createCGImage(
            flippedImage,
            from: flippedImage.extent
        ) else { throw NSError(domain: "CGImageCreation", code: -1, userInfo: nil) }
        print(cgImage)
        
        return cgImage
    }
    
}
