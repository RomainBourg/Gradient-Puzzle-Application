//
//  ViewController.swift
//  projet_Romain_Bourg
//
//  Created by esirem on 17/11/2017.
//  Copyright © 2017 esirem. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    @IBOutlet weak var labelParties: UILabel!
    @IBOutlet weak var boutonTriche: UIButton!
    @IBAction func boutonTriche(_ sender: Any) {
        triche()
    }
    
    let reuseIdentifier = "cell"
    let nbCellulesLignes = 340/34
    let nbCellulesColonnes = 630/45
    var items: [String] = []
    var celluleSelectionnee : ColorCell? = nil
    var maxMelange : Int = 1
    var data : UICollectionView? = nil
    var nbCoups : Int = 0

    var couleur1 = UIColor.black
    var couleur2 = UIColor.black
    var couleur3 = UIColor.black
    var couleur4 = UIColor.black
    
    override func viewDidLoad() {
        
        initGame()
    }
    
    func initGame()
    {
        items = []
        for i in 0...(nbCellulesLignes*nbCellulesColonnes)-1 {
            items.append("\(i)")
        }
        
        //Mise à jour du label indicateur du nombre de parties
        self.labelParties!.text = "Partie \(Int(log2(Float(maxMelange)))+1)"
        
        nbCoups = 0
        
        //Génération des 4 couleurs principales
        var hue = Double(arc4random_uniform(256))/255
        let saturation = 0.95
        let value = 0.95
        let saturation2 = 0.90
        let value2 = 0.75
        
        hue = generateHue(h: hue)
        let c1 = hsv_to_rgb(h: hue, s: saturation2, v: value)
        
        hue = generateHue(h: hue)
        let c2 = hsv_to_rgb(h: hue, s: saturation, v: value2)
        
        hue = generateHue(h: hue)
        let c3 = hsv_to_rgb(h: hue, s: saturation, v: value2)
        
        hue = generateHue(h: hue)
        let c4 = hsv_to_rgb(h: hue, s: saturation2, v: value)
        
        couleur1 = UIColor(red:CGFloat(c1.r), green:CGFloat(c1.g), blue:CGFloat(c1.b), alpha:1)
        couleur2 = UIColor(red:CGFloat(c2.r), green:CGFloat(c2.g), blue:CGFloat(c2.b), alpha:1)
        couleur3 = UIColor(red:CGFloat(c3.r), green:CGFloat(c3.g), blue:CGFloat(c3.b), alpha:1)
        couleur4 = UIColor(red:CGFloat(c4.r), green:CGFloat(c4.g), blue:CGFloat(c4.b), alpha:1)
        
        if(self.data != nil)
        {
            self.data!.reloadData()
        }
    }

    //Retourne le nombre de cellules à créer
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    //Créer une cellule pour chaque item
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.data = collectionView
        //On récupère la cellule
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! ColorCell
        
        cell.valeur = Int(indexPath.item)
        
        //On marque les cases qui ne peuvent pas êtres bougées
        switch(cell.valeur)
        {
            case 0, 9, 130, 139:
                cell.label.text = "\u{00B7}"
            default:
                cell.label.text = ""
        }
        
        //Interpolation des couleurs par rapport aux coordonnées et à la position de la cellule
        let x : Double = Double(cell.valeur%nbCellulesLignes)/Double(nbCellulesLignes-1)
        let y : Double = Double(cell.valeur/nbCellulesLignes)/Double(nbCellulesColonnes-1)
        
        let redValue = interpolate(a:UIColorToRGB(color:couleur1).r, b:UIColorToRGB(color:couleur3).r, c:UIColorToRGB(color:couleur2).r, d:UIColorToRGB(color:couleur4).r, x:x, y:y)
        let greenValue = interpolate(a:UIColorToRGB(color:couleur1).g, b:UIColorToRGB(color:couleur3).g, c:UIColorToRGB(color:couleur2).g, d:UIColorToRGB(color:couleur4).g, x:x, y:y)
        let blueValue = interpolate(a:UIColorToRGB(color:couleur1).b, b:UIColorToRGB(color:couleur3).b, c:UIColorToRGB(color:couleur2).b, d:UIColorToRGB(color:couleur4).b, x:x, y:y)
        cell.backgroundColor = UIColor(red:CGFloat(redValue)/255, green:CGFloat(greenValue)/255, blue:CGFloat(blueValue)/255, alpha:1)

        cell.layer.borderColor = UIColor.black.cgColor
        
        //Mélange des cellules
        if cell.valeur == 139
        {
            melanger()
        }
        return cell
    }

    
    //Cellule sélectionnée
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ColorCell
        if cell.valeur != 0 && cell.valeur != 9 && cell.valeur != 130 && cell.valeur != 139 {
            
            //Si on la sélectionne
            if(celluleSelectionnee == nil)
            {
                celluleSelectionnee = cell;
                cell.layer.borderWidth = 1.0
            }
                
            //Si on l'échange avec une autre
            else
            {
                cell.echanger(c: celluleSelectionnee!)
                celluleSelectionnee!.layer.borderWidth = 0.0
                celluleSelectionnee = nil;
                nbCoups += 1
                checkGagne()
            }
        }
    }
    
    //Conversion UIColor -> RGB
    func UIColorToRGB(color : UIColor) -> (r:Double, g: Double, b:Double)
    {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Double(r), Double(g), Double(b));
    }
    
    //Interpolation entre les 4 couleurs de base et une position donnée
    func interpolate(a : Double, b : Double, c : Double, d : Double, x : Double, y : Double) -> Int
    {
        let part1 : Double = Double(a*255)*(1-x)*(1-y)
        let part2 : Double = Double(b*255)*x*(1-y)
        let part3 : Double = Double(c*255)*(1-x)*y
        let part4 : Double = Double(d*255)*x*y
        return Int(part1 + part2 + part3 + part4)
    }
    
    //Conversion couleur HSV -> RGB
    func hsv_to_rgb(h : Double, s : Double, v : Double) -> (r:Double, g: Double, b:Double)
    {
        let h_i = Int(h*6)
        let f = Int(h*6) - (h_i)
        let p = v * (1 - s)
        let q = v * (1 - Double(f)*s)
        let t = v * (1 - (1 - Double(f)) * s)
        var r = 0.0
        var g = 0.0
        var b = 0.0

        switch(h_i)
        {
        case 0:
            r = v
            g = t
            b = p
            
        case 1:
            r = q
            g = v
            b = p
            
        case 2:
            r = p
            g = v
            b = t
            
        case 3:
            r = p
            g = q
            b = v
            
        case 4:
            r = t
            g = p
            b = v
        case 5:
            r = v
            g = p
            b = q
        default:
            r = 1
            g = 1
            b = 1
        }
        return (Double(r), Double(g), Double(b))
    }
    
    //Génère une teinte
    func generateHue(h : Double) -> Double
    {
        let golden_ratio_conjugate = 0.618033988749895
        var temp = h
        temp += golden_ratio_conjugate
        temp = temp.truncatingRemainder(dividingBy: 1)
        return temp
    }
    
    //Mélange les cellules
    func melanger()
    {
        //Limitation du nombre de mélange
        var n = maxMelange
        if(n > 100)
        {
            n = 100
        }
        
        for _ in 0...n        {
            let indexA = IndexPath(item: getRandomCellNotCorner(), section: 0)
            let indexB = IndexPath(item: getRandomCellNotCorner(), section: 0)
            let cellA = self.data!.cellForItem(at: indexA) as! ColorCell
            let cellB = self.data!.cellForItem(at: indexB) as! ColorCell
            cellA.echanger(c : cellB)
        }
    }
    
    //Renvoie aléatoirement une cellule qui n'est pas un coin
    func getRandomCellNotCorner() -> Int
    {
        var n = 0
        while n == 0 || n == 9 || n == 130 || n == 139
        {
            n = Int(arc4random_uniform(UInt32(nbCellulesLignes*nbCellulesColonnes)))
        }
        return n
    }
    
    func triche()
    {
        var n = Int(arc4random_uniform(UInt32(nbCellulesLignes*nbCellulesColonnes)))
        var continuer = true
        while(continuer)
        {
            let index = IndexPath(item: n, section: 0)
            let cell = self.data!.cellForItem(at: index) as! ColorCell
            if(cell.valeur == n)
            {
                n = (n+1)%(nbCellulesLignes*nbCellulesColonnes)
            }
            else
            {
                continuer = false
            }
        }
        
        let indexA = IndexPath(item: n, section: 0)
        let cellA = self.data!.cellForItem(at: indexA) as! ColorCell
        let indexB = IndexPath(item: cellA.valeur, section: 0)
        let cellB = self.data!.cellForItem(at: indexB) as! ColorCell
        cellA.echanger(c : cellB)
        nbCoups += 1
        checkGagne()
    }
    
    func checkGagne()
    {
        //On regarde si toutes les cellules sont en ordre (aka partie gagnée)
        var gagne = true
        var lastElement = 0
        for i in 1...139
        {
            let index = IndexPath(item: i, section: 0)
            let c = self.data!.cellForItem(at: index) as! ColorCell
            if lastElement > c.valeur
            {
                gagne = false
            }
            lastElement = c.valeur
        }
        
        if(gagne)
        {
            let alert = UIAlertController(title: "Partie terminée", message: "Félicitations, vous avez gagné!\n\nNombre de coups: \(nbCoups)", preferredStyle: UIAlertControllerStyle.alert)
            let actionRecommencer = UIAlertAction(title: "Continuer", style: UIAlertActionStyle.default) {
                UIAlertAction in
                self.maxMelange = self.maxMelange*2
                self.initGame()
            }
            alert.addAction(actionRecommencer)
            self.present(alert, animated: true, completion: nil)
            gagne = false
        }
    }
    
}

