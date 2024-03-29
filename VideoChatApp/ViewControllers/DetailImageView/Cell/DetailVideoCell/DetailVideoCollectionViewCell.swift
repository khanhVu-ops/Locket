//
//  DetailVideoCollectionViewCell.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 01/04/5 Reiwa.
//

import UIKit
import AVFoundation
import SnapKit
import AVKit
class DetailVideoCollectionViewCell: UICollectionViewCell {

    private var btnSpeed: UIButton = {
        let btn = UIButton()
        btn.setImage(Constants.Image.settingIcon, for: .normal)
        btn.tintColor = RCValues.shared.color(forKey: .appPrimaryColor)
        btn.backgroundColor = .white.withAlphaComponent(0.8)
        btn.addTarget(self, action: #selector(btnSpeedTapped), for: .touchUpInside)
        return btn
    }()
    
    private var slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumTrackTintColor = .gray
        slider.minimumTrackTintColor = RCValues.shared.color(forKey: .appPrimaryColor)
        slider.setThumbImage(Constants.Image.playCircleIcon.resize(with: CGSize(width: 20, height: 20)), for: .normal)
        slider.addTarget(self, action: #selector(sliderDidChangeValue), for: .valueChanged)
        return slider
    }()
    
    private var btnPlay: UIButton = {
        let btn = UIButton()
        btn.setImage(nil, for: .normal)
        btn.tintColor = RCValues.shared.color(forKey: .appPrimaryColor)
        btn.addTarget(self, action: #selector(btnPlayTapped), for: .touchUpInside)
        return btn
    }()
    
    private var lbTime: UILabel = {
        let lb = UILabel()
        lb.textColor = RCValues.shared.color(forKey: .appPrimaryColor)
        return lb
    }()
    
    private var stvStatus: UIStackView = {
        let stv = UIStackView()
        stv.distribution = .fill
        stv.alignment = .center
        stv.spacing = 10
        return stv
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .medium
        indicator.color = RCValues.shared.color(forKey: .appPrimaryColor)
        indicator.isHidden = true
        indicator.stopAnimating()
        return indicator
    }()
    var playerLayer: AVPlayerLayer?
    var player = AVPlayer()
    var item: DetailItem?
    var timeRecord = 0
    private var timeObserver: Any?
    var rate: Float = 1 {
        didSet {
            self.player.rate = rate
        }
    }
    var actionTapSpeed: ((UIButton) -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        self.addSubview(self.stvStatus)
        [btnSpeed, btnPlay, slider, lbTime].forEach { sub in
            stvStatus.addArrangedSubview(sub)
        }
        [btnSpeed, activityIndicator].forEach { sub in
            self.addSubview(sub)
        }
        self.btnSpeed.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(20)
            make.width.height.equalTo(40)
        }
        self.stvStatus.snp.makeConstraints { make in
            make.trailing.leading.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
        self.btnPlay.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
        activityIndicator.snp.makeConstraints { make in
            make.width.height.equalTo(10)
            make.centerY.equalTo(self.stvStatus.snp.centerY)
            make.leading.equalTo(self.stvStatus.snp.leading).offset(5)
        }
        setUpPreViewLayer()
    }
    
    private func setUpPreViewLayer() {
        self.playerLayer = AVPlayerLayer(player: player)
        self.playerLayer?.player = self.player
        self.playerLayer?.videoGravity = .resizeAspect
        self.playerLayer?.cornerRadius = 25
        self.playerLayer?.masksToBounds = true
        self.layer.insertSublayer(self.playerLayer!, below: self.stvStatus.layer)

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        print("reuse video")
        self.slider.value = 0
        self.lbTime.text = "00:00"
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        item = nil
        
    }

    

    func configure(item: DetailItem, viewModel: DetailImageViewModel?) {
        guard let viewModel = viewModel else {
            print("NIL")
            return
        }
        self.item = item
        self.lbTime.text = Utilitis.shared.convertDurationToTime(duration: item.duration)
        self.startIndicator()
        DispatchQueue.global(qos: .background).async {
            guard let videoURL = URL(string: item.url) else {
                return
            }
            // Khởi tạo AVPlayer với đường dẫn URL của video
            let asset = AVAsset(url: videoURL)
            let playerItem = AVPlayerItem(asset: asset)
            self.player.replaceCurrentItem(with: playerItem)
            self.player.volume = 0.9
            self.player.rate = 3
            DispatchQueue.main.async {
                self.playerLayer?.frame = CGRect(x: 20, y: 0, width: self.bounds.width-40, height: self.bounds.height)
                self.addObserverPeriodicTime()
                self.configVideo(isPlaying: item.isPlaying, currentTime: item.currentTime)
            }
        }
    }
    
    func configVideo(isPlaying: Bool, currentTime: Double) {
        // Chuyển đổi giá trị của slider thành thời gian phát của video
        let time = CMTime(seconds: currentTime, preferredTimescale: 1)
        // Chuyển đổi thời gian phát thành khoảng thời gian mà player cần bắt đầu phát từ đó
        player.seek(to: time)
    }
    
    func addObserverPeriodicTime() {
        let interval = CMTime(value: 1, timescale: 1)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            if self.activityIndicator.isAnimating {
                self.stopIndicator()
            }
            
            self.updateVideoPlayerState(progressTime: time)
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
            lbTime.text = Video.shared.formatTimeVideo(time: second)
            slider.value = progress
            self.layoutIfNeeded()
            if second == 0 {
                pauseVideo()
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
    
    public func playVideo() {
        if slider.value == slider.maximumValue {
            self.player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
        }
        player.play()
        self.setPlayImage(isPlay: true)
    }

    public func pauseVideo() {
        player.pause()
        self.setPlayImage(isPlay: false)
    }
    
    private func setPlayImage(isPlay: Bool) {
        if isPlay {
            if !activityIndicator.isAnimating {
                self.btnPlay.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            }
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
    }
    
    //MARK: objc func
    
    @objc func sliderDidChangeValue() {
        // Chuyển đổi giá trị của slider thành thời gian phát của video
        let time = CMTime(seconds: Double(self.slider.value * Float(timeRecord)), preferredTimescale: 1)
        
        // Chuyển đổi thời gian phát thành khoảng thời gian mà player cần bắt đầu phát từ đó
        player.seek(to: time)
    }
    
    @objc func btnPlayTapped() {
        if player.rate > 0 {
            pauseVideo()
            self.item?.isPlaying = false
        } else {
            playVideo()
            self.item?.isPlaying = true
        }
    }
    
    @objc func btnSpeedTapped() {
        guard let actionTapSpeed = actionTapSpeed else {
            return
        }
        actionTapSpeed(btnSpeed)
    }
}
