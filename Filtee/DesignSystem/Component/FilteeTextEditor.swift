//
//  FilteeTextEditor.swift
//  Filtee
//
//  Created by 김도형 on 6/18/25.
//

import SwiftUI

// MARK: - UITextView Wrapper
struct DynamicUITextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var calculatedHeight: CGFloat
    
    let font: UIFont?
    let maxLines: Int
    let placeholder: String
    let availableWidth: CGFloat
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.font = font
        textView.isScrollEnabled = false
        textView.isEditable = true
        textView.backgroundColor = UIColor.clear
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.delegate = context.coordinator
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainer.widthTracksTextView = true
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        // 플레이스홀더 설정
//        updatePlaceholder(textView)
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // 텍스트가 다를 때만 업데이트 (무한 루프 방지)
        if uiView.text != text && !(uiView.textColor == UIColor.placeholderText && text.isEmpty) {
            let wasFirstResponder = uiView.isFirstResponder
            if text.isEmpty {
//                updatePlaceholder(uiView)
            } else {
                uiView.text = text
                uiView.textColor = UIColor.label
            }
            
            if wasFirstResponder {
                uiView.becomeFirstResponder()
            }
        }
        
        // 높이 계산
        calculateHeight(for: uiView)
    }
    
    private func updatePlaceholder(_ textView: UITextView) {
        if text.isEmpty {
            textView.text = placeholder
            textView.textColor = UIColor.placeholderText
        }
    }
    
    private func calculateHeight(for textView: UITextView) {
        // 정확한 width 계산 (padding 제외)
        let textWidth = availableWidth - textView.textContainerInset.left - textView.textContainerInset.right
        
        // 텍스트 컨테이너 크기 설정
        textView.textContainer.size = CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude)
        
        // 높이 계산
        let size = textView.sizeThatFits(CGSize(width: availableWidth, height: CGFloat.greatestFiniteMagnitude))
        let lineHeight = font?.lineHeight ?? 0
        let padding = textView.textContainerInset.top + textView.textContainerInset.bottom
        let maxHeight = lineHeight * CGFloat(maxLines) + padding
        
        let newHeight: CGFloat
        let shouldScroll: Bool
        
        if size.height >= maxHeight {
            newHeight = maxHeight
            shouldScroll = true
        } else {
            newHeight = max(size.height, lineHeight + padding)
            shouldScroll = false
        }
        
        DispatchQueue.main.async {
            textView.isScrollEnabled = shouldScroll
            if abs(self.calculatedHeight - newHeight) > 1 { // 1포인트 이상 차이날 때만 업데이트
                self.calculatedHeight = newHeight
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: DynamicUITextView
        
        init(_ parent: DynamicUITextView) {
            self.parent = parent
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == UIColor.placeholderText {
                textView.text = ""
                textView.textColor = UIColor.label
                parent.text = ""
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                parent.updatePlaceholder(textView)
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if textView.textColor != UIColor.placeholderText {
                parent.text = textView.text
            } else if textView.text.isEmpty {
                parent.text = ""
            }
            
            parent.calculateHeight(for: textView)
        }
    }
}

// MARK: - SwiftUI Wrapper
struct FilteeTextEditor: View {
    @Binding var text: String
    @State private var textEditorHeight: CGFloat
    
    let font: Pretendard
    let maxLines: Int
    let placeholder: String
    
    init(
        text: Binding<String>,
        font: Pretendard,
        maxLines: Int = 5,
        placeholder: String = "텍스트를 입력하세요..."
    ) {
        self._text = text
        self.font = font
        self.maxLines = maxLines
        self.placeholder = placeholder
        
        // 초기 높이 설정
        let lineHeight = font.height
        self._textEditorHeight = State(initialValue: lineHeight)
    }
    
    var body: some View {
        GeometryReader { geometry in
            DynamicUITextView(
                text: $text,
                calculatedHeight: $textEditorHeight,
                font: font.uiFont,
                maxLines: maxLines,
                placeholder: placeholder,
                availableWidth: geometry.size.width
            )
        }
        .frame(height: textEditorHeight)
    }
}
