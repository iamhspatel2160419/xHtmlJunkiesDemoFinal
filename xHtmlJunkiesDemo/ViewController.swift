//
//  ViewController.swift
//  xHtmlJunkiesDemo
//
//  Created by Apple on 08/12/20.
//

import UIKit

class ViewController: UIViewController {
   
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnFilterClicked: UIButton!
    @IBOutlet weak var lblDateView: UIView!
    @IBOutlet weak var searchBarStoryboardView: UISearchBar!
    
    @IBOutlet weak var detailDateLabel: UILabel!
    var searchTxt = ""
    var model:Model? = nil
    
    var filteredModel_ = FilterModel(items:[Item]())
    
    var isFilteringBySearchText: Bool {
        return !searchTxt.isEmpty
    }
    
    var sortedDateArray:[startDate] {
        if let m = model
        {
            return  m.datesCollection.sorted { $0.startTimeInt < $1.startTimeInt }
        }
        return []
    }
    
    var isFiltering: Bool {
        return self.filteredModel_.list.count > 0 ? true : false
    }
    var selectedDateInterval:Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Practical"
        tableView.delegate = self
        tableView.dataSource = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
       
        setUpSearchBarDesign()
        
        
        
        
        
        API.callRequest { [weak self] (_, isSuccess, model) in
            
            if isSuccess{
                if let m = model
                {
                    if let self = self
                    {
                        self.model = m
                        DispatchQueue.main.async
                        {
                            self.tableView.reloadData()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.collectionView.reloadData()
                            }
                        }
                        
                    }
                }
                
            }
            
        }
    }
    
    
    
    
    func convertDateToOtherFormat(selectedDate:String,currentDateFormat :String,newDateFormat:String) -> String
    {
        let objDateformatter = DateFormatter()
        objDateformatter.dateFormat = currentDateFormat
        objDateformatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        
        let strDate = objDateformatter.date(from: selectedDate)
        objDateformatter.dateFormat = newDateFormat
        objDateformatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        
        let strfinalDate = objDateformatter.string(from: strDate!)
        return strfinalDate
    }
    func setUpSearchBarDesign()
    {
        searchBarStoryboardView.delegate = self
        searchBarStoryboardView.setShowsCancelButton(false, animated: false)
        searchBarStoryboardView.tintColor = UIColor(rgb: 0xFF5733)
        searchBarStoryboardView.placeholder = "Search Header name"
        searchBarStoryboardView.searchBarStyle = .default
        searchBarStoryboardView.showsCancelButton = true
        searchBarStoryboardView.layer.borderWidth = 1
        searchBarStoryboardView.layer.borderColor = UIColor.clear.cgColor
        if #available(iOS 13, *) {
            
        }
        else
        {
            if let cancelButton : UIButton = searchBarStoryboardView.value(forKey: "_cancelButton") as? UIButton{
                cancelButton.isEnabled = true
            }
        }
    }
    
}
extension ViewController:UISearchBarDelegate
{
    // MARK: - Search Delegate Method Implementation
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBarStoryboardView.setShowsCancelButton(false, animated: false)
        searchBarStoryboardView.text = ""
        searchTxt = ""
        selectedDateInterval = 0
        filteredModel_.list.removeAll()
        tableView.reloadData()
    }
    
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar)
    {
        searchBarStoryboardView.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        self.view.endEditing(true)
        searchBarStoryboardView.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        searchTxt = searchText
        self.filterContentForSearchText(searchText)
    }
    
    func filterContentForSearchText(_ searchText: String)
    {
        DispatchQueue.global(qos: .background).async
        {
            let value = searchText
            self.filteredModel_.list = self.model!.list.filter { User  -> Bool in
                return User.Heading.contains(value)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
}
extension ViewController:UICollectionViewDelegate,UICollectionViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedDateArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:CustomCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as! CustomCollectionViewCell
        cell.lblText.text = sortedDateArray[indexPath.row].startDate
        cell.lblText.textColor = .white
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        
        if model != nil
        {
            let timeInterval1 = sortedDateArray[indexPath.row].startTimeInt
            DispatchQueue.global(qos: .background).async
            {
                if let _ = self.model
                {
                    self.filteredModel_.list = self.model!.list.filter { User  -> Bool in
                        
                        return timeInterval1 == User.startTimeInt
                    }
                    if self.filteredModel_.list.count == 0
                    {
                        self.filteredModel_.list = self.model!.list.filter { User  -> Bool in
                            return timeInterval1 == User.endTimeInt
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
            }
            
            
            detailDateLabel.text = sortedDateArray[indexPath.row].startDate
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 44.0, height: 44.0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}

extension ViewController : UITableViewDelegate,UITableViewDataSource
{
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering && isFilteringBySearchText
        {
            return filteredModel_.list.count
        }
        else if isFiltering
        {
            return filteredModel_.list.count
        }
        else if isFilteringBySearchText
        {
            return filteredModel_.list.count
        }
        else
        {
            
            if let model = model
            {
                return model.list.count
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : CustomCell
        cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell")! as! CustomCell
        
        var isFilter = false
        if isFiltering && isFilteringBySearchText
        {
            isFilter = true
        }
        else if isFiltering
        {
            isFilter = true
        }
        else if isFilteringBySearchText
        {
            isFilter = true
        }
        else
        {
            isFilter = false
        }
        
        
        
        guard let obj = model else { return UITableViewCell() }
        let ele = isFilter ? filteredModel_.list[indexPath.row] : obj.list[indexPath.row]
        
        
        
        let startTime =  self.convertDateToOtherFormat(selectedDate: ele.startTime,
                                                       currentDateFormat: "HH:mm:ss",
                                                       newDateFormat: "hh:mm")
        let startTimeAM_PM =  self.convertDateToOtherFormat(selectedDate: ele.startTime,
                                                            currentDateFormat: "HH:mm:ss",
                                                            newDateFormat: "aa")
        
        
        
        let endTime =  self.convertDateToOtherFormat(selectedDate: ele.endTime,
                                                     currentDateFormat: "HH:mm:ss",
                                                     newDateFormat: "hh:mm")
        let endTimeAM_PM =  self.convertDateToOtherFormat(selectedDate: ele.endTime,
                                                          currentDateFormat: "HH:mm:ss",
                                                          newDateFormat: "aa")
        
        let timeFrame = "\(startTime) \(startTimeAM_PM) - \(endTime) \(endTimeAM_PM)"
        
        
        cell.lblTimeStartEnd.text = timeFrame
        cell.lblHeader.layer.cornerRadius = cell.lblHeader.frame.size.height/2.0
        cell.lblHeader.layer.masksToBounds = true
        cell.lblHeader.text = "   \(ele.tagName)   "
        cell.lblHeader.textColor = .white
        if !ele.tagColor.isEmpty
        {
            let colorValue = ele.tagColor.replacingOccurrences(of: "#", with: "")
            cell.lblHeader.backgroundColor = UIColor(rgb: Int(colorValue) ?? 0xFF5733)
        }
        cell.lblDescription.text = ele.Heading
        
        
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named:"red")
        // Set bound to reposition
        let imageOffsetY: CGFloat = -5.0
        imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
        // Create string with attachment
        let attachmentString = NSAttributedString(attachment: imageAttachment)
        // Initialize mutable string
        let completeText = NSMutableAttributedString(string: "")
        // Add image to mutable string
        completeText.append(attachmentString)
        // Add your text to mutable string
        let textAfterIcon = NSAttributedString(string: " Live Stream")
        completeText.append(textAfterIcon)
        cell.lblTag.textAlignment = .left
        cell.lblTag.attributedText = completeText
        
        
        
        
        let _imageAttachment = NSTextAttachment()
        _imageAttachment.image = UIImage(named:"pin")
        // Set bound to reposition
        let _imageOffsetY: CGFloat = -5.0
        _imageAttachment.bounds = CGRect(x: 0, y: _imageOffsetY, width: _imageAttachment.image!.size.width, height: _imageAttachment.image!.size.height)
        // Create string with attachment
        let _attachmentString = NSAttributedString(attachment: _imageAttachment)
        // Initialize mutable string
        let _completeText = NSMutableAttributedString(string: "")
        // Add image to mutable string
        _completeText.append(_attachmentString)
        // Add your text to mutable string
        let _textAfterIcon = NSAttributedString(string: "Ahmedabad, Gujarat, India")
        _completeText.append(_textAfterIcon)
        cell.lblAddress.textAlignment = .left
        cell.lblAddress.attributedText = _completeText
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 220
    }
    
    
}


