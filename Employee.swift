//
//  Employee.swift
//  CMBExersizeChadW
//
//  Created by Chad Wiedemann on 3/4/17.
//  Copyright © 2017 Chad Wiedemann LLC. All rights reserved.
//

import UIKit

//custom protocol used to send an employee object back after downloads complete to the Data Access Object to turn into a managed object and save to Core Data
protocol DidFinishDownloadingEmoployeeInfo {
    func createManagedEmployee(employee: Employee)
}

class Employee: NSObject {

    var firstName: String = ""
    var lastName: String = ""
    var id: Int = 0
    var bio: String = ""
    var title: String = ""
    var avatarFilePath: String = ""
    var delegate: DidFinishDownloadingEmoployeeInfo?
    
    //custom init method
    init(firstName: String,lastName: String,id: Int,title: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.id = id
        self.title = title
    }

    //gets the data used to create the UIImage from the URL provided in the JSON file
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    // downloads the employee image and saves to the file system
    func downloadImage(url: URL) {
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            let filename = self.getDocumentsDirectory().appendingPathComponent(String(self.id))
            try? data.write(to: filename)
            self.avatarFilePath = String(describing: filename)
            self.downloadBiosAPI()
        }
    }
    
    //gets the document directory for use in other functions
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    //parses through the JSON response from the FullContact API to extract employees' bio
    func setBioFromJSON(dictionary: Any) -> String {
        let dict = dictionary as! NSDictionary
        if self.lastName != "Gentry" {
            if let socialProfilesArray = dict.value(forKey: "socialProfiles") as? Array<NSDictionary> {
                for dict in socialProfilesArray {
                    if let dict = dict.value(forKey: "bio") {
                        return dict as! String
                    }
                }
            }
        }
        return ""
    }
    
    //sends a GET request to FullContact Person API to retrieve publicly available information to properly populate employee biographies
    func downloadBiosAPI() {
            let httpRequestURL = "https://api.fullcontact.com/v2/person.json?email=" + "\(self.firstName)" + "%40coffeemeetsbagel.com"
            let url = URL.init(string: httpRequestURL)
            var request = URLRequest.init(url: url!)
            request.httpMethod = "GET"
            request.setValue("cddf3e10ff6f75c4", forHTTPHeaderField: "X-FullContact-APIKey")
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                guard let data = data else {
                    print("Data is empty")
                    return
                }
                let json = try! JSONSerialization.jsonObject(with: data, options: [])
                let bio  = self.setBioFromJSON(dictionary: json)
                self.bio = bio
                self.delegate?.createManagedEmployee(employee: self)
                print(self.bio)
            })
            task.resume()
    }
}
