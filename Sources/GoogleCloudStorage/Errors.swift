package enum UploadError: Error {
    case uploadFailed(error: Error)
    case invalidFileData
    case invalidDocumentType(value: String)
}
