//
//  DetailViewController.swift
//  uptodd
//
//  Created by Vinayak Balaji Tuptewar on 27/10/20.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var detailstextview: UITextView!
    
    var songData:Songs?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageview.image = UIImage(imageLiteralResourceName: songData!.imageString)
        self.titlelabel.text = songData!.name
        self.detailstextview.text = songData!.artistName
    }
    


}
