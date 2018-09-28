import Foundation


func compute(_ x: Int) -> Int {
  return x * x + 1
}

func computeWithSideEffect(_ x: Int) -> Int {
  let result = x * x + 1
  print("result is \(result)")
  return result
}

computeWithSideEffect(2)
assertEqual(5, computeWithSideEffect(2))

[3, 5]
  .map(compute)
  .map(compute)

[3, 5]
  .map(compute >>> compute)


//side effect 가 있는 경우 실행순서가 다르구만
[3, 5]
  .map(computeWithSideEffect)
  .map(computeWithSideEffect)

[3, 5]
  .map(computeWithSideEffect >>> computeWithSideEffect)



//print 를 테스트하는 방법이 없을까
//반환값으로 노출시켜서 테스트해보자
func computeAndPrint(_ x: Int) -> (Int, [String]) {
  let result = x * x + 1
  return (result, ["result is \(result)"])
}

//output 타입이 바뀌어서 composition 이 깨짐

func compose<A, B, C>(_ f: @escaping (A) -> (B, [String]), _ g: @escaping (B) -> (C, [String])) -> ((A) -> (C, [String])) {
  return { a in
    let (b, bLogs) = f(a)
    let (c, cLogs) = g(b)
    return (c, bLogs + cLogs)
  }
}

2 |> compose(computeAndPrint, computeAndPrint)

// 괄호를 안쓰려면 infix 연산자 사용

precedencegroup EffectfulComposition {
  associativity: left
  higherThan: ForwardApplication
  lowerThan: ForwardComposition
}

infix operator >=>: EffectfulComposition

func >=><A, B, C>(_ f: @escaping (A) -> (B, [String]), _ g: @escaping (B) -> (C, [String])) -> ((A) -> (C, [String])) {
  return { a in
    let (b, bLogs) = f(a)
    let (c, cLogs) = g(b)
    return (c, bLogs + cLogs)
  }
}


2
  |> computeAndPrint
  >=> incr
  >>> computeAndPrint
  >=> square
  >>> computeAndPrint







// Date 가 자꾸 바뀌어서 테스트 불가한 경우

func greetWithEffect(_ name: String) -> String {
  let sec = Int(Date().timeIntervalSince1970) % 60
  return "hello \(name), It's \(sec) secs past the min"
}
greetWithEffect("joo")

assertEqual("hello joo, It's 14 secs past the min", greetWithEffect("joo"))

//side effect를 발생시키는 date 를 의존성 주입하자

func greet(name: String, at date: Date) -> String {
  let sec = Int(date.timeIntervalSince1970) % 60
  return "hello \(name), It's \(sec) secs past the min"
}

assertEqual("hello joo, It's 14 secs past the min", greet(name: "joo", at: Date(timeIntervalSince1970: 14)))


func upperCased(_ str: String) -> String {
  return str.uppercased()
}

"sjfois" |> upperCased >>> greetWithEffect
"sfjldsfsd" |> greetWithEffect >>> upperCased


// date 를 의존성 주입하면 compose 불가능하므로 String -> String 형태를 다시 만들어야한다
//date를 입력하면 새로운 String -> String 함수를 반환하는 함수로 변형

func greet(at date: Date) -> ((String) -> String) {
  return { name in
    let sec = Int(date.timeIntervalSince1970) % 60
    return "hello \(name), It's \(sec) secs past the min"
  }
}

"jun" |> greet(at: Date()) >>> upperCased







let formatter = NumberFormatter()
func decimalStyle(_ format: NumberFormatter) {
  format.numberStyle = .decimal
  format.maximumFractionDigits = 2
}
func currencyStyle(_ format: NumberFormatter) {
  format.numberStyle = .currency
  format.roundingMode = .down
}

func wholeStyle(_ format: NumberFormatter) {
  format.maximumFractionDigits = 0
}

decimalStyle(formatter)
wholeStyle(formatter)
formatter.string(from: 1234.6)

currencyStyle(formatter)
formatter.string(from: 1234.6)

decimalStyle(formatter)
wholeStyle(formatter)
formatter.string(from: 1234.6)

//numberformatter 클래스는 참조타입이므로 mutation 부작용 가능
//value 타입으로 변형하자

struct NumberFormatterConfig {
  var numberStyle: NumberFormatter.Style = .none
  var roundingMode: NumberFormatter.RoundingMode = .up
  var maximumFractionDigits: Int = 0
  
  var formatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = self.numberStyle
    formatter.roundingMode = self.roundingMode
    formatter.maximumFractionDigits = self.maximumFractionDigits
    return formatter
  }
}

func decimalStyle(_ format: NumberFormatterConfig) -> NumberFormatterConfig {
  var format = format
  format.numberStyle = .decimal
  format.maximumFractionDigits = 2
  return format
}
func currencyStyle(_ format: NumberFormatterConfig) -> NumberFormatterConfig {
  var format = format
  format.numberStyle = .currency
  format.roundingMode = .down
  return format
}
func wholeStyle(_ format: NumberFormatterConfig) -> NumberFormatterConfig {
  var format = format
  format.maximumFractionDigits = 0
  return format
}


// format 을 복사하기 귀찮으므로 inout 을 사용
func inoutDecimalStyle(_ format: inout NumberFormatterConfig) {
  format.numberStyle = .decimal
  format.maximumFractionDigits = 2
}

func inoutCurrencyStyle(_ format: inout NumberFormatterConfig) {
  format.numberStyle = .currency
  format.roundingMode = .down
}

func inoutWholeStyle(_ format: inout NumberFormatterConfig) {
  format.maximumFractionDigits = 0
}

var config = NumberFormatterConfig()
inoutDecimalStyle(&config)
inoutWholeStyle(&config)
config.formatter.string(from: 1234.6)

inoutCurrencyStyle(&config)
config.formatter.string(from: 1234.6)

inoutDecimalStyle(&config)
inoutWholeStyle(&config)
config.formatter.string(from: 1234.6)

//다시 버그가 발생했군
//compose 가능하도록 helper 함수를 만들어보자

func toInout<A>(_ f: @escaping (A) -> A) -> ((inout A) -> Void) {
  return { a in
    a = f(a)
  }
}

func fromInout<A>(_ f: @escaping (inout A) -> Void) -> ((A) -> A) {
  return { a in
    var copy = a
    f(&copy)
    return copy
  }
}

precedencegroup SingleTypeComposition {
  associativity: left
  higherThan: ForwardApplication
}

infix operator <>: SingleTypeComposition

func <> <A>(f: @escaping (A) -> A, g: @escaping (A) -> A) -> (A) -> A {
  return f >>> g
}

func <> <A>(f: @escaping (inout A) -> Void, g: @escaping (inout A) -> Void) -> (inout A) -> Void {
  return { a in
    f(&a)
    g(&a)
  }
}

decimalStyle <> currencyStyle

inoutDecimalStyle <> inoutCurrencyStyle



config |> decimalStyle <> wholeStyle
config.formatter.string(from: 1234.6)

config |> currencyStyle
config.formatter.string(from: 1234.6)

config |> decimalStyle <> wholeStyle
config.formatter.string(from: 1234.6)

func |> <A>(a: inout A, f: (inout A) -> Void) -> Void {
  f(&a)
}

config |> inoutDecimalStyle <> inoutWholeStyle
config.formatter.string(from: 1234.6)

config |> inoutCurrencyStyle
config.formatter.string(from: 1234.6)

config |> inoutDecimalStyle <> inoutWholeStyle
config.formatter.string(from: 1234.6)

//compose 가능하도록 바꾸니까 버그가 사라졌네...
