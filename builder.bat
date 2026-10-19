@echo off
echo [1/4] Compiling trans code...
avr-g++ -mmcu=atmega328p -DF_CPU=16000000UL -Os -o board_trans.elf board_trans.cpp

if %errorlevel% neq 0 (
    echo Error with trans.
    pause
    exit /b %errorlevel%
)

echo [2/4] Generating HEX files...
avr-objcopy -O ihex -R .eeprom board_trans.elf board_trans.hex

echo [3/4] Uploading the HEX...
avrdude -p atmega328p -c arduino -P COM5 -b 115200 -U flash:w:board_trans.hex:i

echo ========================================
echo [4/4] Process finished.
pause
