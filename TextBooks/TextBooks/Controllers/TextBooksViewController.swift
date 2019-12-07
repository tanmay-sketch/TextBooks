//
//  TextBooksViewController.swift
//  TextBooks
//
//  Created by Akshay on 17/10/19.
//  Copyright © 2019 Tanmay Grandhisiri. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseFirestore

class TextBooksViewController: UIViewController {

    private var books = [Book]()
    private var originalBooks = [Book]()
    private let db = Firestore.firestore()

    var filterGrade: Int?
    
    @IBOutlet var collectionView: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db.collection("/books /").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    document.data().forEach { item in
                        if let value = item.value as? [String: Any] {
                            let book = Book(with: value)
                            self.originalBooks.append(book)
                            self.books.append(book)
                        }
                        self.collectionView?.reloadData()
                    }
                }
            }
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFilter" {
            if let filterController = (segue.destination as? UINavigationController)?.viewControllers.first as? BooksFilterViewController {
                filterController.grades = getGradesFromBooks()
                filterController.filterGrade = self.filterGrade
                filterController.gradeSelected = { [weak self] grade in
                    self?.filterGrade = grade
//                    print("Grade selected is \(grade)")
                    self?.showBooksFor(grade: grade)
                }
            }
        } else if segue.identifier == "showBookDetails" {
            let cell = sender as! UICollectionViewCell
            let indexPath = collectionView!.indexPath(for: cell)!
        
            let detailsController = segue.destination as! BookDetailsViewController
            detailsController.book = books[indexPath.item]
        }
        
    }
    
    private func getGradesFromBooks() -> [Int] {
        var grades = Set<Int>()
        for book in originalBooks {
            grades = grades.union(book.grade)
        }
        return Array(grades.sorted())
    }
    
    private func showBooksFor(grade: Int?) {
        if let gradeSelected = grade {
            books = originalBooks.filter { book -> Bool in
                return book.grade.contains(gradeSelected)
            }
        } else {
            books.removeAll()
            books.append(contentsOf: originalBooks)
        }
        collectionView?.reloadData()
        print(books.map({$0.title}))
    }

}


extension TextBooksViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookCell", for: indexPath) as! CollectionViewCell
        let book = books[indexPath.item]
        cell.configure(book: book)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cell Selected", indexPath.item)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let totalWidth = collectionView.bounds.width-30;
        
        let eachCellWidth = totalWidth/2
        
        let size = CGSize(width: eachCellWidth, height: eachCellWidth)
        return size
    }
    
}
