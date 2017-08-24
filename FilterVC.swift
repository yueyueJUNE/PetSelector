import UIKit

var genderFilter = [String]()
var ageFilter = [String]()
var colorFilter = [String]()
var sizeFilter = [String]()
var breedFilter = [String]()
var location = ""
var breedtxt = ""


class FilterVC: UIViewController, LocationSelectorDelegate , BreedSelectorDelegate{

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var breedLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!

    //gender button
    @IBOutlet var genderBtn: [UIButton]!
    //age button
    @IBOutlet var ageBtn: [UIButton]!
    //size button
    @IBOutlet var sizeBtn: [UIButton]!
    //color button
    @IBOutlet var colorBtn: [UIButton]!
    
    @IBAction func selectGender(_ sender: UIButton) {
        changeButtonColor(sender)
    }

    @IBAction func slectAge(_ sender: UIButton) {
        changeButtonColor(sender)
    }
    
    @IBAction func selectSize(_ sender: UIButton) {
        changeButtonColor(sender)
    }
    
    @IBAction func selectColor(_ sender: UIButton) {
        changeButtonColor(sender)
    }
    
    
    func changeButtonColor(_ sender: UIButton) {
        if (sender.backgroundColor == .white) {
            
            sender.backgroundColor = .clear
            
        } else {
            sender.backgroundColor = .white
            
        }
    
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaultbuttons(genderBtn)
        setDefaultbuttons(ageBtn)
        setDefaultbuttons(sizeBtn)
        setDefaultbuttons(colorBtn)
        
        
        if location == "" || location == "不限" {
            location = "点我选择..."
        }
        
        locationLbl.text = location
        if location != "点我选择..." {
            locationLbl.textColor = .black
        }
        breedLbl.text = breedtxt == "" ? "点我选择..." : breedtxt
        if breedtxt != "" {
            breedLbl.textColor = .black
        }

        
        for gender in genderFilter {
            if gender == "公" {
                genderBtn[0].backgroundColor = .white
            }
            if gender == "母" {
                genderBtn[1].backgroundColor = .white
            }
        
        }
        
         for age in ageFilter {
         
         if age == "幼年" {ageBtn[0].backgroundColor = .white}
         if age == "成年" {ageBtn[1].backgroundColor = .white}
         if age == "老年" {ageBtn[2].backgroundColor = .white}
         
         }
         
         for age in sizeFilter {
         if age == "迷你" {sizeBtn[0].backgroundColor = .white}
         if age == "小型" {sizeBtn[1].backgroundColor = .white}
         if age == "中型" {sizeBtn[2].backgroundColor = .white}
         if age == "大型" {sizeBtn[3].backgroundColor = .white}
         
         }
         
         
        for color in colorFilter {
             if color == "黑" {colorBtn[0].backgroundColor = .white}
             if color == "白" {colorBtn[1].backgroundColor = .white}
             if color == "花" {colorBtn[2].backgroundColor = .white}
             if color == "棕" {colorBtn[3].backgroundColor = .white}
             if color == "黄" {colorBtn[4].backgroundColor = .white}
             if color == "其他" {colorBtn[5].backgroundColor = .white}
         
        }
         
    
        
        //自定义导航按钮
        let leftBarBtn = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(back))
        self.navigationItem.leftBarButtonItem = leftBarBtn
        
        let saveBtn = UIBarButtonItem(title: "保存", style: .plain, target: self, action:#selector(saveFilter))
        self.navigationItem.rightBarButtonItem = saveBtn

        // tap to choose location
        let locationTap = UITapGestureRecognizer(target: self, action: #selector(selectLocation))
        //locationLbl.numberOfTapsRequired = 1
        locationLbl.isUserInteractionEnabled = true
        locationLbl.addGestureRecognizer(locationTap)

        
        // tap to choose breed
        let breedTap = UITapGestureRecognizer(target: self, action: #selector(selectBreed))
        breedLbl.isUserInteractionEnabled = true
        breedLbl.addGestureRecognizer(breedTap)
        
    }

    func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveFilter(){
        genderFilter.removeAll(keepingCapacity: false)
        ageFilter.removeAll(keepingCapacity: false)
        colorFilter.removeAll(keepingCapacity: false)
        sizeFilter.removeAll(keepingCapacity: false)
        breedFilter.removeAll(keepingCapacity: false)
        location = ""
        
        for button in genderBtn {
            if button.backgroundColor == .white {
                if button.tag == 0 {genderFilter.append("公")}
                else if button.tag == 1 {genderFilter.append("母")}
            }
        }
        
        for button in ageBtn {
            if button.backgroundColor == .white {
                if button.tag == 0 {ageFilter.append("幼年")}
                else if button.tag == 1 {ageFilter.append("成年")}
                else if button.tag == 2 {ageFilter.append("老年")}
            }
        }

        for button in sizeBtn {
            if button.backgroundColor == .white {
                if button.tag == 0 {sizeFilter.append("迷你")}
                else if button.tag == 1 {sizeFilter.append("小型")}
                else if button.tag == 2 {sizeFilter.append("中型")}
                else if button.tag == 3 {sizeFilter.append("大型")}

            }
        }

        for button in colorBtn {
            if button.backgroundColor == .white {
                if button.tag == 0 {colorFilter.append("黑")}
                else if button.tag == 1 {colorFilter.append("白")}
                else if button.tag == 2 {colorFilter.append("花")}
                else if button.tag == 3 {colorFilter.append("棕")}
                else if button.tag == 4 {colorFilter.append("黄")}
                else if button.tag == 5 {colorFilter.append("其他")}

            }
        }
        
        //判断是否设置filter
        if locationLbl.text! == "点我选择..." {
            location = "不限"
        } else {
            location = locationLbl.text!
        }
        
        if breedLbl.text! == "点我选择..." {
            breedFilter.append("不限")
        } else {
            breedFilter = breedLbl.text!.replacingOccurrences(of: " ", with: "").characters.split(separator: "\n").map(String.init)
        }
        
        // send notification to postVC to be reloaded
        NotificationCenter.default.post(name: Notification.Name(rawValue: "setFilter"), object: nil)
        
        self.dismiss(animated: true, completion: nil)
    }

    
    func setDefaultbuttons(_ buttons: [UIButton]){
    
        for button in buttons {
            //button.backgroundColor = .clear
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.darkGray.cgColor
            
        }
    }
    
    
    func selectLocation() {
    let locationSelector = LocationSelector()
    locationSelector.delegate = self;
    self.navigationController?.pushViewController(locationSelector, animated: true)
    }

   
    func selectBreed() {
        let breedSelector = BreedSelector(true)
        breedSelector.delegate = self;
        self.navigationController?.pushViewController(breedSelector, animated: true)
        
    }

    
    func locationSelected(_ locations: String) {
        locationLbl.text = locations
        locationLbl.textColor = .black
        self.navigationController?.popToViewController(self, animated: true)
    }

    
    func breedSelected(_ breeds: [String]) {
        var selectedBreeds = String()
        for breed in breeds {
            selectedBreeds += breed + "\n"
        }
        if selectedBreeds == "" {
            selectedBreeds = "点我选择..."
            breedLbl.textColor = .lightGray
        }
        
        if selectedBreeds != "点我选择..." {

            breedLbl.textColor = .black

        }
        print(selectedBreeds)
        breedLbl.text = selectedBreeds.trimmingCharacters(in: NSCharacterSet.newlines)
        breedtxt = selectedBreeds.trimmingCharacters(in: NSCharacterSet.newlines)
        self.navigationController?.popToViewController(self, animated: true)
    }
    
}

