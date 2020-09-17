import Foundation

public func run(_ name: String, action: () -> Void) {
    print("\n------Operator name:", name, "------\n")
    action()
}

extension Thread {
    public var number: Int {
        let desc = self.description
        let threadNumber = try! NSRegularExpression(pattern: "number = (\\d+)", options: .caseInsensitive)
        if let numberMatches = threadNumber.firstMatch(in: desc, range: NSMakeRange(0, desc.count)) {
            let s = NSString(string: desc).substring(with: numberMatches.range(at: 1))
            return Int(s) ?? 0
        }
        return 0
    }
}

