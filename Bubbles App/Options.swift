import Foundation
import UIKit

protocol OptionViewDelegate: class{
    func onOptionChanged(newOption: String)
    func onCameraPressed()
}

public class OptionsView  : UIView{
    let icons = [
        "blow": UIImage(named: "blow")!,
        "auto": UIImage(named: "catavento")!,
        "touch": UIImage(named: "touch")!,
        "camera": UIImage(named: "camera")!,
    ]
    
    let colors = [
        "selected_icon": #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1),
        "default_icon": #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1),
//        "selected_background": #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 0),
//        "default_background": #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0) ,

        "selected_background": #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1),
        "default_background":#colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1),
    ]
    
    var buttons = [String: UIButton]()
    weak var delegate: OptionViewDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initButtons()
        self.addButtonsToView()
        
        self.changeButton(toButton: self.buttons["blow"]!)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    public override func draw(_ rect: CGRect) {
        print("Pintando!")
    }
    
    
    func initButtons(){
        for (buttonName, _) in self.icons {
            let button = getButton(withName: buttonName, index: 0)
            self.buttons[buttonName] = button
        }
    }
    
    func addButtonsToView(){
        let order = [
            "blow",
            "auto",
            "touch",
            "camera",
            ]
        
        for (_, button) in self.buttons{
            self.addSubview(button)
        }
        
        var offset = CGFloat(0)
        var prevButton: UIButton?
        
        for (buttonName) in order{
            let button = self.buttons[buttonName]!
            button.translatesAutoresizingMaskIntoConstraints = false
            button.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            if prevButton == nil{
                button.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            }else{
                print("Appending to button")
                button.topAnchor.constraint(equalTo: prevButton!.topAnchor, constant: offset).isActive = true
            }
            button.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1).isActive = true
            button.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.25 ).isActive = true
            if buttonName != "camera"{
                button.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
                button.layer.borderWidth = 2
                button.layer.cornerRadius = 4
            }else{
                button.setImage(icons["camera"]!.maskWithColor(color: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)), for: .normal)
            }
            print("Offset is ", button.bounds.size.height)
            prevButton = button
            offset =  button.bounds.size.height;
        }
    }
    
    func getButton(withName named : String, index: Int) -> UIButton{
        let buttonIcon = self.icons[named]!
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height:(buttonIcon.cgImage?.height)! + 2))
        button.setImage(buttonIcon.maskWithColor(color: self.colors["default_icon"]!), for: .normal)
        
        button.addTarget(self, action: #selector(self.buttonCallback), for: .touchDown)
        
        return button
    }
    
    func changeButton(toButtonNamed : String){
        for(buttonName, button) in buttons{
            if buttonName == toButtonNamed{
                changeButton(toButton: button)
                return
            }
        }
    }
    
    func changeButton(toButton: UIButton){
        for (buttonName, button) in buttons{
            if buttonName == "camera" && button == toButton{
                self.delegate?.onCameraPressed()
                return
            }
        }
        for (buttonName, button) in buttons{
            let icon = self.icons[buttonName]!
            if buttonName == "camera"{
                if toButton == button{
                    self.delegate?.onCameraPressed()
                    break
                }
                continue
            }
            if button == toButton{
                print("O botao eh ", button)
                setButtonAsActive(button: button, withIcon: icon)
                self.delegate?.onOptionChanged(newOption: buttonName)
            }else{
                setButtonAsInactive(button: button, withIcon: icon)
            }
        }
    }
    
    @objc func buttonCallback(sender: UIButton!){
        changeButton(toButton: sender)
    }
    
    
    func setButtonAsActive(button: UIButton, withIcon icon: UIImage){
        button.backgroundColor = self.colors["selected_background"]
        button.setImage(icon.maskWithColor(color: self.colors["selected_icon"]!), for: .normal)
    }
    
    func setButtonAsInactive(button: UIButton, withIcon icon: UIImage ){
        button.backgroundColor = self.colors["default_background"]
        button.setImage(icon.maskWithColor(color: self.colors["default_icon"]!), for: .normal)
    }
    
    func addBehavior() {
        print("Add all the behavior here")
    }
    
}
