# fpga-calculator

A multi-function fpga Calculator capable of addition, subtraction, multiplication, and division.

HBE-Combo II DLD (Xilinx), Verilog HDL

<img src="img/HBE-Combo2-DLD-1024x643.jpg">

## Function definition

- 수의 대상 : 자연수, 정수, 유리수, (무리수), (허수)
- 연산의 종류 : 덧셈, 뺄셈, 곱셈, 나눗셈
- 입출력 : 무한대로 입력받기
- 시리얼 통신
- 연산자의 우선순위(스택)

### 자연수의 덧셈, 뺄셈, 곱셈

가장 큰 이슈 : one hot code

### 자연수의 나눗셈

지수형 표현 방식(십의 승수를 이용한 표현(가수, 기수, 승수(지수)))

정규화 표현 방식 : 소수점 이상으로 한 자리만 표현하고 지수를 이용해서 표현하는 방식

### 정수의 사칙연산

### 실수의 사칙연산

### 무리수의 사칙연산

### 연산자의 우선순위

### 데이터 입력 범위, 오버풀로우 발생 범위

## Variable declaration

|Declaration|Variable|Description|
|---|---|---|
|reg [3:0]|reg_num|눌린 push 스위치에 해당하는 값이 들어간다.|
|reg [2:0]|reg_opr|눌린 dip 스위치에 해당하는 값이 들어간다.|
||||
|reg [31:0]|reg_trm|항의 값|
|reg |reg_trm_sgn|항의 부호|
|reg [31:0]|reg_trm_mgn|항의 절대값|
||||
|reg [31:0]|reg_rlt|연산 결과를 저장한다.(입력) / -21_4748_3648 ~ 21_4748_3647|
|reg |reg_rlt_sgn|reg_rlt의 부호를 저장한다.|
|reg [31:0]|reg_rlt_mag|reg_rlt의 값을 저장한다. reg_rlt와 같은 32비트로 선언된다.|
|reg [127:0]|reg_rlt_bcd|연산 결과를 bcd로 저장한다.(출력) / LCD line2의 16칸에 들어갈 10진수 값을 위한 코드이다. 1칸 당 상위 4비트에는 0000을 할당하고 하위 4비트에는 bcd를 할당하여, 총 8비트를 할당한다. bcd가 십진수 한 자리 당 4비트인데 반해, 1칸 당 8비트씩 할당하는 이유는 각 자릿수 값에 8'b0011_0000를 더함으로써 바로 ascii 코드로 바꿀 수 있기 때문이다.|
|||
|reg [7:0]|reg_lcd_swp|push 스위치에서 해당하는 아스키 코드가 들어있다.|
|reg [7:0]|reg_lcd_swd|dip 스위치에서 해당하는 아스키 코드가 들어있다.|
|reg [7:0]|reg_lcd|lcd에 띄울 아스키 값이 들어간다. reg_lcd_swp 또는 reg_lcd_swd에 들어 있는 8비트 아스키 값이 들어간다.|

## Code explanatinon

## Binary to BCD(Double dabble algorithm)

Result

```md
Hundreds Tens Ones   Original
  0010   0100 0011   11110011
```

243

```md
0000 0000 0000   11110011   Initialization
0000 0000 0001   11100110   Shift
0000 0000 0011   11001100   Shift
0000 0000 0111   10011000   Shift
0000 0000 1010   10011000   Add 3 to ONES, since it was 7
0000 0001 0101   00110000   Shift
0000 0001 1000   00110000   Add 3 to ONES, since it was 5
0000 0011 0000   01100000   Shift
0000 0110 0000   11000000   Shift
0000 1001 0000   11000000   Add 3 to TENS, since it was 6
0001 0010 0001   10000000   Shift
0010 0100 0011   00000000   Shift
   2    4    3
       BCD
```

24310

```md
0000 0000 0000   11110011   Initialization
0000 0000 0001   11100110   Shift
0000 0000 0011   11001100   Shift
0000 0000 0111   10011000   Shift
0000 0000 1010   10011000   Add 3 to ONES, since it was 7
0000 0001 0101   00110000   Shift
0000 0001 1000   00110000   Add 3 to ONES, since it was 5
0000 0011 0000   01100000   Shift
0000 0110 0000   11000000   Shift
0000 1001 0000   11000000   Add 3 to TENS, since it was 6
0001 0010 0001   10000000   Shift
0010 0100 0011   00000000   Shift
   2    4    3
       BCD
```

각 반복에서 왼쪽의 BCD 값을 두 배로 만들고 원래 비트 패턴에 따라 1 또는 0을 추가하여 동시에 두 작업을 수행한다. 왼쪽으로 쉬프트하는 것으로 두 작업을 동시에 수행한다. 어떤 숫자가 5 이상인 경우 10진수에서 전파되도록 3이 추가된다.

1. 변환할 원래 숫자가 n 비트로 된 레지스터에 저장되어 있다고 가정한다. 원래 숫자와 해당 BCD 표현을 모두 수용할 수 있는 크기의 스크래치 공간을 예약한다. 여기에는 n + 4 x ceil(n/3) 비트가 필요하다.
2. 스크래치 공간을 BCD 자릿수와 원래 레지스터로 분할 한다.
3. 스크래치 공간을 모두 0으로 초기화한다.
4. 알고리즘을 n번 반복한다. 각 반복에서 최소 5인 모든 bCD 자릿수는 3이 추가된다. 그런 다음 전체 스크래치 공간이 한 비트 왼쪽으로 이동한다.

## Pin setting

<img src="img/pin1.png">

<img src="img/pin2.png">
