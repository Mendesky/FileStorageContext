package enum StorageError: Error {
    case uploadFailed(error: Error)
    case uploadUnknownedFailed(message: String)
    case setMetadataFailed(error: Error)
    case getMetadataFailed(error: Error)
    case downloadFailed(error: Error)
    case markDeletedFailed(error: Error)
    case invalidFileData
    case invalidDocumentType(value: String)
}
