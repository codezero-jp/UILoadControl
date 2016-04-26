//
//  UIRefreshControlBottom.swift
//  MovileRecrutamentoIOS
//
//  Created by Felipe Antonio Cardoso on 09/12/15.
//  Copyright © 2015 Felipe Antonio Cardoso. All rights reserved.
//

import UIKit
import Foundation

public class UILoadControl: UIControl {
    
    private var activityIndicatorView: UIActivityIndicatorView?
    
    public var heightLimit: CGFloat = 80.0
    
    public private (set) var loading: Bool = false {
        didSet {
            /*
             Set layout to a "loading" or "not loading" state
             */
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                
                var contentInset = self.scrollView.contentInset
                
                if self.loading {
                    contentInset.bottom = self.heightLimit
                    self.activityIndicatorView?.startAnimating()
                }else{
                    contentInset.bottom = 0.0
                    self.activityIndicatorView?.stopAnimating()
                }
                
                self.scrollView.contentInset = contentInset
            }
        }
    }
    
    var scrollView: UIScrollView = UIScrollView()
    
    override public var frame: CGRect {
        didSet{
            if (frame.size.height > heightLimit) && !loading {
                self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize(activityIndicatorStyle: .Gray)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize(activityIndicatorStyle: .Gray)
    }
    
    public convenience init(target: AnyObject, action: Selector, style: UIActivityIndicatorViewStyle = .Gray) {
        self.init()
        self.initialize(activityIndicatorStyle: style)
        self.addTarget(target, action: action, forControlEvents: .ValueChanged)
    }
    
    /*
     Initilize the control
     */
    private func initialize(activityIndicatorStyle style: UIActivityIndicatorViewStyle) {
        /*
         Prepare activityIndicator
         */
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: style)
        activityIndicatorView.hidesWhenStopped = false
        activityIndicatorView.transform = CGAffineTransformMakeScale(1.4, 1.4)
        
        self.addSubview(activityIndicatorView)
        self.bringSubviewToFront(activityIndicatorView)
        self.activityIndicatorView = activityIndicatorView
        
        self.reloadTargetsIfNedeed()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    /*
     Update layout at finsih to load
     */
    public func endLoading() {
        self.loading = false
        self.fixPosition()
    }
    
}

extension UILoadControl {
    /*
     Make sure that the trigger target is active
     */
    private func reloadTargetsIfNedeed() {
        let selectorName: Selector = "didValueChange:"
        if self.actionsForTarget(self, forControlEvent: UIControlEvents.ValueChanged) == nil {
            self.addTarget(self, action: selectorName, forControlEvents: UIControlEvents.ValueChanged)
        }
    }
    
    
    /*
     Check if the control frame should be updated.
     This method is called after user hits the end of the scrollView
     */
    func updateUI() {
        if self.scrollView.contentSize.height < self.scrollView.bounds.size.height {
            return
        }
        
        let contentOffSetBottom = max(0, ((scrollView.contentOffset.y + scrollView.frame.size.height) - scrollView.contentSize.height))
        if (contentOffSetBottom >= 0 && !loading) || (contentOffSetBottom >= heightLimit && loading) {
            self.updateFrame(CGRectMake(0.0, scrollView.contentSize.height, scrollView.frame.size.width, contentOffSetBottom))
        }
    }
    
    /*
     Update layout after user scroll the scrollView
     */
    private func updateFrame(rect: CGRect) {
        guard let superview = self.superview else {
            return
        }
        
        superview.frame = rect
        frame = superview.bounds
        self.activityIndicatorView?.alpha = (((frame.size.height * 100) / heightLimit) / 100)
        self.activityIndicatorView?.center = CGPointMake((frame.size.width / 2), (frame.size.height / 2))
    }
    
    /*
     Place control at the scrollView bottom
     */
    private func fixPosition() {
        self.updateFrame(CGRectMake(0.0, scrollView.contentSize.height, scrollView.frame.size.width, 0.0))
    }
    
    @objc private func didValueChange(sender: AnyObject?) {
        self.loading = true
    }
}
