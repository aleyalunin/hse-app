//
//  Lesson.swift
//  HSEapp
//
//  Created by Alexander on 01/02/2017.
//  Copyright © 2017 Alexander. All rights reserved.
//

import Foundation

class Entities{
    
    class Lesson{
    
        var date: Date
        var startTime: String
        var endTime: String
        var type: String
        var discipline: String
        var lecturer: String
        var address: String
        var lectureRoom: String
        
        init(date: Date, startTime: String, endTime: String, type: String, discipline: String, lecturer: String, address: String, lectureRoom: String) {
            self.date = date
            self.startTime = startTime
            self.endTime = endTime
            self.type = type
            self.discipline = discipline
            self.lecturer = lecturer
            self.address = address
            self.lectureRoom = lectureRoom
        }
    }

    class Day{
        
        var date: Date
        var lessons: [Lesson]
        
        init(date: Date, lessons: [Lesson]) {
            self.date = date
            self.lessons = lessons
        }
    }

}


