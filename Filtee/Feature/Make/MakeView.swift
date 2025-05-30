//
//  MakeView.swift
//  Filtee
//
//  Created by 김도형 on 5/30/25.
//

import SwiftUI
import PhotosUI

struct MakeView: View {
    @State
    private var filter = FilterMakeModel()
    @State
    private var pickerItem: PhotosPickerItem?
    @State
    private var selectedImage: Image?
    
    var body: some View {
        ScrollView(content: content)
            .filteeNavigation(
                title: "MAKE",
                leadingItems: leadingItems,
                trailingItems: trailingItems
            )
            .background(content: scrollViewBackground)
            .onChange(of: pickerItem, perform: pickerItemOnChange)
    }
}

// MARK: - Configure Views
private extension MakeView {
    func content() -> some View {
        VStack(spacing: 12) {
            TextField(text: $filter.title) {
                Text("필터 이름을 입력해주세요.")
            }
            .textFieldStyle(.filtee(.default, title: "필터명"))
            .padding(.horizontal, 20)
            
            categorySection
            
            photoSection
            
            TextField(text: $filter.description) {
                Text("이 필터에 대해 간단하게 소개해주세요.")
            }
            .textFieldStyle(.filtee(.default, title: "소개"))
            .padding(.horizontal, 20)
            
            TextField(text: $filter.description) {
                Text("1000")
            }
            .keyboardType(.numberPad)
            .textFieldStyle(.filtee(
                .default,
                title: "판매가격",
                subtitle: "원"
            ))
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    func leadingItems() -> some View {
        Button(action: { }) {
            Image(.chevron)
                .resizable()
        }
        .buttonStyle(.filteeToolbar)
    }
    
    func trailingItems() -> some View {
        Button(action: {}) {
            Image(.save)
                .resizable()
        }
        .buttonStyle(.filteeToolbar)
    }
    
    func backgroundImage(_ image: Image) -> some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity)
            .overlay(Color(red: 0.04, green: 0.04, blue: 0.04).opacity(0.9))
            .ignoresSafeArea()
    }
    
    func scrollViewBackground() -> some View {
        VisualEffect(style: .systemChromeMaterialDark)
            .ifLet(selectedImage) { view, image in
                view.background { backgroundImage(image) }
            }
            .ignoresSafeArea()
    }
    
    func section(
        _ title: String,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(spacing: 0) {
            FilteeTitle(title)
            
            content()
        }
    }
    
    @ViewBuilder
    var categorySection: some View {
        let categories = FilterMakeModel.Category.allCases
        
        section("카테고리") {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(categories, id: \.self) { category in
                        let isSelectd = filter.category == category.rawValue
                        Button(category.rawValue) {
                            categoryButtonAction(category.rawValue)
                        }
                        .buttonStyle(.filteeSelected(isSelectd))
                        .animation(.filteeDefault, value: isSelectd)
                        .padding(.vertical, 1)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    var photoSection: some View {
        VStack(spacing: 0) {
            FilteeTitle("대표 사진 선택") {
                if selectedImage != nil {
                    Button("수정하기") {
                        
                    }
                    .font(.pretendard(.body1(.medium)))
                    .foregroundStyle(.gray75)
                }
            }
            
            photoPicker
        }
    }
    
    @ViewBuilder
    var photoPicker: some View {
        if let selectedImage {
            PhotosPicker(selection: $pickerItem) {
                selectedImage
                    .resizable()
            }
            .aspectRatio(1, contentMode: .fill)
            .frame(maxWidth: .infinity)
            .clipRectangle(12)
            .clipped()
            .padding(.horizontal, 20)
            .filteeBlurReplace()
        } else {
            PhotosPicker(selection: $pickerItem) {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.blackTurquoise)
                    .overlay {
                        Image(.plus)
                            .resizable()
                            .foregroundStyle(.gray75)
                            .frame(width: 32, height: 32)
                    }
                    .frame(height: 100)
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Functions
private extension MakeView {
    func pickerItemOnChange(_ newValue: PhotosPickerItem?) {
        guard let newValue else { return }
        
        Task {
            guard
                let data = try? await newValue.loadTransferable(type: Data.self),
                let uiImage = UIImage(data: data)
            else { return }
            withAnimation(.filteeSpring) {
                selectedImage = Image(uiImage: uiImage)
            }
        }
    }
    
    func categoryButtonAction(_ category: String) {
        filter.category = category
    }
}

#Preview {
    MakeView()
}
