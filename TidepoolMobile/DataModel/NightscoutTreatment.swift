//
//  NightscoutTreatment.swift
//  RileyLink
//
//  Created by Pete Schwamb on 3/9/16.
//  Copyright © 2016 Pete Schwamb. All rights reserved.
//

//KS from rileylink minimedkit/messages/messagebody.swift
import Foundation


public protocol MessageBody {
    static var length: Int {
        get
    }
    
    init?(rxData: Data)
    
    var txData: Data {
        get
    }
}


public protocol DictionaryRepresentable {
    var dictionaryRepresentation: [String: Any] {
        get
    }
}

//KS from rileylink nightscoutuploadkit/timeformat.swift
class TimeFormat: NSObject {
    private static var formatterISO8601 = DateFormatter.ISO8601DateFormatter()
    
    static func timestampStrFromDate(_ date: Date) -> String {
        return formatterISO8601.string(from: date)
    }
}
//KS from minimedkit/extensions/nsdateformatter.swift
extension DateFormatter {
    // TODO: Replace with Foundation.ISO8601DateFormatter
    class func ISO8601DateFormatter() -> Self {
        let formatter = self.init()
        formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssX"
        
        return formatter
    }
}


public class NightscoutTreatment: DictionaryRepresentable {
    
    let timestamp: Date
    let enteredBy: String
    let notes: String?
    var id: String?
    let eventType: String?
    let duration: Double?//TimeInterval?


    public init(timestamp: Date, enteredBy: String, notes: String? = nil, id: String? = nil, eventType: String? = nil, duration: Double? = nil) {
        self.timestamp = timestamp
        self.enteredBy = enteredBy
        self.id = id
        self.notes = notes
        self.eventType = eventType
        self.duration = duration
    }
    
    public var dictionaryRepresentation: [String: Any] {
        var rval = [
            "created_at": TimeFormat.timestampStrFromDate(timestamp),
            "timestamp": TimeFormat.timestampStrFromDate(timestamp),
            "enteredBy": enteredBy,
        ]
        if let id = id {
            rval["_id"] = id
        }
        if let notes = notes {
            rval["notes"] = notes
        }
        if let eventType = eventType {
            rval["eventType"] = eventType
        }
        rval["duration"] = String(format:"%.2f", duration ?? 0)
        return rval
    }
    
    func dictionaryFromNote() -> [String: AnyObject] {
        let dateFormatter = DateFormatter()
        let jsonObject: [String: AnyObject] = [
            "message": [
                "created_at": dateFormatter.isoStringFromDate(self.timestamp, zone: nil),
                "timestamp": dateFormatter.isoStringFromDate(self.timestamp, zone: nil),
                "enteredBy": self.enteredBy,
                "_id": UUID().uuidString,
                "notes": self.notes,
                "eventType": self.eventType,
                "duration": self.duration
                ] as AnyObject
        ]
        return jsonObject
    }
}
