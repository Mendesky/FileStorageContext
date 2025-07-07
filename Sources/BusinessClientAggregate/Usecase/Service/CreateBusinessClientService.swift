package class CreateBusinessClientService: CreateBusinessClientUsecase {
    let repository: BusinessClientRepository
    
    package init(repository: BusinessClientRepository) {
        self.repository = repository
    }
}