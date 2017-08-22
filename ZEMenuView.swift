// 掘金:http://gold.xitu.io/#/user/567bbee434f81a1d8790bd0c
// 简书"http://www.jianshu.com/p/1523c6bd3253
// github:https://github.com/Lafree317

import UIKit


protocol ZEMenuViewDelegate {
    func menuViewSelectIndex(_ index:Int)
}

class ZEMenuView: UIView {
    /** 屏幕宽度高度 */
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    
    /** button两种状态的颜色 可以无视 */
    let COLOR_BUTTON_DEFAULT = UIColor.init(red: 124/255.0, green: 129/255.0, blue: 138/255.0, alpha: 1)
    let COLOR_BUTTON_SELECT = UIColor.init(red: 0/255.0, green: 153/255.0, blue: 102/255.0, alpha: 1)

    
    let buttonWidth:CGFloat = 75
    let menuHeight:CGFloat = 30
    var lineView:UIView?
    var titleArr:Array<String> = []
    var buttonArr:Array<UIButton> = []
    var margin:CGFloat!
    var delegate:ZEMenuViewDelegate?
    
    func setUIWithArr(_ titleArr:Array<String>){
        self.backgroundColor = UIColor.init(red: 250/255.0, green: 250/255.0, blue: 250/255.0, alpha: 1)
        self.titleArr = titleArr
        margin = (screenWidth - (CGFloat(titleArr.count) * buttonWidth)) / CGFloat(titleArr.count+1)
        for i in 0 ..< titleArr.count  {
            let floatI = CGFloat(i)
            
            let button = UIButton(type: UIButtonType.custom)
            let buttonX = margin*(floatI+1)+floatI*buttonWidth
            
            button.frame = CGRect(x: buttonX, y: 0, width: buttonWidth,height: menuHeight)
            
            let title = titleArr[i]
            button.setTitle(title, for: UIControlState())
            button.setTitleColor(COLOR_BUTTON_DEFAULT, for: UIControlState())
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
            buttonArr.append(button)
            self.addSubview(button)
        }
        buttonSelectIndex(0)
        
        
        // 分割线..没啥用
        let line = UIView(frame: CGRect(x: 0,y: self.frame.height-1,width: screenWidth,height: 1))
        line.backgroundColor = UIColor.groupTableViewBackground
        self.addSubview(line)
        
        // 下划线
        lineView = UIView(frame: CGRect(x: margin,y: self.frame.size.height-2,width: buttonWidth,height: 2))
        lineView?.backgroundColor = COLOR_BUTTON_SELECT
        self.addSubview(lineView!)
    }
    
    func buttonClick(_ button:UIButton){
        let index = buttonArr.index(of: button)
        buttonSelectIndex(index!)
        delegate?.menuViewSelectIndex(index!)
        UIView.animate(withDuration: 0.3, animations: { 
            self.scrollToRate(CGFloat(index!))
        }) 
    }
    
    
    func scrollToRate(_ rate:CGFloat){
        if Int(rate) >= titleArr.count {
            return
        }
        let index = Int(rate)
        let pageRate = rate - CGFloat(index)
        let button = self.buttonArr[index]
        self.lineView?.frame.origin.x = button.frame.origin.x + ( button.frame.width+margin )*pageRate
        buttonSelectIndex(Int(rate + 0.5))
    }
 
    
    func buttonSelectIndex(_ index:Int){
        for button in buttonArr {
            button.setTitleColor(COLOR_BUTTON_DEFAULT, for: UIControlState())
        }
        let button = buttonArr[index]
        button.setTitleColor(COLOR_BUTTON_SELECT, for: UIControlState())
    }
}
