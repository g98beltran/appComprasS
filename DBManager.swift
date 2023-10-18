//
//  File.swift
//  gerardo_Compras
//
//  Created by g98beltran on 21/3/23.
//

import Foundation
import UIKit
import CloudKit

struct Article: Hashable {
    let id: Int
    let name: String
    let price: Float
    let arancel: Float
    let unitsPerContainer: Int
    
}
struct Proveedor: Hashable {
    let id: Int
    let name: String
    let companyName: String
    let telefono: String
    let email: String
    
}

struct Product: Hashable {
    let id: Int
    let nom: String
    let descripcio: String
    let proveedor: Int
    
}


class DBManager {
    var db : OpaquePointer? = nil
    
    //conexion con base de datos local en el ipad
    
    init(conDB nombreDB : String) {
        if let dbPath = Bundle.main.path(forResource: nombreDB, ofType: "db") {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsURL.appendingPathComponent(nombreDB + ".db")
            
            // Copiar la base de datos al directorio de documentos si no existe
            if !FileManager.default.fileExists(atPath: destinationURL.path) {
                do {
                    try FileManager.default.copyItem(at: URL(fileURLWithPath: dbPath), to: destinationURL)
                } catch let error {
                    print("Error al copiar la base de datos: \(error.localizedDescription)")
                }
            }
            
            // Abrir la base de datos desde el directorio de documentos
            if sqlite3_open(destinationURL.path, &(self.db)) == SQLITE_OK {
                print("Base de datos \(destinationURL.path) abierta OK")
            } else {
                let error = String(cString:sqlite3_errmsg(db))
                print("Error al intentar abrir la BD: \(error) ")
                
                
            }
        } else {
            print("El archivo no se encuentra")
        }
    }
    
    /*if let dbPath = Bundle.main.path(forResource: nombreDB, ofType: "db") {
     if sqlite3_open(dbPath, &(self.db)) == SQLITE_OK {
     print("Base de datos \(dbPath) abierta OK")
     }
     else {
     let error = String(cString:sqlite3_errmsg(db))
     print("Error al intentar abrir la BD: \(error) ")
     }
     }
     else {
     print("El archivo no se encuentra")
     }*/
    
    //Consulta a la base de datos local para obtener historico de productos comprados
    
    
    func consulta1() -> [Article] {
        let querySQL = "select id,name_es,purchasePrice,arancel, unitsPerContainer from articles where purchasePrice > 0 and name_es not null"
        var statement : OpaquePointer?;
        var lista: [Article] = [];
        
        let result = sqlite3_prepare_v2(db, querySQL, -1, &statement, nil)
        if (result==SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                let id = Int(sqlite3_column_int(statement, 0))
                let name_es = String(cString: sqlite3_column_text(statement, 1))
                let purchasePrice = Float(sqlite3_column_double(statement, 2))
                let arancel = Float(sqlite3_column_double(statement, 3))
                let unitsPerContainer = Int(sqlite3_column_int(statement, 4))
                let article = Article(id: id, name: name_es, price: purchasePrice, arancel: arancel, unitsPerContainer: unitsPerContainer)
                lista.append(article)
            }
        }
        sqlite3_finalize(statement);
        return lista
    }
    func consulta2() -> [Proveedor] {
        let querySQL = "select id,name,companyName,phoneNumber,email from Contacts"
        var statement : OpaquePointer?;
        var lista: [Proveedor] = [];
        
        let result = sqlite3_prepare_v2(db, querySQL, -1, &statement, nil)
        if (result==SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                let id = Int(sqlite3_column_int(statement, 0))
                let name = String(cString: sqlite3_column_text(statement, 1))
                let companyName = String(cString: sqlite3_column_text(statement, 2))
                let phoneNumber = String(cString: sqlite3_column_text(statement, 3))
                let email = String(cString: sqlite3_column_text(statement, 4))
                
                let proveedor = Proveedor(id: id, name: name,companyName:companyName, telefono: phoneNumber, email: email)
                lista.append(proveedor)
            }
        }
        sqlite3_finalize(statement);
        return lista
    }
    
    
    func consulta3(proveidor: Int) -> [Product] {
        let querySQL = "select id,nom,descripcio,proveedor from Product where proveedor=\(proveidor)"
        var statement : OpaquePointer?;
        var lista: [Product] = [];
        
        let result = sqlite3_prepare_v2(db, querySQL, -1, &statement, nil)
        if (result==SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                let id = Int(sqlite3_column_int(statement, 0))
                let nom = String(cString: sqlite3_column_text(statement, 1))
                let descripcio = String(cString: sqlite3_column_text(statement, 2))
                let proveedor = Int(sqlite3_column_int(statement, 3))
                
                let product = Product(id: id, nom: nom, descripcio: descripcio, proveedor: proveedor)
                lista.append(product)
            }
        }
        sqlite3_finalize(statement);
        return lista
    }
    
    
    
    
    func createAndInsertProductTable(products: [producte]) {
        let createTableSQL = """
                    CREATE TABLE IF NOT EXISTS Product (id INTEGER PRIMARY KEY, nom TEXT, descripcio TEXT, proveedor INTEGER);
        """
        
        var createTableStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, createTableSQL, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Product table created successfully.")
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("Error creating Product table: \(errorMessage)")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Error preparing create Product table statement: \(errorMessage)")
        }
        
        sqlite3_finalize(createTableStatement)
        
        //Se realiza el insert en la base de datos local en la tabla contacts
        
        let insertContactSQL = "INSERT INTO Product (id, nom, descripcio, proveedor ) VALUES ( ?, ?, ?, ?);"
        var insertStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertContactSQL, -1, &insertStatement, nil) == SQLITE_OK {
            for product in products {
                sqlite3_bind_int(insertStatement, 1, Int32(product.id))
                sqlite3_bind_text(insertStatement, 2, (product.nom as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 3, (product.descripcio as NSString).utf8String, -1, nil)
                sqlite3_bind_int(insertStatement, 4, Int32(product.proveedor))
                
                
                if sqlite3_step(insertStatement) != SQLITE_DONE {
                    let errorMessage = String(cString: sqlite3_errmsg(db))
                    print("Error inserting Product: \(errorMessage)")
                }else {
                    print("Producto insertado exitosamente")
                }
                
                sqlite3_reset(insertStatement)
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Error preparing insert Product statement: \(errorMessage)")
        }
        
        
        
        sqlite3_finalize(insertStatement)
        
        
        // preparar la consulta SELECT para seleccionar todos los registros de la tabla Contacts
        let query = "SELECT * FROM Product;"
        var selectStatement: OpaquePointer?
        
        // ejecutar la consulta SELECT
        if sqlite3_prepare_v2(db, query, -1, &selectStatement, nil) == SQLITE_OK {
            while sqlite3_step(selectStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(selectStatement, 0)
                let nom = String(cString: sqlite3_column_text(selectStatement, 1))
                let descripcio = String(cString: sqlite3_column_text(selectStatement, 2))
                let proveedor = sqlite3_column_int(selectStatement, 3)
                
                
                //Se printea el resultado de insertar el proveedor
                
                print("id: \(id), nom: \(nom), descripcio: \(descripcio), proveedor: \(proveedor)")
            }
        }else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Error preparing SELECT statement: \(errorMessage)")}
        
        
        // liberar recursos
        sqlite3_finalize(selectStatement)
        //crida a external calls
        //print("LLAMAMOS A: Enviar els productes al servidor.")
        
        //sendPostRequestProductes();//sendPostRequest()
        //print("---------------------------------------------------------------")
        
        //print("LLAMAMOS A: Enviar carpeta imagenes dels productes al servidor.")
        //Envia las imagenes al servidor
        //let folderPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/img/"
        //sendImagesInFolderToServer(folderPath: folderPath)
        
        //print("---------------------------------------------------------------")

        
        
    }
    
    func sincronisar(){
        //crida a external calls
        print("LLAMAMOS A: Enviant Datos al servidor.")
        
        sendPostRequestProductes();
        sendPostRequest();
        print("---------------------------------------------------------------")
        
        print("LLAMAMOS A: Enviar carpeta imagenes dels productes al servidor.")
        //Envia las imagenes al servidor
        let folderPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/img/"
        sendImagesInFolderToServer(folderPath: folderPath)
        
        print("---------------------------------------------------------------")
    }
    
    
    //Se crea la tabla contacts que es una copia de la de providers de el erp y se insertan los datos que se meten en la app
    
    
    func createAndInsertContactsTable(contacts: [Contact]) {
        let createTableSQL = """
                    CREATE TABLE IF NOT EXISTS Contacts (id INTEGER PRIMARY KEY, name TEXT, companyName TEXT, productsType TEXT, phoneNumber TEXT, phoneNumberTwo TEXT, email TEXT, skype TEXT, webOne TEXT, webTwo TEXT, address TEXT, otherInfo TEXT, details TEXT, creationTime INTEGER, createdByDeviceId TEXT, wasDeleted INTEGER, firstContactTimeInterval DOUBLE,firstContact INTEGER, samplesRequestedTimeInterval DOUBLE,samplesRequested INTEGER, samplesReceivedTimeInterval DOUBLE,samplesReceived TEXT, quotationReceivedTimeInterval DOUBLE,quotationReceived TEXT, firstOrderTimeInterval DOUBLE,firstOrder TEXT, fair INTEGER);
        """
        
        var createTableStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, createTableSQL, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Contacts table created successfully.")
            } else {
                let errorMessage = String(cString: sqlite3_errmsg(db))
                print("Error creating Contacts table: \(errorMessage)")
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Error preparing create Contacts table statement: \(errorMessage)")
        }
        
        sqlite3_finalize(createTableStatement)
        
        //Se realiza el insert en la base de datos local en la tabla contacts
        
        let insertContactSQL = "INSERT INTO Contacts (id, name, companyName, productsType, phoneNumber, phoneNumberTwo, email, skype, webOne, webTwo, address, otherInfo, details, creationTime, createdByDeviceId, wasDeleted, firstContactTimeInterval, firstContact, samplesRequestedTimeInterval, samplesRequested, samplesReceivedTimeInterval, samplesReceived, quotationReceivedTimeInterval, quotationReceived, firstOrderTimeInterval, firstOrder, fair) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
        var insertStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertContactSQL, -1, &insertStatement, nil) == SQLITE_OK {
            for contact in contacts {
                sqlite3_bind_int64(insertStatement, 1, Int64(contact.id))
                sqlite3_bind_text(insertStatement, 2, (contact.name as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 3, (contact.companyName as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 4, (contact.productsType as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 5, (contact.phoneNumber as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 6, (contact.phoneNumberTwo as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 7, (contact.email as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 8, (contact.skype as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 9, (contact.webOne as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 10, (contact.webTwo as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 11, (contact.address as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 12, (contact.otherInfo as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 13, (contact.details as NSString).utf8String, -1, nil)
                sqlite3_bind_int(insertStatement, 14, Int32(contact.creationTime))
                sqlite3_bind_text(insertStatement, 15,(contact.createdByDeviceId as NSString).utf8String, -1, nil)
                sqlite3_bind_int(insertStatement, 16, Int32(contact.wasDeleted))
                sqlite3_bind_double(insertStatement, 17, contact.firstContactTimeInterval)
                sqlite3_bind_text(insertStatement, 18, (contact.firstContact as NSString).utf8String, -1, nil)
                sqlite3_bind_double(insertStatement, 19, contact.samplesRequestedTimeInterval)
                sqlite3_bind_text(insertStatement, 20, (contact.samplesRequested as NSString).utf8String, -1, nil)
                sqlite3_bind_double(insertStatement,21, contact.samplesReceivedTimeInterval)
                sqlite3_bind_text(insertStatement, 22, (contact.samplesReceived as NSString).utf8String, -1, nil)
                sqlite3_bind_double(insertStatement, 23, contact.quotationReceivedTimeInterval)
                sqlite3_bind_text(insertStatement, 24, (contact.quotationReceived as NSString).utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 25, (contact.firstOrder as NSString).utf8String, -1, nil)
                sqlite3_bind_int(insertStatement, 26, Int32(contact.fair))
                
                if sqlite3_step(insertStatement) != SQLITE_DONE {
                    let errorMessage = String(cString: sqlite3_errmsg(db))
                    print("Error inserting contact: \(errorMessage)")
                }else {
                    print("Contacto insertado exitosamente")
                }
                
                sqlite3_reset(insertStatement)
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Error preparing insert Contact statement: \(errorMessage)")
        }
        
        
        
        sqlite3_finalize(insertStatement)
        
        
        // preparar la consulta SELECT para seleccionar todos los registros de la tabla Contacts
        let query = "SELECT * FROM Contacts;"
        var selectStatement: OpaquePointer?
        
        // ejecutar la consulta SELECT
        if sqlite3_prepare_v2(db, query, -1, &selectStatement, nil) == SQLITE_OK {
            while sqlite3_step(selectStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(selectStatement, 0)
                let name = String(cString: sqlite3_column_text(selectStatement, 1))
                let companyName = String(cString: sqlite3_column_text(selectStatement, 2))
                let productsType = String(cString: sqlite3_column_text(selectStatement, 3))
                let phoneNumber = String(cString: sqlite3_column_text(selectStatement, 4))
                let phoneNumberTwo = String(cString: sqlite3_column_text(selectStatement, 5))
                let email = String(cString: sqlite3_column_text(selectStatement, 6))
                let skype = String(cString: sqlite3_column_text(selectStatement, 7))
                let webOne = String(cString: sqlite3_column_text(selectStatement, 8))
                let webTwo = String(cString: sqlite3_column_text(selectStatement, 9))
                let address = String(cString: sqlite3_column_text(selectStatement, 10))
                let otherInfo = String(cString: sqlite3_column_text(selectStatement, 11))
                let details = String(cString: sqlite3_column_text(selectStatement, 12))
                let creationTime = sqlite3_column_int(selectStatement, 13)
                let createdByDeviceId = String(cString: sqlite3_column_text(selectStatement, 14))
                let wasDeleted = sqlite3_column_int(selectStatement, 15)
                let firstContactTimeInterval = sqlite3_column_double(selectStatement, 16)
                let firstContact = String(cString: sqlite3_column_text(selectStatement, 17))
                let samplesRequestedTimeInterval = sqlite3_column_double(selectStatement, 18)
                let samplesRequested = String(cString: sqlite3_column_text(selectStatement, 19))
                let samplesReceivedTimeInterval = sqlite3_column_double(selectStatement, 20)
                let samplesReceived = String(cString: sqlite3_column_text(selectStatement, 21))
                let quotationReceivedTimeInterval = sqlite3_column_double(selectStatement, 22)
                let quotationReceived = String(cString: sqlite3_column_text(selectStatement, 23))
                let firstOrderTimeInterval = 0.0//sqlite3_column_double(selectStatement, 24)
                let firstOrder = String(cString: sqlite3_column_text(selectStatement, 24))
                let fair = sqlite3_column_int(selectStatement, 25)
                
                //Se printea el resultado de insertar el proveedor
                
                print("id: \(id), name: \(name), companyName: \(companyName), productsType: \(productsType), phoneNumber: \(phoneNumber), phoneNumberTwo: \(phoneNumberTwo), email: \(email), skype: \(skype), webOne: \(webOne), webTwo: \(webTwo), address: \(address), otherInfo: \(otherInfo), details: \(details), creationTime: \(creationTime), createdByDeviceId: \(createdByDeviceId), wasDeleted: \(wasDeleted), firstContactTimeInterval: \(firstContactTimeInterval), firstContact: \(firstContact),samplesRequestedTimeInterval:\(samplesRequestedTimeInterval), samplesRequested: \(samplesRequested), samplesReceivedTimeInterval: \(samplesReceivedTimeInterval), samplesReceived: \(samplesReceived),quotationReceivedTimeInterval: \(quotationReceivedTimeInterval) ,quotationReceived: \(quotationReceived), firstOrderTimeInterval: \(firstOrderTimeInterval), firstOrder: \(firstOrder), fair: \(fair)")
            }
        }else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Error preparing SELECT statement: \(errorMessage)")}
        
        
        // liberar recursos
        sqlite3_finalize(selectStatement)
        //crida a external calls
        print("LLAMAMOS A: Enviar els proveedors al servidor.")
        //sendPostRequest()
        print("---------------------------------------------------------------")
        
        print("LLAMAMOS A: Enviar carpeta imagenes dels proveedors al servidor.")
        //Envia las imagenes al servidor
        //let folderPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/img/"
        //sendImagesInFolderToServer(folderPath: folderPath)
        
        print("---------------------------------------------------------------")

        
        
    }
    
    //Enviar datos al server, ERP
    
    func sendPostRequest() {
        
        // preparar la consulta SELECT para seleccionar todos los registros de la tabla Contacts
        let query = "SELECT * FROM Contacts;"
        var selectStatement: OpaquePointer?
        
        
        var contacts = [[String: Any]]()
        if sqlite3_prepare_v2(db, query, -1, &selectStatement, nil) == SQLITE_OK {
            while sqlite3_step(selectStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(selectStatement, 0)
                let name = String(cString: sqlite3_column_text(selectStatement, 1))
                let companyName = String(cString: sqlite3_column_text(selectStatement, 2))
                let productsType = String(cString: sqlite3_column_text(selectStatement, 3))
                let phoneNumber = String(cString: sqlite3_column_text(selectStatement, 4))
                let phoneNumberTwo = String(cString: sqlite3_column_text(selectStatement, 5))
                let email = String(cString: sqlite3_column_text(selectStatement, 6))
                let skype = String(cString: sqlite3_column_text(selectStatement, 7))
                let webOne = String(cString: sqlite3_column_text(selectStatement, 8))
                let webTwo = String(cString: sqlite3_column_text(selectStatement, 9))
                let address = String(cString: sqlite3_column_text(selectStatement, 10))
                let otherInfo = String(cString: sqlite3_column_text(selectStatement, 11))
                let details = String(cString: sqlite3_column_text(selectStatement, 12))
                let creationTime = sqlite3_column_int(selectStatement, 13)
                let createdByDeviceId = String(cString: sqlite3_column_text(selectStatement, 14))
                let wasDeleted = sqlite3_column_int(selectStatement, 15)
                let firstContactTimeInterval = sqlite3_column_double(selectStatement, 16)
                let firstContact = String(cString: sqlite3_column_text(selectStatement, 17))
                let samplesRequestedTimeInterval = sqlite3_column_double(selectStatement, 18)
                let samplesRequested = String(cString: sqlite3_column_text(selectStatement, 19))
                let samplesReceivedTimeInterval = sqlite3_column_double(selectStatement, 20)
                let samplesReceived = String(cString: sqlite3_column_text(selectStatement, 21))
                let quotationReceivedTimeInterval = sqlite3_column_double(selectStatement, 22)
                let quotationReceived = String(cString: sqlite3_column_text(selectStatement, 23))
                let firstOrderTimeInterval = 0.0//sqlite3_column_double(selectStatement, 24)
                let firstOrder = String(cString: sqlite3_column_text(selectStatement, 24))
                let fair = sqlite3_column_int(selectStatement, 25)
                
                
                
                let contact: [String: Any] = [    "id": id,    "name": name,    "companyName": companyName,    "productsType": productsType,    "phoneNumber": phoneNumber,    "phoneNumberTwo": phoneNumberTwo,    "email": email,    "skype": skype,    "webOne": webOne,    "webTwo": webTwo,    "address": address,    "otherInfo": otherInfo,    "details": details,    "creationTime": creationTime,    "createdByDeviceId": createdByDeviceId,    "wasDeleted": wasDeleted, "firstContactTimeInterval":firstContactTimeInterval,    "firstContact": firstContact, "samplesRequestedTimeInterval":samplesRequestedTimeInterval,    "samplesRequested": samplesRequested, "samplesReceivedTimeInterval":samplesReceivedTimeInterval,    "samplesReceived": samplesReceived, "quotationReceivedTimeInterval":quotationReceivedTimeInterval,    "quotationReceived": quotationReceived,"firstOrderTimeInterval":firstOrderTimeInterval,    "firstOrder": firstOrder,    "fair": fair]

                contacts.append(contact)
            }
        }else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Error preparing SELECT statement: \(errorMessage)")
        }
        sqlite3_finalize(selectStatement)
        let params = ["contacts": contacts]
        //let params = ["taputamare"]


        // Define la URL de destino
        guard let url = URL(string: "http://server/index.php/ExternalCalls/appFeriasProveedores") else { return }

        // Crea la solicitud HTTP POST
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Codifica los datos a formato JSON y los asigna al cuerpo de la solicitud
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else { return }
        request.httpBody = httpBody

        // Crea una sesión de URL y envía la solicitud
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error al enviar solicitud(proveedores): \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Error en la respuesta del servidor(proveedores): \(httpResponse.statusCode)")
                return
            }

            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Respuesta del servidor,insertados proveedores: \(dataString)")
            }
        }.resume()
    }
    
    //Enviar datos al server, ERP
    
    func sendPostRequestProductes() {
        
        // preparar la consulta SELECT para seleccionar todos los registros de la tabla Contacts
        let query = "SELECT * FROM Product;"
        var selectStatement: OpaquePointer?
        
        
        var Products = [[String: Any]]()
        if sqlite3_prepare_v2(db, query, -1, &selectStatement, nil) == SQLITE_OK {
            while sqlite3_step(selectStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(selectStatement, 0)
                let nom = String(cString: sqlite3_column_text(selectStatement, 1))
                let descripcio = String(cString: sqlite3_column_text(selectStatement, 2))
                let proveedor = sqlite3_column_int(selectStatement, 3)
                
                let Product: [String: Any] = [    "id": id,    "nom": nom,    "descripcio": descripcio,    "proveedor": proveedor]

                Products.append(Product)
            }
        }else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("Error preparing SELECT statement: \(errorMessage)")
        }
        sqlite3_finalize(selectStatement)
        let params = ["products": Products]
        //let params = ["taputamare"]


        // Define la URL de destino
        guard let url = URL(string: "http://server/index.php/ExternalCalls/appFeriasProveedoresProductes") else { return }

        // Crea la solicitud HTTP POST
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Codifica los datos a formato JSON y los asigna al cuerpo de la solicitud
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else { return }
        request.httpBody = httpBody

        // Crea una sesión de URL y envía la solicitud
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error al enviar solicitud(productes): \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Error en la respuesta del servidor(productes): \(httpResponse.statusCode)")
                return
            }

            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Respuesta del servidor,insertats productes: \(dataString)")
            }
        }.resume()
    }
    
    //proveidors
    func sendImagesInFolderToServer(folderPath: String) {
        let fileManager = FileManager.default
        let folderURL = URL(fileURLWithPath: folderPath)
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            
            for fileURL in fileURLs {
                let imageName = fileURL.lastPathComponent
                guard let image = UIImage(contentsOfFile: fileURL.path) else { continue }
                sendImageToServer(image: image, imageName: imageName)
                //break //aso fa q soles sanvie una foto
            }
            /*let imageName = folderURL.lastPathComponent
            guard let image = UIImage(contentsOfFile: folderURL.path) else { return }
            sendImageToServer(image: image, imageName: imageName)*/
            
        } catch {
            print("Error al obtener la lista de archivos en la carpeta(img): \(error.localizedDescription)")
        }
    }
    
    func sendImageToServer(image: UIImage, imageName: String) {
        // Define la URL de destino
        guard let url = URL(string: "http://server/index.php/ExternalCalls/provagerardo/\(imageName)") else { return }

        // Crea la solicitud HTTP POST
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        print(url)
        // Crea los datos de la imagen a enviar
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }

        // Agrega la imagen al cuerpo de la solicitud como un parámetro con el nombre de archivo como clave
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition:form-data; name=\"imagen\"; filename=\"\(imageName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        // Crea una tarea de carga de archivo y la asigna al cuerpo de la solicitud
        let uploadTask = URLSession.shared.uploadTask(with: request, from: nil) { (data, response, error) in
            if let error = error {
                print("Error al enviar solicitud(img): \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Error en la respuesta del servidor(img): \(httpResponse.statusCode)")
                return
            }

            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Respuesta del servidor(img): \(dataString)")
            }
        }
        uploadTask.resume()
    }
}






