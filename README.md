# Semiconductor System Design Project 2026

On-Device AI 반도체 시스템 설계 과정에서 진행한 **RTL 설계 · SoC 통합 · UVM 검증** 실습을 정리한 저장소입니다.
조합/순차 회로 기초부터 RV32I CPU, AXI4-Lite 기반 SoC, UVM 검증 환경까지 약 7개월간의 학습 과정을 단계별로 담았습니다.

> 직렬 통신 IP 설계, 버스 연동, 검증 환경 구축 등 실무에 가까운 작업을 포함하고 있습니다.

---

## 📁 레포 구성

| 폴더 | 영역 | 핵심 내용 |
|------|------|-----------|
| [`2026_Verilog_Project`](./2026_Verilog_Project) | RTL 설계 기초 | FSM, FIFO, UART, 센서 컨트롤러(SR04/DHT11), Basys-3 구현 |
| [`2026_System_Verilog_Project`](./2026_System_Verilog_Project) | SoC 설계 | RV32I CPU, SPI/I2C IP, AXI4-Lite, MicroBlaze 연동 |
| [`2026_UVM_Project`](./2026_UVM_Project) | 검증 (Verification) | UVM 기반 Adder/RAM/UART/SPI/I2C/AXI4-SPI 검증 환경 |

---

## 🔹 2026_Verilog_Project — RTL 설계 기초

Verilog/SystemVerilog 문법과 디지털 설계 기본기를 다지고, Basys-3 보드에 직접 구현한 실습 모음입니다.

| 구분 | 주요 항목 |
|------|-----------|
| 조합·순차 회로 | blocking/non-blocking, Adder, FND 출력, 카운터, 클럭 분주 |
| FSM | Moore / Mealy 머신, ASM 기반 상태 설계 (HW 구현 포함) |
| 메모리 | 단일포트 RAM |
| 주변장치 컨트롤러 | UART, FIFO, SR04 초음파, DHT11 온습도, Stopwatch/Watch |
| 통합 프로젝트 | UART + FIFO, Stopwatch + SR04 + DHT11 통합 시스템 |

📌 *제약 조건 파일(`Basys-3-Master.xdc`) 포함 — 실제 FPGA 합성/구현까지 진행*

---

## 🔹 2026_System_Verilog_Project — SoC 설계

직렬 통신 IP를 직접 설계하고 AXI4-Lite 버스에 래핑해 MicroBlaze SoC와 연동하는, 본 과정의 중심이 되는 영역입니다.

| 구분 | 주요 항목 |
|------|-----------|
| SV 문법·검증 기초 | 8bit register, SRAM, race condition, OOP, FIFO(SV) |
| CPU 설계 | Dedicated CPU, **RV32I Single-Cycle / Multi-Cycle** (개인·팀) |
| 직렬 통신 IP | **SPI Master/Slave, I2C Master/Slave** 설계 및 디버깅 |
| 버스 / SoC 통합 | **AXI4-Lite** 슬레이브, AXI4-GPIO, AXI4-Lite UART |
| MicroBlaze 연동 | GPIO, Timer Counter, Timer Interrupt |
| IP화 | SPI / I2C / UART의 AXI4-Lite IP 패키징 |

📌 *RTL 설계 → AXI 래핑 → MicroBlaze C 펌웨어까지 SoC 전 계층을 직접 다룬 작업이 포함되어 있습니다.*

---

## 🔹 2026_UVM_Project — 검증 (Verification)

SystemVerilog 기반 UVM 검증 방법론을 적용해, 단순 모듈부터 프로토콜 IP까지 검증 환경을 직접 구축한 영역입니다.

| 구분 | 주요 항목 |
|------|-----------|
| UVM 기초 | Adder, Counter — Agent/Driver/Monitor/Scoreboard 구조 학습 |
| 메모리 검증 | RAM, APB-RAM 검증 환경 |
| 프로토콜 검증 | **UART, SPI, I2C, AXI4-SPI** UVM 환경 (seq_item ~ coverage 전 계층) |

📌 *Monitor 샘플링 타이밍, 핸드셰이크 동기화 등 검증 환경 구축 과정에서 마주한 문제와 해결 과정을 코드와 함께 남겼습니다.*

---

## 🛠 사용 도구

`SystemVerilog` · `Verilog` · `UVM` · `Vivado` · `MicroBlaze` · `Basys-3 (Artix-7)` · `C (펌웨어)`
