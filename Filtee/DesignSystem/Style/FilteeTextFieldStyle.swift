//
//  FTTextFieldStyle.swift
//  Filtee
//
//  Created by 김도형 on 5/12/25.
//

import SwiftUI

@MainActor
private struct FilteeTextFieldStyle: @preconcurrency TextFieldStyle {
    typealias Configuration = TextField<Self._Label>
    
    private let state: TextFieldState
    private let title: String?
    private let subTitle: String?
    
    init(
        state: TextFieldState,
        title: String?,
        subTitle: String?
    ) {
        self.state = state
        self.title = title
        self.subTitle = subTitle
    }
    
    func _body(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title {
                Text(title)
                    .font(.pretendard(.body1(.bold)))
                    .foregroundStyle(.gray60)
                    .frame(height: 48)
                    .filteeBlurReplace()
            }
            
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
            
            if let subTitle {
                Text(subTitle)
                    .font(.pretendard(.body2(.bold)))
                    .foregroundStyle(.gray75)
            }
        }
        .animation(.filteeSpring, value: state == .loading)
        .frame(height: 42)
        .padding(.horizontal, 12)
        .background(.clear)
        .clipRectangle(8)
        .roundedRectangleStroke(
            radius: 8,
            color: .deepTurquoise,
            lineWidth: 2
        )
    }
}

@MainActor
extension TextFieldStyle where Self == FilteeTextFieldStyle {
    static func filtee(
        _ state: FilteeTextFieldStyle.TextFieldState,
        title: String? = nil,
        subtitle: String? = nil
    ) -> Self {
        FilteeTextFieldStyle(
            state: state,
            title: title,
            subTitle: subtitle
        )
    }
}

extension FilteeTextFieldStyle {
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
            Text("이 필터에 대해 간단하게 소개해주세요.")
                .foregroundStyle(.deepTurquoise)
        }
        .textFieldStyle(.filtee(.default, title: "필터소개"))
        
        TextField(text: $text) {
            Text("이 필터에 대해 간단하게 소개해주세요.")
                .foregroundStyle(.deepTurquoise)
        }
        .textFieldStyle(.filtee(.loading, title: "필터소개"))
        
        TextField(text: $text) {
            Text("1000")
                .foregroundStyle(.deepTurquoise)
        }
        .textFieldStyle(.filtee(.default, title: "판매가격", subtitle: "원"))
        
        TextField(text: $text) {
            Text("이메일")
                .foregroundStyle(.deepTurquoise)
        }
        .textFieldStyle(.filtee(.error("중복된 이메일 입니다."), title: "이메일"))
        
        Spacer()
    }
    .frame(maxWidth: .infinity)
    .background(Material.thick)
    .background(.gray100)
}
