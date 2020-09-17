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
weather.temperature = 25

//: [Next](@next)
