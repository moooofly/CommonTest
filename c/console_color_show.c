#include <stdio.h>

int main()
{
    printf("\n------------------ 特殊控制代码输出测试 -------------------\n");
    printf("\033[0;33m highlight off (高亮关闭)\033[0m\n");
    printf("\033[1;33m highlight (高亮)\033[0m\n");
    printf("\033[4;33m underline (下划线)\033[0m\n");
    printf("\033[5;33m blink (闪烁)\033[0m\n");
    printf("\033[7;33m reverse (反白)\033[0m\n");
    printf("\033[8;33m invisable (不可见)\033[0m\n");
    printf("------------ lager 中默认日志输出配色方案测试 -------------\n");
    printf("\033[0;38m lager 中 debug 日志级别使用的配色方案 \033[0m\n");
    printf("\033[1;37m lager 中 info 日志级别使用的配色方案 \033[0m\n");
    printf("\033[1;36m lager 中 notice 日志级别使用的配色方案 \033[0m\n");
    printf("\033[1;33m lager 中 warning 日志级别使用的配色方案 \033[0m\n");
    printf("\033[1;31m lager 中 error 日志级别使用的配色方案 \033[0m\n");
    printf("\033[1;35m lager 中 critical 日志级别使用的配色方案 \033[0m\n");
    printf("\033[1;44m lager 中 alert 日志级别使用的配色方案 \033[0m\n");
    printf("\033[1;41m lager 中 emergency 日志级别使用的配色方案 \033[0m\n");
    printf("-----------------------------------------------------------\n\n");

    return 0;
}
