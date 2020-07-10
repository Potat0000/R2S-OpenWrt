CC = gcc
LD = gcc

SOURCES = main.c SSD1306_OLED_Library/SSD1306_OLED.c I2C_Library/I2C.c
OBJS := $(SOURCES:.c=.o)
CPPFLAGS := -I SSD1306_OLED_Library -I I2C_Library
CFLAGS := -g

screen: $(OBJS)
	$(CC) $^ -o $@

clean:
	rm -rf screen $(OBJS)
