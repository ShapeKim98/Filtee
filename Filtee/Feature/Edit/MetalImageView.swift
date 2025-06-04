//
//  MetalImageView.swift
//  Filtee
//
//  Created by 김도형 on 6/2/25.
//

@preconcurrency import SwiftUI
import MetalKit

struct MetalImageView: UIViewRepresentable {
    @Binding var image: CGImage
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
        let device = MTLCreateSystemDefaultDevice()
        view.device = device
        view.delegate = context.coordinator
        view.backgroundColor = .clear
        do {
            let processor = try ImageFilterProcessor(device: device, image: image)
            context.coordinator.processor = processor
            view.setNeedsDisplay()
        } catch { print("Failed to initialize ImageFilterProcessor: \(error)") }
        return view
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        uiView.setNeedsDisplay()
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
            guard let drawable = view.currentDrawable,
                  let renderPassDescriptor = view.currentRenderPassDescriptor,
                  let commandBuffer = await processor?.commandQueue.makeCommandBuffer()
            else { return }
            
            do {
                try await processor?.renderToView(
                    drawableSize: view.drawableSize,
                    renderPassDescriptor: renderPassDescriptor,
                    commandBuffer: commandBuffer,
                    filterValues: filterValues
                )
                commandBuffer.present(drawable)
                commandBuffer.commit()
            } catch {
                print("Failed to render: \(error)")
            }
        }
    }
}

struct MetalImageExampleView: View {
    @State private var filterValues = FilterValuesModel()
    @State private var inputImage = UIImage(named: "SampleOriginal")!.cgImage!
    
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
        }
    }
}
