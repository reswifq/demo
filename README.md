# ReswifqDemo

![Swift](https://img.shields.io/badge/swift-3.1-brightgreen.svg)

Simple project to demonstrate the use of [Reswifq](https://github.com/reswifq/reswifq).

## 🏁 Getting Started

The project is composed by four targets:

- **Scheduler** - enqueues and schedules jobs, usually your webservice
- **Worker** - dequeues and processes pending jobs
- **Clock** - monitor expired jobs and schedules delayed jobs for execution
- **Jobs** - shared module containing the jobs definitions

This is the recommended and most common setup for [Reswifq](https://github.com/reswifq/reswifq). Although, it's not the only way and nothing should stop you from using a different structure if it makes sense for your project.

**Note:** A [Redis](https://redis.io) server is required in order to run this demo project.

## **Scheduler**

A simple jobs scheduler implementation that enqueues a `DemoJob` every second. In a real use case this would probably be your webservice or a dedicated cronjob.

```swift
let client = Redis()
client.connect(host: "localhost", port: 6379, callback: { _ in })

let queue = Reswifq(client: client)

while true {

    do {
        try queue.enqueue(DemoJob())
    } catch let error {
        print(error.localizedDescription)
    }

    sleep(1)
}
```

## Worker

An example of how to instantiate and run a worker process.

```swift
let client = RedisClientPool(maxElementCount: 10) { () -> RedisClient in

    let client = Redis()
    client.connect(host: "localhost", port: 6379, callback: { _ in })

    return client
}

let queue = Reswifq(client: client)
queue.jobMap[String(describing: DemoJob.self)] = DemoJob.self

let worker = Worker(queue: queue, maxConcurrentJobs: 4, averagePollingInterval: 0)

worker.run()
```

Apart from a standard `Worker` configuration, the `jobMap` is what requires some major attention.

`queue.jobMap[String(describing: DemoJob.self)] = DemoJob.self`

This is telling the queue, that whenever a job of type `DemoJob` is dequeued, it has to create an instance of type `DemoJob`.

**Notes:**

 - The job's type is simply a `String` and mapping it to a concrete type is **mandatory**.
 - The `jobMap`'s keys must correspond to the `Job`'s type attribute.
 - Note the use of a `RedisClientPool`, to ensure the same client is not used by different threads at the same time.
 - A `RedisClientPool` is not required when `maxConcurrentJobs` is `1`.

## Clock

An instance of `Reswifc`, configured with both a `Monitor` and a `Scheduler` process.

- **Monitor** - analyzes the processing queue for expired jobs
- **Scheduler** - analyzes the delayed queue for overdue jobs and schedules them for execution

```swift
let client = RedisClientPool(maxElementCount: 2) { () -> RedisClient in

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
```

**Notes:** 

- As each process runs in its own thread we are using a `RedisClientPool` of size `2` which is shared across both because we are passing to each process the same queue instance.
- Based on your project, you may need or not, any combination of the above processes running.

### Do I need a Monitor process?

Yes, if you need a reliable queue, otherwise expired jobs will simply fail without any retry attempt.

### Do I need a Scheduler process?

Yes, if you need to schedule jobs for delayed execution. For example: run a job on a specific date and time.

### Do I need a Clock process at all?

Yes, if you need either a `Monitor` or a `Scheduler`.

## 🔧 Compatibility

This package has been tested on macOS and Ubuntu.

## 📖 License

Created by [Valerio Mazzeo](https://github.com/valeriomazzeo).

Copyright © 2017 [VMLabs Limited](https://www.vmlabs.it). All rights reserved.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

See the [GNU Lesser General Public License](http://www.gnu.org/licenses) for more details.
