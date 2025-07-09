package class UploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocumentService: UploadProfitseekingEnterpriseAnnualIncomeTaxReturnDocumentUsecase {
    let repository: BusinessClientRepository
    
    package init(repository: BusinessClientRepository) {
        self.repository = repository
    }
}
