//
//  MessageAudioCell.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 05/07/5 Reiwa.
//

import Foundation
import UIKit
import AVFoundation
import SnapKit

class MessageAudioCell: BaseMessageTableViewCell, AVAudioPlayerDelegate {
    private lazy var btnPlay: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "play.fill"), for: .normal)
        btn.addTarget(self, action: #selector(tapPlayAudio), for: .touchUpInside)
        return btn
    }()
    
    private lazy var lbDuration: UILabel = {
        let lb = UILabel()
        lb.textColor = .black
        lb.textAlignment = .center
        lb.font = UIFont.systemFont(ofSize: 15)
        return lb
    }()
    
    private var slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumTrackTintColor = .gray
        slider.setThumbImage(UIImage(named: "ic_play_circle")?.resize(with: CGSize(width: 20, height: 20)), for: .normal)
        slider.addTarget(self, action: #selector(sliderDidChangeValue), for: .valueChanged)
        return slider
    }()
    
    private lazy var stvAudio: UIStackView = {
        let stv = UIStackView()
        [btnPlay, slider, lbDuration].forEach { sub in
            stv.addArrangedSubview(sub)
        }
        stv.axis = .horizontal
        stv.alignment = .center
        stv.distribution = .fill
        stv.spacing = 5
        return stv
    }()
    
    let player = AVPlayer()
    private var timeObserver: Any?
    var item: MessageModel?
    var audioPlayer: AVAudioPlayer?
    var timeRecord = 0
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .medium
        indicator.isHidden = true
        indicator.stopAnimating()
        return indicator
    }()
    
    override func prepareForReuse() {
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        self.slider.value = 0
    }
    
    override func setUpView() {
        super.setUpView()
        
        self.vContentMessage.addSubview(stvAudio)
        self.btnPlay.addSubview(activityIndicator)
        
        self.vContentMessage.snp.makeConstraints { make in
            make.width.equalTo(self).multipliedBy(0.65)
        }
        self.stvAudio.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-5)
        }
        
        self.btnPlay.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        self.activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(10)
        }
    }
    
    override func configure(item: MessageModel, user: UserModel, indexPath: IndexPath) {
        super.configure(item: item, user: user, indexPath: indexPath)
        
        self.item = item
        self.btnPlay.tintColor = item.senderID != self.uid ? Constants.Color.mainColor : .white
        self.slider.minimumTrackTintColor = item.senderID != self.uid ? Constants.Color.mainColor : .white
        self.lbDuration.textColor = item.senderID != self.uid ? Constants.Color.mainColor : .white
        self.activityIndicator.color = item.senderID != self.uid ? Constants.Color.mainColor : .white
        self.lbDuration.text = Utilitis.shared.convertDurationToTime(duration: item.duration ?? 0.0)
        
    }
    

    func loadAudio(url: URL) {
        self.startIndicator()
        DispatchQueue.global(qos: .background).async {
            // Khởi tạo AVPlayer với đường dẫn URL của video
            let asset = AVAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            self.player.replaceCurrentItem(with: playerItem)
            self.player.volume = 1.0
            self.player.play()
            DispatchQueue.main.async {
                self.addObserverPeriodicTime()
            }
        }
    }
    
    func addObserverPeriodicTime() {
        let interval = CMTime(value: 1, timescale: 1)
//        var duration = 0.0
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            if self?.activityIndicator.isAnimating == true {
                self?.stopIndicator()
            }
            self?.updateVideoPlayerState(progressTime: time)
//            guard let self = self else {
//                return
//
//            }
//            if self.activityIndicator.isAnimating {
//                self.stopIndicator()
//            }
//            if duration > 0 {
//                let currentTime = time.seconds
//                self.progressView.progress = Float(currentTime / duration)
//                if currentTime == duration {
//                    self.pauseVideo()
//                } else {
//                    self.lbDuration.text = Utilitis.shared.convertDurationToTime(duration: duration - currentTime)
//                }
//
//            } else {
//                duration = self.player.currentItem?.duration.seconds ?? 0.0
//            }
        }
    }
    
    func updateVideoPlayerState(progressTime: CMTime) {
        guard let duration = player.currentItem?.duration else { return }
        let timeRemaining = duration - progressTime
        guard !(timeRemaining.seconds.isNaN || timeRemaining.seconds.isInfinite) else {
            return
        }
        timeRecord = Int(duration.seconds)
        let remainTime = Int(timeRemaining.seconds)
        update(second: remainTime)
    }
    
    func update(second: Int) {
//        let time = (second >= 0) ? second : timeRecord
        let progress:Float = Float((timeRecord - second))/Float(timeRecord )
        lbDuration.text = Video.shared.formatTimeVideo(time: second)
        slider.value = progress
        self.layoutIfNeeded()
        if second == 0 {
            pauseVideo()
        }
    }
    
    
    public func playVideo() {
        guard let audioURL = URL(string: item?.fileURL ?? "") else {
            return
        }
        self.loadAudio(url: audioURL)
//        self.playAudioFromURL(audioURL: item?.fileURL ?? "")
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
    
    private func startIndicator() {
        self.activityIndicator.isHidden = false
        self.btnPlay.setImage(nil, for: .normal)
        self.activityIndicator.startAnimating()
    }

    private func stopIndicator() {
        self.activityIndicator.isHidden = true
        self.btnPlay.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        self.activityIndicator.stopAnimating()
        self.setPlayImage(isPlay: true)
    }
    
    @objc func tapPlayAudio() {
        if player.rate == 1 {
            pauseVideo()
        } else {
            if slider.value == 1 {
                self.player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
            }
            playVideo()
        }
    }
    
    @objc private func updateSlider() {
        // Lấy giá trị hiện tại của thời gian phát của video
        let currentTime = player.currentItem?.currentTime().seconds ?? 0.0
        // Cập nhật giá trị của slider trên luồng chính
        DispatchQueue.main.async {
            self.slider.value = Float(currentTime)
        }
    }
    
    @objc func sliderDidChangeValue() {
        // Chuyển đổi giá trị của slider thành thời gian phát của video
        let time = CMTime(seconds: Double(self.slider.value * Float(timeRecord)), preferredTimescale: 1)
        
        // Chuyển đổi thời gian phát thành khoảng thời gian mà player cần bắt đầu phát từ đó
        player.seek(to: time)
    }
}
