//
//  MakeView.swift
//  Filtee
//
//  Created by 김도형 on 5/30/25.
//

import SwiftUI

struct MakeView: View {
    @State
    private var filter = FilterMakeModel()
    
    var body: some View {
        ScrollView(content: content)
            .filteeNavigation(
                title: "MAKE",
                leadingItems: leadingItems,
                trailingItems: trailingItems
            )
            .background(content: scrollViewBackground)
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
    
    func scrollViewBackground() -> some View {
        VisualEffect(style: .systemChromeMaterialDark)
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
                        FilteeTag(category.rawValue)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    var photoSection: some View {
        section("대표 사진 등록") {
            Button(action: {}) {
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

#Preview {
    MakeView()
}
