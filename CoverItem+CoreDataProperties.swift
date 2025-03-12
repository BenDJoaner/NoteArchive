//
//  CoverItem+CoreDataProperties.swift
//  NoteArchive
//
//  Created by 梁骐显 on 2025/3/8.
//
//

import Foundation
import CoreData


extension CoverItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoverItem> {
        return NSFetchRequest<CoverItem>(entityName: "CoverItem")
    }

    @NSManaged public var title: String?
    @NSManaged public var id: UUID?
    @NSManaged public var cabinet: ArchiveCabinet?

}

extension CoverItem : Identifiable {

}
