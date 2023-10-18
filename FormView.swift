//
//  SwiftUIView.swift
//  gerardo_Compras
//
//  Created by g98beltran on 4/4/23.
//

import SwiftUI
import UIKit
import Photos

struct producte {
    var id: Int
    var nom: String
    var descripcio: String
    var proveedor: Int
    
    
    init(id: Int, nom: String, descripcio: String, proveedor: Int) {
        self.id = id
        self.nom = nom
        self.descripcio = descripcio
        self.proveedor = proveedor
        
    }
}

struct Contact {
    var id: Int
    var name: String
    var companyName: String
    var productsType: String
    var phoneNumber: String
    var phoneNumberTwo: String
    var email: String
    var skype: String
    var webOne: String
    var webTwo: String
    var address: String
    var otherInfo: String
    var details: String
    var creationTime: Int
    var createdByDeviceId: String
    var wasDeleted: Int
    var firstContactTimeInterval: Double
    var firstContact: String
    var samplesRequestedTimeInterval: Double
    var samplesRequested: String
    var samplesReceivedTimeInterval: Double
    var samplesReceived: String
    var quotationReceivedTimeInterval: Double
    var quotationReceived: String
    var firstOrderTimeInterval: Double
    var firstOrder: String
    var fair: Int
    
    init(id: Int, name: String, companyName: String, productsType: String, phoneNumber: String, phoneNumberTwo: String, email: String, skype: String, webOne: String, webTwo: String, address: String, otherInfo: String, details: String, creationTime: Int, createdByDeviceId: String, wasDeleted: Int, firstContactTimeInterval: Double,firstContact: String, samplesRequestedTimeInterval: Double, samplesRequested: String, samplesReceivedTimeInterval: Double, samplesReceived: String, quotationReceivedTimeInterval: Double, quotationReceived: String,firstOrderTimeInterval: Double, firstOrder: String, fair: Int) {
        self.id = id
        self.name = name
        self.companyName = companyName
        self.productsType = productsType
        self.phoneNumber = phoneNumber
        self.phoneNumberTwo = phoneNumberTwo
        self.email = email
        self.skype = skype
        self.webOne = webOne
        self.webTwo = webTwo
        self.address = address
        self.otherInfo = otherInfo
        self.details = details
        self.creationTime = creationTime
        self.createdByDeviceId = createdByDeviceId
        self.wasDeleted = wasDeleted
        self.firstContact = firstContact
        self.samplesRequested = samplesRequested
        self.samplesReceived = samplesReceived
        self.quotationReceived = quotationReceived
        self.firstOrder = firstOrder
        self.fair = fair
        self.firstContactTimeInterval = firstContactTimeInterval
        self.samplesRequestedTimeInterval = samplesRequestedTimeInterval
        self.samplesReceivedTimeInterval = samplesReceivedTimeInterval
        self.quotationReceivedTimeInterval = quotationReceivedTimeInterval
        self.firstOrderTimeInterval = firstOrderTimeInterval
    }
}
struct ProveedorsView: View {
    let dbManager = DBManager(conDB: "gerardo")
    //@State private var searchText = ""
    var proveedors: [Proveedor] {
        return dbManager.consulta2().reversed()
        /*if searchText.isEmpty {
            return dbManager.consulta2()
        } else {
            let searchWords = searchText.lowercased().split(separator: " ")
            return dbManager.consulta2().filter { Proveedor in
                let Proveedorname = Proveedor.name.lowercased()
                return searchWords.allSatisfy { word in
                    Proveedorname.contains(word)
                }
            }
        }*/
    }
    var body: some View {
        Text("-------------------------------------------------")
        Text("Llista de Proveidors.")
            .font(.largeTitle)
        Text("-------------------------------------------------")
        VStack {
            
            //SearchBar(text: $searchText)
            Text("ID-NOM-COMPANYIA-TLF-MAIL").font(.system(size: 20))
            let colors = [Color.teal, Color.blue, Color.green, Color.gray, Color.purple, Color.yellow, Color.orange, Color.red]
            List(proveedors, id: \.id) { PROVEEDOR in
                let colorIndex = proveedors.firstIndex(of: PROVEEDOR) ?? 0
                let backgroundColor = colors[colorIndex % colors.count].opacity(0.2)
                ZStack {
                    backgroundColor
                    VStack(alignment: .leading, spacing: 10) {
                        
                        NavigationLink(destination: ProductView(proveedorId: PROVEEDOR.id,proveedornom: PROVEEDOR.name)){
                            HStack {
                                if let image = getImageFromDocumentsDirectory(fileName: "\(PROVEEDOR.id).jpg") {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .aspectRatio(contentMode: .fit)
                                    
                                }
                                Text("\(String(PROVEEDOR.id)) - \(PROVEEDOR.name) - \(PROVEEDOR.companyName) -  \n \(PROVEEDOR.telefono) - \(PROVEEDOR.email) ")
                                    .font(.system(size: 25))
                                    .foregroundColor(.black)
                                
                            }
                        }
                        
                        /*HStack(spacing: 100) {
                            Spacer().frame(width: 10)
                            Image(systemName: "pencil")
                                .foregroundColor(.green)
                                .font(.system(size: 50))
                                .onTapGesture {
                                    print("apretar editar")
                                }
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .font(.system(size: 50))
                                .onTapGesture {
                                    print("apretar borrar")
                                }
                        }*/
                    }
                    .padding()
                }
                .cornerRadius(0)
            }
            
        }

    }
}
struct ListaProductosView: View {
    var proveedorId: Int
    var proveedornom: String
    let dbManager = DBManager(conDB: "gerardo")
    //@State private var searchText = ""
    var productes: [Product] {
        return dbManager.consulta3(proveidor: proveedorId).reversed()
        /*if searchText.isEmpty {
            return dbManager.consulta2()
        } else {
            let searchWords = searchText.lowercased().split(separator: " ")
            return dbManager.consulta2().filter { Proveedor in
                let Proveedorname = Proveedor.name.lowercased()
                return searchWords.allSatisfy { word in
                    Proveedorname.contains(word)
                }
            }
        }*/
    }
    var body: some View {
        Text("-------------------------------------------------")
        Text("Llista de Productes, del proveidor \(proveedornom).")
            .font(.largeTitle)
        Text("-------------------------------------------------")
        VStack {
            
            //SearchBar(text: $searchText)
            Text("ID-NOM-ID_PROVEIDOR-DESCRIPCIO").font(.system(size: 20))
            let colors = [Color.red, Color.blue, Color.green, Color.orange, Color.purple, Color.yellow]
            List(productes, id: \.id) { producte in
                let colorIndex = productes.firstIndex(of: producte) ?? 0
                let backgroundColor = colors[colorIndex % colors.count].opacity(0.2)
                ZStack {
                    backgroundColor
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            if let image = getImageFromDocumentsDirectory(fileName: "\(producte.id).jpg") {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .aspectRatio(contentMode: .fit)
                            }
                            Text("\(String(producte.id)) - \(producte.nom) - \(String(producte.proveedor)) -  \n \(producte.descripcio)")
                                .font(.system(size: 25))
                                .foregroundColor(.black)
                            if let image = getImageFromDocumentsDirectory(fileName: "\(producte.id).jpg") {
                                NavigationLink(destination: AmpliarImagenView(image: image)) {
                                                                
                                }
                            }

                        }
                    }

                        /*VStack(alignment: .leading, spacing: 10) {
                            //NavigationLink(destination: ProductView(proveedorId: PROVEEDOR.id,proveedornom: PROVEEDOR.name)){
                            Text("\(String(producte.id)) - \(producte.nom) - \(String(producte.proveedor)) -  \n \(producte.descripcio)")
                                .font(.system(size: 25))
                                .foregroundColor(.black)
                            //}
                        }
                        .padding()*/
                    
                }
                .cornerRadius(0)
            }
            
        }

    }
}
struct AmpliarImagenView: View {
    @State private var scale: CGFloat = 1.0
    @GestureState private var magnifyBy = CGFloat(1.0)
    
    var image: UIImage
    
    var body: some View {
        let magnification = MagnificationGesture()
            .updating($magnifyBy) { currentState, gestureState, _ in
                gestureState = currentState
            }
            .onEnded { scale in
                self.scale *= scale
            }
        
        let scaledImage = Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(scale * magnifyBy)
            .padding()
            .gesture(magnification)
        
        return scaledImage
    }
}

func getImageFromDocumentsDirectory(fileName: String) -> UIImage? {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileURL = documentsURL.appendingPathComponent("img/\(fileName)")
    do {
        let imageData = try Data(contentsOf: fileURL)
        return UIImage(data: imageData)
    } catch {
        print("Error loading image : \(error)")
    }
    return nil
}

struct ProductView: View {
    var proveedorId: Int
    var proveedornom: String
    

    @State private var isShowingImagePicker = false
    @State private var image: UIImage?
    
    var dbManager = DBManager(conDB: "gerardo")
    
    @State public var id: Int = Int(Date().timeIntervalSince1970)//Int( abs(Int64(arc4random())))
    @State var nom: String = ""
    @State var descripcio: String = ""
    
    @State private var navigateToProductes = false
    @State private var isSavingProd = false
    
    var body: some View {
        VStack {
            NavigationLink(destination: ListaProductosView(proveedorId: proveedorId,proveedornom: proveedornom)) {
                Text("Productes de \(proveedornom)")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                    .frame(minWidth: 0, maxWidth: 500)
                    .background(Color.teal)
                    .cornerRadius(10)
            }
            .padding(.top, -20)
            
            Text("-----------------------------------------------")
            Text("Afegir Productes al Proveidor \(proveedornom).")
                .font(.largeTitle)
            Text("-----------------------------------------------")
            
            Form {
                TextField("Nom", text: $nom)
                TextField("Descripció", text: $descripcio)
            }
            .font(.title)
            .foregroundColor(.blue)
            .padding(.horizontal)
            
            HStack {
                VStack {
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                        Button(action: {
                            isShowingImagePicker = true
                        }) {
                            Text("Fer foto")
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .background(Color.purple.opacity(0.5))
                                .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        Button(action: {
                            isShowingImagePicker = true
                        }) {
                            if let defaultImage = UIImage(named: "defaultImage") {
                                VStack{
                                    Image(uiImage: defaultImage)
                                        .resizable()
                                        .scaledToFit()
                                    Text("Fer foto")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                        .padding()
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .background(Color.purple.opacity(0.5))
                                        .cornerRadius(10)
                                }
                            } else {
                                Text("Fer foto")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .padding()
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .background(Color.purple).opacity(0.5)
                                    .cornerRadius(10)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .onDisappear {
                    self.image = nil
                }
                .sheet(isPresented: $isShowingImagePicker) {
                    ImagePicker(sourceType: .camera, id: self.id) { image in
                        self.image = image
                    }
                }
                
                VStack {
                        if let image = getImageFromDocumentsDirectory(fileName: "\(proveedorId).jpg") {
                            NavigationLink(destination: AmpliarImagenView(image: image)) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                            }
                    } else {
                        if let defaultImage = UIImage(named: "defaultImage") {
                            Image(uiImage: defaultImage)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    
                    Button(action: {
                        guard !isSavingProd else {
                            return // Evitar que el botón sea presionado si ya se está guardando
                        }
                        isSavingProd = true
                        
                        
                        
                        let producte = producte(id: id, nom: nom, descripcio: descripcio, proveedor: proveedorId)
                        print(producte)
                        dbManager.createAndInsertProductTable(products: [producte])
                        
                        id = Int(Date().timeIntervalSince1970)//Int(abs(Int64(arc4random())))
                        nom = ""
                        descripcio = ""
                        
                        navigateToProductes = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isSavingProd = false
                        }
                        
                    }) {
                        if let _ = getImageFromDocumentsDirectory(fileName: "\(proveedorId).jpg") {
                            Text("Guarda Producte")
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .background(Color.pink.opacity(0.5))
                                .cornerRadius(10)
                        } else {
                            Text("Guarda Producte")
                                .foregroundColor(.white)
                                .font(.headline)
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .background(Color.pink.opacity(0.5))
                                .cornerRadius(10)
                        }
                    }
                    
                    if navigateToProductes {
                        NavigationLink(destination: ListaProductosView(proveedorId: proveedorId, proveedornom: proveedornom), isActive: $navigateToProductes) {
                            EmptyView()
                        }
                        .hidden()
                        .disabled(isSavingProd)
                    }
                }
            }

            .padding(.horizontal)
        }
        .ignoresSafeArea(.keyboard)
    }
}


struct FormView: View {
    
    //@State public var id: Int = UUID().hashValue
    @State public var id: Int = Int(Date().timeIntervalSince1970)//Int( abs(Int64(arc4random())))
    @State var name: String = ""
    @State var companyName: String = ""
    @State var productsType: String = ""
    @State var phoneNumber: String = ""
    @State var phoneNumberTwo: String = ""
    @State var email: String = ""
    @State var skype: String = ""
    @State var webOne: String = ""
    @State var webTwo: String = ""
    @State var address: String = ""
    @State var otherInfo: String = ""
    @State var details: String = ""
    @State var creationTime: Int = 0
    @State var createdByDeviceId: String = ""
    @State var wasDeleted: Int = 0
    @State var firstContact: String = String(Date().timeIntervalSince1970)
    @State var samplesRequested: String = String(Date().timeIntervalSince1970)
    @State var samplesReceived: String = String(Date().timeIntervalSince1970)
    @State var quotationReceived: String = String(Date().timeIntervalSince1970)
    @State var firstOrder: String = String(Date().timeIntervalSince1970)
    @State var fair: Int = 9
    @State var firstContactTimeInterval: Double = 0
    @State var samplesRequestedTimeInterval: Double = 0
    @State var samplesReceivedTimeInterval: Double = 0
    @State var quotationReceivedTimeInterval: Double = 0
    @State var firstOrderTimeInterval: Double = 0
    

    @State private var isShowingImagePicker = false
    @State private var image: UIImage?
    @State private var navigateToProveedors = false
    
    
    
    
    
    var dbManager = DBManager(conDB: "gerardo")
    
    //locureets
    @State private var isSaving = false

    
    
    
        var body: some View {
            VStack {
                NavigationLink(destination: ProveedorsView()) {
                                Text("Llista Proveidors")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .frame(minWidth: 0, maxWidth: 600)
                        .background(Color.teal)
                        .cornerRadius(10)
                }
                .padding(.top, -20)
                Text("------------------------------------------")
                Text("Crear un nou proveidor amb foto.")
                    .font(.largeTitle)
                Text("------------------------------------------")
                Form {
                    TextField("Name", text: $name)
                    TextField("Company Name", text: $companyName)
                    TextField("Product Type", text: $productsType)
                    TextField("Phone Number", text: $phoneNumber)
                    TextField("Email", text: $email)
                    TextField("Address", text: $address)
                    TextField("Web Site", text: $webOne)
                    TextField("Other Information", text: $otherInfo)
                    TextField("Details", text: $details)
                    
                    

                }.font(.title).foregroundColor(.blue)
                
                HStack{
                    VStack {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                            Button(action: {
                                isShowingImagePicker = true
                            }) {
                                Text("Fer Foto")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .padding()
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .background(Color.purple.opacity(0.5))
                                    .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            Button(action: {
                                isShowingImagePicker = true
                            }) {
                                Text("Fer Foto")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                    .padding()
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .background(Color.purple.opacity(0.8))
                                    .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .onDisappear {
                        self.image = nil
                    }
                    .sheet(isPresented: $isShowingImagePicker) {
                        ImagePicker(sourceType: .camera, id: self.id) { image in
                            self.image = image
                        }
                    }
                    //.navigationTitle("Nuevo Proveedor")
                    
                    Button(action: {
                        
                        guard !isSaving else {
                                       return // Evitar que el botón sea presionado si ya se está guardando
                                   }
                        isSaving = true
                        
                        let myContact = Contact(id: id, name: name, companyName: companyName, productsType: productsType, phoneNumber: phoneNumber, phoneNumberTwo: phoneNumberTwo, email: email, skype: skype, webOne: webOne, webTwo: webTwo, address: address, otherInfo: otherInfo, details: details, creationTime: creationTime, createdByDeviceId: createdByDeviceId, wasDeleted: wasDeleted,firstContactTimeInterval: firstContactTimeInterval,firstContact: firstContact, samplesRequestedTimeInterval: samplesRequestedTimeInterval,samplesRequested: samplesRequested,samplesReceivedTimeInterval: samplesReceivedTimeInterval, samplesReceived: samplesReceived,quotationReceivedTimeInterval: quotationReceivedTimeInterval, quotationReceived: quotationReceived,firstOrderTimeInterval: firstOrderTimeInterval, firstOrder: firstOrder, fair: fair)
                        print(myContact)
                        
                        dbManager.createAndInsertContactsTable(contacts: [myContact])
                        
                        // Reset all the @State variables to their default values
                        id = Int(Date().timeIntervalSince1970)//Int(abs(Int64(arc4random())))
                        name = ""
                        companyName = ""
                        productsType = ""
                        phoneNumber = ""
                        phoneNumberTwo = ""
                        email = ""
                        skype = ""
                        webOne = ""
                        webTwo = ""
                        address = ""
                        otherInfo = ""
                        details = ""
                        creationTime = 0
                        createdByDeviceId = ""
                        wasDeleted = 0
                        firstContact = String(Date().timeIntervalSince1970)
                        samplesRequested = String(Date().timeIntervalSince1970)
                        samplesReceived = String(Date().timeIntervalSince1970)
                        quotationReceived = String(Date().timeIntervalSince1970)
                        firstOrder = String(Date().timeIntervalSince1970)
                        fair = 9
                        firstContactTimeInterval = 0
                        samplesRequestedTimeInterval = 0
                        samplesReceivedTimeInterval = 0
                        quotationReceivedTimeInterval = 0
                        firstOrderTimeInterval = 0
                        navigateToProveedors = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isSaving = false
                        }
                        
                    }) {
                        Text("Guarda Proveidor")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(Color.pink.opacity(0.5))
                            .cornerRadius(10)
                    }
                    if navigateToProveedors {
                        NavigationLink(destination: ProveedorsView(), isActive: $navigateToProveedors) {
                            EmptyView()
                        }
                        .hidden()
                        .disabled(isSaving)
                    }
                        
                }
                .ignoresSafeArea(.keyboard)
            }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
extension UIImage {
    func saveToDocumentsFolder(id: Int) -> String? {
        //let formatter = DateFormatter()
        //formatter.dateFormat = "yyyyMMddHHmmss"
        
        let fileName = "\(id).jpg"
        
        //pa guardar img en ipad
        //UIImageWriteToSavedPhotosAlbum(self, nil, nil, nil)
        
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
    var id: Int // nueva propiedad
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
                        if let filePath = image.saveToDocumentsFolder(id: self.id) {
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



struct FormView_Previews: PreviewProvider {
    static var previews: some View {
        FormView()
    }
}
