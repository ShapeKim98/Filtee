//
//  FilterDetailView.swift
//  Filtee
//
//  Created by 김도형 on 5/25/25.
//

import SwiftUI
import MapKit
import Contacts

import Nuke

struct FilterDetailView: View {
    @EnvironmentObject
    private var navigation: NavigationRouter<MainPath>
    
    @Environment(\.filterClient.filterDetail)
    private var filterClientFilterDetail
    @Environment(\.filterClient.filterLike)
    private var filterClientFilterLike
    @Environment(\.orderClient.ordersCreate)
    private var orderClientOrdersCreate
    @Environment(\.iamportClient.requestIamport)
    private var iamportClientRequestIamport
    @Environment(\.paymentsClient.paymentsValidation)
    private var paymentsClientPaymentsValidation
    
    @State
    private var filter: FilterDetailModel?
    @State
    private var originalImage: Image?
    @State
    private var filteredImage: Image?
    @State
    private var filterPivot: CGFloat = 0
    @State
    private var imageSectionHeight: CGFloat = 0
    @State
    private var photoAddress: String?
    @State
    private var iamportPayload: IamportPaymentPayloadModel?
    @State
    private var name: String?
    
    private let filterId: String
    
    init(filterId: String) {
        self.filterId = filterId
    }
    
    var body: some View {
        ScrollView(content: content)
            .filteeNavigation(
                title: filter?.title ?? "",
                leadingItems: toolbarLeading,
                trailingItems: toolbarTrailing
            )
            .background {
                scrollViewBackground
            }
            .task(bodyTask)
            .fullScreenCover(item: $iamportPayload) { payload in
                paymentWeb(payload)
            }
    }
}

// MARK: - Configure Views
private extension FilterDetailView {
    func toolbarLeading() -> some View {
        Button(action: backButtonAction) {
            Image(.chevron).resizable()
        }
        .buttonStyle(.filteeToolbar)
    }
    
    @ViewBuilder
    func toolbarTrailing() -> some View {
        let isLike = filter?.isLike ?? false
        let image: ImageResource = isLike ? .likeFill : .likeEmpty
        
        Button(action: likeButtonAction) {
            Image(image).resizable()
        }
        .buttonStyle(.filteeToolbar)
        .animation(.filteeDefault, value: isLike)
    }
    
    func content() -> some View {
        VStack(spacing: 28) {
            imageSection
            
            price
            
            informationSection
            
            if let creator = filter?.creator {
                FilteeProfile(profile: creator)
            }
        }
    }
    
    func backgroundImage(_ image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity)
            .overlay(Color(red: 0.04, green: 0.04, blue: 0.04).opacity(0.8))
            .ignoresSafeArea()
    }
    
    var scrollViewBackground: some View {
        VisualEffect(style: .systemChromeMaterialDark)
            .ifLet(filteredImage) { view, image in
                view.background { backgroundImage(image) }
            }
            .ignoresSafeArea()
    }
    
    var imageSection: some View {
        GeometryReader { proxy in
            let local = proxy.frame(in: .local)
            let width = local.width
            
            if let originalImage, let filteredImage {
                filteredImage
                    .squareImage(width)
                    .frame(width: filterPivot, alignment: .leading)
                    .cornerRadius(radius: 24, corners: [.topLeft, .bottomLeft])
                    .clipped()
                    .offset(x: local.minX)
                    .filteeBlurReplace()
                
                originalImage
                    .squareImage(width)
                    .frame(width: width - filterPivot, alignment: .trailing)
                    .cornerRadius(radius: 24, corners: [.topRight, .bottomRight])
                    .clipped()
                    .offset(x: local.minX + filterPivot)
                    .filteeBlurReplace()
                
                let sliderWidth: CGFloat = 48 * 2 + 8 + 24
                
                filterSlider
                    .offset(x: filterPivot - sliderWidth / 2, y: width + 12)
                    .gesture(DragGesture().onChanged({ value in
                        filterSliderDragGestureOnChanged(value, in: local)
                    }))
                    .onAppear { filterSliderOnAppear(width) }
                    .filteeBlurReplace()
            }
            
            divider
                .offset(y: width + 12 + 24 + 20)
        }
        .animation(.smooth, value: originalImage)
        .animation(.smooth, value: filteredImage)
        .frame(height: imageSectionHeight)
        .padding(.horizontal, 20)
    }
    
    var filterSlider: some View {
        HStack(spacing: 4) {
            Text("After")
                .font(.pretendard(.caption2(.semiBold)))
                .foregroundStyle(.gray60)
                .frame(width: 48, height: 20)
                .background(.gray75.opacity(0.5))
                .clipRectangle(9999)
            
            Circle().fill(.gray75.opacity(0.5))
                .frame(width: 24, height: 24)
                .overlay {
                    Circle().stroke(.secondary, lineWidth: 2)
                }
                .overlay {
                    Image(.polygon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12, height: 12, alignment: .top)
                        .foregroundStyle(.secondary)
                        .padding(6)
                }
            
            Text("Before")
                .font(.pretendard(.caption2(.semiBold)))
                .foregroundStyle(.gray60)
                .frame(width: 48, height: 20)
                .background(.gray75.opacity(0.5))
                .clipRectangle(9999)
        }
    }
    
    var divider: some View {
        Rectangle().fill(.deepTurquoise)
            .frame(maxWidth: .infinity)
            .frame(height: 1)
    }
    
    @ViewBuilder
    var price: some View {
        if let filter {
            HStack(alignment: .bottom, spacing: 8) {
                Text("\(filter.price)")
                    .font(.mulgyeol(.title1))
                    .foregroundStyle(.gray30)
                
                Text("Coin")
                    .font(.mulgyeol(.body1))
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    var countSection: some View {
        if let filter {
            HStack(spacing: 8) {
                countCell(title: "다운로드", count: filter.buyerCount)
                
                countCell(title: "찜하기", count: filter.likeCount)
                
                Spacer()
            }
        }
    }
    
    func countCell(title: String, count: Int) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.pretendard(.caption1(.semiBold)))
                .foregroundStyle(.gray75)
            
            Text("\(count)")
                .font(.pretendard(.title(.bold)))
                .foregroundStyle(.gray30)
                .contentTransition(.numericText())
                .animation(.filteeDefault, value: count)
        }
        .frame(width: 99, height: 56)
        .background(.deepTurquoise)
        .clipRectangle(8)
    }
    
    var informationSection: some View {
        VStack(spacing: 20) {
            countSection
            
            if let photoMetadata =  filter?.photoMetadata {
                FilteeMetadataCell(photoMetadata: photoMetadata)
            }
            
            filterPresets
            
            let isDownloaded = filter?.isDownloaded ?? false
            Button(isDownloaded ? "구매완료" : "결제하기") {
                paymentButtonAction()
            }
            .buttonStyle(.filteeCTA)
            .disabled(isDownloaded)
            
            divider
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    var filterPresets: some View {
        if let presets = filter?.filterValues {
            FilteeContentCell(title: "Filter Presets", subtitle: "LUT") {
                VStack(spacing: 16) {
                    HStack {
                        filterValue(.brightness, value: presets.brightness)
                        
                        filterValue(.exposure, value: presets.exposure)
                        
                        filterValue(.contrast, value: presets.contrast)
                        
                        filterValue(.saturation, value: presets.saturation)
                        
                        filterValue(.sharpness, value: presets.sharpness)
                        
                        filterValue(.blur, value: presets.blur)
                    }
                    
                    HStack {
                        filterValue(.vignette, value: presets.vignette)
                        
                        filterValue(.noise, value: presets.noiseReduction)
                        
                        filterValue(.highlights, value: presets.highlights)
                        
                        filterValue(.shadows, value: presets.shadows)
                        
                        filterValue(.temperature, value: presets.temperature)
                        
                        filterValue(.blackPoint, value: presets.blackPoint)
                    }
                }
                .padding(20)
                .if(!(filter?.isDownloaded ?? false)) { $0.overlay {
                    ZStack {
                        VisualEffect(style: .systemUltraThinMaterial)
                        
                        VStack(spacing: 12) {
                            Image(.lock)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                            
                            Text("결제가 필요한 유료 필터입니다")
                                .font(.pretendard(.body1(.bold)))
                            
                        }
                        .foregroundStyle(.gray45)
                    }
                }}
            }
        }
    }
    
    func filterValue(
        _ resource: ImageResource,
        value: Float
    ) -> some View {
        VStack(spacing: 4) {
            Image(resource)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .foregroundStyle(.gray30)
            
            Text(String(format: "%.1f", value))
                .font(.pretendard(.body1(.bold)))
                .foregroundStyle(.gray75)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
    
    func paymentWeb(_ payload: IamportPaymentPayloadModel) -> some View {
        NavigationStack {
            PaymentWebViewModeView(payload: payload)
                .task(paymentWebViewModeViewTask)
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button("취소") {
                            iamportPayload = nil
                        }
                        .buttonStyle(.plain)
                    }
                }
        }
    }
}

// MARK: - Functions
private extension FilterDetailView {
    @Sendable
    func bodyTask() async {
        do {
            filter = try await filterClientFilterDetail(filterId)
            filter?.creator.introduction = nil
            filter?.creator.description = filter?.description
            async let originalImage = fetchImage(urlString: filter?.original)
            async let filteredImage = fetchImage(urlString: filter?.filtered)
            
            self.originalImage = try await originalImage
            self.filteredImage = try await filteredImage
        } catch {
            print(error)
        }
    }
    
    @Sendable
    func paymentWebViewModeViewTask() async {
        do {
            guard let iamport = try await iamportClientRequestIamport(),
                  iamport.success
            else { return }
            try await paymentsClientPaymentsValidation(iamport.impUid)
            iamportPayload = nil
            filter?.isDownloaded = true
        } catch { print(error) }
    }
    
    func paymentButtonAction() {
        fetchOrderCreate()
    }
    
    func filterSliderDragGestureOnChanged(
        _ value: DragGesture.Value,
        in local: CGRect
    ) {
        guard
            0 <= value.location.x && value.location.x <= local.maxX
        else { return }
        
        filterPivot = value.location.x
    }
    
    func filterSliderOnAppear(_ width: CGFloat) {
        withAnimation(.smooth) {
            filterPivot = width / 2
        }
        
        imageSectionHeight = width + 12 + 24 + 20 + 1
    }
    
    func likeButtonAction() {
        Task {
            guard let isLike = filter?.isLike else { return }
            do {
                let response = try await filterClientFilterLike(filterId, !isLike)
                self.filter?.isLike = response
                self.filter?.likeCount += response ? 1 : -1
            } catch {
                print(error)
            }
        }
    }
    
    func backButtonAction() {
        navigation.pop()
    }
    
    func fetchImage(urlString: String?) async throws -> Image? {
        guard let urlString, let url = URL(string: urlString) else {
            return nil
        }
        let image = try await ImagePipeline.shared.imageTask(with: url).response.image
        guard image.imageOrientation == .up,
              let cgImage = image.cgImage
        else { return Image(uiImage: image) }
        let upImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .up)
        return Image(uiImage: upImage)
    }
    
    func fetchOrderCreate() {
        guard let filter else { return }
        Task {
            do {
                let order = try await orderClientOrdersCreate(filter.id, filter.price)
                iamportPayload = IamportPaymentPayloadModel(
                    orderCode: order.orderCode,
                    price: order.totalPrice,
                    name: filter.title,
                    buyerName: "김도형"
                )
            } catch { print(error) }
        }
    }
}

private extension Image {
    @MainActor
    func squareImage(_ width: CGFloat) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: width)
            .clipRectangle(24)
    }
}

#if DEBUG
#Preview {
    FilterDetailView(filterId: "")
        .environment(\.filterClient, .testValue)
}
#endif
