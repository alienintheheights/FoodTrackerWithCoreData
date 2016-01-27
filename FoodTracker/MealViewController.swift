//
//  MealViewController.swift
//  FoodTracker
//
//  Created by Mr. Shoe on 1/5/16.
//  Copyright © 2016 Thinking Dog. All rights reserved.
//

import CoreData
import UIKit

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {	// MARK: Properties
	
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var photoImageView: UIImageView!
	@IBOutlet weak var ratingControl: RatingControl!
	
	@IBOutlet weak var saveButton: UIBarButtonItem!
	
	/*
	This value is either passed by `MealTableViewController` in `prepareForSegue(_:sender:)`
	or constructed as part of adding a new meal.
	*/
	var meal: Meal?
	
	var managedObjectContext: NSManagedObjectContext!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Handle the text field’s user input through delegate callbacks.
		nameTextField.delegate = self
		
		// Set up views if editing an existing Meal.
		if let meal = meal {
			navigationItem.title = meal.valueForKey("name") as? String
			nameTextField.text   = meal.valueForKey("name") as? String
			photoImageView.image = meal.valueForKey("photo") as? UIImage
			ratingControl.rating = (meal.valueForKey("rating") as? NSNumber)!
		}
		
		// Enable the Save button only if the text field has a valid Meal name.
		checkValidMealName()
	}
	
	
	
	// MARK: UITextFieldDelegate
	func textFieldDidBeginEditing(textField: UITextField) {
		// Disable the Save button while editing.
		saveButton.enabled = false
	}
	
	func checkValidMealName() {
		// Disable the Save button if the text field is empty.
		let text = nameTextField.text ?? ""
		saveButton.enabled = !text.isEmpty
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		// Hide the keyboard.
		textField.resignFirstResponder()
		return true
	}
	
	func textFieldDidEndEditing(textField: UITextField) {
		checkValidMealName()
		navigationItem.title = textField.text
	}
	
	// MARK: UIImagePickerControllerDelegate
	func imagePickerControllerDidCancel(picker: UIImagePickerController) {
		// Dismiss the picker if the user canceled.
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		// The info dictionary contains multiple representations of the image, and this uses the original.
		let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
		
		// Set photoImageView to display the selected image.
		photoImageView.image = selectedImage
		
		// Dismiss the picker.
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	// MARK: Navigation
	@IBAction func cancel(sender: UIBarButtonItem) {
		// Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
		let isPresentingInAddMealMode = presentingViewController is UINavigationController
		
		if isPresentingInAddMealMode {
			dismissViewControllerAnimated(true, completion: nil)
		}
		else {
			navigationController!.popViewControllerAnimated(true)
		}
	}
	
	
	// This method lets you configure a view controller before it's presented.
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if saveButton === sender {
			let name = nameTextField.text as String!
			let photo = photoImageView.image as UIImage!
			let rating = ratingControl.rating as NSNumber!
			
			if (meal != nil) { // editing
				// Update Record
				if (name != meal!.valueForKey("name") as? String) {
					meal!.setValue(name, forKey: "name")
				}
				if (photo != meal!.valueForKey("photo") as? UIImage) {
					meal!.setValue(photo, forKey: "photo")
				}
				if (rating != meal!.valueForKey("rating") as? NSNumber) {
					meal!.setValue(rating, forKey: "rating")
				}
				do {
					// Save Record
					try meal!.managedObjectContext?.save()
					
					// Dismiss View Controller
					navigationController?.popViewControllerAnimated(true)
					
				} catch {
					let saveError = error as NSError
					print("\(saveError), \(saveError.userInfo)")
					
					// Show Alert View
					showAlertWithTitle("Warning", message: "Your to-do could not be saved.", cancelButtonTitle: "OK")
				}
				
			} else {
				// Create Entity
				let entity = NSEntityDescription.entityForName("Meal", inManagedObjectContext: self.managedObjectContext)
				
				// Initialize Record
				let record = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: self.managedObjectContext)
				
				// Populate Record
				record.setValue(name, forKey: "name")
				record.setValue(photo, forKey: "photo")
				record.setValue(rating, forKey: "rating")
				do {
					// Save Record
					try record.managedObjectContext?.save()
					
					// Dismiss View Controller
					navigationController?.popViewControllerAnimated(true)
					
				} catch {
					let saveError = error as NSError
					print("\(saveError), \(saveError.userInfo)")
					
					// Show Alert View
					showAlertWithTitle("Warning", message: "Your to-do could not be saved.", cancelButtonTitle: "OK")
				}
			}
			
			
			
		}
	}
	
	
	// MARK: Actions
	@IBAction func selectImageFromPhotoLibrary(sender: UITapGestureRecognizer) {
		// Hide the keyboard.
		nameTextField.resignFirstResponder()
		
		// UIImagePickerController is a view controller that lets a user pick media from their photo library.
		let imagePickerController = UIImagePickerController()
		
		// Only allow photos to be picked, not taken.
		imagePickerController.sourceType = .PhotoLibrary
		
		// Make sure ViewController is notified when the user picks an image.
		imagePickerController.delegate = self
		
		presentViewController(imagePickerController, animated: true, completion: nil)
	}
	
	// MARK: Helper Methods
	private func showAlertWithTitle(title: String, message: String, cancelButtonTitle: String) {
		// Initialize Alert Controller
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		
		// Configure Alert Controller
		alertController.addAction(UIAlertAction(title: cancelButtonTitle, style: .Default, handler: nil))
		
		// Present Alert Controller
		presentViewController(alertController, animated: true, completion: nil)
	}
	
	
	
}

