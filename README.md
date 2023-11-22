# fpga-calculator

A multi-function fpga Calculator capable of addition, subtraction, multiplication, and division.

HBE-Combo II DLD (Xilinx), Verilog HDL

<img src="img/HBE-Combo2-DLD-1024x643.jpg">

## Function definition

- 수의 대상 : 자연수, 정수, 유리수, (무리수), (허수)
- 연산의 종류 : 덧셈, 뺄셈, 곱셈, 나눗셈
- 입출력 : 무한대로 입력받기, 무한대로 출력하기
- 시리얼 통신
- 연산자의 우선순위(스택)

### 자연수의 덧셈, 뺄셈, 곱셈

가장 큰 이슈 : one hot code

### 자연수의 나눗셈

고정소수점 방식 vs 부동소수점 방식

지수형 표현 방식(십의 승수를 이용한 표현(가수, 기수, 승수(지수)))

정규화 표현 방식 : 소수점 이상으로 한 자리만 표현하고 지수를 이용해서 표현하는 방식

### 정수의 사칙연산

### 실수의 사칙연산

### 무리수의 사칙연산

### 연산자의 우선순위

### 데이터 입력 범위, 오버풀로우 발생 범위

## Variable declaration

|Variable|Description|
|---|---|
|||

## Pin setting

<img src="img/pin1.png">

<img src="img/pin2.png">
