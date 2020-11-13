//
//  ViewController.swift
//  uptodd
//
//  Created by AAYUSH on 22/10/20.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController,AVAudioPlayerDelegate,UIGestureRecognizerDelegate {

    @IBOutlet weak var collectionV: UICollectionView!
    var arrData = [Songs]()
    var player:AVPlayer!
    var position = 0
    @IBOutlet weak var playerView: UIView!
    @IBOutlet weak var playerImageV: UIImageView!
    @IBOutlet weak var playerSongName: UILabel!
    @IBOutlet weak var playerPlayPauseBtn: UIButton!
    @IBOutlet weak var playerSlider: UISlider!
    
    var nowPlayingInfo = [String : Any] ()
    let commandCenter = MPRemoteCommandCenter.shared()
    
    var playerItem: AVPlayerItem!
    var clocktimer = Timer()

    var isClockTimerOn:Bool = false
    private var clockTimeInMinute = Int()
    private var timer : DispatchSourceTimer?
    
    
    @IBOutlet weak var dropDownView: UIView!
    @IBOutlet weak var tableV: UITableView!
    var arrTime:[Int] = [5, 10, 15]
    var count:Int = 0 // for hide unhide dropDownView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadViewfunctionality()
        setupAudioSession()
        setupLongGestureRecognizerOnCollection()
    }
    
    
    
    func setupLongGestureRecognizerOnCollection() {
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longPressedGesture.minimumPressDuration = 0.5
        longPressedGesture.delegate = self
        longPressedGesture.delaysTouchesBegan = true
        collectionV.addGestureRecognizer(longPressedGesture)
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state != .began) {
            return
        }
        let p = gestureRecognizer.location(in: collectionV)

        if let indexPath = collectionV.indexPathForItem(at: p) {
            var detailVC = self.storyboard?.instantiateViewController(withIdentifier: "dvc")as!DetailViewController
            detailVC.songData = self.arrData[indexPath.row]
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func loadViewfunctionality(){
        playerSlider.addTarget(self, action: #selector(playbackSliderValueChanged(_:)), for: .valueChanged)
        
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
        playerView.isHidden = true
        
        setUpNotifications()
        
        dropDownView.isHidden = true
    }
    
    func setUpNotifications(){
//      Pause music when call begin, play music when call ends.
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(notification:)), name: AVAudioSession.interruptionNotification, object: nil)

    }
    
    @objc func handleInterruption(notification:NSNotification){
        guard let userInfo = notification.userInfo,
              let typeInt = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeInt) else { return }

        switch type {
        case .began:
        // Pause your player
            if player != nil{
                self.pause()
            }else{
                print("Music player is Not using")
            }
            
        case .ended:
            if let optionInt = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionInt)
                if options.contains(.shouldResume) {
                    // Resume your player
                    if player != nil{
                        self.play()
                    }else{
                        print("Music player is Not using so not playing song ")
                    }
                    
                }
            }
        }
        
    }
    
    @IBAction func alarmClockClick(_ sender: UIButton) {
        print("alarmClockClick")
        if count == 0{
            dropDownView.isHidden = false
            count = 1
        }else{
            dropDownView.isHidden = true
            count = 0
        }
        
        
    }
    
    fileprivate func startDispatchTimer(){
        var seconds = clockTimeInMinute * 60
        print("Timer scheduled for min = \(seconds/60) min")
        let interval : DispatchTime = .now() + .seconds(seconds)
        if timer == nil {
            timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
            timer!.schedule(deadline:interval)
            timer!.setEventHandler {
                // do something when the timer fires
                self.stopDispatchTimer()
                self.isClockTimerOn = false
                print("timer=nil & timer?.cancel()")
            }
            timer!.resume()
        }
    }

    fileprivate func stopDispatchTimer(){
        DispatchQueue.main.async {
            self.pause()
        }
        timer?.cancel()
        timer = nil
    }
    
    
    @IBAction func playPauseBtnClick(_ sender: UIButton) {
        if player.rate == 1{
            pause()
        }else{
            play()
        }
    }
    
    @IBAction func backwordBtnClick(_ sender: UIButton) {
        previousSong()
    }
    
    @IBAction func forwardBtnClick(_ sender: UIButton) {
        nextSong()
    }
    
    func nextSong(){
//        used to close ClockTimer
        if isClockTimerOn{
            self.isClockTimerOn = false
            timer?.cancel()
            timer = nil
            print("timer?.cancel()  &  timer=nil")
        }
        
        
        if position < (self.arrData.count - 1){
            position = position + 1
            playSong(arrPosition: position)
        }else{
            print("last position")
            playSong(arrPosition: position)
        }
    }
    
    func previousSong(){
        if isClockTimerOn{
            self.isClockTimerOn = false
            timer?.cancel()
            timer = nil
            print("timer?.cancel()  &  timer=nil")
        }
        if position > 0{
            position = position - 1
            playSong(arrPosition: position)
        }else{
            print("first position")
            playSong(arrPosition: position)
        }
    }
    
    func play(){
        self.player.play()
        playerPlayPauseBtn.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
        setupNowPlaying()
    }
    
    func pause(){
        self.player.pause()
        playerPlayPauseBtn.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
        setupNowPlaying()
    }
    
    
    func playSong(arrPosition:Int){
        playerImageV.image = UIImage(imageLiteralResourceName: self.arrData[arrPosition].imageString)
        playerSongName.text = self.arrData[arrPosition].name
        guard let soundurl = Bundle.main.url(forResource: self.arrData[arrPosition].songString, withExtension: "mp3") else{ print("error in song url"); return }
        playerItem = AVPlayerItem(url: soundurl)
        player = AVPlayer(playerItem: playerItem)

        play()
        
        let duration : CMTime = playerItem.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        playerSlider.minimumValue = 0
        playerSlider.maximumValue = Float(seconds)
        playerSlider.isContinuous = true
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateSlider), userInfo: nil, repeats: true)
        
        setupRemoteCommandCenter()
    }
    
    
    @objc func playbackSliderValueChanged(_ playbackSlider:UISlider){
//        when we are seeking from player slider
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        player.seek(to: targetTime)
        
        if player.rate == 1{
            player.play()
        }else{
            player.pause()
        }
        
//        used to change nowPlayingInfoCenter seeker
        setupNowPlaying()
    }
    
    @objc func updateSlider(){
//        updating player slider seeking at every 0.5 sec later
        playerSlider.value = Float(playerItem.currentTime().seconds)
        
        let duration : CMTime = playerItem.asset.duration
        let seconds : Float64 = CMTimeGetSeconds(duration)
        if isClockTimerOn{
            if Int(player.currentTime().seconds) == Int(seconds){
                playSong(arrPosition: position)
            }
        }else{
            if Int(player.currentTime().seconds) == Int(seconds){
                nextSong()
            }
        }
        
    }
    
    
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.soloAmbient, mode: .default, options: .allowAirPlay)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting the AVAudioSession:", error.localizedDescription)
        }
    }

    func setupNowPlaying() {
        // Define Now Playing Info
        nowPlayingInfo[MPMediaItemPropertyTitle] = self.arrData[position].name
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = self.arrData[position].name
        nowPlayingInfo[MPMediaItemPropertyArtist] = self.arrData[position].artistName
        let image = UIImage(imageLiteralResourceName: self.arrData[position].imageString) ?? UIImage()
        nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (size) -> UIImage in
            return image
        })
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerItem.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playerItem.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        if self.player.rate == 1{
            MPNowPlayingInfoCenter.default().playbackState = .playing
        }else{
            MPNowPlayingInfoCenter.default().playbackState = .paused
        }
    }
    
    func  setupRemoteCommandCenter() {
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget {event in
            self.play()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget {event in
            self.pause()
            return .success
        }
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget {event in
            self.nextSong()
            return .success
        }
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget {event in
            self.previousSong()
            return .success
        }
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget(self, action: #selector(changeThumbSlider(_:)))
        
//        for headphones
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget{event in
            if self.player.rate == 1{
                self.pause()
            }else{
                self.play()
            }
            return .success
        }
                
    }
    
    
    @objc func changeThumbSlider ( _ event : MPChangePlaybackPositionCommandEvent) -> MPRemoteCommandHandlerStatus{
//        when we are seeking from nowPlayingInfoCenter
        let seconds = Float(TimeInterval(event.positionTime))
        let targetTime:CMTime = CMTimeMake(value: Int64(seconds), timescale: 1)
        player.seek(to: targetTime)
        
        return .success
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
        playerView.isHidden = false
        position = indexPath.row
        playSong(arrPosition: indexPath.row)
    }
    
}




extension ViewController:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 130, height: 130)
    }
}



extension ViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTime.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")as! DropDownTableViewCell
        cell.timeLbl.text = "\(self.arrTime[indexPath.row])min"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        clockTimeInMinute = self.arrTime[indexPath.row]
        isClockTimerOn = true
        startDispatchTimer()
        dropDownView.isHidden = true
        count = 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
