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
    var inputTexture: MTLTexture?
    private var filterParams: FilterValuesModel
    
    let vertexBuffer: MTLBuffer
    let pipelineState: MTLRenderPipelineState
    let commandQueue: MTLCommandQueue
    var outputTexture: MTLTexture?
    
    var filteredTextureStack: [MTLTexture] = []
    var nextTextureStack: [MTLTexture] = []
    
    init(device: MTLDevice?, image: CGImage) throws {
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
        
        let texture = try textureLoader.newTexture(
            cgImage: image,
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
        
        // 렌더 파이프라인 상태 설정
        renderEncoder.setRenderPipelineState(pipelineState)
        
        // 원본 텍스처 설정 (프래그먼트 셰이더에 전달)
        renderEncoder.setFragmentTexture(inputTexture, index: 0)
        
        // 샘플러 설정
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        guard let samplerState = device.makeSamplerState(
            descriptor: samplerDescriptor
        ) else {
            renderEncoder.endEncoding()
            throw NSError(domain: "SamplerCreation", code: -1, userInfo: nil)
        }
        renderEncoder.setFragmentSamplerState(samplerState, index: 0)
        
        // 필터 값 버퍼 설정 (인덱스 1)
        var filterValues = filterValues
        renderEncoder.setFragmentBuffer(
            device.makeBuffer(bytes: &filterValues, length: MemoryLayout<FilterValuesModel>.size, options: []),
            offset: 0,
            index: 1
        )
        
        // 해상도 버퍼 설정 (인덱스 2)
        var resolution = SIMD2<Float>(Float(inputTexture.width), Float(inputTexture.height))
        renderEncoder.setFragmentBytes(&resolution, length: MemoryLayout<SIMD2<Float>>.size, index: 2)
        
        // 뷰 크기 버퍼 설정 (인덱스 3)
        var drawableSize = SIMD2<Float>(
            Float(drawableSize.width),
            Float(drawableSize.height)
        )
        renderEncoder.setFragmentBytes(&drawableSize, length: MemoryLayout<SIMD2<Float>>.size, index: 3)
        
        // 버텍스 버퍼 설정
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        // 렌더링 명령
        renderEncoder.drawPrimitives(
            type: .triangleStrip,
            vertexStart: 0,
            vertexCount: 4
        )
        renderEncoder.endEncoding()
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
