;  File: traffic_light_system.s
; Class: CDA 3104, Fall 2022
;   Dev: Zachary Sutton, Ayleen Roque, Corey Record, Paulo Drefahl
;  Desc: Traffic Light System
; ----------------------------------------------------------
#define __SFR_OFFSET 0
#include <avr/io.h>
#include "vector_table.inc"    
    
 setup:
          sbi       DDRD, DDD0          ; setting PD0 to output (LED 11)
          sbi       DDRD, DDD1          ; setting PD1 to output (LED 10)
          sbi       DDRD, DDD4          ; setting PD4 to output (LED 6)
          sbi       DDRD, DDD5          ; setting PD5 to output (LED 5)
          sbi       DDRD, DDD6          ; setting PD6 to output (LED 4)
          sbi       DDRB, DDB0          ; setting PB0 to output (LED 8)
          sbi       DDRB, DDB1          ; setting PB1 to output (LED 3)
          sbi       DDRB, DDB2          ; setting PB2 to output (LED 2)
          sbi       DDRB, DDB3          ; setting PB3 to output (LED 1)
          sbi       DDRB, DDB4          ; setting PB0 to output (LED 7)
          cbi       DDRD, DDD2          ; clear PD2 to input
          sbi       PORTD, PORTD2       ; enable PD2 pullup (BUTTON 12)
          cbi       DDRD, DDD3          ; clear PD3 to input
          sbi       PORTD, PORTD3       ; enable PD3 pullup (BUTTON 9)
          cbi       DDRC, DDC0          ; clear PC0 to input 
          sbi       PORTC, DDC0         ; enable PC0 pullup (PHOTORESISTOR 13)
          cbi       PORTD, PORTD0       ; turn LED 11 off    
    
setup_Timer1:                           ;timer 1 setup
          clr       r20                 ; set zero in timer1
          sts       TCNT1H, r20         ; counter  
          sts       TCNT1L, r20
    
          ;calculate 0.5 sec
          ; 31249 ---- what we got for 0.5 seconds (500 milliseconds)
          ; in Output Compare Match Registers
          ldi       r20, 0x7A           ; high byte of 500 ms
          sts       OCR1AH, r20         ; OCR1AH 
          ldi       r20, 0x11           ; low byte for 500 ms
          sts       OCR1AL, r20
   
    ; setting CTC mode and clk select 256
          clr       r20                 ; clear r20
          sts       TCCR1A, r20         ; clear WGM11 and WGM10
          ldi       r20, 0b00001100     ; set WGM12 and CS12
          sts       TCCR1B, r20
    
          ldi       r20, 0b00000010       
          sts       TIMSK1, r20         ; for Timer1
    
          sei                           ; enable global interrupts (might not be necessary for this timer)
    
          ldi r18, 0                    ;set timer to 0
          sbi PORTB, PORTB1             ;turn on LED 3
          sbi PORTD, PORTD6             ;turn on LED 4
    
crosswalk_LEDs:
          sbi       PORTB, PORTB4       ;turn on LED 7
          sbi       PORTD, PORTD1       ;turn on LED 10

loop:                   
          
check_button_9:
          sbis      PIND, PIND3         ;Button 9 is pressed
          rjmp      check_north_south
          sbis      PIND, PIND2         ;Button 12 is pressed
          rjmp      check_east_west
          rjmp      end_loop
          
check_north_south:
          sbic      PINB, PINB3         ;check if LED 1 is on
          rjmp      LED_8
          rjmp      end_loop
          
check_east_west:
          sbic      PIND, PIND6         ;check if LED 4 is on
          rjmp      LED_11


end_loop:
          rjmp      loop
              
    
timer_interupt:
          inc       r18                 ;increment timer by  0.5s

          cpi       r18, 1              ;check if timer is at 0.5s
          breq      timer_pt_5
          cpi       r18, 2              ;check if timer is at 1s
          breq      timer_1   
          cpi       r18, 3              ;check if timer is at 1.5s
          breq      timer_1_pt_5
          cpi       r18, 4              ;check if timer is at 2s
          breq      timer_2
          
timer_pt_5:
          rjmp timer_interupt_end     
          
timer_1:
          rjmp timer_interupt_end
          
timer_1_pt_5:
          sbic PINB, PINB1              ;check if LED 3 is on
          rjmp LED_3_on
          sbic PIND, PIND4              ;check if LED 6 is on
          rjmp LED_6_on
          
timer_2:  
          sbic      PIND, PIND6         ;check if LED 4 is on 
          rjmp      east_west
          sbic      PINB, PINB3         ;check if LED 1 is on
          rjmp      north_south
          
timer_interupt_end:
          reti
           
LED_3_on:
          cbi       PORTB, PORTB1       ;turn off LED 3
          sbi       PORTB, PORTB2       ;turn on LED 2
          rjmp timer_interupt_end
                    
LED_6_on:
          cbi       PORTD, PORTD4       ;turn off LED 6
          sbi       PORTD, PORTD5       ;turn on LED 5
          rjmp      timer_interupt_end
          
LED_8:
          sbi       PORTB, PORTB0       ;turn on LED 8
          cbi       PORTB, PORTB4       ;turn off LED 7
          rjmp      end_loop

LED_11:
          sbi       PORTD, PORTD0       ;turn on LED 11
          cbi       PORTD, PORTD1       ;turn off LED 10
          rjmp      end_loop
          
east_west:
          cbi       PORTD, PORTD6       ;turn off LED 4
          cbi       PORTB, PORTB2       ;turn off LED 2
          sbi       PORTD, PORTD4       ;turn on LED 6
          sbi       PORTB, PORTB3       ;turn on LED 1
          
          cbi       PORTD, PORTD0       ;turn on LED 11
          sbi       PORTD, PORTD1       ;turn off LED 10
          
          clr       r18                 ;set timer to 0
          rjmp      timer_interupt_end
    
north_south:
          cbi       PORTB, PORTB3       ;turn off LED 1
          cbi       PORTD, PORTD5       ;turn off LED 5
          sbi       PORTB, PORTB1       ;turn on LED 3
          sbi       PORTD, PORTD6       ;turn on LED 4
          
          cbi       PORTB, PORTB0       ;turn off LED 8
          sbi       PORTB, PORTB4       ;turn on LED 7
          
          clr       r18                 ;set timer to 0
          rjmp      timer_interupt_end