//
//  FirstViewController.swift
//  HSEapp
//
//  Created by Alexander on 22/01/2017.
//  Copyright © 2017 Alexander. All rights reserved.
//

import UIKit

class ScheduleViewController: UITableViewController, LessonCellDelegate {

    var w = LessonsManager()
    
    @IBAction func previousWeek(_ sender: Any) {
    }
    @IBAction func nextWeek(_ sender: Any) {
    }
    @IBOutlet weak var lastUpdateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delaysContentTouches = false
        lastUpdateLabel.text = "Последнее обновление: " + getCurrentDate()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.refresh), for: UIControlEvents.valueChanged)
        tableView.backgroundView = refreshControl
        
        // Getting data
        let url = URL(string: "http://92.242.58.221/ruzservice.svc/v2/personlessons?fromdate=05.15.2017&todate=05.22.2017&email=aayalunin@edu.hse.ru")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print("ERROR")
            }
            
            if let content = data {
                do
                {
                    let myJSON = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                    
                    if let lessons = myJSON["Lessons"] as? NSArray {
                        if let lesson = lessons[0] as? NSDictionary {
                            if let building = lesson["building"] as? NSString {
                                print(building)
                            }
                        }
                    }
                }
                catch
                {
                    
                }
            }
            
        }
        task.resume()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationController = navigationController as? ScrollingNavigationController {
            navigationController.followScrollView(tableView, delay: 50.0)
        }
    }
    
    func refresh(sender:AnyObject) {
        refreshBegin(refreshEnd: {(x:Int) -> () in
            self.lastUpdateLabel.text = "Последнее обновление: " + self.getCurrentDate()
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        })
    }
    
    func refreshBegin(refreshEnd:@escaping (Int) -> ()) {
        DispatchQueue.global(qos: .default).async() {
            print("refreshing")
            sleep(1)
            DispatchQueue.main.async() {
                refreshEnd(0)
            }
        }
    }
    
    
    func getCurrentDate() -> String {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy, HH:mm"
        return formatter.string(from: currentDateTime)
    }
    
    // MARK: Table configuration
    
    // By classes:
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return w.week.days.count
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if w.week.days[section].lessons!.count > 0
//        {
//            return w.week.days[section].lessons!.count
//        } else{
//            return 1
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        if w.week.days[indexPath.section].lessons!.count > 0
//        {
//            let cell = scheduleTableView.dequeueReusableCell(withIdentifier: "lessonCell", for: indexPath)
//            
//            let lesson = w.week.days[indexPath.section].lessons?[indexPath.row]
//            
//            if let lessonCell = cell as? LessonCell{
//                lessonCell.setUpLessonCellWith(lesson: lesson!)
//            }
//            return cell
//        } else {
//           let cell = scheduleTableView.dequeueReusableCell(withIdentifier: "noLessonsCell", for: indexPath)
//            return cell
//        }
//        
//    }
//    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return w.week.days[section].date
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
//        headerView.backgroundColor = headerColor
//        
//        let label = UILabel(frame: CGRect(x: 15,y: 0, width: tableView.bounds.size.width, height: 30))
//        label.text = String(describing: w.week.days[section].date)
//        label.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightSemibold)
//        
//        headerView.addSubview(label)
//        
//        return headerView
//    }
    
    // By JSON:
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return scheduleDataJSON.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if scheduleDataJSON[section]["lessons"].count > 0
        {
            return scheduleDataJSON[section]["lessons"].count
        } else{
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if scheduleDataJSON[indexPath.section]["lessons"].count > 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "lessonCell", for: indexPath)
            
            let lesson = scheduleDataJSON[indexPath.section]["lessons"][indexPath.row]
            
            if let lessonCell = cell as? LessonCell {
                lessonCell.delegate = self
                lessonCell.setUpLessonCellWith(lesson: lesson)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noLessonsCell", for: indexPath)
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        headerView.backgroundColor = headerColor
        
        let label = UILabel(frame: CGRect(x: 15,y: 0, width: tableView.bounds.size.width, height: 30))
        label.text = scheduleDataJSON[section]["date"].string
        label.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightSemibold)
        
        headerView.addSubview(label)
        
        return headerView
    }
    
    // MARK: - LessonCellDelegate
    
    func callSegueFromCell(data: AnyObject) {
        self.performSegue(withIdentifier: "fromScheduleToMap", sender: data)
        
    }
    
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "fromScheduleToMap" {
            let vc = segue.destination as! MapViewController
            vc.address = "kirpichnaya 33"
        }
    }
    
    // MARK: - Scroll view delegate
    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        
//        if(velocity.y>0) {
//            UIView.animate(withDuration: 2.5, delay: 0, options: UIViewAnimationOptions(), animations: {
//                self.navigationController?.setNavigationBarHidden(true, animated: true)
//            }, completion: nil)
//            
//        } else {
//            UIView.animate(withDuration: 2.5, delay: 0, options: UIViewAnimationOptions(), animations: {
//                self.navigationController?.setNavigationBarHidden(false, animated: true)
//            }, completion: nil)    
//        }
//    }
    
    // Design stuff
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 25))
        return footerView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 25
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}







