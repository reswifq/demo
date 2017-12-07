//
//  main.swift
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
import SwiftRedis
import KituraRedisClient
import RedisClient
import Reswifq
import Jobs

let client = RedisClientPool(maxElementCount: 2) { () throws -> RedisClient in

    let client = Redis()
    client.connect(host: "localhost", port: 6379, callback: { _ in })

    return client
}

let queue = Reswifq(client: client)

let reswifc = Reswifc(processes: [
    Reswifc.Monitor(queue: queue, interval: 5, maxRetryAttempts: 3),
    Reswifc.Scheduler(queue: queue, interval: 1)
    ])

reswifc.run()
