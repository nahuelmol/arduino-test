## arduino-test 

Checking if utilities do exist

```
avr-gcc --version
avr-objcopy --version
avrdude --version
```

For compiling then:
```
avr-g++ -mmcu=atmega328p -DF_CPU=16000000UL -Os -o board_trans.elf board_trans.cpp
```

Later:
```
avr-objcopy -O ihex -R .eeprom main.elf board_trans.hex
```

Then, the following three files will be generated:
```
board_trans.cpp
board_trans.elf
board_trans.hex
```

The next step is uploading the hex to the board. First, check the computer detects the device

```
avrdude -v -p atmega328p -c arduino -P COM<n> -b 115200
```

If everything is right, we should see the next response:
```
avrdude: Device signature = 0x1e950f
```

Upload the .hex to the board by typing what's next:
```
avrdude -p atmega328p -c arduino -P COM<n> -b 115200 -U flash:w:board_trans.hex:i
```

Some Arduinos use 57600 instead of 115200 baud rate. Avrdude does not upload it when baud rate's is the incorrect.

### code

In the code are specific functions for:

* baud rate setting
* ADC setting
