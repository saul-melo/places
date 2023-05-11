//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by melo on 5/5/23.
//

import Foundation
import CoreLocation
import MapKit
import LocalAuthentication

extension ContentView {
    @MainActor class ViewModel: ObservableObject {
        @Published var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 50, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 25, longitudeDelta: 25))
        @Published private(set) var locations: [Location]
        @Published var selectedPlace: Location?
        
        @Published var isUnlocked = false
        
        let savePath = FileManager.documentsDirectory.appendingPathComponent("savedPlaces")
        
        init() {
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                print("no saved Locations data, init empty Locations list")
                locations = []
            }
        }
        
        func addLocation(completion: @escaping (Bool) -> ()) {
            let latitude = mapRegion.center.latitude
            let longitude = mapRegion.center.longitude
            for location in locations {
                if location.latitude == latitude && location.longitude == longitude {
                    completion(false)
                    return
                }
            }
            let newLocation = Location(id: UUID(), name: "new location", description: "description", latitude: latitude, longitude: longitude)
            locations.append(newLocation)
            save()
            completion(true)
        }
        
        func update(location: Location) {
            guard let selectedPlace = selectedPlace else { return }
            if let index = locations.firstIndex(of: selectedPlace) {
                locations[index] = location
            }
            save()
        }
        
        func save() {
            do {
                let data = try JSONEncoder().encode(locations)
                try data.write(to: savePath, options: [.atomic, .completeFileProtection])
            } catch {
                print("unable to save data")
            }
        }
        
        func deleteAllPlaces() {
            do {
                try FileManager.default.removeItem(at: savePath)
                locations = []
            } catch {
                print("error trying to delete places at savePath \(savePath)")
            }
        }
        
        func authenticate(completion: @escaping (String) -> ()) {
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                let reason = "please authenticate yourself to unlock your places"
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                    if success {
                        Task { @MainActor in
                            self.isUnlocked = true
                            completion("")
                        }
                    } else {
                        if let error = authenticationError {
                            let strMessage = self.errorMessage(errorCode: error._code)
                            if strMessage != "" {
                                completion(strMessage)
                            }
                        }
                    }
                }
            } else {
                let strMessage = self.errorMessage(errorCode: (error?._code)!)
                if strMessage != "" {
                    completion(strMessage)
                }
            }
        }
        
        func errorMessage(errorCode: Int) -> String {
            var strMessage = ""
            
            switch errorCode {
            case LAError.Code.authenticationFailed.rawValue:
                strMessage = "Authentication Failed"
//            case LAError.Code.userCancel.rawValue: // no need to notify user that auth was cancelled
//                strMessage = "User Canceled"
            case LAError.Code.systemCancel.rawValue:
                strMessage = "System Canceled"
            case LAError.Code.passcodeNotSet.rawValue:
                strMessage = "Please go to Settings & Turn On Passcode"
            case LAError.Code.biometryNotAvailable.rawValue:
                strMessage = "TouchID or FaceID Not Available"
            case LAError.Code.biometryNotEnrolled.rawValue:
                strMessage = "TouchID or FaceID Not Enrolled"
            case LAError.Code.biometryLockout.rawValue:
                strMessage = "TouchID or FaceID Lockout Please go to Settings & Turn On Passcode"
            case LAError.Code.appCancel.rawValue:
                strMessage = "App Canceled"
            case LAError.Code.invalidContext.rawValue:
                strMessage = "Invalid Context"
            default:
                strMessage = ""
            }
            return strMessage
        }
    }
}
