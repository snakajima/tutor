//
//  BookModel.swift
//  aitango
//
//  Created by SATOSHI NAKAJIMA on 6/22/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Book: Hashable {
    var id: String
    var title: String
    var words: [String]
}

@Observable class BooksModel {
    public var books: [Book] = []
    private var db = Firestore.firestore()
    
    init() {
        db.collection("books")
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self else { return }
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    return
                }
                self.books = documents.compactMap { snapshot -> Book in
                    let document = snapshot.data()
                    print("doc=", document["title"] ?? "N/A", snapshot.documentID)
                    return Book(id: snapshot.documentID, title: document["title"] as! String, words: document["words"] as! [String])
                }
            }
    }
}
