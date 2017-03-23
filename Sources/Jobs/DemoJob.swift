//
//  DemoJob.swift
//  ReswifqDemo
//
//  Created by Valerio Mazzeo on 21/02/2017.
//  Copyright © 2017 VMLabs Limited. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Lesser General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//  See the GNU Lesser General Public License for more details.
//
//  You should have received a copy of the GNU Lesser General Public License
//  along with this program. If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import Reswifq

public struct DemoJob: Job {

    // MARK: Initialization

    public init() {
        self.identifier = UUID().uuidString
    }

    // MARK: Attributes

    public let identifier: String

    // MARK: Job

    public func perform() throws {
        print("I am \(self.identifier)")
    }

    // MARK: DataDecodable

    public init(data: Data) throws {

        let object = try JSONSerialization.jsonObject(with: data)

        guard let dictionary = object as? Dictionary<String, Any> else {
            throw DataDecodableError.invalidData(data)
        }

        guard let identifier = dictionary["identifier"] as? String else {
            throw DataDecodableError.invalidData(data)
        }

        self.identifier = identifier
    }

    // MARK: DataEncodable

    public func data() throws -> Data {

        let object: [String: Any] = [
            "identifier": self.identifier
        ]

        return try JSONSerialization.data(withJSONObject: object)
    }
}
