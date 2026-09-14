import Foundation
import SwiftData

@Model
final class CategoryEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String
    var type: String

    init(id: UUID, name: String, icon: String, type: String) {
        self.id = id
        self.name = name
        self.icon = icon
        self.type = type
    }
}
