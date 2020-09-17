//: [Previous](@previous)

import Combine

class Temperature {
    var value: Int
    init(value: Int) {
        self.value = value
    }
}

class Weather {
    @Published var temperature: Temperature = Temperature(value: 1)
}
let weather = Weather()
_ = weather.$temperature
    .sink {
        print ("Temperature now: \($0.value)")
}
weather.temperature.value = 2

print(weather.temperature.value)

//: [Next](@next)
