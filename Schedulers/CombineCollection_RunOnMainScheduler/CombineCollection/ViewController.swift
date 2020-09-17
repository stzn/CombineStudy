//
//  ViewController.swift
//  CombineCollection
//
//  Created by Shinzan Takata on 2020/07/19.
//

import UIKit

class BreedListViewController: UIViewController {
    struct Item: Hashable {
        let id: String
    }

    enum Section {
        case main
    }

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var collectionView: UICollectionView!
    private let appearance = UICollectionLayoutListConfiguration.Appearance.plain

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "List"
    }
}

