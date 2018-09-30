import UIKit

struct Pair<A, B> {
  let first: A
  let second : B
}

//and
Pair<Void, Void>.init(first: (), second: ())
//Pair<Void, Never>.init(first: (), second: ???)

//or
enum Either<A, B> {
  case left(A)
  case right(B)
}


//optional
Either<Bool, Void>.left(true)
Either<Bool, Void>.right(())



//Void 대체할 필요 있음
//Void 는 튜플이므로 extension 못함
struct Unit {}

extension Unit: Equatable {
  static func == (lhs: Unit, rhs: Unit) -> Bool {
    return true
  }
}


func sum(_ xs: [Int]) -> Int {
  var result: Int = 0
  for x in xs {
    result += x
  }
  return result
}

func product(_ xs: [Int]) -> Int {
  var result: Int = 1
  for x in xs {
    result *= x
  }
  return result
}

sum([1, 2]) + sum([]) == sum([1, 2] + [])
product([1, 2]) * product([]) == product([1, 2] + [])

sum([]) == 0
product([]) == 1


//URLSession.shared.dataTask(with: <#T##URL#>, completionHandler: <#T##(Data?, URLResponse?, Error?) -> Void#>)

//콜백함수에서 3가지가 모두 옵셔널이지만 경우의수가 2*2*2 는 절대 될 수 없다

//Either<Pair<Data, URLResponse>, Error>

