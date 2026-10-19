#include <avr/io.h>
#include <util/delay.h>

void UART_init(unsigned int ubrr) {
    UBRR0H = (unsigned char)(ubrr >> 8);
    UBRR0L = (unsigned char)ubrr;
    UCSR0B = (1 << RXEN0) | (1 << TXEN0);
    UCSR0C = (1 << UCSZ01) | (1 << UCSZ00);
}

void UART_transmit(unsigned char data) {
    while (!(UCSR0A & (1 << UDRE0)));
    UDR0 = data;
}

void UART_print(const char* str) {
    while (*str != 0) {
        UART_transmit(*str);
        str++;
    }
}

void UART_printNumber(int num) {
    char buffer[7];
    char* p = buffer + 6;
    *p = '\0';
    
    if (num == 0) {
        *--p = '0';
    } else {
        while (num > 0) {
            *--p = '0' + (num % 10);
            num /= 10;
        }
    }
    UART_print(p);
}

void ADC_init(void) {
    ADMUX = (1 << REFS0);
    ADCSRA = (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0);
}

unsigned int ADC_read(unsigned char channel) {
    ADMUX = (ADMUX & 0xF0) | (channel & 0x0F);
    ADCSRA |= (1 << ADSC);
    
    while (ADCSRA & (1 << ADSC));
    
    return ADC;
}

int main(void) {
    UART_init(103);
    
    ADC_init();

    while (1) {
        unsigned int valorSensor = ADC_read(0);
        
        UART_print("Value A0: ");
        UART_printNumber(valorSensor);
        UART_print("\r\n");
        
        _delay_ms(500);
    }
}

