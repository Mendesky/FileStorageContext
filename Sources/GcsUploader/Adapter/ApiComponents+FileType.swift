extension Components.Parameters.fileContentType {
    
    var wrapped: (fileType: String, ext: String) {
        switch self {
        case .jpeg:
            ("image/jpeg", "jpg")
        case .pdf:
            ("application/pdf", "pdf")
        case .png:
            ("image/png", "png")
        }
    }
}
