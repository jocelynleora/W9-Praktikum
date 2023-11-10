import SwiftUI

struct MTGCardView: View {
    var card: MTGCard
    
    var body: some View {
        VStack {
            // Tampilkan gambar kartu
            AsyncImage(url: URL(string: card.image_uris?.large ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                case .failure:
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.red)
                case .empty:
                    ProgressView()
                @unknown default:
                    ProgressView()
                }
            }
            
            // Tampilkan nama kartu
            Text(card.name)
                .font(.title)
                .padding()
            
            // Tampilkan jenis kartu dan teks orakel
            VStack(alignment: .leading) {
                Text("Type: \(card.type_line)")
                Text("Oracle Text: \(card.oracle_text)")
            }
            .padding()
        }
    }
}

struct ContentView: View {
    @State private var mtgCards: [MTGCard] = []
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false


    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3) // Three cards per row

    var filteredCards: [MTGCard] {
        if searchText.isEmpty {
            return mtgCards
        } else {
            return mtgCards.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    
    var body: some View {
        TabView {
            NavigationView {
                VStack {
                    // Search bar
                    SearchBar(text: $searchText)

                    // Cards display
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredCards) { card in
                                NavigationLink(destination: MTGCardView(card: card)) {
                                    CardImageView(card: card)
                                        .frame(height: 215) // Adjust the image height as needed
                                }
                            }
                        }
                        .padding()
                    }
                    .onAppear {
                        // Load data from a JSON file
                        if let data = loadJSON() {
                            do {
                                let decoder = JSONDecoder()
                                let cards = try decoder.decode(MTGCardList.self, from: data)
                                mtgCards = cards.data
                            } catch {
                                print("Error decoding JSON: \(error)")
                            }
                        }
                    }
                }
                .navigationBarTitle("MTG Cards")
            }
            .tabItem {
                Image(systemName: "house")
                Text("Home")
            }

            Text("Collection")
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Collection")
                }

            Text("Decks")
                .tabItem {
                    Image(systemName: "rectangle.stack.fill")
                    Text("Decks")
                }

            Text("Scan")
                .tabItem {
                    Image(systemName: "qrcode.viewfinder")
                    Text("Scan")
                }
        }
        .accentColor(.black) // Change accent color to black
    }

    
    struct SearchBar: View {
            @Binding var text: String

            var body: some View {
                HStack {
                    TextField("Search", text: $text)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal, 8)
                }
                .padding(.top, 8)
            }
        }

    }

    
    // Function to load data from a JSON file
    func loadJSON() -> Data? {
        if let path = Bundle.main.path(forResource: "WOT-Scryfall", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return data
            } catch {
                print("Error loading JSON: \(error)")
            }
        }
        return nil
    }


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CardImageView: View {
    var card: MTGCard
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: card.image_uris?.large ?? "")) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8) // Adjust the corner radius as needed
                                .stroke(Color.black, lineWidth: 4) // Adjust the line width and color as needed
                        )
                case .failure:
                    Image(systemName: "exclamationmark.triangle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.red)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8) // Adjust the corner radius as needed
                                .stroke(Color.black, lineWidth: 1) // Adjust the line width and color as needed
                        )
                case .empty:
                    ProgressView()
                @unknown default:
                    ProgressView()
                }
            }
        
    
            
            Text(card.name)
                .font(.system(size: 12).bold()) // Adjust the size (e.g., 14) to your preference
                .padding(.top, 8) // Adjust the padding as needed

        }
    }
}
