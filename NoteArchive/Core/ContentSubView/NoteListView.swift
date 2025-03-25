//
//  NoteListView.swift
//  NoteArchive
//
//  Created by 梁骐显 on 2025/3/9.
//

import SwiftUI
import SwiftUICore
import Foundation
import NaturalLanguage
//import ContributionChart

struct NoteListView: View {
    var notes: FetchedResults<Note>
    @Binding var selectedNote: Note?
    var moveToTrash: (Note) -> Void
    var addNote: () -> Void
    var parentConfig: AppConfig? // 添加 appConfig 参数
    @FocusState private var isKeyboardActive: Bool
    @State private var frequentWords: [String] = []
    @State private var viewWidth: CGFloat = UIScreen.main.bounds.width - 32 // 假设左右边距各16

    
    @State private var searchText: String = ""
    var body: some View {
        SearchBar()
            .padding(.horizontal)
            .onChange(of: searchText) { _ in
                updateFrequentWords()
            }
        // 添加 ChipsView
        ChipsView(width: viewWidth) {
            ForEach(frequentWords, id: \.self) { word in
                let horizontalSpace: CGFloat = 10
                let chipWidth = word.size(withAttributes: [.font: UIFont.preferredFont(forTextStyle: .body)]).width + horizontalSpace * 2
                
                Button(action: {
                    searchText = word
                }) {
                    Text(word)
                        .font(.body)
                        .foregroundStyle(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, horizontalSpace)
                        .background(.blue.gradient, in: .capsule)
                }
                .containerValue(\.viewWidth, chipWidth)
            }
        }
        .padding(.horizontal)
        .animation(.easeInOut, value: frequentWords)
        
        List {
            // 过滤掉“隐私”和“回收站”书架
            ForEach(notes.filter { $0.isShowen }, id: \.self) { note in
                NoteRowView(note: note, selectedNote: $selectedNote, moveToTrash: moveToTrash)
            }
            // 添加档案夹按钮
            AddNoteButtonView(addNote: addNote)
        }
//        .listStyle(DefaultListStyle())
        .listStyle(PlainListStyle())
    }

    private func togglePin(note: Note) {
        withAnimation {
            note.isPinned.toggle()
            do {
                try note.managedObjectContext?.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    @ViewBuilder
    func SearchBar() -> some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
            
            TextField("Search", text: $searchText)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 15)
        .background(.primary.opacity(0.06), in: .rect(cornerRadius: 10))

    }
    
    private func updateFrequentWords() {
        // 收集所有文本数据
        var allTexts: [String] = []
        for note in notes {
            for cover in note.coversArray {
                if let pages = cover.drawingPages?.allObjects as? [DrawingPage] {
                    for page in pages {
                        if let text = page.textData {
                            allTexts.append(text)
                        }
                    }
                }
            }
        }
        
        // 调用高频词分析方法
        frequentWords = findFrequentWords(in: allTexts)
    }
    
    func findFrequentWords(in texts: [String]) -> [String] {
        var wordFrequency = [String: Int]()
        let tokenizer = NLTokenizer(unit: .word)
        
        // 遍历每一段文本
        for text in texts {
            tokenizer.string = text
            // 分词并统计词频
            tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex) { tokenRange, _ in
                let word = String(text[tokenRange])
                wordFrequency[word, default: 0] += 1
                return true
            }
        }
        
        // 过滤出出现次数超过3次的词，并返回为数组
        return wordFrequency.filter { $0.value > 3 }.map { $0.key }
    }

    //let frequentWords = findFrequentWords(in: texts)
    //print(frequentWords) // 输出: ["电脑", "Deepseek", "宇宙"]
}

struct AddNoteButtonView: View {
    var addNote: () -> Void

    var body: some View {
        Button(action: addNote) {
            HStack {
                Image(systemName: "folder.fill.badge.plus")
                Text("AddFolder")
            }
            .foregroundColor(.blue)
        }
    }
}

struct NoteRowView: View {
    var note: Note
    @Binding var selectedNote: Note?
    var moveToTrash: (Note) -> Void
    @State private var data = []
    var body: some View {
        let data = getCoverData(note: selectedNote ?? note)
        NavigationLink(destination: FolderView(note: note, folderState: FolderView.FolderState.e_normal, systemImageType: .badgeclock), tag: note, selection: $selectedNote) {
//            ZStack(alignment: .topTrailing) { // 使用 ZStack 将图片作为背景
                // 主要内容
                VStack {
                    HStack {
                        if note.isPinned {
                            Image(systemName: "bookmark.fill")
                                .foregroundColor(.orange)
                        }
                        Text(note.title ?? "Untitled")
//                        Text("\(note.covers?.count ?? 0)")
//                            .font(.caption)
//                            .foregroundColor(.gray)
                        Spacer()
                    }
                    HStack {
                        ContributionChartView(data: data, rows: 5, columns: 20, targetValue: 1.0, blockColor: Color(hex: note.colorStr ?? "#7D177D"))
                            .frame(width: 285, height: 75)
//                            .background(Color(.systemGray6))
                            .background(Color(hex: note.colorStr ?? "#7D177D").opacity(0.3))
                            .cornerRadius(5)
                            .shadow(radius: 1)

                        Spacer()
                    }
                }
                .padding(2)
            // 背景图片
//            Image(systemName: note.iconStr ?? "aqi.medium" ) // 使用 heartdoc 图片
//                .resizable()
//                .scaledToFit()
//                .frame(width: 120, height: 120) // 调整图片大小
//                .opacity(0.3) // 设置透明度
//                .foregroundColor(Color(hex: note.colorStr ?? "#555555"))
////                    .offset(x: 50, y: -50)
//            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                togglePin(note: note)
            } label: {
                Label(note.isPinned ? "Unpin" : "Pin", systemImage: note.isPinned ? "bookmark.slash" : "bookmark.fill")
            }
            .tint(note.isPinned ? .gray : .orange)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                moveToTrash(note)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func togglePin(note: Note) {
        withAnimation {
            note.isPinned.toggle()
            do {
                try note.managedObjectContext?.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func getCoverData(note: Note) -> [Double] {
        var result: [Double] = []
        for cover in note.coversArray {
            // 使用 nil 合并运算符 (??) 提供默认值，以防 drawingPages 为 nil
            let pageCount = cover.drawingPages?.count ?? 0
            if pageCount > 10 {
                _ = 10
            }
            result.append(Double(pageCount) / 10.0)
        }
        return result
    }
}
