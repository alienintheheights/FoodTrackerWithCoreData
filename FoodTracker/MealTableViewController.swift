//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by .a. on 1/7/16.
//  Copyright © 2016 Thinking Dog. All rights reserved.
//

import UIKit
import CoreData

class MealTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

	// MARK: Properties
	let ReuseIdentifierToDoCell = "MealTableViewCell"
 
	var managedObjectContext: NSManagedObjectContext!
	
	lazy var fetchedResultsController: NSFetchedResultsController = {
		// Initialize Fetch Request
		let fetchRequest = NSFetchRequest(entityName: "Meal")
		
		// Add Sort Descriptors
		let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
		fetchRequest.sortDescriptors = [sortDescriptor]
		
		// Initialize Fetched Results Controller
		let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
			managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
		
		// Configure Fetched Results Controller
		fetchedResultsController.delegate = self
		
		return fetchedResultsController
	}()
	
	// MARK: -
	// MARK: View Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Use the edit button item provided by the table view controller.
		navigationItem.leftBarButtonItem = editButtonItem()
		
		do {
			try self.fetchedResultsController.performFetch()
		} catch {
			let fetchError = error as NSError
			print("\(fetchError), \(fetchError.userInfo)")
		}
		
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if let sections = fetchedResultsController.sections {
			//print(sections.count)
			return sections.count
		}
		
		return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let sections = fetchedResultsController.sections {
			let sectionInfo = sections[section]
			//print(sectionInfo.numberOfObjects)
			return sectionInfo.numberOfObjects
			// [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects] + 1;		
		}
		
		return 0
    }
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifierToDoCell, forIndexPath: indexPath) as! MealTableViewCell
		
		// Configure Table View Cell
		configureCell(cell, atIndexPath: indexPath)
		
		return cell
	}
	
	func configureCell(cell: MealTableViewCell, atIndexPath indexPath: NSIndexPath) {
		// Fetch Record
		let record = fetchedResultsController.objectAtIndexPath(indexPath)
		
		// Update Cell
		if let name = record.valueForKey("name") as? String {
			cell.nameLabel.text = name
		}
		
		if let photo = record.valueForKey("photo") as? UIImage {
			cell.photoImageView.image = photo
		}
		
		
		if let rating = record.valueForKey("rating") as? NSNumber {
			cell.ratingControl.rating = rating
		}
	}
	
	// Override to support editing the table view.
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			// Delete the row from the data source
			
			self.tableView.beginUpdates() // Avoid NSInternalInconsistencyException
			
			// Fetch Record
			let meal = fetchedResultsController.objectAtIndexPath(indexPath) as! Meal
			
			self.managedObjectContext.deleteObject(meal);
			
			do {
				try self.managedObjectContext.save()
			} catch {
				let fetchError = error as NSError
				print("\(fetchError), \(fetchError.userInfo)")
			}
			
			// Delete the (now empty) row on the table
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
			
			
			self.tableView.endUpdates()
			
		} else if editingStyle == .Insert {
			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
		}
	}
	
	// Override to support conditional editing of the table view.
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}

	@IBAction func unwindToMealList(sender: UIStoryboardSegue) {
		//if let sourceViewController = sender.sourceViewController as? MealViewController {
			if let selectedIndexPath = tableView.indexPathForSelectedRow {
				// Update an existing meal.
				//meals[selectedIndexPath.row] = meal
				tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
			}
			else {
				// Add a new meal.
				//let newIndexPath = NSIndexPath(forRow: [tableView.indexPathForSelectedRow], inSection: 0)
				//meals.append(meal)
				//tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
			}
			
		//}
	}
	
	
	// MARK: NSFetchedResultsControllerDelegate
	
	func controllerWillChangeContent(controller: NSFetchedResultsController) {
		self.tableView.beginUpdates()
	}
	
	func controller(controller: NSFetchedResultsController,
		didChangeObject anObject: AnyObject,
		atIndexPath indexPath: NSIndexPath?,
		forChangeType type: NSFetchedResultsChangeType,
		newIndexPath: NSIndexPath?)
	{
		switch(type) {
			
		case .Insert:
			if let newIndexPath = newIndexPath {
				tableView.insertRowsAtIndexPaths([newIndexPath],
					withRowAnimation:UITableViewRowAnimation.Fade)
			}
			
		case .Delete:
			if let indexPath = indexPath {
				tableView.deleteRowsAtIndexPaths([indexPath],
					withRowAnimation: UITableViewRowAnimation.Fade)
			}
			
		case .Update:
			if let _ = indexPath {
				// TODO
				print("Configure update cell here")
			}
			
		case .Move:
			if let indexPath = indexPath {
				if let newIndexPath = newIndexPath {
					tableView.deleteRowsAtIndexPaths([indexPath],
						withRowAnimation: UITableViewRowAnimation.Fade)
					tableView.insertRowsAtIndexPaths([newIndexPath],
						withRowAnimation: UITableViewRowAnimation.Fade)
				}
			}
		}
	}
	
	func controller(controller: NSFetchedResultsController,
		didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
		atIndex sectionIndex: Int,
		forChangeType type: NSFetchedResultsChangeType)
	{
		switch(type) {
			
		case .Insert:
			tableView.insertSections(NSIndexSet(index: sectionIndex),
				withRowAnimation: UITableViewRowAnimation.Fade)
			
		case .Delete:
			tableView.deleteSections(NSIndexSet(index: sectionIndex),
				withRowAnimation: UITableViewRowAnimation.Fade)
			
		default:
			break
		}
	}
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		tableView.endUpdates()
	}
	
	// MARK: - Navigation
 
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		
		if segue.identifier == "ShowDetail" {
			let mealDetailViewController = segue.destinationViewController as! MealViewController
			mealDetailViewController.managedObjectContext = managedObjectContext
			// note: ! means if the cast fails, the app will crash. Just an FYI
			if let indexPath = tableView.indexPathForSelectedRow {
				// Fetch Record
				let meal = fetchedResultsController.objectAtIndexPath(indexPath) as! Meal
				// Configure View Controller
				mealDetailViewController.meal = meal
			}
			
		}
		else if segue.identifier == "AddItem" {
			let nav = segue.destinationViewController as! UINavigationController
			let mealDetailViewController = nav.topViewController as! MealViewController
			mealDetailViewController.managedObjectContext = managedObjectContext

		}
	}
	
}
