import CoreData

extension NSManagedObjectContext {

    /// Create a child context of `self`
    ///
    /// - Returns: a context that has `self` as parent context
    open func childContext(concurrencyType type: NSManagedObjectContextConcurrencyType = .privateQueueConcurrencyType) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: type)
        context.parent = self
        return context
    }

}
