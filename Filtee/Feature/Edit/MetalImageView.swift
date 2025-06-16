//
//  MetalImageView.swift
//  Filtee
//
//  Created by 김도형 on 6/2/25.
//

@preconcurrency import SwiftUI
import MetalKit

struct MetalImageView: UIViewRepresentable {
    @EnvironmentObject
    private var coordinator: Coordinator
    
    func makeCoordinator() -> Coordinator {
        self.coordinator
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
        view.colorPixelFormat = .rgba16Float
        do {
            let processor = try ImageFilterProcessor(
                device: device,
                image: coordinator.image
            )
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
    final class Coordinator: NSObject, ObservableObject {
        @Published
        var image: CGImage?
        @Published
        var filterValues: FilterValuesModel
        
        weak var view: MTKView?
        var processor: ImageFilterProcessor?
        
        init(
            image: CGImage?,
            filterValues: FilterValuesModel
        ) {
            self.image = image
            self.filterValues = filterValues
        }
        
        deinit { print(#function) }
        
        func updateValue(_ newValue: CGFloat) {
            switch filterValues.currentFilterValue {
            case .brightness:
                filterValues.brightness = Float(newValue)
                return
            case .exposure:
                filterValues.exposure = Float(newValue)
                return
            case .contrast:
                filterValues.contrast = Float(newValue)
                return
            case .saturation:
                filterValues.saturation = Float(newValue)
                return
            case .sharpness:
                filterValues.sharpness = Float(newValue)
                return
            case .blur:
                filterValues.blur = Float(newValue)
                return
            case .vignette:
                filterValues.vignette = Float(newValue)
                return
            case .noise:
                filterValues.noiseReduction = Float(newValue)
                return
            case .highlights:
                filterValues.highlights = Float(newValue)
                return
            case .shadows:
                filterValues.shadows = Float(newValue)
                return
            case .temperature:
                filterValues.temperature = Float(newValue)
                return
            case .blackPoint:
                filterValues.blackPoint = Float(newValue)
                return
            }
        }
        
        func filteredImage() async throws -> CGImage? {
            return try await processor?.filteredImage(
                filterValues: filterValues
            )
        }
        
        @MainActor
        func rotatedImage() {
            self.image = image?.rotateCGImage(byAngleDegrees: 90)
            guard let image else { return }
            
            Task { [weak self] in
                do {
                    try await self?.processor?.updateInputTexture(image)
                    self?.view?.setNeedsDisplay()
                } catch { print(error) }
            }
        }
    }
}

extension MetalImageView.Coordinator: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        self.view = view
        print("MTKView drawable size changed: \(size)")
    }
    
    func draw(in view: MTKView) {
        Task { [weak self] in
            guard let drawable = view.currentDrawable,
                  let renderPassDescriptor = view.currentRenderPassDescriptor,
                  let processor = self?.processor,
                  let commandBuffer = processor.commandQueue.makeCommandBuffer(),
                  let filterValues = self?.filterValues
            else { return }
            
            do {
                try await processor.renderToView(
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
