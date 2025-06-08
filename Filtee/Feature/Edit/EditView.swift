//
//  EditView.swift
//  Filtee
//
//  Created by 김도형 on 5/30/25.
//

import SwiftUI

struct EditView: View {
    @State
    private var image: CGImage
    @State
    private var filterValues = FilterValuesModel()
    @State
    private var imageHeight: CGFloat = .zero
    @State
    private var currentValue: FilterValue = .brightness
    @State
    private var valueOffsetX: CGFloat = 0
    @State
    private var valueSliderFrame: CGRect = .zero
    @State
    private var valueIndicatorSize: CGSize = .zero
    
    
    private var value: Float {
        switch currentValue {
        case .brightness:
            return filterValues.brightness
        case .exposure:
            return filterValues.exposure
        case .contrast:
            return filterValues.contrast
        case .saturation:
            return filterValues.saturation
        case .sharpness:
            return filterValues.sharpness
        case .blur:
            return filterValues.blur
        case .vignette:
            return filterValues.vignette
        case .noise:
            return filterValues.noiseReduction
        case .highlights:
            return filterValues.highlights
        case .shadows:
            return filterValues.shadows
        case .temperature:
            return filterValues.temperature
        case .blackPoint:
            return filterValues.blackPoint
        }
    }
    
    init(image: CGImage) {
        self.image = image
    }
    
    var body: some View {
        VStack(spacing: 0) {
            MetalImageView(image: $image, filterValues: $filterValues)
            
            valueSlider
            
            valueButtonList
        }
        .filteeNavigation(title: "EDIT")
        .background { bodyBackground }
    }
}

// MARK: - Configure Views
private extension EditView {
    func backgroundImage(_ image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity)
            .overlay(Color(red: 0.04, green: 0.04, blue: 0.04).opacity(0.8))
            .ignoresSafeArea()
    }
    
    var bodyBackground: some View {
        VisualEffect(style: .systemChromeMaterialDark)
            .ifLet(UIImage(cgImage: image)) { view, image in
                view.background { backgroundImage(Image(uiImage: image)) }
            }
            .ignoresSafeArea()
    }
    
    var valueSlider: some View {
        GeometryReader { proxy in
            let frame = proxy.frame(in: .local)
            
            RoundedRectangle(cornerRadius: 9999, style: .continuous)
                .fill(.blackTurquoise)
                .frame(height: 12)
                .offset(y: frame.maxY - 12)
            
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 1, green: 0, blue: 0.7), location: 0.00),
                    Gradient.Stop(color: Color(red: 0.03, green: 0.79, blue: 0.55), location: 1.00),
                ],
                startPoint: UnitPoint(x: 0, y: 0.5),
                endPoint: UnitPoint(x: 1, y: 0.5)
            )
            .clipRectangle(9999)
            .frame(width: valueOffsetX, height: 12)
            .offset(y: frame.maxY - 12)
            .onAppear { valueSliderOnAppear(frame: frame) }
            
            ZStack {
                Circle().fill(.clear)
                    .frame(width: 12, height: 12)
                
                Circle().fill(.blackTurquoise)
                    .frame(width: 4, height: 4)
                    .padding(4)
            }
            .offset(x: valueOffsetX - 12, y: frame.maxY - 12)
            
            Text(String(format: "%.1f", value))
                .contentTransition(.numericText())
                .animation(.filteeDefault, value: value)
                .font(.pretendard(.body2(.bold)))
                .foregroundStyle(.gray75)
                .frame(width: 56, height: 22)
                .padding(.horizontal, 11)
                .background(.blackTurquoise)
                .clipRectangle(8)
                .frame(height: 40, alignment: .top)
                .background(.black.opacity(0.01))
                .offset(x: valueOffsetX - (88 / 2))
                .gesture(DragGesture().onChanged({ value in
                    valueIndicatorDragGestureOnChanged(value, frame: frame)
                }))
        }
        .frame(height: 40)
        .padding(.top, 16)
        .padding(.horizontal, 20)
    }
    
    var valueButtonList: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(FilterValue.allCases, id: \.self) { type in
                        valueButton(type, proxy: proxy)
                            .id(type.rawValue)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
            }
            .padding(.top, 20)
        }
    }
    
    @ViewBuilder
    func valueButton(_ type: FilterValue, proxy: ScrollViewProxy) -> some View {
        let isSelected = type == currentValue
        
        Button(action: { valueButtonAction(type: type, proxy: proxy) }) {
            VStack(spacing: 8) {
                Image(type.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                
                Text(type.title)
                    .font(.pretendard(.caption2(.semiBold)))
                    .allowsTightening(true)
            }
            .frame(width: 74)
            .foregroundStyle(isSelected ? .gray30 : Color.secondary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Functions
private extension EditView {
    func valueIndicatorDragGestureOnChanged(_ value: DragGesture.Value, frame: CGRect) {
        guard value.location.x > valueSliderFrame.minX,
              value.location.x < valueSliderFrame.maxX
        else { return }
        valueOffsetX = value.location.x
        normalizationOffset()
    }
    
    func valueSliderOnAppear(frame: CGRect) {
        valueSliderFrame = frame
        normalizationValue()
    }
    
    func normalizationValue() {
        let minimum = currentValue.minimum - currentValue.median
        let maximum = currentValue.maximum - currentValue.median
        
        let minOffsetX = valueSliderFrame.minX - valueSliderFrame.midX
        let maxOffsetX = valueSliderFrame.maxX - valueSliderFrame.midX
        
        let normalizeValue = (maxOffsetX - minOffsetX) / (maximum - minimum)
        let newOffsetX = (CGFloat(value) - currentValue.median) * normalizeValue + valueSliderFrame.midX
        valueOffsetX = newOffsetX
    }
    
    func normalizationOffset() {
        let minimum = currentValue.minimum - currentValue.median
        let maximum = currentValue.maximum - currentValue.median
        
        let minOffsetX = valueSliderFrame.minX - valueSliderFrame.midX
        let maxOffsetX = valueSliderFrame.maxX - valueSliderFrame.midX
        
        let normalizeValue = (maximum - minimum) / (maxOffsetX - minOffsetX)
        let newValue = (valueOffsetX - valueSliderFrame.midX) * normalizeValue + currentValue.median
        
        updateValue(newValue)
    }
    
    func updateValue(_ newValue: CGFloat) {
        switch currentValue {
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
    
    func valueButtonAction(type: FilterValue, proxy: ScrollViewProxy) {
        withAnimation(.filteeSpring) {
            currentValue = type
            normalizationValue()
            proxy.scrollTo(type.rawValue, anchor: .center)
        }
    }
}

private extension EditView {
    enum FilterValue: String, CaseIterable {
        case brightness
        case exposure
        case contrast
        case saturation
        case sharpness
        case blur
        case vignette
        case noise
        case highlights
        case shadows
        case temperature
        case blackPoint
        
        var image: ImageResource {
            switch self {
            case .brightness:
                return .brightness
            case .exposure:
                return .exposure
            case .contrast:
                return .contrast
            case .saturation:
                return .saturation
            case .sharpness:
                return .sharpness
            case .blur:
                return .blur
            case .vignette:
                return .vignette
            case .noise:
                return .noise
            case .highlights:
                return .highlights
            case .shadows:
                return .shadows
            case .temperature:
                return .temperature
            case .blackPoint:
                return .blackPoint
            }
        }
        
        var title: String {
            self.rawValue.uppercased()
        }
        
        var minimum: CGFloat {
            switch self {
            case .contrast,
                 .saturation:
                return 0
            case .temperature:
                return 2000
            default: return -1
            }
        }
        
        var median: CGFloat {
            switch self {
            case .contrast,
                 .saturation:
                return 1
            case .temperature:
                return 6500
            default: return 0
            }
        }
        
        var maximum: CGFloat {
            switch self {
            case .contrast,
                 .saturation:
                return 2
            case .temperature:
                return 11000
            default: return 1
            }
        }
        
        var unit: CGFloat {
            switch self {
            case .temperature: return 100
            default: return 0.01
            }
        }
    }
}

#Preview {
    EditView(image: UIImage(resource: .sampleOriginal).cgImage!)
}
