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
    
    init(image: CGImage) {
        self.image = image
    }
    
    var body: some View {
        VStack {
            GeometryReader { reader in
                MetalImageView(image: $image, filterValues: $filterValues)
            }
            Spacer()
        }
        .background { scrollViewBackground }
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
    
    var scrollViewBackground: some View {
        VisualEffect(style: .systemChromeMaterialDark)
            .ifLet(UIImage(cgImage: image)) { view, image in
                view.background { backgroundImage(Image(uiImage: image)) }
            }
            .ignoresSafeArea()
    }
}

#Preview {
    EditView(image: UIImage(resource: .sampleOriginal).cgImage!)
}
