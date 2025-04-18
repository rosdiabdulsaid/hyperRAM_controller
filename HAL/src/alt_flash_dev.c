/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2004 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
*                                                                             *
* Altera does not recommend, suggest or require that this reference design    *
* file be used in conjunction or combination with any other product.          *
******************************************************************************/

/******************************************************************************
*                                                                             *
* Alt_flash.c - Functions to register a flash device to the "generic" flash   *
*               interface                                                     *
*                                                                             *
* Author PRR                                                                  *
*                                                                             *
******************************************************************************/

#include <errno.h>
#include "sys/alt_llist.h"
#include "sys/alt_flash_dev.h"
#include "priv/alt_file.h"

ALT_LLIST_HEAD(alt_flash_dev_list);

alt_flash_fd* alt_flash_open_dev(const char* name)
{
  alt_flash_dev* dev = (alt_flash_dev*)alt_find_dev(name, &alt_flash_dev_list);

  if ((dev) && dev->open)
  {
    return dev->open(dev, name);
  }

  return dev;
}

void alt_flash_close_dev(alt_flash_fd* fd)
{
  if (fd && fd->close)
  {
    fd->close(fd);
  }
  return;
}

int alt_flash_device_register( alt_flash_fd* fd)
{
  return alt_dev_llist_insert ((alt_dev_llist*) fd, &alt_flash_dev_list);
}


