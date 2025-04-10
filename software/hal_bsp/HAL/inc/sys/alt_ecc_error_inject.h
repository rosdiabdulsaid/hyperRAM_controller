#ifndef _ALT_ECC_ERROR_INJECT_H_
#define _ALT_ECC_ERROR_INJECT_H_

/*
 * Copyright (c) 2024 Altera Corporation, San Jose, California, USA.  
 * All rights reserved.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to 
 * deal in the Software without restriction, including without limitation the 
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is 
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in 
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
 * DEALINGS IN THE SOFTWARE.
 */

#include "alt_types.h"
#include "system.h"

/*
 * The following enumeration describes the value in the mtval2
 * for ECC error. The same value could be used for ECC error injection.
 */
enum alt_ecc_error_type_e {
	NIOSV_GPR_ECC_UNCORRECTABLE_ERROR						= 1,
	NIOSV_FPR_ECC_UNCORRECTABLE_ERROR						= 3,
	NIOSV_VPR_ECC_UNCORRECTABLE_ERROR						= 5,
	NIOSV_CSR_ECC_UNCORRECTABLE_ERROR						= 7,
	NIOSV_INSTRUCTION_TCM1_CORRECTABLE_ERROR				= 16,
	NIOSV_INSTRUCTION_TCM1_UNCORRECTABLE_ERROR				= 17,
	NIOSV_INSTRUCTION_TCM2_CORRECTABLE_ERROR				= 18,
	NIOSV_INSTRUCTION_TCM2_UNCORRECTABLE_ERROR				= 19,
	NIOSV_DATA_TCM1_CORRECTABLE_ERROR						= 24,
	NIOSV_DATA_TCM1_UNCORRECTABLE_ERROR						= 25,
	NIOSV_DATA_TCM2_CORRECTABLE_ERROR						= 26,
	NIOSV_DATA_TCM2_UNCORRECTABLE_ERROR						= 27,
	NIOSV_INSTRUCTION_CACHE_TAG_RAM_UNCORRECTABLE_ERROR		= 33,
	NIOSV_INSTRUCTION_CACHE_DATA_RAM_UNCORRECTABLE_ERROR	= 35,
	NIOSV_INSTRUCTION_CACHE_LOAD_CORRECTABLE_ERROR			= 36,
	NIOSV_INSTRUCTION_CACHE_LOAD_UNCORRECTABLE_ERROR		= 37,
	NIOSV_DATA_CACHE_TAG_RAM_UNCORRECTABLE_ERROR			= 41,
	NIOSV_DATA_CACHE_DATA_RAM_UNCORRECTABLE_ERROR			= 43,
	NIOSV_DATA_CACHE_LOAD_CORRECTABLE_ERROR					= 44,
	NIOSV_DATA_CACHE_LOAD_UNCORRECTABLE_ERROR				= 45,
	NIOSV_DATA_CACHE_STORE_CORRECTABLE_ERROR				= 46,
	NIOSV_DATA_CACHE_STORE_UNCORRECTABLE_ERROR				= 47
};
typedef enum alt_ecc_error_type_e alt_ecc_error_type;

void alt_ecc_error_inject(alt_ecc_error_type error_type);

#endif /* _ALT_ECC_ERROR_INJECT_H_ */
