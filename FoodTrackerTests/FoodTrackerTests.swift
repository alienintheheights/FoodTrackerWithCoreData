//
//  FoodTrackerTests.swift
//  FoodTrackerTests
//
//  Created by Mr. Shoe on 1/5/16.
//  Copyright © 2016 Thinking Dog. All rights reserved.
//

import XCTest
import CoreData
@testable import FoodTracker

class FoodTrackerTests: XCTestCase {
    
	// MARK: FoodTracker Tests
	
	// Tests to confirm that the Meal initializer returns when no name or a negative rating is provided.
	func testMealInitialization() {
		let managedObjectContext = setUpInMemoryManagedObjectContext()
		let entity = NSEntityDescription.insertNewObjectForEntityForName("Meal", inManagedObjectContext: managedObjectContext)
		
		// TODO: convert using CoreData
		
		// Success case
		//let potentialItem = Meal(name: "Newest Meal", photo: nil, rating: 5)
		//XCTAssertNotNil(potentialItem)
		
		// Failure cases.
		//let noName = Meal(name: "", photo: nil, rating: 0)
		//XCTAssertNil(noName, "Empty name is invalid")
		
		//let badRating = Meal(name: "Really bad rating", photo: nil, rating: -1)
		//XCTAssertNil(badRating, "Negative ratings are invalid, be positive")
	}
	
	func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
		let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!
		
		let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
		
		do {
			try persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
		} catch {
			print("Adding in-memory persistent store coordinator failed")
		}
		
		let managedObjectContext = NSManagedObjectContext()
		managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
		
		return managedObjectContext
	}
}
