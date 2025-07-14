package enum UploadError: Error {
    case uploadFailed(error: Error)
    case fileDataIsNil
    case customerIdIsNil
    case documentTypeIsNil
}
