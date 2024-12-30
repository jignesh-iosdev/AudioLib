//
//  File.swift
//  Audio_X
//
//  Created by Jigneshkumar Gangajaliya on 29/12/24.
//

import Foundation
import AVFoundation

public protocol AudioPlayerDelegate {
    func timerProgress(_ timer: TimeInterval)
}

@MainActor
public class AudioPlayer {
    let audioPlayer = AVAudioPlayer()
    private var player: AVPlayer?
    private let url: URL
    let delegate: AudioPlayerDelegate
    var asset: AVURLAsset?
    
    public init(url: URL, delegate: AudioPlayerDelegate) {
        self.delegate = delegate
        self.url = url
        initialSetup()
    }
    
    public func getMusicTimer() -> TimeInterval? {
        player?.currentItem?.asset.duration.seconds
    }
    
    public var title: String? {
        asset?.metadata.first(where: {$0.commonKey == .commonKeyTitle})?.value as? String
    }
    
    public var artist: String? {
        asset?.metadata.first(where: {$0.commonKey == .commonKeyArtist})?.value as? String
    }
    
    public var album: String? {
        asset?.metadata.first(where: {$0.commonKey == .commonKeyAlbumName})?.value as? String
    }
    
    public var playbackDurationInSeconds: TimeInterval? {
        asset?.duration.seconds
    }
    
    public var artworkImageData: Data? {
        let artworkdata = asset?.metadata.first(where: {$0.commonKey == .commonKeyArtwork})
        return artworkdata?.value as? Data
    }
    
    private func initialSetup() {
        asset = AVURLAsset(url: url)
        player = AVPlayer(playerItem: AVPlayerItem(asset: asset!))
        player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 2), // used to monitor the current play time and update slider
                                        queue: DispatchQueue.main, using: { [weak self] (progressTime) in
            
            DispatchQueue.main.async { [self] in
                self?.delegate.timerProgress(progressTime.seconds)
            }
        })
    }
    
    public func pause() {
        player?.pause()
    }
    
    public func play() {
        player?.play()
    }
}
