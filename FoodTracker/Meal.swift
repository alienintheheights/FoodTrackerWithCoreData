//
//  Meal.swift
//  FoodTracker
//
//  Created by Mr. Shoe on 1/8/16.
//  Copyright © 2016 Thinking Dog. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct MealKeys {
	var name: String
	var photo: UIImage?
	var rating: NSNumber
}

@objc(Meal)
class Meal: NSManagedObject {
	@NSManaged var name: String!
	@NSManaged var photo: UIImage?
	@NSManaged var rating: NSNumber

	
	override var description: String {
		return "name: \(name)" +
			"rating: \(rating)"
	}
	
	
	
}
