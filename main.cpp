#include <avr/io.h>
#include <util/delay.h>

const int enPin=8;
const int stepXPin = 2; //X.STEP
const int dirXPin = 5; // X.DIR
const int stepYPin = 3; //Y.STEP
const int dirYPin = 6; // Y.DIR
const int stepZPin = 4; //Z.STEP
const int dirZPin = 7; // Z.DIR

int stepPin=stepYPin;
int dirPin=dirYPin;

const int stepsPerRev=200;
int pulseWidthMicros = 100;
int millisBtwnSteps = 1000;

void setup() {
    DDRB |= (1 << PB0);
    DDRD |= (1 << PD3);
    DDRD |= (1 << PD6);

    PORTB &= ~(1 << PB0);
}

void loop() {
    PORTD |= (1 << PD6);

    for (int i = 0; i < stepsPerRev; i++) {
        PORTB |= (1 << PD3);
        _delay_us(100);
        PORTB &= ~(1 << PD3);
        _delay_us(100);
    }
    _delay_ms(1000);

    PORTD &= ~(1 << PD6);
    for (int i = 0; i < 2*stepsPerRev; i++) {
        PORTB |= (1 << PD3);
        _delay_us(100);
        PORTB &= ~(1 << PD3);
        _delay_us(100);
    }
    _delay_ms(1000);
}

int main() {
    setup();
    while(1) {
        loop();
    }
}
