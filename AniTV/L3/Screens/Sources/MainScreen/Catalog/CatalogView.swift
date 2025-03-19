import Common
import SwiftUI
import Kingfisher
import Components
import ServiceLayer
import DITranquillity
import Combine

@MainActor
final class CatalogViewModel: ObservableObject {
    @Published
    var posters: [PosterModel] = []
    var series: [Series] = []
    
    var diContainer: DIContainer? {
        didSet {
            feedService = diContainer?.resolve()
        }
    }
    
    @Published
    var mainFilter: FilterData?
    @Published
    var seriesFilterModel = SeriesFilterModel()
    
    @Published
    var done = false
    
    private var feedService: FeedService?
    private var cancellable = Set<AnyCancellable>()
    
    var page = 1
    
    func setup() {
        guard let feedService else { return }
        
        loadData()
        feedService
            .fetchFiltedData()
            .sink(receiveValue: { [weak self] value in
                self?.mainFilter = value
                self?.seriesFilterModel.main = value
            }).store(in: &cancellable)
    }
    
    func loadData() {
        cancellable.removeAll()
        feedService?.fetchCatalog(
            page: page,
            filter: seriesFilterModel.filter
        ).sink(onNext: { [weak self] series in
            let ids = Set(self?.posters.compactMap { $0.id } ?? [])
            let series = series.filter { !ids.contains($0.id) }
            self?.posters += series.compactMap { PosterModel(id: $0.id, title: $0.names.first ?? "", description: $0.desc?.string ?? "", posterUrl: $0.poster) }
            self?.series += series
            self?.page += 1
            
            if series.isEmpty {
                self?.done = true
            }
        }).store(in: &cancellable)
    }
    
    func startFilterLoad() {
        page = 1
        series = []
        posters = []
        done = false
        loadData()
    }
}

public struct CatalogView: View {
    @EnvironmentObject
    var dependencyContainer: DependencyContainer
    
    @StateObject
    private var viewModel = CatalogViewModel()
    
    @State private var showAlert = false
    @State private var selectedItems: [String] = []
    @FocusState private var currentFocus: Int?
    
    @State
    private var poster: PosterModel?
    
    public var body: some View {
        VStack(spacing: 22) {
            Button("Фильтрация") {
                showAlert = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            ScrollView(.vertical) {
                LazyVGrid(columns: columns, spacing: 60) {
                    ForEach(viewModel.posters, id: \.title) { poster in
                        CardView(poster: poster) {
                            self.poster = poster
                        }
                        .focused($currentFocus, equals: poster.id)
                    }
                }
                .buttonStyle(.borderless)
                
                if !viewModel.done {
                    Button(action: {
                        viewModel.loadData()
                        currentFocus = viewModel.posters.last?.id
                    }) {
                        Text("Следующая страница")
                            .frame(maxWidth: .infinity) // Растягиваем текст на всю ширину
                            .padding() // Добавляем отступы
                            .background(Color.blue) // Задаем цвет фона
                            .foregroundColor(.white) // Задаем цвет текста
                            .cornerRadius(10) // Закругляем углы
                    }
                    .padding()
                    .padding(.all, 22)
                    .cornerRadius(10)
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(12)
            .onAppear {
                viewModel.diContainer = dependencyContainer.container
                viewModel.setup()
            }
        }
        .sheet(isPresented: $showAlert) {
            FilterView(mainFilter: $viewModel.seriesFilterModel) {
                viewModel.startFilterLoad()
            }
        }
        .fullScreenCover(item: $poster) { item in
            if let series = viewModel.series.first(where: { $0.id == item.id }) {
                ZStack {
                    Color.appBackground
                        .ignoresSafeArea()
                    SeriesPageView(series: series, container: dependencyContainer.container, isFullScreen: true)
                }
            }
        }
    }
    
    public init() {}
}
