//
//  ViewController.swift
//  PZXPiPTeleprompter
//
//  Created by pzx on 2023/5/16.
//

import UIKit
import AVKit
import SnapKit

let SCREEN_WIDTH                      = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT                     = UIScreen.main.bounds.size.height

class ViewController: UIViewController {
    
    
    //画中画vc
    var pipVC: AVPictureInPictureController?
    
    //播放器
    var playerLayer: AVPlayerLayer?
    var avPlayer: AVPlayer?

    
    //画中画window
    var firstWindow : UIWindow?
    
    // 自定义view
    var pipView : UIView?
    var textView: UITextView!
    // timer
    private var displayerLink: CADisplayLink!
    
    //打开画中画按钮
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
         
        
        initAVKits()
    }

    
    func initAVKits(){
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // 处理错误
            print("处理错误")
        }
        
        let path = Bundle.main.path(forResource: "holder", ofType: "mp4")
        let sourceMovieUrl = URL(fileURLWithPath: path!)
        self.avPlayer = AVPlayer(url: sourceMovieUrl)
         playerLayer = AVPlayerLayer(player: self.avPlayer)
        playerLayer!.frame = CGRect(x: 30, y: 160, width: SCREEN_WIDTH-60, height: 40)
        playerLayer!.backgroundColor = UIColor.black.cgColor
        playerLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer!.cornerRadius = 10.0
        playerLayer!.masksToBounds = true
//        playerLayer?.fillMode = .
        self.view.layer.addSublayer(playerLayer!)
        
        
        self.pipVC = AVPictureInPictureController.init(playerLayer: self.playerLayer!)
        self.pipVC?.delegate = self;
        ///隐藏系统快进快退播放按钮进度条
        self.pipVC?.setValue(1, forKey: "controlsStyle")
        
        
        pipView = UIView()
        pipView?.backgroundColor = .orange
        
        textView = UITextView()
        textView.text = """
            文本文本开头
            这是自定义view，想放什么放什么
            这是自定义view，想放什么放什么
            这是自定义view，想放什么放什么
            这是自定义view，想放什么放什么
            这是自定义view，想放什么放什么
            文本
            文本
            文本
            文本文本结尾
            """
        textView.backgroundColor = .black
        textView.textColor = .white
        textView.isUserInteractionEnabled = false
        pipView!.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        
        
    }

    @IBAction func startButtonPressed(_ sender: Any) {
        
        if (AVPictureInPictureController.isPictureInPictureSupported()) {
            
            if (self.pipVC?.isPictureInPictureActive == true) {
                
                self.pipVC?.stopPictureInPicture()
                
            } else {
                
                self.pipVC?.startPictureInPicture()

            }
            
        } else {
            
            print("不支持画中画");
        }
        
        
    }
    
    
    ///滚动部分
    // 开始滚动
    private func startTimer() {
        if displayerLink != nil {
            displayerLink.invalidate()
            displayerLink = nil
        }
        displayerLink = CADisplayLink.init(target: self, selector: #selector(move))
        displayerLink.preferredFramesPerSecond = 30
        let currentRunloop = RunLoop.current
        // 常驻线程
        currentRunloop.add(Port(), forMode: .default)
        displayerLink.add(to: currentRunloop, forMode: .default)
    }
    
    // 停止滚动
    private func stopTimer() {
        if displayerLink != nil {
            displayerLink.invalidate()
            displayerLink = nil
        }
    }
    
    @objc private func move() {
        let offsetY = textView.contentOffset.y
        textView.contentOffset = .init(x: 0, y: offsetY + 0.2)
        if textView.contentOffset.y > textView.contentSize.height {
            textView.contentOffset = .zero
        }
    }
}


extension ViewController :  AVPictureInPictureControllerDelegate {
    
    //即将开启画中画
    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {

        print("画中画初始化后11：\(UIApplication.shared.windows)")


        firstWindow = UIApplication.shared.windows.first
        
        pipView?.frame = CGRect(x: 0, y: 0, width: (firstWindow?.frame.size.width)!, height: (firstWindow?.frame.size.height)!)
        
        firstWindow?.addSubview(self.pipView!)
        pipView!.snp.makeConstraints { (make) -> Void in
            make.edges.equalToSuperview()
        }

        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene

        print("画中画初始化后22：\(windowScene!.windows)")

//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//             firstWindow = windowScene.windows.first
//                // 使用 window 进行操作
//            firstWindow?.addSubview(self.pipView!)
//
//
//        }
        
    }
    
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        startTimer()
        // 打印所有window
//        print("画中画弹出后：\(UIApplication.shared.windows)")

        
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        stopTimer()
    }
    
    
}

