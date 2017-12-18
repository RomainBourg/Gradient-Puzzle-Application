//
//  ColorCell.swift
//  projet_Romain_Bourg
//
//  Created by esirem on 17/11/2017.
//  Copyright © 2017 esirem. All rights reserved.
//

import UIKit

class ColorCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
    var valeur: Int = 0
    
    func echanger(c: ColorCell) {
        let v : Int = c.valeur
        c.valeur = self.valeur
        self.valeur = v
        
        let color : UIColor = c.backgroundColor!
        c.backgroundColor = self.backgroundColor
        self.backgroundColor = color
        
    }
    
}
