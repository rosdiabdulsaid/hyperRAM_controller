/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2024 Altera Corporation, San Jose, California, USA.      *
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
******************************************************************************/

/* 
 * This is for handling ECC exception. The code is pulled in at the beginning
 * of trap_vector when ALT_CPU_ECC_PRESENT is defined (ECC Full is enabled).
 */

#include "system.h"

#ifdef ALT_CPU_ECC_PRESENT

    .section .exceptions.entry.ecc_fatal, "xa"
    .align 2

	/* Clear the alt_ecc_inject CSR */
	csrwi 0x7C0, 0

	/* Flush the CPU pipeline as there will be other instructions with
	 * the ECC-exception bit set in the CPU pipe.
	 */
	fence.i

	/* save t0 into mscratch */
	csrw mscratch, t0

	/* mcause == 19 is ECC exception */
	csrr t0, mcause
	addi t0, t0, -19
	bne t0, x0, alt_not_ecc_exception

	/* Load alt_ecc_exception_handler value/address */
    lui t0, %hi(alt_ecc_exception_handler)
    lw t0, %lo(alt_ecc_exception_handler)(t0)

    /* Check if alt_ecc_exception_handler is not zero */
    bnez t0, jump_to_ecc_handler

    /* If alt_ecc_fatal_exception_handler is zero (the handler is not
	 * registered), the operation must stop here.
	 */
    ebreak

jump_to_ecc_handler:
    /* Jump to t0 to invoke alt_ecc_exception_handler.
	 * The ra register woudn't be modified as we expect the handler wouldn't
	 * return. If it does return, the operation must stop here.
	 */
	jalr x0, t0
	ebreak

/* If the handler able to correct/recover the error, adding jump operation to
 * this label (j alt_not_ecc_exception) to continue normal exception operation.
 */
.globl alt_not_ecc_exception
alt_not_ecc_exception:
	/* Restore t0 */
	csrr t0, mscratch

/*
 * There is a concrete alt_ecc_exception_register() function implemented in
 * alt_ecc_error_inject.c. By doing this, it tells linker that above code need
 * to be pulled in at the beggining of trap_vector and included in the
 * compilation.
 */
.weak alt_ecc_exception_register
alt_ecc_exception_register:

#endif /*ALT_CPU_ECC_PRESENT*/
