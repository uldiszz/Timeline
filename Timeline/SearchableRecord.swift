//
//  SearchableRecord.swift
//  Timeline
//
//  Created by Uldis Zingis on 17/10/16.
//  Copyright © 2016 Uldis Zingis. All rights reserved.
//

import Foundation

protocol SearchableRecord {
    func matchesSearchTerm(searchTerm: String) -> Bool
}
