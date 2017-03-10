//
//  DAO.swift
//  CMBExersizeChadW
//
//  Created by Chad Wiedemann on 3/4/17.
//  Copyright © 2017 Chad Wiedemann LLC. All rights reserved.
//

import UIKit
import CoreData

class DAO: NSObject, DidFinishDownloadingEmoployeeInfo {

    var employeeObjectArray: Array<Employee> = []
    var employeeManagedObjectArray: Array<ManagedEmployee> = []
    var employeeJSONArray: Array<NSDictionary>?
    static let sharedInstance = DAO()
    var haveData = false
    
    //this is used so that the programmer doesn't make typos when trying to access dictionary keys
    enum dictionaryKeys: String {
        case avatar = "avatar"
        case bio = "bio"
        case firstName = "firstName"
        case id = "id"
        case lastName = "lastName"
        case title = "title"
    }
    
    //custom initializer used to load saved data from core data and the file system
    override init() {
        super.init()
        let moc = self.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ManagedEmployee")
        let sortDescriptor = NSSortDescriptor(key: "lastName", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetch.sortDescriptors = sortDescriptors
        do{
            let fetchedEmployees = try moc.fetch(fetch)
            self.employeeManagedObjectArray = fetchedEmployees as! Array<ManagedEmployee>
            if self.employeeManagedObjectArray.count < 1{
                self.readTeamJSONIntoArray()
            }else {
                self.haveData = true
                self.createEmployeeArrayFromCoreData()
            }
        } catch let error as NSError{
            print("Could not fetch. \(error), \(error.userInfo)")
            self.readTeamJSONIntoArray()
        }
    }
    
    //creates an array of regular objects from the managed objects returned by core data
    func createEmployeeArrayFromCoreData() {
        for MOEmployee in self.employeeManagedObjectArray{
            let tempEmployee = Employee.init(firstName: MOEmployee.firstName!, lastName: MOEmployee.lastName!, id: Int(MOEmployee.id), title: MOEmployee.title!)
            tempEmployee.bio = MOEmployee.bio!
            tempEmployee.avatarFilePath = MOEmployee.avatarFilePath!
            self.employeeObjectArray.append(tempEmployee)
        }
        
    }
    
    //reads the JSON file into and array property
    func readTeamJSONIntoArray() {
        do {
            if let file = Bundle.main.url(forResource: "team", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let object = json as? [NSDictionary] {
                        self.employeeJSONArray = object
                        self.addChadIntoEmployeeArray()
                } else {
                    print("JSON is invalid")
                    }
            } else {
                print("no file")
                }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //adds my information into the JSON dictionary of employees to try and be funny:)
    func addChadIntoEmployeeArray() {
        let chadsDictionary: NSDictionary = [
            "avatar": "https://media.licdn.com/media/AAEAAQAAAAAAAAWnAAAAJGRjN2M0ZjNjLTBkY2UtNGJiYi05YzY4LTNiY2E0NTUxY2VjYQ.jpg",
            "bio": "I have zero cycles",
            "firstName": "Chad",
            "id": "19",
            "lastName": "Wiedemann",
            "title": "iOS Engineer"
        ]
        self.employeeJSONArray?.append(chadsDictionary)
        self.createEmployeeArray()
    }
    
    //creates an array of employee objects with images and bios downloaded from FullContact API
    func createEmployeeArray() {
        for data in self.employeeJSONArray! {
            let employeeID: Int = Int(data.value(forKey: dictionaryKeys.id.rawValue) as! String)!
            let tempEmployee = Employee.init(firstName: data.value(forKey: dictionaryKeys.firstName.rawValue as String) as! String, lastName: data.value(forKey: dictionaryKeys.lastName.rawValue) as! String, id: employeeID , title: data.value(forKey: dictionaryKeys.title.rawValue) as! String)
            tempEmployee.delegate = self
            let downloadURL = URL.init(string: data.value(forKey: dictionaryKeys.avatar.rawValue) as! String)
            self.employeeObjectArray.append(tempEmployee)
            tempEmployee.downloadImage(url: downloadURL!)
        }
    }

    //creates managed objects to store in Core Data and then saves the context after all the employees are created
    func createManagedEmployee(employee: Employee){
        let MOEmployee = NSEntityDescription.insertNewObject(forEntityName: "ManagedEmployee", into: persistentContainer.viewContext) as! ManagedEmployee
        MOEmployee.avatarFilePath = employee.avatarFilePath
        MOEmployee.bio = employee.bio
        MOEmployee.firstName = employee.firstName
        MOEmployee.id = Int16(employee.id)
        MOEmployee.lastName = employee.lastName
        MOEmployee.title = employee.title
        self.employeeManagedObjectArray.append(MOEmployee)
        if self.employeeManagedObjectArray.count == self.employeeObjectArray.count {
            self.haveData = true
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: NSNotification.Name(rawValue: "finishedDownload"), object: nil)
            do{
                try persistentContainer.viewContext.save()
            }catch{
                fatalError("Failure to save context: \(error)")
            }
        }
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CMBExersizeChadW")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
