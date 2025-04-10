/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2009      Altera Corporation, San Jose, California, USA.      *
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
#include <errno.h>
#include "system.h"

/*
 * Provides an interrupt registry mechanism for the any CPUs internal interrupt
 * controller (IIC).
 */
#ifndef ALT_CPU_EIC_PRESENT

#include "alt_types.h"
#include "sys/alt_irq.h"
#include "sys/alt_warning.h"
#include "priv/alt_iic_isr_register.h"

/** @Function Description:  This function is stubbed to provide HAL compatibility
  * and compilation to succeed, however it will always fail if used by the application
  * since Nios V/c does not provide interrupt support.
  *
  * @API Type:              External
  * @param ic_id            Interrupt controller ID
  * @param irq              IRQ ID number
  * @param isr              Pointer to interrupt service routine
  * @param isr_context      Opaque pointer passed to ISR
  * @param flags            
  * @return                 0 if successful, else error (-1)
  */
int alt_iic_isr_register(alt_u32 ic_id, alt_u32 irq, alt_isr_func isr, 
  void *isr_context, void *flags)
{
  ALT_STUB_WARNING(alt_iic_isr_register);
  
  int rc = -ENOSYS;
  return rc; 
}

#endif /* ALT_CPU_EIC_PRESENT */
