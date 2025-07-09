package enum UploadError: Error {
    case uploadFailed(error: Error)
    case fileDataIsNil(businessClientId: String, documentType: DocumentType)
    case customerIdIsNil(businessClientId: String, documentType: DocumentType)
    case yearIsNil(businessClientId: String, documentType: DocumentType)
}
