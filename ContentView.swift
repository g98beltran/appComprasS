//
//  ContentView.swift
//  gerardo_Compras
//
//  Created by g98beltran on 13/3/23.
//

import SwiftUI
import UIKit
import Photos


struct SearchBar: UIViewRepresentable {
    @Binding var text: String

    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}
struct ContentView: View {
    /*@State private var image: UIImage?
     @State private var isShowingImagePicker = false  */
    let dbManager = DBManager(conDB: "gerardo")
    @State private var searchText = ""
    //@State private var showForm = true
    
    var filteredArticles: [Article] {
        if searchText.isEmpty {
            return dbManager.consulta1()
        } else {
            let searchWords = searchText.lowercased().split(separator: " ")
            return dbManager.consulta1().filter { article in
                let articleName = article.name.lowercased()
                return searchWords.allSatisfy { word in
                    articleName.contains(word)
                }
            }
        }
    }
    
    
    

    var body: some View {
        
            NavigationView {
                
                VStack {
                    Text("-------------------")
                    Button(action: {
                        dbManager.sincronisar()
                    }) {
                        Text("Enviar TOT/Sincronisar")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(Color.black)
                            //.cornerRadius(10)
                        
                    }
                    Text("Buscador de de productes").font(.system(size: 20))
                    SearchBar(text: $searchText)
                    Text("ID-NOM-PREU-ARANCEL-UNIDADESxCONTAINER").font(.system(size: 20))
                    let colors = [Color.pink,Color.teal,Color.orange, Color.blue, Color.green, Color.gray, Color.purple, Color.yellow, Color.red]
                    List(filteredArticles, id: \.id) { article in
                        let colorIndex = filteredArticles.firstIndex(of: article) ?? 0
                        let backgroundColor = colors[colorIndex % colors.count].opacity(0.2)
                        ZStack {
                            backgroundColor
                            VStack(alignment: .leading, spacing: 10) {
                                Text("\(article.id) - \(article.name) \n - \(String(format: "%.2f", article.price)) $ - \(String(format: "%.2f", article.arancel)) % - \(article.unitsPerContainer) unitats -")
                                    .font(.system(size: 25))
                                    .foregroundColor(.black)
                            }
                            .padding()
                        }
                        .cornerRadius(0)
                    }.navigationBarTitle("APP-COMPRAS", displayMode: .inline)
                    /*NavigationLink(
                        destination: FormView()){
                            Text("Nou Contacte")
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(10)
                        }*/
                    
                    
                }
                FormView()
                
            }.navigationBarTitleDisplayMode(.large)
            

        }
    }


            /*
            //CODIGO PARA LA IMAGEN
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Button(action: {
                    isShowingImagePicker = true
                }) {
                    Text("Tomar foto")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .onDisappear {
            self.image = nil
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(sourceType: .camera) { image in
                self.image = image
            }
        }
        .navigationTitle("Tomar foto")
    }
}

extension UIImage {
    func saveToDocumentsFolder() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let fileName = "\(formatter.string(from: Date())).jpg"
        
        //pa guardar img en ipad
        UIImageWriteToSavedPhotosAlbum(self, nil, nil, nil)
        
        guard let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return nil
        }
        let filePath = "\(documentsPath)/img/\(fileName)"
        do {
            try FileManager.default.createDirectory(atPath: "\(documentsPath)/img", withIntermediateDirectories: true, attributes: nil)
            if let jpegData = self.jpegData(compressionQuality: 0.8) {
                try jpegData.write(to: URL(fileURLWithPath: filePath), options: .atomic)
                return filePath
            } else {
                return nil
            }
        } catch {
            print(error.localizedDescription)
            return nil
        }
        
        
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    typealias Coordinator = ImagePickerCoordinator
    
    var sourceType: UIImagePickerController.SourceType
    var onImagePicked: (UIImage?) -> Void
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
    
    func makeCoordinator() -> ImagePickerCoordinator {
        return ImagePickerCoordinator(onImagePicked: { image in
                    if let image = image {
                        if let filePath = image.saveToDocumentsFolder() {
                            print("Image saved at \(filePath)")
                        } else {
                            print("Failed to save image")
                        }
                    }
                    self.onImagePicked(image)
                })
        //return ImagePickerCoordinator(onImagePicked: onImagePicked)
    }
}

class ImagePickerCoordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let onImagePicked: (UIImage?) -> Void
    
    init(onImagePicked: @escaping (UIImage?) -> Void) {
        self.onImagePicked = onImagePicked
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        onImagePicked(image)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        onImagePicked(nil)
        picker.dismiss(animated: true, completion: nil)
    }
}
             
             */
    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


/*
struct ContentView: View {
    let dbManager = DBManager(conDB: "myDB")
    @State private var searchText = ""
    var filteredArticles: [Any] {
        if searchText.isEmpty {
            return dbManager.consulta1()
        } else {
            return dbManager.consulta1().filter { (article) -> Bool in
                if let articleDict = article as? [String:Any], let name = articleDict["nombre"] as? String {
                    return name.lowercased().contains(searchText.lowercased())
                } else {
                    return false
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            SearchBar(text: $searchText)
            List(filteredArticles, id: \.self) { article in
                if let articleDict = article as? [String:Any] {
                    Text("\(articleDict["nombre"]!) - \(articleDict["precio"]!)")
                }
            }
        }
    }
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}*/
/*
 struct ArticleListView: View {
     let dbManager = DBManager(conDB: "myDB")
     @State private var searchText = ""
     @State private var filteredArticles: [Any] = []
     
     var body: some View {
         VStack {
             SearchBar(text: $searchText, placeholder: "Buscar artículo") { query in
                 filteredArticles = dbManager.searchArticles(query: query)
             }
             List(filteredArticles, id: \.self) { article in
                 if let articleDict = article as? [String:Any] {
                     Text("\(articleDict["nombre"]!) - \(articleDict["precio"]!)")
                 }
             }
         }
     }
 }

 struct SearchBar: View {
     @Binding var text: String
     var placeholder: String
     var onSearch: (String) -> Void
     
     var
 */

/*
 struct ContentView: View {
 @State private var searchText = ""
 let dbManager = DBManager(conDB: "gerardo")
 
 
 
 var body: some View {
 VStack {
 SearchBar(text: $searchText)
 //Text("Hello, world!")
 }
 .padding()
 }
 }
 
 struct ContentView_Previews: PreviewProvider {
 static var previews: some View {
 ContentView()
 }
 }
 
 struct SearchBar: UIViewRepresentable {
 @Binding var text: String
 
 class Coordinator: NSObject, UISearchBarDelegate {
 @Binding var text: String
 
 init(text: Binding<String>) {
 _text = text
 }
 
 func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
 text = searchText
 }
 }
 
 func makeCoordinator() -> SearchBar.Coordinator {
 return Coordinator(text: $text)
 }
 
 func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
 let searchBar = UISearchBar(frame: .zero)
 searchBar.delegate = context.coordinator
 searchBar.searchBarStyle = .minimal
 searchBar.placeholder = "Search"
 return searchBar
 }
 
 func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
 uiView.text = text
 }
 }
 */
