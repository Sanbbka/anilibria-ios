import Common
import SwiftUI
import Components
import ServiceLayer
import DITranquillity
import Combine

struct SeriesFilterModel {
    var genres: Set<String> = []
    var years: Set<String> = []
    var seasons: Set<String> = []
    var sorting = SeriesSorting.mostPopularity
    var isCompleted = true
    
    var main = FilterData()
    
    var filter: SeriesFilter {
        .init(genres: genres, years: years, seasons: seasons, sorting: sorting, isCompleted: isCompleted)
    }
}

struct FilterView: View {
    internal init(mainFilter: Binding<SeriesFilterModel>, completion: @escaping () -> Void) {
        self._mainFilter = mainFilter
        self.saveFilter = mainFilter.wrappedValue
        self.completion = completion
    }
    
    @Binding var mainFilter: SeriesFilterModel
    @State var saveFilter: SeriesFilterModel
    let completion: () -> Void
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        VStack {
            HStack {
                Text("Сортировка: ")
                Picker("Выберите значение", selection: $saveFilter.sorting) {
                    Text("По популярности").tag(SeriesSorting.mostPopularity)
                    Text("Новейшие").tag(SeriesSorting.newest)
                }
                .pickerStyle(.menu)
                Spacer()
            }
            HStack {
                Text("Завершено: ")
                Picker("Выберите значение", selection: $saveFilter.isCompleted) {
                    Text("Да").tag(true)
                    Text("Нет").tag(false)
                }
                .pickerStyle(.menu)
                Spacer()
            }
            
            TagViewSection(
                selectedTags: $saveFilter.years,
                allowsMultipleSelection: true,
                tags: saveFilter.main.years,
                title: "Года"
            )
            
            TagViewSection(
                selectedTags: $saveFilter.seasons,
                allowsMultipleSelection: true,
                tags: saveFilter.main.seasons.compactMap { $0.original },
                title: "Сезоны"
            )
            
            TagViewSection(
                selectedTags: $saveFilter.genres,
                allowsMultipleSelection: true,
                tags: saveFilter.main.genres,
                title: "Жанры"
            )
            
            VStack(spacing: 20) {
                Button("Подтвердить") {
                    self.mainFilter = saveFilter
                    presentationMode.wrappedValue.dismiss()
                    completion()
                }
                Button("Отмена") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.red)
            }
            .padding()
        }
        .padding()
        .background(Color.black)
        .cornerRadius(10)
        .shadow(radius: 10)
        .frame(width: UIScreen.main.bounds.width / 3)
    }
    
    struct TagViewSection: View {
        init(selectedTags: Binding<Set<String>>, allowsMultipleSelection: Bool, tags: [String], title: String) {
            self._selectedTags = selectedTags
            self.allowsMultipleSelection = allowsMultipleSelection
            self.tags = tags
            self.title = title
        }
        
        // Состояние для хранения выбранных тегов
        @Binding
        var selectedTags: Set<String>
        let allowsMultipleSelection: Bool
        let title: String
        
        // Список тегов
        let tags: [String]
        
        var body: some View {
            VStack {
                HStack {
                    Text(title)
                    Spacer()
                }
                ScrollView(.horizontal) {
                    HStack(spacing: 22) {
                        ForEach(tags, id: \.self) { tag in
                            Button(tag) {
                                if allowsMultipleSelection {
                                    if selectedTags.contains(tag) {
                                        selectedTags.remove(tag) // Убираем тег из выбранных
                                    } else {
                                        selectedTags.insert(tag) // Добавляем тег в выбранные
                                    }
                                } else {
                                    selectedTags.removeAll()
                                    selectedTags.insert(tag)
                                }
                            }
                            .tint(selectedTags.contains(tag) ? .blue : .gray)
                            .buttonBorderShape(.capsule)
                        }
                    }
                    .padding([.all], 22)
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
