//
//  WeatherAPIModel.swift
//  WeatherAssignment
//
//  Created by Deepti Walde on 23/05/18.
//  Copyright © 2018 Deepti Walde. All rights reserved.
//

import UIKit

//MARK:-  Weather API Struct
struct WeatherReport: Decodable
{
    let coord: Coord?
    let weather : [Weather]?
    let base : String?
    let main : Main?
    let visibility : Int?
    let wind : Wind?
    let clouds : Cloud?
    let dt     : Int?
    let sys    : Sys?
    let id     : Int?
    let name   : String?
    let cod    : Int
}

struct Coord : Codable {
    let lon : Float?
    let lat : Float?
}

struct Weather : Codable {
    let id : Int
    let main : String
    let description : String
    let icon : String
}

struct Main : Codable {
    let temp : Float?
    let pressure : Int?
    let humidity : Int?
    let temp_min : Int?
    let temp_max : Int?
}

struct Wind : Codable {
    let speed : Float?
    let deg   : Int?
}

struct Cloud : Codable {
    let all : Int?
}

struct Sys : Codable {
    let type    : Int?
    let id      : Int?
    let message : Double?
    let country : String?
    let sunrise : Int?
    let sunset  : Int?
}
