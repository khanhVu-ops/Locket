//
//  MessageAudioTableViewCell.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 18/04/5 Reiwa.
//

import UIKit
import AVFoundation
class MessageAudioTableViewCell: UITableViewCell {

    @IBOutlet weak var stv: UIStackView!
    @IBOutlet weak var vContent: UIView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var lbDuration: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    
    let player = AVPlayer()
    private var timeObserver: Any?
    var item: MessageModel?
    var bombSoundEffect: AVAudioPlayer?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setUpView()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        timeObserver = nil
        progressView.progress = 0
    }
    
    func setUpView() {
        self.vContent.addConnerRadius(radius: 15)
        self.vContent.addBorder(borderWidth: 1.5, borderColor: Constants.Color.mainColor)
        self.lbTime.backgroundColor = UIColor(hexString: "#F1F1F1")
        self.lbTime.addConnerRadius(radius: 8)
    }
    
    func configure(item: MessageModel) {
        self.item = item
        if item.senderID != UserDefaultManager.shared.getID() {
            self.stv.alignment = .leading
            self.vContent.backgroundColor = .white
            self.btnPlay.tintColor = Constants.Color.mainColor
            self.progressView.progressTintColor = Constants.Color.mainColor
            self.lbDuration.textColor = Constants.Color.mainColor
        } else {
            self.stv.alignment = .trailing
            self.vContent.backgroundColor = Constants.Color.mainColor
            self.btnPlay.tintColor = .white
            self.progressView.progressTintColor = .white
            self.lbDuration.textColor = .white
        }
        self.lbTime.text = convertToString(timestamp: item.created!)
        guard let audioURL = URL(string: item.audioURL ?? "") else {
            return
        }
        self.loadAudio(url: audioURL)
    }
    
    func loadAudio(url: URL) {
        DispatchQueue.global(qos: .background).async {
            // Khởi tạo AVPlayer với đường dẫn URL của video
            let asset = AVAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            self.player.replaceCurrentItem(with: playerItem)
            self.player.volume = 0.9
            DispatchQueue.main.async {
                self.addObserverPeriodicTime()
            }
        }
        
    }
    
    func addObserverPeriodicTime() {
        let interval = CMTime(value: 1, timescale: 1)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            if let item = self.item {
                if item.duration! > 0 {
                    let currentTime = time.seconds
                    if currentTime == item.duration {
                        self.pauseVideo()
                        self.player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
                    } else {
                        self.progressView.progress = Float(currentTime / item.duration!)
                        let minutes = Int(currentTime / 60)
                        let seconds = Int(currentTime.truncatingRemainder(dividingBy: 60))
                        self.lbDuration.text = String(format: "%02d:%02d", minutes, seconds)
                    }

                } else {
                    item.duration = self.player.currentItem?.duration.seconds ?? 10.0
                }
            } else {
                print("NO tiems")
            }
        }
    }
    
    public func playVideo() {
        player.play()
        self.setPlayImage(isPlay: true)
    }

    public func pauseVideo() {
        player.pause()
        self.setPlayImage(isPlay: false)
    }
    private func setPlayImage(isPlay: Bool) {
        if isPlay {
            self.btnPlay.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        } else {
            self.btnPlay.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    @IBAction func btnPlayAudioTapped(_ sender: Any) {
        if player.rate > 0 {
            pauseVideo()
        } else {
            playVideo()
        }
    }
}
