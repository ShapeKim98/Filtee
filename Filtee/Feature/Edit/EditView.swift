//
//  EditView.swift
//  Filtee
//
//  Created by 김도형 on 5/30/25.
//

import SwiftUI

struct EditView: View {
    @StateObject
    private var coordinator: MetalImageView.Coordinator
    
    @EnvironmentObject
    private var navigation: NavigationRouter<MakePath>
    
    @Binding
    private var filteredImage: CGImage?
    @Binding
    private var originalImage: UIImage?
    @Binding
    private var filterValues: FilterValuesModel
    
    @State
    private var imageHeight: CGFloat = .zero
    @State
    private var valueOffsetX: CGFloat = 0
    @State
    private var valueSliderFrame: CGRect = .zero
    @State
    private var dragGestureTask: Task<Void, Never>?
    @State
    private var previousFilterStack: [FilterValuesModel] = []
    @State
    private var nextFilterStack: [FilterValuesModel] = []
    @State
    private var isOriginal: Bool = false
    @State
    private var tempFilterValues: FilterValuesModel?
    
    init(
        filteredImage: Binding<CGImage?>,
        originalImage: Binding<UIImage?>,
        filterValues: Binding<FilterValuesModel>
    ) {
        self._coordinator = StateObject(
            wrappedValue: MetalImageView.Coordinator(
                image: originalImage.wrappedValue?.cgImage,
                filterValues: filterValues.wrappedValue,
                rotationAngle: 0
            )
        )
        self._filteredImage = filteredImage
        self._originalImage = originalImage
        self._filterValues = filterValues
    }
    
    var body: some View {
        VStack(spacing: 0) {
            MetalImageView()
                .environmentObject(coordinator)
                .overlay(alignment: .bottom) {
                    filterStatusBar
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                }
                .animation(.default, value: coordinator.rotationAngle)
            
            Group {
                valueSlider
                    .opacity(isOriginal ? 0.5 : 1)
                
                valueButtonList
            }
            .disabled(isOriginal)
        }
        .filteeNavigation(
            title: "EDIT",
            leadingItems: leadingItems,
            trailingItems: trailingItems
        )
        .background { bodyBackground }
    }
}

// MARK: - Configure Views
private extension EditView {
    func leadingItems() -> some View {
        Button(action: backButtonAction) {
            Image(.chevron)
                .resizable()
        }
        .buttonStyle(.filteeToolbar)
    }
    
    func trailingItems() -> some View {
        Button(action: saveButtonAction) {
            Image(.save)
                .resizable()
        }
        .buttonStyle(.filteeToolbar)
    }
    
    func backgroundImage(_ image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .overlay(Color(red: 0.04, green: 0.04, blue: 0.04).opacity(0.8))
            .clipped()
            .ignoresSafeArea()
    }
    
    var bodyBackground: some View {
        VisualEffect(style: .systemChromeMaterialDark)
            .ifLet(filteredImage) { view, image in
                view.background { backgroundImage(Image(uiImage: UIImage(cgImage: image))) }
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
                format: coordinator.filterValues.currentFilterValue.format,
                coordinator.filterValues.currentValue
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
                    .onEnded({ _ in valueIndicatorDragGestureOnEnded()})
            )
        }
        .frame(height: 40)
        .padding(.top, 16)
        .padding(.horizontal, 20)
        .valueFeedback(trigger: coordinator.filterValues.currentValue)
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
        let isSelected = type == coordinator.filterValues.currentFilterValue
        
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
    
    var filterStatusBar: some View {
        HStack(spacing: 8) {
            Group {
                Button(action: redoButtonAction) {
                    filterStatusButtonLabel
                }
                .buttonStyle(.plain)
                .disabled(previousFilterStack.isEmpty)
                .rotation3DEffect(.degrees(180), axis: (0, 1, 0))
                
                Button(action: undoButtonAction) {
                    filterStatusButtonLabel
                }
                .buttonStyle(.plain)
                .disabled(nextFilterStack.isEmpty)
            }
            .disabled(isOriginal)

            
            Spacer()
            
            Button(action: originalButtonAction) {
                Image(.compare)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipRectangle(8)
                    .rotationEffect(.degrees(isOriginal ? 180 : 0))
                    .animation(nil, value: isOriginal)
            }
            .buttonStyle(.plain)
            
            Button(action: degreeButtonAction) {
                Image(systemName: "rotate.left")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipRectangle(8)
            }
            .buttonStyle(.plain)
        }
    }
    
    var filterStatusButtonLabel: some View {
        Image(.redo)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial)
            .clipRectangle(8)
    }
}

// MARK: - Functions
private extension EditView {
    func backButtonAction() {
        navigation.pop()
    }
    
    func saveButtonAction() {
        let coordinator = self.coordinator
        Task {
            filteredImage = try await coordinator.filteredImage()
            filterValues = coordinator.filterValues
            let degrees = CGFloat(coordinator.rotationAngle)
            let cgImage = originalImage?.cgImage?.rotateCGImage(byAngleDegrees: degrees)
            guard let cgImage else { return }
            originalImage = UIImage(cgImage: cgImage)
            navigation.pop()
        }
    }
    
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
    
    func valueIndicatorDragGestureOnEnded() {
        if !nextFilterStack.isEmpty {
            nextFilterStack.removeAll()
        }
        pushPreviousFilterStack()
    }
    
    func valueSliderOnAppear(frame: CGRect) {
        valueSliderFrame = frame
        normalizationValue()
    }
    
    func valueButtonAction(
        type: FilterValuesModel.FilterValue,
        proxy: ScrollViewProxy
    ) {
        coordinator.filterValues.currentFilterValue = type
        normalizationValue()
        withAnimation(.default) {
            proxy.scrollTo(type.rawValue, anchor: .center)
        }
    }
    
    func redoButtonAction() {
        popPreviousFilterStack()
    }
    
    func undoButtonAction() {
        popNextFilterStack()
    }
    
    func originalButtonAction() {
        isOriginal.toggle()
        if isOriginal {
            tempFilterValues = coordinator.filterValues
            coordinator.filterValues = FilterValuesModel()
        } else {
            guard let tempFilterValues else { return }
            self.tempFilterValues = nil
            coordinator.filterValues = tempFilterValues
        }
    }
    
    func degreeButtonAction() {
        let newRotationAngle = coordinator.rotationAngle + 90
        coordinator.rotationAngle = newRotationAngle.truncatingRemainder(dividingBy: 360)
    }
    
    func normalizationValue() {
        let currentFilterValue = coordinator.filterValues.currentFilterValue
        let minimum = currentFilterValue.minimum - currentFilterValue.median
        let maximum = currentFilterValue.maximum - currentFilterValue.median
        
        let minOffsetX = valueSliderFrame.minX - valueSliderFrame.midX
        let maxOffsetX = valueSliderFrame.maxX - valueSliderFrame.midX
        
        let normalizeValue = (maxOffsetX - minOffsetX) / (maximum - minimum)
        let newOffsetX = (CGFloat(coordinator.filterValues.currentValue) - currentFilterValue.median) * normalizeValue + valueSliderFrame.midX
        withAnimation(.filteeSpring) {
            valueOffsetX = newOffsetX
        }
    }
    
    func normalizationOffset(_ value: DragGesture.Value) {
        let currentFilterValue = coordinator.filterValues.currentFilterValue
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
        coordinator.updateValue(newValue)
    }
    
    func pushPreviousFilterStack() {
        if previousFilterStack.isEmpty {
            previousFilterStack.append(FilterValuesModel())
        }
        previousFilterStack.append(coordinator.filterValues)
    }
    
    func popPreviousFilterStack() {
        if coordinator.filterValues == previousFilterStack.last {
            let _ = previousFilterStack.popLast()
        }
        guard let filter = previousFilterStack.popLast() else {
            return
        }
        nextFilterStack.append(coordinator.filterValues)
        coordinator.filterValues = filter
        normalizationValue()
    }
    
    func popNextFilterStack() {
        if coordinator.filterValues == nextFilterStack.last {
            let _ = nextFilterStack.popLast()
        }
        guard let filter = nextFilterStack.popLast() else {
            return
        }
        previousFilterStack.append(coordinator.filterValues)
        coordinator.filterValues = filter
        normalizationValue()
    }
    
    func updateFilteredImage() {
        let coordinator = coordinator
        Task {
            do {
                let image = try await coordinator.filteredImage()
                guard let image else { return }
                filteredImage = image
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    EditView(
        filteredImage: .constant(UIImage(resource: .rice).cgImage!),
        originalImage: .constant(UIImage(resource: .rice)),
        filterValues: .constant(FilterValuesModel())
    )
}
