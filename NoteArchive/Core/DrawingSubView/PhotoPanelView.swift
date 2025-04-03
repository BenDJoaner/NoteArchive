//
//  PhotoPanelView.swift
//  NoteArchive
//
//  Created by BC on 2025/4/3.
//
import SwiftUI
import PhotosUI

struct PhotoPanelView: View {
    @State private var selectedImages: [UIImage] = []
    @State private var imageTransforms: [ImageTransform] = []
    @State private var showImagePicker = false
    @State private var editingImageIndex: Int? = nil  // 当前编辑的图片索引，nil表示没有编辑
    
    // Scale limits
    private let minScale: CGFloat = 0.3
    private let maxScale: CGFloat = 5.0
    
    struct ImageTransform {
        var position: CGSize = .zero
        var lastPosition: CGSize = .zero
        var scale: CGFloat = 1.0
        var rotation: Angle = .zero
        var lastScale: CGFloat = 1.0
        var lastRotation: Angle = .zero
    }
    
    var body: some View {
        VStack {
            // Control panel
            HStack {
                Button(action: {
                    showImagePicker = true
                }) {
                    Text("Import Photo")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Text(editingImageIndex != nil ? "Edit Mode" : "Browse Mode")
                    .foregroundColor(.gray)
            }
            .padding()
            
            // Image display area
            ZStack {
                if selectedImages.isEmpty {
                    Text("Please import a photo")
                        .foregroundColor(.gray)
                } else {
                    ForEach(selectedImages.indices, id: \.self) { index in
                        let isEditing = editingImageIndex == index
                        
                        ContainerView(
                            position: imageTransforms[index].position,
                            content: {
                                ZStack {
                                    // Image with border
                                    Image(uiImage: selectedImages[index])
                                        .resizable()
                                        .scaledToFit()
                                        .scaleEffect(imageTransforms[index].scale)
                                        .rotationEffect(imageTransforms[index].rotation)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(isEditing ? Color.blue : Color.clear, lineWidth: 5)
                                                .scaleEffect(imageTransforms[index].scale)
                                                .rotationEffect(imageTransforms[index].rotation)
                                        )
                                    
                                    // Action buttons (scale and rotate with image)
                                    if isEditing {
                                        VStack(spacing: 16) {
                                            Button(action: {
                                                // Confirm changes
                                                withAnimation {
                                                    editingImageIndex = nil
                                                    imageTransforms[index].lastPosition = imageTransforms[index].position
                                                    imageTransforms[index].lastScale = imageTransforms[index].scale
                                                    imageTransforms[index].lastRotation = imageTransforms[index].rotation
                                                }
                                            }) {
                                                Image(systemName: "checkmark")
                                                    .padding(10)
                                                    .background(Color.green)
                                                    .foregroundColor(.white)
                                                    .clipShape(Circle())
                                            }
                                            
                                            Button(action: {
                                                // Delete image
                                                withAnimation {
                                                    selectedImages.remove(at: index)
                                                    imageTransforms.remove(at: index)
                                                    // 如果删除的是正在编辑的图片，取消编辑状态
                                                    if editingImageIndex == index {
                                                        editingImageIndex = nil
                                                    } else if let editingIndex = editingImageIndex, editingIndex > index {
                                                        // 如果删除的图片在正在编辑的图片前面，调整编辑索引
                                                        editingImageIndex = editingIndex - 1
                                                    }
                                                }
                                            }) {
                                                Image(systemName: "trash")
                                                    .padding(10)
                                                    .background(Color.red)
                                                    .foregroundColor(.white)
                                                    .clipShape(Circle())
                                            }
                                        }
                                        .padding(16)
                                        .rotationEffect(imageTransforms[index].rotation)
                                    }
                                }
                            }
                        )
                        .gesture(
                            LongPressGesture(minimumDuration: 0.5)
                                .onEnded { _ in
                                    withAnimation {
                                        // 如果已经有图片在编辑，先取消它的编辑状态
                                        if let currentEditingIndex = editingImageIndex {
                                            // 保存当前编辑图片的状态
                                            imageTransforms[currentEditingIndex].lastPosition = imageTransforms[currentEditingIndex].position
                                            imageTransforms[currentEditingIndex].lastScale = imageTransforms[currentEditingIndex].scale
                                            imageTransforms[currentEditingIndex].lastRotation = imageTransforms[currentEditingIndex].rotation
                                        }
                                        
                                        // 切换到新选择的图片
                                        editingImageIndex = index
                                    }
                                }
                        )
                        .simultaneousGesture(
                            isEditing ?
                            DragGesture()
                                .onChanged { value in
                                    imageTransforms[index].position = CGSize(
                                        width: imageTransforms[index].lastPosition.width + value.translation.width,
                                        height: imageTransforms[index].lastPosition.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    imageTransforms[index].lastPosition = imageTransforms[index].position
                                }
                            : nil
                        )
                        .simultaneousGesture(
                            isEditing ?
                            MagnificationGesture()
                                .onChanged { value in
                                    let newScale = imageTransforms[index].lastScale * value
                                    imageTransforms[index].scale = min(max(newScale, minScale), maxScale)
                                }
                                .onEnded { _ in
                                    imageTransforms[index].lastScale = imageTransforms[index].scale
                                }
                            : nil
                        )
                        .simultaneousGesture(
                            isEditing ?
                            RotationGesture()
                                .onChanged { angle in
                                    imageTransforms[index].rotation = imageTransforms[index].lastRotation + angle
                                }
                                .onEnded { _ in
                                    imageTransforms[index].lastRotation = imageTransforms[index].rotation
                                }
                            : nil
                        )
                        .zIndex(isEditing ? 1 : 0) // 正在编辑的图片显示在最上层
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImages: $selectedImages, imageTransforms: $imageTransforms)
        }
    }
}

// Container view, handles position only
struct ContainerView<Content: View>: View {
    let position: CGSize
    let content: () -> Content
    
    var body: some View {
        content()
            .offset(position)
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Binding var imageTransforms: [PhotoPanelView.ImageTransform]
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    DispatchQueue.main.async {
                        if let image = image as? UIImage {
                            self.parent.selectedImages.append(image)
                            self.parent.imageTransforms.append(PhotoPanelView.ImageTransform())
                        }
                    }
                }
            }
        }
    }
}
