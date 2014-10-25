//  Copyright (c) 2014 Yellowbek. All rights reserved.

import Foundation

public typealias SongContext = [String: SongExpression]

func contextDescription(context: SongContext) -> String {
    var contextPairs = Array<String>()
    for (key, value) in context {
        contextPairs.append("\(key) = \(value)")
    }
    contextPairs.sort { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
    return ", ".join(contextPairs)
}
