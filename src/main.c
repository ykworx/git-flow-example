#include <stdio.h>
#include "version.h"

int main(int argc, char *argv[])
{
  printf("Hello World Version : %s\n", version_string); 
  printf("MAJOR %d MINOR %d PATCH %d\n", APP_VERSION_MAJOR,
      APP_VERSION_MINOR,
      APP_VERSION_PATCH);
  printf("TEST 1");
}
