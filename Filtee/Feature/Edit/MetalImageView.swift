//
//  MetalImageView.swift
//  Filtee
//
//  Created by 김도형 on 6/2/25.
//

@preconcurrency import SwiftUI
import MetalKit

struct MetalImageView: UIViewRepresentable {
    @Binding var image: UIImage
    @Binding var filterValues: FilterValuesModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, filterValues: $filterValues)
    }
    
    func makeUIView(context: Context) -> MTKView {
        let view = MTKView()
        view.enableSetNeedsDisplay = true
        view.isPaused = true
        view.clearColor = MTLClearColorMake(0, 0, 0, 1)
        view.framebufferOnly = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        let device = MTLCreateSystemDefaultDevice()
        view.device = device
        view.delegate = context.coordinator
        do {
            let processor = try ImageFilterProcessor(device: device, image: image)
            context.coordinator.processor = processor
            view.setNeedsDisplay()
        } catch { print("Failed to initialize ImageFilterProcessor: \(error)") }
        return view
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        Task {
            do {
                try await context.coordinator.processor?.updateImage(
                    filterValues: filterValues
                )
                uiView.setNeedsDisplay()
            } catch { print("Failed to update image: \(error)") }
        }
    }
}

extension MetalImageView {
    final class Coordinator: NSObject {
        @Binding
        private var filterValues: FilterValuesModel
        
        var parent: MetalImageView
        var processor: ImageFilterProcessor?
        
        init(_ parent: MetalImageView, filterValues: Binding<FilterValuesModel>) {
            self.parent = parent
            self._filterValues = filterValues
        }
    }
}

extension MetalImageView.Coordinator: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        print("MTKView drawable size changed: \(size)")
    }
    
    func draw(in view: MTKView) {
        Task {
            guard let processor else { return }
            guard let outputTexture = await processor.outputTexture,
                  let drawable = view.currentDrawable,
                  let commandBuffer = await processor.commandQueue.makeCommandBuffer()
            else { return }
            
            let renderPassDescriptor = MTLRenderPassDescriptor()
            renderPassDescriptor.colorAttachments[0].texture = drawable.texture
            renderPassDescriptor.colorAttachments[0].loadAction = .clear
            renderPassDescriptor.colorAttachments[0].storeAction = .store
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)
            
            guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(
                descriptor: renderPassDescriptor
            ) else { return }
            
            let pipelineState = await processor.pipelineState
            renderEncoder.setRenderPipelineState(pipelineState)
            renderEncoder.setFragmentTexture(outputTexture, index: 0)
            
            // 샘플러 설정
            let samplerDescriptor = MTLSamplerDescriptor()
            samplerDescriptor.minFilter = .linear
            samplerDescriptor.magFilter = .linear
            guard let device = view.device,
                  let samplerState = device.makeSamplerState(
                    descriptor: samplerDescriptor
                  )
            else { renderEncoder.endEncoding(); return }
            renderEncoder.setFragmentSamplerState(samplerState, index: 0)
            
            // 필터 값 버퍼 (필터 적용 없이 기본 값으로 설정)
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
                Float(outputTexture.width),
                Float(outputTexture.height)
            )
            renderEncoder.setFragmentBytes(
                &resolution,
                length: MemoryLayout<SIMD2<Float>>.size,
                index: 2
            )
            
            let vertexBuffer = await processor.vertexBuffer
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            renderEncoder.drawPrimitives(
                type: .triangleStrip,
                vertexStart: 0,
                vertexCount: 4
            )
            renderEncoder.endEncoding()
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}

struct MetalImageExampleView: View {
    @State private var filterValues = FilterValuesModel()
    @State private var inputImage = UIImage(named: "SampleOriginal")!
    
    var body: some View {
        ScrollView {
            VStack {
                MetalImageView(image: $inputImage, filterValues: $filterValues)
                    .frame(width: 400, height: 400)
                    .border(Color.gray, width: 1)
                
                Slider(value: $filterValues.brightness, in: -1.0...1.0) { Text("Brightness") }
                Slider(value: $filterValues.exposure, in: -1.0...1.0) { Text("Exposure") }
                Slider(value: $filterValues.contrast, in: 0.0...2.0) { Text("Contrast") }
                Slider(value: $filterValues.saturation, in: 0.0...2.0) { Text("Saturation") }
                Slider(value: $filterValues.sharpness, in: -1.0...1.0) { Text("Sharpness") }
                Slider(value: $filterValues.blur, in: -1.0...1.0) { Text("Blur") }
                Slider(value: $filterValues.vignette, in: -1.0...1.0) { Text("Vignette") }
                Slider(value: $filterValues.noiseReduction, in: -1.0...1.0) { Text("Noise Reduction") }
                Slider(value: $filterValues.highlights, in: -1.0...1.0) { Text("Highlights") }
                Slider(value: $filterValues.shadows, in: -1.0...1.0) { Text("Shadows") }
                Slider(value: $filterValues.temperature, in: 3000.0...10000.0) { Text("Temperature") }
                Slider(value: $filterValues.blackPoint, in: -1.0...1.0) { Text("Black Point") }
            }
            .foregroundStyle(.primary)
            .padding()
            .onAppear {
                print("ContentView appeared, image: \(inputImage.size)")
            }
        }
    }
}
