//
//  GameViewController.swift
//  MemoryGame
//
//  Created by Daniel Tsirulnikov on 19.3.2016.
//  Copyright © 2016 Daniel Tsirulnikov. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MemoryGameDelegate {

    // MARK: Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!

    let gameController = MemoryGame()
    var timer:NSTimer?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameController.delegate = self
        resetGame()
    }

    func resetGame() {
        if timer?.valid == true {
            timer?.invalidate()
            timer = nil
        }
        collectionView.userInteractionEnabled = false
        collectionView.reloadData()
        timerLabel.text = String(format: "%@: ---", NSLocalizedString("TIME", comment: "time"))
    }
    
    @IBAction func didPressPlayButton() {
        if gameController.isPlaying {
            resetGame()
            playButton.setTitle(NSLocalizedString("Play", comment: "play"), forState: .Normal)
        } else {
            setupNewGame()
            playButton.setTitle(NSLocalizedString("Stop", comment: "stop"), forState: .Normal)
        }
    }
    
    func setupNewGame() {
        let cardsData:[UIImage] = [
            UIImage(named: "brand1")!,
            UIImage(named: "brand2")!,
            UIImage(named: "brand3")!,
            UIImage(named: "brand4")!,
            UIImage(named: "brand5")!,
            UIImage(named: "brand6")!
        ];
        
        gameController.newGame(cardsData)
    }
    
    func gameTimerAction() {
        timerLabel.text = String(format: "%@: %.0fs", NSLocalizedString("TIME", comment: "time"), gameController.elapsedTime)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameController.numberOfCards > 0 ? gameController.numberOfCards : 12
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cardCell", forIndexPath: indexPath) as! CardCVC
        cell.showCard(false, animted: false)

        guard let card = gameController.cardAtIndex(indexPath.item) else { return cell }
        cell.card = card

        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CardCVC

        if cell.shown { return }
        gameController.didSelectCard(cell.card)
        
        collectionView.deselectItemAtIndexPath(indexPath, animated:true)
    }
    
    // MARK: - UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        //let numberOfColumns:Int = self.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
        
        let itemWidth: CGFloat = CGRectGetWidth(collectionView.frame) / 3.0 - 15.0 //numberOfColumns as CGFloat - 10 //- (minimumInteritemSpacing * numberOfColumns))

        return CGSizeMake(itemWidth, itemWidth)
    }
    
    // MARK: - MemoryGameDelegate

    func memoryGameDidStart(game: MemoryGame) {
        collectionView.reloadData()
        collectionView.userInteractionEnabled = true

        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "gameTimerAction", userInfo: nil, repeats: true)

    }

    func memoryGame(game: MemoryGame, showCards cards: [Card]) {
        for card in cards {
            let index = gameController.indexForCard(card)
            let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection:0)) as! CardCVC
            cell.showCard(true, animted: true)
        }
    }
    
    func memoryGame(game: MemoryGame, hideCards cards: [Card]) {
        for card in cards {
            let index = gameController.indexForCard(card)
            let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection:0)) as! CardCVC
            cell.showCard(false, animted: true)
        }
    }

    
    func memoryGameDidEnd(game: MemoryGame, elapsedTime: NSTimeInterval) {
        timer?.invalidate()

        let alertController = UIAlertController(
            title: NSLocalizedString("Hurrah!", comment: "title"),
            message: String(format: "%@ %.0fs", NSLocalizedString("You finished the game in", comment: "message"), gameController.elapsedTime),
            preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Dismiss", comment: "dismiss"), style: .Cancel) { [weak self] (action) in
            self?.resetGame()
        }
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true) { }
        

    }
    


}

