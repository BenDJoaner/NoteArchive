//
//  ArchiveCabinet+CoreDataProperties.swift
//  NoteArchive
//
//  Created by 梁骐显 on 2025/3/8.
//
//

import Foundation
import CoreData


extension ArchiveCabinet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ArchiveCabinet> {
        return NSFetchRequest<ArchiveCabinet>(entityName: "ArchiveCabinet")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var covers: NSSet?

}

// MARK: Generated accessors for covers
extension ArchiveCabinet {

    @objc(addCoversObject:)
    @NSManaged public func addToCovers(_ value: CoverItem)

    @objc(removeCoversObject:)
    @NSManaged public func removeFromCovers(_ value: CoverItem)

    @objc(addCovers:)
    @NSManaged public func addToCovers(_ values: NSSet)

    @objc(removeCovers:)
    @NSManaged public func removeFromCovers(_ values: NSSet)

}

extension ArchiveCabinet : Identifiable {

}
