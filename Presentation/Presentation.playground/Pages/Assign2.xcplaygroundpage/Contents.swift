//: [Previous](@previous)

import Combine

class Weather {
    @Published var temperature: Double = 20
}
let weather = Weather()
_ = weather.$temperature
    .sink {
        print ("Temperature now: \($0)")
}
[1,2,3].publisher
    .map { $0 * 2 }
    .assign(to: &weather.$temperature)

//: [Next](@next)
