# 함수형 프로그래밍 공부

- point free 보면서 학습하기

# 함수형 프로그래밍

## free func vs method
- free func : 파라미터에 함수를 넣어서 체이닝. nested func, 안에서 밖으로 읽어야 하므로 가독성 불편
- method : extension 을 사용하여 오른쪽에 계속 이어서 체이닝 가능. 왼쪽에서 오른쪽으로 읽어서 가독성 용이. 자동완성 기능 제공
- custom 연산자를 사용하여 free func 으로 가독성 유지 가능. 그러나 custom 연산자를 만들 때 신중해야함


## func composition
- 연산자를 통해 기존 함수들을 이용해 새로운 함수를 쉽게 형성한다
- free func 을 이용해서 func composition 을 하는 것이 재사용성이 더 높다
- free func 을 이용하면 함수를 다른 함수의 파라미터로 넣을 수 있으므로 데이터 변형하는 것을 노출시키지 않고 변형이 가능하다
- composition을 하기 위해서는 input 과 output의 타입을 잘 맞춰야 한다
- 타입이 잘 안맞다면 compose 하는 함수를 탈출클로저를 이용해서 구현해서 사용한다
- () 를 안쓰고 싶다면 infix operator 를 사용해라


## side effect
- side effect 가 발생하면 test 하기 어렵다
- side effect 가 발생하면 그것을 드러내기 위해 변형한다. 그 과정에서 composition이 깨진다
- 깨진 composition을 다시 개선하는 연산자를 만들어야 한다
- 참조 타입은 원본을 변형하므로 side effect 가 발생할 가능성이 높다. 따라서 복사해서 번형하는 값타입을 사용하는 것이 안전하다
- 함수의 파라미터를 변형하고 싶다면 inout 을 사용한다


## UI 재사용성 개선하기
- UIAppearance : 뷰 관련 class 의 proxy appearance 에 접근 가능하도록 도와주는 프로토콜
- 각각의 스타일을 함수로 만들어서 func composition 을 사용하라


## type safe
- swift type 을 수학적으로 대체해보자
- Void = 1, 빈 튜플
- Never = 0, 빈 enum

```swift
typealias Void = ()
enum Never {}
```


- 여러 타입을 포함한 컬렉션의 struct 가 몇가지의 경우의 수를 가질 수 있는지를 더욱 명확하고 간단하게 나타내어 런타임 에러의 발생 가능성을 줄일 수 있다
