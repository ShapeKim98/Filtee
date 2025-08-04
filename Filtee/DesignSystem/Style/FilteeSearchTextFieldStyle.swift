//
//  FilteeSearchTextFieldStyle.swift
//  Filtee
//
//  Created by 김도형 on 7/10/25.
//

import SwiftUI

@MainActor
struct FilteeSearchTextFieldStyle: @preconcurrency TextFieldStyle {
    typealias Configuration = TextField<Self._Label>
    
    private let state: TextFieldState
    private let isFloating: Bool
    
    init(state: TextFieldState, isFloating: Bool) {
        self.state = state
        self.isFloating = isFloating
    }
    
    func _body(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            field(configuration: configuration)
            
            if case let .error(message) = state {
                Text(message)
                    .font(.pretendard(.caption1(.medium)))
                    .foregroundStyle(.red)
                    .filteeBlurReplace()
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
    
    private func field(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            if case .loading = state {
                ProgressView()
                    .controlSize(.mini)
                    .tint(.brightTurquoise)
            }
            
            configuration
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .font(.pretendard(.body2()))
                .foregroundStyle(.gray45)
        }
        .animation(.filteeSpring, value: state == .loading)
        .frame(height: 42)
        .padding(.horizontal, 12)
        .if(isFloating) { $0.background(.ultraThinMaterial) }
        .if(!isFloating) { $0.background(.blackTurquoise) }
        .clipRectangle(9999)
    }
}

@MainActor
extension TextFieldStyle where Self == FilteeSearchTextFieldStyle {
    static func filteeSearch(
        _ state: FilteeSearchTextFieldStyle.TextFieldState,
        isFloating: Bool = false
    ) -> Self {
        FilteeSearchTextFieldStyle(state: state, isFloating: isFloating)
    }
}

extension FilteeSearchTextFieldStyle {
    enum TextFieldState: Equatable {
        case `default`
        case typed
        case error(String)
        case loading
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State
    var text: String = ""
    
    VStack {
        Spacer()
        
        TextField(text: $text) {
            Text("검색할 작가 이름을 입력해주세요.")
                .foregroundStyle(.gray90)
        }
        .textFieldStyle(.filteeSearch(.default, isFloating: true))
        
        TextField(text: $text) {
            Text("검색할 작가 이름을 입력해주세요.")
                .foregroundStyle(.gray90)
        }
        .textFieldStyle(.filteeSearch(.loading))
        
        TextField(text: $text) {
            Text("검색할 작가 이름을 입력해주세요.")
                .foregroundStyle(.gray90)
        }
        .textFieldStyle(.filteeSearch(.default))
        
        TextField(text: $text) {
            Text("검색할 작가 이름을 입력해주세요.")
                .foregroundStyle(.gray90)
        }
        .textFieldStyle(.filteeSearch(.error("중복된 이메일 입니다.")))
        
        Spacer()
    }
    .frame(maxWidth: .infinity)
    .background(Material.thick)
    .background(.gray100)
}
