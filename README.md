# NoteArchive - 您的智能手写笔记档案馆 📖✍️

![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0+-orange?logo=swift) ![Platform](https://img.shields.io/badge/Platform-iOS_15+-blue)

## 简介
专为Apple Pencil设计的极简手写笔记应用，采用真实物理笔记本交互逻辑。通过三级存储结构（文件柜->文件夹->笔记）打造您的数字档案馆，独家搭载**翻页动画引擎**带来真实的书写体验。

## 核心功能
🗄️ 结构化存储体系  
- 三级管理体系：文件柜（无限数量）→ 文件夹（颜色/名称可编辑）→ 笔记本（封面自定义）
- 滑动删除 & 长按重组内容

🔒 生物加密空间  
- Face ID/Touch ID加密的隐私文件夹
- 每次访问实时验证

✍️ 纯手写体验  
- Apple Pencil专属输入（禁用虚拟键盘）
- 压感笔刷 & 橡皮擦工具组
- 手势快捷操作：双指撤销/三指重做

📜 智能文本识别  
- 实时OCR文字提取（支持中英文）
- 画圈选择内容即可复制文本

📖 拟真翻页效果  
- 集成[Pages](https://github.com/nachonavarro/Pages)翻页组件
- 支持左右横翻/上下竖翻模式
- 自定义翻页动画曲率（`pageCurlFactor`参数可调）

## 技术亮点
- 基于SwiftUI 4.0声明式开发
- CoreData本地加密存储
- VisionKit文本识别框架
- 全应用方向适配（Portrait/Landscape）

## Todo List
✅ 已完成  
- 文件柜管理系统
- 生物特征验证模块
- 翻页动画核心集成
- 手写压力感应模块
- 动态封面生成器

❌ 进行中  
- [ ] PDF/图片导入模块
- [ ] 语义搜索算法开发
- [ ] iCloud同步引擎
- [ ] 智能笔迹美化
- [ ] 多语言即时翻译

---

# NoteArchive - Your Smart Handwriting Archive 📖✍️

![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0+-orange?logo=swift) ![Platform](https://img.shields.io/badge/Platform-iOS_15+-blue)

## Introduction
A minimalist handwriting notes app exclusively designed for Apple Pencil. Featuring realistic page-flip animations powered by [Pages](https://github.com/nachonavarro/Pages) package, it reimagines digital note-taking with physical notebook interaction logic.

## Key Features
🗄️ Hierarchical Storage  
- Three-tier system: Cabinets (Unlimited) → Folders (Color-coded) → Notebooks (Custom covers)
- Swipe-to-delete & Drag-and-drop reorganization

🔒 Biometric Vault  
- Face ID/Touch ID protected privacy folders
- Dynamic re-authentication per access

✍️ Pencil-First Design  
- Apple Pencil exclusive input (virtual keyboard disabled)
- Pressure-sensitive tools & gesture shortcuts
- Two-finger undo / Three-finger redo

📜 Smart Text Extraction  
- Real-time OCR via VisionKit
- Lasso-select handwriting to copy text

📖 Realistic Page Flip  
- Integrated [Pages](https://github.com/nachonavarro/Pages) flip engine
- Horizontal/Vertical flip modes
- Customizable curl intensity (`pageCurlFactor` adjustable)

## Technical Highlights
- SwiftUI 4 declarative architecture
- CoreData with AES-256 encryption
- VisionKit text recognition
- Universal orientation support

## Development Roadmap
✅ Completed  
- Cabinet management system
- Biometric authentication layer
- Page-flip animation core
- Pencil pressure analysis
- Dynamic cover generator

❌ In Progress  
- [ ] PDF/Image import module  
- [ ] Semantic search algorithm  
- [ ] iCloud sync engine  
- [ ] Handwriting beautification  
- [ ] Live translation API
