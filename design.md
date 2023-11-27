# Calculator Design

## 1. Functional definition and Design specification

- 사칙 연산 : 자연수 → 정수 → 유리수 → 무리수 → 허수
- 무한대로 입력받기
- 가수, 기수, 지수 양식으로 표현하기
- delete button
- shift button을 이용해서 연산자를 push switch로 입력받기
- 커서 이동시키며 수정하기(원형큐)
- 시리얼 통신
- 화살표로 커서 이동시켜서 입력값 수정 기능

## 2. 상태 정의

123+-456x789=

### 상위 상태 머신

0. [state0] init <- 초기 상태
1. [state1] operand <- 피연산자 입력
2. [state2] operator <- 연산자 입력
3. [state3] result <- 등호 입력

### 하위 상태 머신

[state1] operand

언제 입력될지 모른다, 결과가 입력에 의존한다. -> 밀리 상태 머신

[state2] operator

1. state1 : reg_trm_mgn를 갱신한다.
2. state2 : reg_trm_sgn을 고려하여 reg_trm을 결정한다.
3. state3 : reg_rlt를 갱신한다.

[state3] result

-> 무어 상태 기계(현재 상태에 의해서만 출력이 결정된다.)

1. state1 : reg_trm_mgn를 갱신한다.
2. state2 : reg_trm_sgn을 고려하여 reg_trm을 결정한다.
3. state3 : 최종 reg_rlt를 계산한다.
4. state4 : reg_rlt_mgn과 reg_rlt_sgn을 계산한다.
