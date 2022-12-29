#include "main.h"

#ifdef __linux__

int serial_baud(int speed) 
{
  switch (speed) {
    case 50: return B50;
    case 75: return B75;
    case 110: return B110;
    case 134: return B134;
    case 150: return B150;
    case 200: return B200;
    case 300: return B300;
    case 600: return B600;
    case 1200: return B1200;
    case 1800: return B1800;
    case 2400: return B2400;
    case 4800: return B4800;
    case 9600: return B9600;
    case 19200: return B19200;
    case 38400: return B38400;
    case 57600: return B57600;
    case 115200: return B115200;
    case 230400: return B230400;
    case 460800: return B460800;
    case 500000: return B500000;
    case 576000: return B576000;
    case 921600: return B921600;
    case 1000000: return B1000000;
    case 1152000: return B1152000;
    case 1500000: return B1500000;
    case 2000000: return B2000000;
    case 2500000: return B2500000;
    case 3000000: return B3000000;
    case 3500000: return B3500000;
    case 4000000: return B4000000;
    default: return -1;
  }
}

#endif

#ifdef __APPLE__

int serial_baud(int speed) {
  switch (speed) {
    case 50: return B50;
    case 75: return B75;
    case 110: return B110;
    case 134: return B134;
    case 150: return B150;
    case 200: return B200;
    case 300: return B300;
    case 600: return B600;
    case 1200: return B1200;
    case 1800: return B1800;
    case 2400: return B2400;
    case 4800: return B4800;
    case 7200: return B7200;
    case 9600: return B9600;
    case 14400: return B14400;
    case 19200: return B19200;
    case 28800: return B28800;
    case 38400: return B38400;
    case 57600: return B57600;
    case 76800: return B76800;
    case 115200: return B115200;
    case 230400: return B230400;
    default: return -1;
  }
}
#endif

void serial_open(Serial *serial) 
{
  struct termios *fdt = &serial->fdt;
  memset(fdt, 0, sizeof(struct termios));
  serial->fd = open(serial->path, O_RDWR | O_NOCTTY);
  if (serial->fd < 0) {
    serial->error = "open failed";
    return;
  }
  if (isatty(serial->fd) < 0) {
    serial->error = "isatty failed";
    return;
  }
  if (tcgetattr(serial->fd, fdt) < 0) {
    serial->error = "tcgetattr failed";
    return;
  }

  fdt->c_cflag |= CLOCAL | CREAD;
  fdt->c_lflag &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
  fdt->c_iflag &= ~(INLCR | IGNCR | ICRNL | IXON | IXOFF | IXANY);
  fdt->c_oflag &= ~(ONLCR | OCRNL | OPOST);
 
  int baud = serial_baud(serial->speed);
  if (baud > 0) {
    cfsetispeed(fdt, baud);
    cfsetospeed(fdt, baud);
  } else {
    serial->error = "Invalid speed";
    return;
  }

  // config {8,7}{N,E,O}{1,2}
  switch (serial->config[0]) {
    case '8':
      fdt->c_cflag &= ~CSIZE;
      fdt->c_cflag |= CS8;
      break;
    case '7':
      fdt->c_cflag &= ~CSIZE;
      fdt->c_cflag |= CS7;
      break;
    default:
      serial->error = "Invalid databits";
      return;
  }
  switch (serial->config[1]) {
    case 'N':
      fdt->c_cflag &= ~PARENB;
      break;
    case 'E':
      fdt->c_cflag |= PARENB;
      fdt->c_cflag &= ~PARODD;
      fdt->c_iflag |= INPCK;
      fdt->c_iflag |= ISTRIP;
      break;
    case 'O':
      fdt->c_cflag |= PARENB;
      fdt->c_cflag |= PARODD;
      fdt->c_iflag |= INPCK;
      fdt->c_iflag |= ISTRIP;
      break;
    default:
      serial->error = "Invalid parity";
      return;
  }
  switch (serial->config[2]) {
    case '1':
      fdt->c_cflag &= ~CSTOPB;
      break;
    case '2':
      fdt->c_cflag |= CSTOPB;
      break;
    default:
      serial->error = "Invalid stopbits";
      return;
  }

  // http://unixwiz.net/techtips/termios-vmin-vtime.html
  // blocks until 1 char arrives.
  fdt->c_cc[VMIN] = 1;
  fdt->c_cc[VTIME] = 0;

  if (tcsetattr(serial->fd, TCSANOW, fdt) < 0) {
    serial->error = "tcsetattr failed";
    return;
  }
}
