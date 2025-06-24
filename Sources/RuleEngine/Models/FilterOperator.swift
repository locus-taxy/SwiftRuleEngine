enum FilterOperator: String, Codable {
    case isTrue = "IS_TRUE"
    case isFalse = "IS_FALSE"
    case equals = "EQUALS"
    case notEquals = "NOT_EQUALS"
    case greaterThan = "GREATER_THAN"
    case lessThan = "LESS_THAN"
    case lesserThan = "LESSER_THAN"
    case greaterThanOrEquals = "GREATER_THAN_OR_EQUALS"
    case lessThanOrEquals = "LESS_THAN_OR_EQUALS"
    case lesserThanOrEquals = "LESSER_THAN_OR_EQUALS"
    case contains = "CONTAINS"
    case notContains = "NOT_CONTAINS"
    case isNull = "IS_NULL"
    case isNotNull = "IS_NOT_NULL"
    case isIn = "IS_IN"
    case isNotIn = "IS_NOT_IN"
}

extension FilterOperator {
    var isEqualityBased: Bool {
        switch self {
        case .isTrue, .isFalse, .equals, .notEquals, .isIn, .isNotIn:
            true
        default:
            false
        }
    }

    var isComparisonBased: Bool {
        switch self {
        case .isTrue, .isFalse, .equals, .notEquals, .greaterThan, .lessThan,
             .lesserThan, .greaterThanOrEquals, .lessThanOrEquals, .lesserThanOrEquals,
             .isIn, .isNotIn:
            true
        default:
            false
        }
    }
}
