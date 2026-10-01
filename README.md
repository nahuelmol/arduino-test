#arduino-test 

checking compilers

```
avr-gcc --version
avr-objcopy --version
avrdude --version
```

For compiling then:
```
avr-g++ -mmcu=atmega328p -DF_CPU=16000000UL -Os -o main.elf main.cpp
```

Later:
```
avr-objcopy -O ihex -R .eeprom main.elf main.hex
```

The directory will have the following thre files:
```
main.cpp
main.elf
main.hex
```

```
avrdude -v -p atmega328p -c arduino -P COM<n> -b 115200
```

If everthing's okey we should see something as follows:
```
avrdude: Device signature = 0x1e950f
```

Upload the .hex to the board by typing the following:
```
avrdude -p atmega328p -c arduino -P COM<n> -b 115200 -U flash:w:main.hex:i
```

Some arduinos use 57600 instead of 115200 baudios. Check it
