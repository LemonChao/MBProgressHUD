//
//  MBProgressHUD.swift
//  MBProgressHUD
//
//  Created by zchao on 2019/9/18.
//  Copyright © 2019 zhengchao. All rights reserved.
//

import UIKit
public enum MBProgressHUDMode {
    /// UIActivityIndicatorView.(Indeterminate模糊的,无进度)
    case indeterminate
    /// A round, pie-chart like(饼状图), progress view.(Determinatew确切的,有进度)
    case determinate
    /// Horizontal progress bar.
    case determinateHorizontalBar
    /// Ring-shaped progress view.(Annular环形的)
    case annularDeterminate
    /// Shows a custom view.
    case customView
    /// Shows only labels.
    case text
}

public enum MBProgressHUDAnimation {
    /// Opacity animation
    case fade
    /// Opacity + scale animation (zoom in when appearing zoom out when disappearing)
    case zoom
    /// Opacity + scale animation (zoom out style)
    case zoomOut
    /// Opacity + scale animation (zoom in style)
    case zoomIn
}

public enum MBProgressHUDBackgroundStyle {
    /// Solid color(单色) background
    case solidColor
    /// UIVisualEffectView or UIToolbar.layer background view
    case blur
}



/**
 * Displays a simple HUD window containing a progress indicator and two optional labels for short messages.
 *
 * This is a simple drop-in class for displaying a progress HUD view similar to Apple's private UIProgressHUD class.
 * The MBProgressHUD window spans over the entire space given to it by the initWithFrame: constructor and catches all
 * user input on this region, thereby preventing the user operations on components below the view.
 *
 * @note To still allow touches to pass through the HUD, you can set hud.userInteractionEnabled = NO.
 * @attention MBProgressHUD is a UI class and should therefore only be accessed on the main thread.
 */
public class MBProgressHUD: UIView {

    
    /// Creates a new HUD, adds it to provided view and shows it. The counterpart(配对) to this method is hideHUDForView:animated:.
    ///
    /// - Parameters:
    ///   - view:  The view that the HUD will be added to
    ///   - animated: If set to YES the HUD will appear using the current animationType. If set to NO the HUD will not use animations while appearing.
    /// - Returns: A reference to the created HUD.
    ///
    /// - see: hideHUDForView:animated:
    /// - see: animationType
    public class func showHUDAddedTo(view: UIView, animated: Bool) -> MBProgressHUD {
        return MBProgressHUD()
    }
    
    
    /// Finds the top-most(最顶端) HUD subview that hasn't finished and hides it. The counterpart to this method is showHUDAddedTo:animated:.
    /// - note: This method sets removeFromSuperViewOnHide. The HUD will automatically be removed from the view hierarchy when hidden.
    ///
    /// - Parameters:
    ///   - view: The view that is going to be searched for a HUD subview.
    ///   - animated: If set to YES the HUD will disappear using the current animationType. If set to NO the HUD will not use animations while disappearing.
    /// - Returns: YES if a HUD was found and removed, NO otherwise.
    public class func hideHUDForView(_ view: UIView, animated: Bool) -> Bool {
        return true
    }
    
    
    /// Finds the top-most HUD subview that hasn't finished and returns it.
    ///
    /// - Parameter view: The view that is going to be searched.
    /// - Returns: A reference to the last HUD subview discovered.
    public class func HUDForView(_ view: UIView) -> MBProgressHUD? {
        return nil
    }
    
    
    /// A convenience constructor that initializes the HUD with the view's bounds. Calls the designated constructor with view.bounds as the parameter.
    ///
    /// - Parameter view: The view instance that will provide the bounds for the HUD. Should be the same instance as the HUD's superview (i.e., the view that the HUD will be added to).
    public func initWithView(_ view: UIView) -> MBProgressHUD {
        return MBProgressHUD(frame: view.bounds)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func commonInit() {
        print("\(#function) ==>\(count+=1)")
        // Set default values for properties
        animationType = MBProgressHUDAnimation.fade
        mode = MBProgressHUDMode.indeterminate
        margin = 20
        defaultMotionEffectsEnabled = true
        contentColor = UIColor(white: 0, alpha: 0.7)
        
        
        // Transparent background如果开发中UIView.background是不透明的，opaque设置为YES， 如果opaque设置NO，那么color的alpha应该小于1.
        isOpaque = false
        backgroundColor = UIColor.clear
        // Make it invisible for now
        alpha = 0
        autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        layer.allowsGroupOpacity = false
        
        
        #if !TARGET_OS_TV
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarOrientationDidChange(_:)), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
        #endif
    }
    
    deinit {
        #if !TARGET_OS_TV
        NotificationCenter.default.removeObserver(self, name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
        #endif

    }
    
    // mark: - Show & Hide
    
    func done() {
        print("\(#function) ==>\(count+=1)")

        
        
    }
    
    
    // MARK: - UI
    private func setupViews() {
        print("\(#function) ==>\(count+=1)")

        let defaultColor = contentColor
        backgroundView.frame = self.bounds
        backgroundView.style = MBProgressHUDBackgroundStyle.solidColor
        backgroundView.color = UIColor.clear
        backgroundView.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue)
        backgroundView.alpha = 0
        self.addSubview(backgroundView)
        
        bezelView.translatesAutoresizingMaskIntoConstraints = false
        bezelView.layer.cornerRadius = 5
        bezelView.alpha = 0
        self.addSubview(bezelView)
        updateBezelMotionEffects()
        
        label.adjustsFontSizeToFitWidth = false
        label.textAlignment = NSTextAlignment.center
        label.textColor = defaultColor
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.isOpaque = false
        label.backgroundColor = UIColor.clear
        
        detailsLabel.adjustsFontSizeToFitWidth = false
        detailsLabel.textAlignment = NSTextAlignment.center
        detailsLabel.textColor = defaultColor
        detailsLabel.font = UIFont.boldSystemFont(ofSize: 16)
        detailsLabel.isOpaque = false
        detailsLabel.backgroundColor = UIColor.clear
        detailsLabel.numberOfLines = 0
        
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.setTitleColor(defaultColor, for: .normal)
        
        for view in [label, detailsLabel, button] {
            view.translatesAutoresizingMaskIntoConstraints = false
            view.setContentHuggingPriority(UILayoutPriority(rawValue: 998), for: .horizontal)
            view.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 998), for: .vertical)
            bezelView.addSubview(view)
        }
        
        topSpacer.translatesAutoresizingMaskIntoConstraints = false
        topSpacer.isHidden = true
        bezelView.addSubview(topSpacer)
        
        bottomSpacer.translatesAutoresizingMaskIntoConstraints = false
        bottomSpacer.isHidden = true
        bezelView.addSubview(bottomSpacer)
        
    }
    
    
    private func updateIndicators() {
        print("\(#function) ==>\(count+=1)")
        
        // indicator 正在以activity 显示
        let isActivityIndicator = indicator != nil && indicator!.isKind(of: UIActivityIndicatorView.self)
        let isRoundIndicator = indicator != nil && indicator!.isKind(of: MBRoundProgressView.self)
        let isBarIndicator = indicator != nil && indicator!.isKind(of: MBBarProgressView.self)
        // indicator 正在以
        let isCustomView = indicator != nil && customView == indicator
        
        switch mode {
        case .indeterminate:    //转菊花
            if !isActivityIndicator {
                // Update to indeterminate indicator
                indicator!.removeFromSuperview()
                indicator = UIActivityIndicatorView(style: .whiteLarge)
                (indicator as! UIActivityIndicatorView).startAnimating()
                self.bezelView.addSubview(indicator!)
            }
        case .determinateHorizontalBar:  // 水平进度条
            if !isBarIndicator {
                indicator!.removeFromSuperview()
                indicator = MBBarProgressView()
                self.bezelView.addSubview(indicator!)
            }
        case .determinate:  // 圆形饼状图
            if !isRoundIndicator {
                // Update to determinante indicator
                indicator!.removeFromSuperview()
                indicator = MBRoundProgressView()
                (indicator as! MBRoundProgressView).annular = false
                bezelView.addSubview(indicator!)
            }
        case .annularDeterminate:  // 圆形环状图
            if !isRoundIndicator {
                // Update to determinante indicator
                indicator!.removeFromSuperview()
                indicator = MBRoundProgressView()
                (indicator as! MBRoundProgressView).annular = true
                bezelView.addSubview(indicator!)
            }
        case .customView:
            if !isCustomView {
                // Update custom view indicator
                indicator!.removeFromSuperview()
                indicator = customView
                bezelView.addSubview(indicator!)
            }
        case .text:
            if indicator != nil {
                indicator!.removeFromSuperview()
                indicator = nil
            }
        }
        
        if let indicatorView = indicator {
            indicatorView.translatesAutoresizingMaskIntoConstraints = false
            indicatorView.setContentHuggingPriority(UILayoutPriority(rawValue: 998), for: .horizontal)
            indicatorView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 998), for: .vertical)
            
            if indicatorView.responds(to: #selector(setter: progress)) {
                indicatorView.setValue(progress, forKey: "progress")
            }
            
        }
        
        updateViewsFor(color: contentColor)
        self.setNeedsUpdateConstraints()
        
    }
    
    /// 设置hud内容显示颜色字体,indicator
    func updateViewsFor(color: UIColor) {
        print("\(#function) ==>\(count+=1)")
        label.textColor = color
        detailsLabel.textColor = color
        button.setTitleColor(color, for: .normal)
        
        // UIAppearance settings are prioritized. If they are preset the set color is ignored.
        if let indicatorView = indicator {
            if indicatorView.isKind(of: UIActivityIndicatorView.self) {
                
                let appearance = UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [MBProgressHUD.self])
                if appearance.color == nil {
                    (indicatorView as! UIActivityIndicatorView).color = color
                }
            }else if indicatorView.isKind(of: MBRoundProgressView.self) {
                let appearance = MBRoundProgressView.appearance(whenContainedInInstancesOf: [MBProgressHUD.self])
                
//                if appearance.progressTintColor == nil {
//                    (indicator as! MBRoundProgressView).progressTintColor = color
//                }

            }else if indicatorView.isKind(of: MBBarProgressView.self) {
                let appearance = MBBarProgressView.appearance(whenContainedInInstancesOf: [MBProgressHUD.self])

            }else {
                indicatorView.tintColor = color
            }
            
            
            
            
        }
    }
    
    
    
    
    @objc func statusBarOrientationDidChange(_ notif: Notification) {
        print("\(#function) ==>\(count+=1)")
        if superview != nil {
            updateForCurrentOrientation(animated: true)
        }
    }
    
    
    private func updateForCurrentOrientation(animated: Bool) {
        print("\(#function) ==>\(count+=1)")
        // Stay in sync with the superview in any case
        self.frame = superview?.bounds ?? UIScreen.main.bounds
    }
    
    /// 更新面板(外壳)运动效果
    private func updateBezelMotionEffects() {
        print("\(#function) ==>\(count+=1)")
        guard bezelView.responds(to: #selector(addMotionEffect(_:))) else { return }
        
        if defaultMotionEffectsEnabled {
            let effectOffset: CGFloat = 10
            
            let effectX = UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffect.EffectType.tiltAlongHorizontalAxis)
            effectX.maximumRelativeValue = effectOffset
            effectX.minimumRelativeValue = -effectOffset
            
            let effectY = UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffect.EffectType.tiltAlongVerticalAxis)
            effectY.maximumRelativeValue = effectOffset
            effectY.minimumRelativeValue = -effectOffset

            let group = UIMotionEffectGroup()
            group.motionEffects = [effectX,effectY]
            bezelView.addMotionEffect(group)
        }else {
            for effect in bezelView.motionEffects {
                bezelView.removeMotionEffect(effect)
            }
        }
    }
    
    // MARK: - Layout
    
    public override func updateConstraints() {
        var bezelConstraints:[NSLayoutConstraint] = []
        let metrics = ["margin": margin]
        var subviews = [topSpacer, label, detailsLabel, button, bottomSpacer]
        
        // Remove existing constraints
        self.removeConstraints(self.constraints)
        topSpacer.removeConstraints(topSpacer.constraints)
        bottomSpacer.removeConstraints(bottomSpacer.constraints)
        if !self.bezelConstraints.isEmpty {
            bezelView.removeConstraints(self.bezelConstraints)
            self.bezelConstraints.removeAll()
        }
        
        // Center bezel in container (self), applying the offset if set
        let offsetT = self.offset
        var centeringConstraints:[NSLayoutConstraint] = []
        centeringConstraints.append(NSLayoutConstraint(item: bezelView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: offsetT.x))
        centeringConstraints.append(NSLayoutConstraint(item: bezelView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: offsetT.y))
        applyPriority(998, to: centeringConstraints)
        self.addConstraints(centeringConstraints)
        
        // Ensure minimum side margin is kept
        var sideConstraints:[NSLayoutConstraint] = []
        sideConstraints += NSLayoutConstraint.constraints(withVisualFormat: "|-(>=margin)-[bezelView]-(>=margin)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: metrics, views: ["bezelView":bezelView])
        sideConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=margin)-[bezel]-(>=margin)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: metrics, views: ["bezelView":bezelView])
        applyPriority(999, to: sideConstraints)
        self.addConstraints(sideConstraints)
        
        // Minimum bezel size, if set
        if !minSize.equalTo(CGSize.zero) {
            var minSizeConstraints: [NSLayoutConstraint] = []
            minSizeConstraints.append(NSLayoutConstraint(item: bezelView, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: minSize.width))
            minSizeConstraints.append(NSLayoutConstraint(item: bezelView, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: minSize.height))
            applyPriority(997, to: minSizeConstraints)
            bezelConstraints += minSizeConstraints
        }
        
        // Square aspect ratio, if set
        if square {
            let square = NSLayoutConstraint(item: bezelView, attribute: .height, relatedBy: .equal, toItem: bezelView, attribute: .width, multiplier: 1, constant: 0)
            square.priority = UILayoutPriority(rawValue: 997)
            bezelConstraints.append(square)
        }
        
        // Top and bottom spacing
        topSpacer.addConstraint(NSLayoutConstraint(item: topSpacer, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: margin))
        bottomSpacer.addConstraint(NSLayoutConstraint(item: bottomSpacer, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: margin))
        // Top and bottom spaces should be equal
        bezelConstraints.append(NSLayoutConstraint(item: topSpacer, attribute: .height, relatedBy: .equal, toItem: bottomSpacer, attribute: .height, multiplier: 1, constant: 0))
        
        // Layout subviews in bezel
        var paddingConstraints: [NSLayoutConstraint] = []
        for (index,view) in subviews.enumerated() {
            // Center in bezel
            bezelConstraints += NSLayoutConstraint.constraints(withVisualFormat: "|-(>=margin)-[view]-(>=margin)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: metrics, views: ["view":view])
            // Element spacing
            if index == 0 {
                // First, ensure spacing to bezel edge
                bezelConstraints.append(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: bezelView, attribute: .top, multiplier: 1, constant: 0))
            }
            else if index == subviews.count - 1 {
                // Last, ensure spacing to bezel edge
                bezelConstraints.append(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: bezelView, attribute: .bottom, multiplier: 1, constant: 0))
            }
            if index > 0 {
                // Has previous
                let padding = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: subviews[index-1], attribute: .bottom, multiplier: 1, constant: 0)
                bezelConstraints.append(padding)
                paddingConstraints.append(padding)
            }
        }
        
        bezelView.addConstraints(bezelConstraints)
        self.bezelConstraints = bezelConstraints
        
        self.paddingConstraints = paddingConstraints
        updatePaddingConstraints()
        super.updateConstraints()
    }
    
    public override func layoutSubviews() {
        print("\(#function) ==>\(count+=1)")
        // There is no need to update constraints if they are going to
        // be recreated in [super layoutSubviews] due to needsUpdateConstraints being set.
        // This also avoids an issue on iOS 8, where updatePaddingConstraints
        // would trigger a zombie object access.
        if !self.needsUpdateConstraints() {
            updatePaddingConstraints()
        }
        
        super.layoutSubviews()
    }
    
    
    func updatePaddingConstraints() {
        print("\(#function) ==>\(count+=1)")
        // Set padding(填充) dynamically(动态的), depending on whether the view is visible or not
        var hasVisibleAncestors = false
        
        for padding in paddingConstraints {
            let firsetView = padding.firstItem as! UIView
            let secondView = padding.secondItem as! UIView
            let firstVisible = !firsetView.isHidden && !firsetView.intrinsicContentSize.equalTo(CGSize.zero)
            let secondVisible = !secondView.isHidden && !secondView.intrinsicContentSize.equalTo(CGSize.zero)
            // Set if both views are visible or if there's a visible view on top that doesn't have padding
            // added relative to the current view yet
            padding.constant = (firstVisible && (secondVisible || hasVisibleAncestors)) ? MBDefaultPadding : 0;
            hasVisibleAncestors = hasVisibleAncestors || secondVisible
        }
    }
    
    
    
    func applyPriority(_ priority: Float, to constraints:[NSLayoutConstraint]) {
        for constraint in constraints {
            constraint.priority = UILayoutPriority(rawValue: priority)
        }
    }
    
    
    /// Displays the HUD.
    ///
    /// - Parameter animated: If set to YES the HUD will appear using the current animationType. If set to NO the HUD will not use animations while appearing.
    ///
    /// - note: You need to make sure that the main thread completes its run loop soon after this method call so that the user interface can be updated. Call this method when your task is already set up to be executed in a new thread (e.g., when using something like NSOperation or making an asynchronous call like NSURLRequest).
    /// - see: animationType
    public func show(animated: Bool) {
        
    }
    
    
    /// Hides the HUD. This still calls the hudWasHidden: delegate. This is the counterpart of the show: method. Use it to hide the HUD when your task completes.
    ///
    /// - Parameter animated: If set to YES the HUD will disappear using the current animationType. If set to NO the HUD will not use animations while disappearing.
    /// - see: animationType
    public func hide(animated: Bool) {
        
    }
    
    
    /// Hides the HUD after a delay. This still calls the hudWasHidden: delegate. This is the counterpart of the show: method. Use it to hide the HUD when your task completes.
    ///
    /// - Parameters:
    ///   - animated: If set to YES the HUD will disappear using the current animationType. If set to NO the HUD will not use animations while disappearing.
    ///   - delay: delay in seconds until the HUD is hidden.
    public func hide(animated: Bool, after delay: TimeInterval) {
        
    }
    
    /// The HUD delegate object. Receives HUD state notifications.
    public var delegate: MBProgressHUDDelegate?
    
    /// Called after the HUD is hiden.
    public var completionBlock: String?
    
    /// Grace period(宽限期) is the time (in seconds) that the invoked method may be run without showing the HUD. If the task finishes before the grace time(宽限期) runs out, the HUD will not be shown at all.
    /// This may be used to prevent HUD display for very short tasks. Defaults to 0 (no grace time).
    public var graceTime: TimeInterval = 0
    
    /// The minimum time (in seconds) that the HUD is shown. This avoids the problem of the HUD being shown and than instantly hidden. Defaults to 0 (no minimum show time).
    public var minShowTime: TimeInterval = 0
    
    /// Removes the HUD from its parent view when hidden. Defaults to NO.
    public var removeFromSuperViewOnHide = false
    
    // MARK: - Appearance
    
    /// MBProgressHUD operation mode. The default is MBProgressHUDModeIndeterminate.
    public var mode = MBProgressHUDMode.indeterminate
    
    /// A color that gets forwarded to all labels and supported indicators. Also sets the tintColor for custom views on iOS 7+. Set to nil to manage color individually.
    /// Defaults to semi-translucent black on iOS 7 and later and white on earlier iOS versions. "UI_APPEARANCE_SELECTOR"可以统一设置全局作用
    public var contentColor = UIColor(white: 0, alpha: 0.7)
    
    /// The animation type that should be used when the HUD is shown and hidden.
    public var animationType = MBProgressHUDAnimation.fade
    
    /// The bezel offset relative to the center of the view. You can use MBProgressMaxOffset and -MBProgressMaxOffset to move the HUD all the way to the screen edge in each direction. E.g., CGPointMake(0.f, MBProgressMaxOffset) would position the HUD centered on the bottom edge.
    public var offset: CGPoint = CGPoint.zero
    
    /// The amount of space between the HUD edge and the HUD elements (labels, indicators or custom views). This also represents the minimum bezel distance to the edge of the HUD view.(到HUD视图边缘的最小边框距离) Defaults to 20.f
    public var margin: CGFloat = 20
    
    /// The minimum size of the HUD bezel. Defaults to CGSizeZero (no minimum size).
    public var minSize: CGSize = CGSize.zero

    /// Force the HUD dimensions(尺寸,大小) to be equal if possible.
    public var square = false
    
    /// When enabled, the bezel center gets slightly affected by the device accelerometer data.(运动效果,当启用时,边框中心会受到设备加速度计数据的轻微影响) Has no effect on iOS < 7.0. Defaults to true.
    public var defaultMotionEffectsEnabled = true
    
    // MARK: - Progress

    /// The progress of the progress indicator, from 0.0 to 1.0. Defaults to 0.0.
    @objc public var progress: CGFloat = 0.0
    
    /// The NSProgress object feeding(输送,提供) the progress information to the progress indicator.
    public var progressObject:Progress!
    
    /// 面板外壳View.The view containing the labels and indicator (or customView).
    public let bezelView = MBBackgroundView()
    
    /// View covering the entire HUD area, placed behind bezelView.
    public let backgroundView = MBBackgroundView()
    
    /// The UIView (e.g., a UIImageView) to be shown when the HUD is in MBProgressHUDModeCustomView.The view should implement(实现) intrinsicContentSize for proper sizing. For best results use approximately(大约) 37 by 37 pixels.
    public var customView: UIView?
    
    /// A label that holds an optional short message to be displayed below the activity indicator. The HUD is automatically resized to fit the entire(全部的) text.
    public let label = UILabel()
    
    ///  A label that holds an optional details message displayed below the labelText message. The details text can span(跨越) multiple lines.
    public let detailsLabel = UILabel()
    
    /// A button that is placed below the labels. Visible only if a target / action is added.
    public let button = MBProgressHUDRoundedButton(type: .custom)
    
////////////////////////// fileprivate or internal  ////////////////////////////
    var count:Int = 0
    var topSpacer = UIView()
    var bottomSpacer = UIView()
    var indicator: UIView?
    // = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
    var bezelConstraints: [NSLayoutConstraint] = []
    var paddingConstraints: [NSLayoutConstraint] = []

    
    let MBDefaultPadding: CGFloat = 4
    
}

public protocol MBProgressHUDDelegate: class {
    
    /// Called after the HUD was fully hidden from the screen.
     func hudDidHidden(_ hud: MBProgressHUD)
}

public class MBBackgroundView: UIView {
    
    /// The background style. Defaults to MBProgressHUDBackgroundStyleBlur on iOS 7 or later and MBProgressHUDBackgroundStyleSolidColor otherwise.
    ///
    /// Due to iOS 7 not supporting UIVisualEffectView, the blur effect differs slightly between iOS 7 and later versions.
    var style = MBProgressHUDBackgroundStyle.blur
    
    
    /// The blur effect style, when using MBProgressHUDBackgroundStyleBlur. Defaults to UIBlurEffectStyleLight.
    
    var blurEffectStyle = UIBlurEffect.Style.light
    
    
    ///  The background color or the blur tint color.
    ///
    /// Due to iOS 7 not supporting UIVisualEffectView, the blur effect differs slightly between iOS 7 and later versions.
    
    var color = UIColor.white
}

/// A progress view for showing definite(确切的) progress by filling up a circle (pie chart(饼状图)).
class MBRoundProgressView: UIView {
    
    /// Progress (0.0 to 1.0)
    @objc var progress: Float = 0.0
    
    /// Indicator progress color. Defaults to white color.
    var progressTintColor: UIColor = UIColor.white
    
    /// Indicator background (non-progress) color. (圆形边框的颜色) Only applicable on iOS versions older than iOS 7. Defaults to translucent white (alpha 0.1).
    var backgroundTintColor: UIColor = UIColor.white
    
    /// Display mode - false = round(实心圆) or true = annular(圆环). Defaults to round.
    var annular: Bool = false
    
}

///  A flat bar progress view.
class MBBarProgressView: UIView {
    
    ///  Progress (0.0 to 1.0)
    @objc var progress: Float = 0.0
    
    ///  * Bar border line color. Defaults to white.
    var lineColor: UIColor = UIColor.white
    
    /// Bar background color.Defaults to clear.
    var progressRemainingColor: UIColor = UIColor.clear
    
    ///  Bar progress color. Defaults to white.
    var progressColor = UIColor.white
    
}

public class MBProgressHUDRoundedButton: UIButton {
    
}

