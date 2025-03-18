//
//  LanguageTools.swift
//  NoteArchive
//
//  Created by BC on 2025/3/17.
//
import Foundation
import NaturalLanguage

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
