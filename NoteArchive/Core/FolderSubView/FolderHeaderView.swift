//
//  FolderHeaderView.swift
//  NoteArchive
//
//  Created by 梁骐显 on 2025/3/31.
//

import SwiftUICore
import SwiftUI
struct FolderHeaderView: View {
    @Binding var folderState: FolderView.FolderState
    @Binding var newTitle: String
    @ObservedObject var note: Note
    var saveTitle: () -> Void
    var isPrivacy: Bool
    
    @State private var showIconPicker = false
    @State private var selectedColor: Color = .blue
    
    var body: some View {
        if folderState == .e_editing && !isPrivacy {
            editingHeaderView
        } else if folderState != .e_trash {
            normalHeaderView
        }
    }
    
    private var normalHeaderView: some View {
        HStack {
            Text(titleForState())
                .font(.largeTitle)
                .bold()
                .padding(.leading)
            
            Spacer()
            
            Button(action: {
                folderState = .e_editing
            }) {
                Text("Edit")
                    .font(.headline)
                    .frame(width: 80, height: 44)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
    
    private var editingHeaderView: some View {
        HStack() {
            // Text Field
            HStack(spacing: 10) {
                Image(systemName: "square.and.pencil")
    
                TextField("Folder Name", text: $newTitle)
                    .font(.largeTitle)
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 15)
            .background(.primary.opacity(0.06), in: .rect(cornerRadius: 10))
            
            // Color and Icon Selection
//            HStack(spacing: 20) {
                // Color Picker
                VStack {

                    ColorPicker("", selection: $selectedColor)
                        .labelsHidden()
                        .frame(width: 44, height: 44)
                        .padding(8)
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                        .onChange(of: selectedColor) { newColor in
                            note.colorStr = newColor.toHex()
                        }
//                    Text("Color")
//                        .font(.caption)
                }
                
                // Icon Picker Button (shows current selection)
                VStack {

                    Button(action: {
                        showIconPicker.toggle()
                    }) {
                        Image(systemName: note.iconStr ?? "folder.fill")  // Use note.iconStr
                            .font(.title)
                            .frame(width: 44, height: 44)
                            .padding(8)
                            .background(Color(.systemGray5))
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $showIconPicker) {
                        IconPickerView(selectedIcon: Binding(
                            get: { note.iconStr },
                            set: { newValue in
                                note.iconStr = newValue
                            }
                        ))
                    }
//                    Text("Icon")
//                        .font(.caption)
                }
                
                Spacer()
                
                // Save Button
                Button(action: {
                    saveTitle()
                    folderState = .e_normal
                }) {
                    Text("Save")
                        .font(.headline)
                        .frame(width: 80, height: 44)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
//            }
//            .padding(.horizontal)
        }
        .padding(.horizontal)
        .onAppear {
            selectedColor = Color(hex: note.colorStr ?? "#7D177D")
            // Initialize iconStr if nil
            if note.iconStr == nil {
                note.iconStr = "folder.fill"
            }
        }
    }
    
    private func titleForState() -> String {
        switch folderState {
        case .e_normal: return note.title ?? ""
        case .e_editing: return isPrivacy ? "Confidential".localized : "Editing".localized
        case .e_trash: return "DestructionSite".localized
        case .e_privacy: return "Confidential".localized
        }
    }
}

// New Icon Picker View
struct IconPickerView: View {
    @Binding var selectedIcon: String?
    @Environment(\.presentationMode) var presentationMode
    
    let columns = [
        GridItem(.adaptive(minimum: 60, maximum: 80), spacing: 20)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(SystemImageType.allCases, id: \.self) { iconType in
                        Button(action: {
                            selectedIcon = iconType.rawValue
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            VStack {
                                Image(systemName: iconType.rawValue)
                                    .font(.title)
                                    .frame(width: 44, height: 44)
                                    .padding(8)
                                    .background(
                                        selectedIcon == iconType.rawValue ?
                                        Color.blue.opacity(0.2) : Color(.systemGray5)
                                    )
                                    .cornerRadius(10)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
