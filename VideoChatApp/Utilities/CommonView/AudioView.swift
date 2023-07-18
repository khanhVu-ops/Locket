//
//  AudioView.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 18/04/5 Reiwa.
//

import Foundation
import AVFoundation
import UIKit
import SnapKit
protocol AudioViewProtocol: NSObject {
    func didTapBtnDeleteRecording()
}
class AudioView: UIView {
    
    var audioRecorder: AVAudioRecorder?
    let recFormat = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: 44100, channels: 1, interleaved: true)
    let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
    var recordingSession: AVAudioSession?
    var audioURL: URL!
    var duration = 0.0
    var updateTimer: Timer?
    let scrollView = UIScrollView()
    var waveformView = WaveformView()
    
    weak var delegate: AudioViewProtocol?
    var actionCancel: (()->Void)?
    lazy var btnDelete: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.setImage(UIImage(systemName: "trash.fill"), for: .normal)
        btn.tintColor = RCValues.shared.color(forKey: .appPrimaryColor)
        btn.addTarget(self, action: #selector(btnDeleteTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var btnStop: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(btnStopRecordingTapped), for: .touchUpInside)
        return btn
    }()
    
    lazy var lbTimer: UILabel = {
        let lb = UILabel()
        lb.backgroundColor = .clear
        lb.textColor = .white
        lb.text = "00:00"
        lb.font = UIFont.systemFont(ofSize: 10)
        lb.textAlignment = .center
        return lb
    }()
    private lazy var vRecording: UIView = {
        let v = UIView()
        [btnStop, scrollView, lbTimer].forEach { sub in
            v.addSubview(sub)
        }
        v.addConnerRadius(radius: 10)
        v.backgroundColor = RCValues.shared.color(forKey: .appPrimaryColor)
        return v
    }()
    
    init(height: CGFloat) {
        super.init(frame: .zero)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        [btnDelete, vRecording].forEach { sub in
            self.addSubview(sub)
        }
        
        btnDelete.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.width.equalTo(btnDelete.snp.height).multipliedBy(1)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        vRecording.snp.makeConstraints { make in
            make.leading.equalTo(self.btnDelete.snp.trailing).offset(10)
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-5)
        }
        
        btnStop.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(btnDelete.snp.height).multipliedBy(1)
            make.centerY.equalToSuperview()
        }
        
        lbTimer.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-10)
        }
        self.scrollView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(self.btnStop.snp.trailing).offset(5)
            make.trailing.equalTo(self.lbTimer.snp.leading).offset(-5)

        }
        scrollView.isUserInteractionEnabled = false
        scrollView.addSubview(waveformView)
        waveformView.backgroundColor = .clear
        waveformView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
            make.width.equalTo(10000)
            make.height.equalTo(height)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    let audioPlayer = AVAudioPlayer()

    func startRecording() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers, .allowBluetoothA2DP, .allowAirPlay])
            try recordingSession?.setActive(true)
            try recordingSession?.setPreferredSampleRate(44100)
            self.audioURL = getDocumentsDirectory().appendingPathComponent("recording.m4a")
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            audioRecorder?.record()
            print("start recording")
            startUpdateTimer()
        } catch {
            print(error)
        }
    }
    
    func stopRecording() {
        self.btnStop.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        audioRecorder?.stop()
        audioRecorder = nil
        stopUpdateTimer()
        self.waveformView.clear()
        self.duration = 0.0
        self.points = 0
        do {
            try recordingSession?.setCategory(.playback, mode: .default, options: [])
        } catch {
            print(error)
        }
        print("stop recording")
    }
    
    func startUpdateTimer() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { [weak self] (_) in
            guard let self = self else {
                return
            }
            self.duration += 0.1
            let minutes = Int(self.duration / 60)
            let seconds = Int((self.duration.truncatingRemainder(dividingBy: 60)))
            self.lbTimer.text = String(format: "%02d:%02d", minutes, seconds)
            self.updateMeters()
        })
    }
    
    func stopUpdateTimer() {
        if updateTimer != nil {
            updateTimer?.invalidate()
            updateTimer = nil
        }
    }
    var points = 0
    func updateMeters() {
        audioRecorder?.updateMeters()
        guard let averagePower = (audioRecorder?.averagePower(forChannel: 0)) else {
            return
        }
        let waveformHeight = computeWaveformHeight(forAveragePower: averagePower)
        let bottomOffset = CGRect(x: CGFloat((points) * 4), y: 0, width: 1, height: 1)
        points += 1
        scrollView.scrollRectToVisible(bottomOffset, animated: true)
        waveformView.update(withWaveformHeight: waveformHeight)
    }
    
    func computeWaveformHeight(forAveragePower averagePower: Float) -> CGFloat {
        var height = 0.2
        if averagePower < -55 {
            height = 0.2
        } else if averagePower < -40, averagePower > -55 {
            height = CGFloat((averagePower+56)/3)
        }else if averagePower < -20, averagePower > -40 {
            height = CGFloat((averagePower+41)/2)
        }else if averagePower < -10, averagePower > -20 {
            height = CGFloat((averagePower+21)*5)
        } else {
            height = CGFloat((averagePower+20)*4)
        }
        return height

    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    @objc func btnDeleteTapped() {
        self.stopRecording()
        if let actionCancel = actionCancel {
            actionCancel()
        }
    }
    
    @objc func btnStopRecordingTapped() {
        guard let audioRecorder = audioRecorder else {
            return
        }
        if audioRecorder.isRecording {
            pauseRecording()
        } else {
            continueRecording()
        }
    }
    
    private func pauseRecording() {
        self.audioRecorder?.pause()
        self.stopUpdateTimer()
        self.btnStop.setImage(UIImage(systemName: "play.fill"), for: .normal)
    }
    
    private func continueRecording() {
        self.audioRecorder?.record()
        self.startUpdateTimer()
        self.btnStop.setImage(UIImage(systemName: "stop.fill"), for: .normal)
    }
}
