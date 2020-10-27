//
//  ViewController.swift
//  uptodd
//
//  Created by AAYUSH on 22/10/20.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController,AVAudioPlayerDelegate {

    @IBOutlet weak var collectionV: UICollectionView!
    var arrData = [Songs]()
    var player:AVAudioPlayer!
    var position = 0
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var playerImageV: UIImageView!
    @IBOutlet weak var playerSongName: UILabel!
    @IBOutlet weak var playerPlayPauseBtn: UIButton!
    
    @IBOutlet weak var playerViewBottomAnchor: NSLayoutConstraint!
    @IBOutlet weak var playerViewcenterX: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arrData = [
            Songs(name: "Animals", artistName: "aaa", songString: "Animals", imageString: "5"),
            Songs(name: "Hello", artistName: "bbb", songString: "Hello", imageString: "6"),
            Songs(name: "Levels", artistName: "ccc", songString: "Levels", imageString: "7"),
            Songs(name: "Someone Like You", artistName: "ddd", songString: "Someone Like You", imageString: "8"),
            Songs(name: "Wake Me Up", artistName: "eee", songString: "Wake Me Up", imageString: "5"),
            Songs(name: "Animals", artistName: "fff", songString: "Animals", imageString: "6"),
            Songs(name: "Levels", artistName: "ggg", songString: "Levels", imageString: "7")
        ]
        playerPlayPauseBtn.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }

    
    @IBAction func playPauseBtnClick(_ sender: UIButton) {
        if player.isPlaying {
            print("is playing")
            player.pause()
            playerPlayPauseBtn.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
        }else{
            print("not playing")
            player.play()
            playerPlayPauseBtn.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    @IBAction func backwordBtnClick(_ sender: UIButton) {
        if position > 0{
            position = position - 1
            playSong(arrPosition: position)
            
        }else{
            print("first position")
            playSong(arrPosition: position)
        }
    }
    @IBAction func forwardBtnClick(_ sender: UIButton) {
        if position < self.arrData.count{
            position = position + 1
            playSong(arrPosition: position)
        }else{
            print("last position")
            playSong(arrPosition: position)
        }
    }
    
    
    func playSong(arrPosition:Int){
        print("arrPosition = ",arrPosition)
        playerPlayPauseBtn.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
        playerImageV.image = UIImage(imageLiteralResourceName: self.arrData[arrPosition].imageString)
        playerSongName.text = self.arrData[arrPosition].name
        
        let soundurl = Bundle.main.url(forResource: self.arrData[arrPosition].songString, withExtension: "mp3")
        do{
            player = try AVAudioPlayer(contentsOf: soundurl!)
        }
        catch{
            print(error.localizedDescription)
        }
        player?.play()
    }

}


extension ViewController:UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.arrData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionV.dequeueReusableCell(withReuseIdentifier: "musicCell", for: indexPath)as! MusicCollectionViewCell
        cell.imageV.image = UIImage(imageLiteralResourceName: self.arrData[indexPath.row].imageString)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        position = indexPath.row
        playSong(arrPosition: indexPath.row)
        
    }
    
}




extension ViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130, height: 130)
    }
}
