/*
 * main.c
 *
 *  Description : R2S Screen Control
 *  Author      : Gyj1109
 */

/* Lib Includes */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <signal.h>

/* Header Files */
#include "I2C.h"
#include "SSD1306_OLED.h"
#define BUFMAX SSD1306_LCDWIDTH*SSD1306_LCDHEIGHT

// 'eth0' for the side port, 'eth1' for the middle port, 'br_lan' for the total.
const char eth_port[] = "eth0";
// Just as a waiting time, the time spent in data collection is not considered.
const float flush_time = 0.5;

static volatile sig_atomic_t keep_running = 1;
static void sig_handler(int _) {
    (void)_;
    keep_running = 0;
}

FILE *fp;
char content_buff[BUFMAX];
char buf[BUFMAX];
long long up_time1, up_time2, down_time1, down_time2;
double delta_up_time, delta_down_time;

int main() {
    if(init_i2c_dev(I2C_DEV0_PATH, SSD1306_OLED_ADDR) != 0) {
        printf("R2S Screen Control: OOPS! Something Went Wrong!\r\n");
        exit(1);
    }

    display_Init_seq();
    clearDisplay();

    setTextSize(1);
    setTextColor(WHITE);
    setTextWrap(false);

    char down_command[120], up_command[120];
    strcpy(down_command, "ifstat -i ");
    strcat(down_command, eth_port);
    strcat(down_command, " -t 0.1 1 | tail -n 1 | tr -s ' ' | cut -d ' ' -f ");
    strcpy(up_command, down_command);
    strcat(down_command, "2");
    strcat(up_command, "3");

    signal(SIGINT, sig_handler);
    while (keep_running) {
        clearDisplay();
        setCursor(0,0);

        memset(content_buff, 0, BUFMAX);
        memset(buf, 0, BUFMAX);
        if((fp=popen("cat /sys/devices/system/cpu/cpu[04]/cpufreq/cpuinfo_cur_freq", "r")) != NULL) {
            fgets(content_buff, 8, fp);
            fclose(fp);
            sprintf(buf, "   Freq:  %4d MHz", atoi(content_buff) / 1000);
            print_strln(buf);
        }

        memset(content_buff, 0, BUFMAX);
        memset(buf, 0, BUFMAX);
        if((fp=popen("cat /sys/class/thermal/thermal_zone0/temp", "r")) != NULL) {
            fgets(content_buff, 5, fp);
            fclose(fp);
            sprintf(buf, "   Temp: %.2f C", atoi(content_buff) / 100.0);
            print_strln(buf);
            drawCircle(88, 9, 1, WHITE);
        }

        memset(content_buff, 0, BUFMAX);
        memset(buf, 0, BUFMAX);
        if((fp=popen(up_command, "r")) != NULL) {
            fgets(content_buff, 8, fp);
            fclose(fp);
            if (atof(content_buff) >= 1000) {
                sprintf(buf, "    Up: %6.2f MB/s", atof(content_buff) / 1024);
            } else {
                sprintf(buf, "    Up: %6.2f KB/s", atof(content_buff));
            }
            print_strln(buf);
        }

        memset(content_buff, 0, BUFMAX);
        memset(buf, 0, BUFMAX);
        if((fp=popen(down_command, "r")) != NULL) {
            fgets(content_buff, 8, fp);
            fclose(fp);
            if (atof(content_buff) >= 1000) {
                sprintf(buf, "   Down:%6.2f MB/s", atof(content_buff) / 1024);
            } else {
                sprintf(buf, "   Down:%6.2f KB/s", atof(content_buff));
            }
            print_strln(buf);
        }

        Display();
        usleep(flush_time * 1000000);
    }
    clearDisplay();
    setCursor(0,0);
    Display();
    printf("\n");
}
