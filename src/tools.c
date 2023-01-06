#include "main.h"

void dpi_debug(const char* fmt, ...) 
{
    va_list ap;
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    fprintf(stderr, "\r\n");
    //synchronized or performant?
    fflush(stderr);
}

void dpi_crash(const char* fmt, ...) 
{
    va_list ap;
    va_start(ap, fmt);
    fprintf(stderr, "crash: ");
    vfprintf(stderr, fmt, ap);
    fprintf(stderr, "\r\n");
    fprintf(stderr, "error: %d %s", errno, strerror(errno));
    fprintf(stderr, "\r\n");
    fflush(stderr);
    exit(-1);
    abort();
}
