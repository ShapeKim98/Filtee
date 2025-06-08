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
    private var valueOffsetX: CGFloat = 0
    @State
    private var valueSliderFrame: CGRect = .zero
    @State
    private var dragGestureTask: Task<Void, Never>?
    
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
            
            Text(String(
                format: filterValues.currentFilterValue.format,
                filterValues.currentValue
            ))
            .contentTransition(.numericText())
            .animation(.easeInOut, value: valueOffsetX)
            .font(.pretendard(.body2(.bold)))
            .foregroundStyle(.gray75)
            .frame(width: 64, height: 22)
            .background(.blackTurquoise)
            .clipRectangle(8)
            .frame(height: 40, alignment: .top)
            .background(.black.opacity(0.01))
            .offset(x: valueOffsetX - (64 / 2 + 6))
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        valueIndicatorDragGestureOnChanged(value, frame: frame)
                    })
                    .onEnded({ value in
//                        valueIndicatorDragGestureOnEnded(value)
                    })
            )
        }
        .frame(height: 40)
        .padding(.top, 16)
        .padding(.horizontal, 20)
        .valueFeedback(trigger: filterValues.currentValue)
    }
    
    var valueButtonList: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(
                        FilterValuesModel.FilterValue.allCases,
                        id: \.self
                    ) { type in
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
    func valueButton(
        _ type: FilterValuesModel.FilterValue,
        proxy: ScrollViewProxy
    ) -> some View {
        let isSelected = type == filterValues.currentFilterValue
        
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
        dragGestureTask?.cancel()
        
        dragGestureTask = Task {
            try? await Task.sleep(for: .milliseconds(2))
            normalizationOffset(value)
        }
    }
    
    func valueIndicatorDragGestureOnEnded(_ value: DragGesture.Value) {
        
    }
    
    func valueSliderOnAppear(frame: CGRect) {
        valueSliderFrame = frame
        normalizationValue()
    }
    
    func normalizationValue() {
        let currentFilterValue = filterValues.currentFilterValue
        let minimum = currentFilterValue.minimum - currentFilterValue.median
        let maximum = currentFilterValue.maximum - currentFilterValue.median
        
        let minOffsetX = valueSliderFrame.minX - valueSliderFrame.midX
        let maxOffsetX = valueSliderFrame.maxX - valueSliderFrame.midX
        
        let normalizeValue = (maxOffsetX - minOffsetX) / (maximum - minimum)
        let newOffsetX = (CGFloat(filterValues.currentValue) - currentFilterValue.median) * normalizeValue + valueSliderFrame.midX
        valueOffsetX = newOffsetX
    }
    
    func normalizationOffset(_ value: DragGesture.Value) {
        let currentFilterValue = filterValues.currentFilterValue
        let minimum = currentFilterValue.minimum - currentFilterValue.median
        let maximum = currentFilterValue.maximum - currentFilterValue.median
        
        let minOffsetX = valueSliderFrame.minX - valueSliderFrame.midX
        let maxOffsetX = valueSliderFrame.maxX - valueSliderFrame.midX
        
        let normalizeValue = (maximum - minimum) / (maxOffsetX - minOffsetX)
        var newValue = (value.location.x - valueSliderFrame.midX) * normalizeValue + currentFilterValue.median
        let unit = pow(10, currentFilterValue.decimalUnit)
        newValue = round(newValue * unit) / unit
        
        valueOffsetX = value.location.x
        
        var remainder = newValue.truncatingRemainder(dividingBy: currentFilterValue.unit)
        remainder = remainder < 0 ? ceil(remainder) : floor(remainder)
        guard remainder == 0 else { return }
        updateValue(newValue)
    }
    
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
    
    func valueButtonAction(
        type: FilterValuesModel.FilterValue,
        proxy: ScrollViewProxy
    ) {
        filterValues.currentFilterValue = type
        normalizationValue()
        proxy.scrollTo(type.rawValue, anchor: .center)
    }
}

#Preview {
    EditView(image: UIImage(resource: .sampleOriginal).cgImage!)
}
