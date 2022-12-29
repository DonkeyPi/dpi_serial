#include "main.h"

#define DATA_LEN 256

//ash_serial /dev/ttyUSB0 8N1 9600
int main(int argc, char *argv[]) 
{
  UNUSED(argc);
  Serial serial = {0};
  serial.path = argv[1];
  serial.config = argv[2];
  serial.speed = atoi(argv[3]);
  serial_open(&serial);
  if (serial.error != NULL) 
  {
    ash_crash(serial.error);
  }
  char* data[DATA_LEN];
  struct pollfd fds[2];
  fds[0].fd = 0;
  fds[0].events = POLLIN;
  fds[1].fd = serial.fd;
  fds[1].events = POLLIN;
  while(1) {
    int r = poll(fds, 2, -1);
    if (r < 0) ash_crash("events poll");
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
