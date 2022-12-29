#include "main.h"

char* ash_arg(const char *str, const char *pre)
{
  int len = strlen(pre);
  if (strncmp(str, pre, len) != 0) return NULL;
  return (char *)str + len;
}

#define DATA_LEN 256

//ash_serial --path=/dev/ttyUSB0 --config=8N1 --speed=9600
int main(int argc, char *argv[]) 
{
  UNUSED(argc);
  Serial serial = {0};
  serial.path = "/dev/ttyS0";
  serial.config = "8N1";
  serial.speed = 9600;
  for(int i=1; i<argc; i++)
  {
    char *p;
    p = ash_arg(argv[i], "--path=");
    if (p != NULL) serial.path = p;
    p = ash_arg(argv[i], "--config=");
    if (p != NULL) serial.config = p;
    p = ash_arg(argv[i], "--speed=");
    if (p != NULL) serial.speed = atoi(p);
  }
  serial_open(&serial);
  if (serial.error != NULL) 
  {
    ash_crash("%s %s %d: %s", serial.path, serial.config, serial.speed, serial.error);
  }
  char* data[DATA_LEN];
  struct pollfd fds[2];
  fds[0].fd = 0;
  fds[0].events = POLLIN | POLLHUP;
  fds[1].fd = serial.fd;
  fds[1].events = POLLIN | POLLHUP;
  while(1) {
    int r = poll(fds, 2, -1);
    if (r < 0) ash_crash("events poll");
    if (fds[0].revents & POLLHUP) break;
    if (fds[1].revents & POLLHUP) break;
    if (fds[0].revents & POLLIN) {
        int rn = read(0, data, DATA_LEN);
        if (rn <= 0) break;
        int wn = write(serial.fd, data, rn);
        if (wn != rn) ash_crash("fds[0] wn %d != rn %d", wn, rn);
    }
    if (fds[1].revents & POLLIN) {
        int rn = read(serial.fd, data, DATA_LEN);
        if (rn <= 0) break;
        int wn = write(1, data, rn);
        if (wn != rn) ash_crash("fds[1] wn %d != rn %d", wn, rn);
    }
  }
  exit(1);
  return 0;
}
