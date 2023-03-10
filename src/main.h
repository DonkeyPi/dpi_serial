#ifndef __MAIN_H__
#define __MAIN_H__

#ifdef __APPLE__
#define _DARWIN_C_SOURCE
#endif

#include <stdarg.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h> 
#include <time.h>
#include <math.h>
#include <pthread.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <termios.h>
#include <fcntl.h>
#include <poll.h>

#include <stdbool.h>
#include <stdint.h>

#define UNUSED(x) (void)(x)
#define UNUSED2(x,y) UNUSED(x);UNUSED(y);
#define UNUSED3(x,y,z) UNUSED(x);UNUSED(y);UNUSED(z);
// #define MAX(x, y) ((x)>(y)?(x):(y))

void dpi_debug(const char* fmt, ...);
void dpi_crash(const char* fmt, ...);

// #define __TRACE_ENABLED__

#ifdef __TRACE_ENABLED__

#define dpi_trace(...) dpi_debug(__VA_ARGS__)
#define dpi_trace_every() dpi_trace("%s:%s tid:%ul", __FILE__, __func__, pthread_self());
#define dpi_trace_once() static bool _##__func__ = false; \
    if (!_##__func__) dpi_trace_every(); \
    _##__func__ = true;

#else

#define dpi_trace(...)
#define dpi_trace_every()
#define dpi_trace_once()

#endif

typedef struct {
  int fd;
  int speed;
  struct termios fdt;
  const char* error;
  const char *path;
  const char *config; // 8N1 | 7E1 | 7O1
} Serial;

void dpi_debug(const char* fmt, ...);
void dpi_crash(const char* fmt, ...);

int serial_baud(int speed);
void serial_open(Serial *serial);

#endif
