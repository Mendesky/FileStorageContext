package enum StorageError: Error {
    case uploadFailed(error: Error)
    case setMetadataFailed(error: Error)
    case getMetadataFailed(error: Error)
    case downloadFailed(error: Error)
    case markDeletedFailed(error: Error)
    case invalidFileData
    case invalidDocumentType(value: String)
}
