import Foundation

func incr(_ x: Int) -> Int {
  return x + 1
}

func square(_ x: Int) -> Int {
  return x * x
}

incr(2)
square(2)
square(incr(2))





extension Int {
  func incr() -> Int {
    return self + 1
  }
  
  func square() -> Int {
    return self * self
  }
}
2.incr().square()





precedencegroup ForwardApplication {
  associativity: left
}

infix operator |>: ForwardApplication

func |><A, B>(a: A, f: (A) -> B) -> B {
  return f(a)
}

2 |> incr
2 |> incr |> square

precedencegroup ForwardComposition {
  associativity: left
  higherThan: ForwardApplication
}
infix operator >>>: ForwardComposition
//새로운 함수를 생성하는 연산자
//탈출클로저 : 함수의 인자가 함수의 영역을 탈출하여 함수 밖에서 사용할 수 있다
func >>><A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> ((A) -> C) {
  return { a in
    g(f(a))
  }
}

//new func
incr >>> square
(incr >>> square)(2)
2 |> incr >>> square



extension Int {
  func incrAndSquare() -> Int {
    return self.incr().square()
  }
}
2.incrAndSquare()
2.incr().square()



[1, 2, 3]
  .map{ ($0 + 1) * ($0 + 1)}


//free func 을 사용하면 함수를 파라미터로 전달해주기만 하면 된다
[1, 2, 3]
  .map(incr)
  .map(square)

[1, 2, 3]
  .map(incr >>> square)
