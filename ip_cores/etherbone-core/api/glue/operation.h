/** @file operation.h
 *  @brief The Etherbone operation data structure.
 *
 *  Copyright (C) 2011-2012 GSI Helmholtz Centre for Heavy Ion Research GmbH 
 *
 *  Operations record everything needed to format them into a request.
 *  They also serve the double-role of reporting result status to callbacks.
 *
 *  @author Wesley W. Terpstra <w.terpstra@gsi.de>
 *
 *  @bug None!
 *
 *******************************************************************************
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 3 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 *  
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library. If not, see <http://www.gnu.org/licenses/>.
 *******************************************************************************
 */

#ifndef EB_OPERATION_H
#define EB_OPERATION_H

#include "../etherbone.h"

typedef uint8_t eb_operation_flags_t;
#define EB_OP_WRITE	0x00
#define EB_OP_READ_PTR	0x01
#define EB_OP_READ_VAL	0x02
#define EB_OP_MASK      0x03

#define EB_OP_CFG_SPACE	0x04
#define EB_OP_ERROR	0x08
#define EB_OP_CHECKED	0x10

struct eb_operation {
  eb_address_t address;
  union {
    eb_data_t  write_value;
    eb_data_t  read_value;
    eb_data_t* read_destination;
  } un_value;
  
  eb_operation_flags_t flags;
  eb_format_t format;
  eb_operation_t next;
};

EB_PRIVATE eb_operation_t eb_find_bus(eb_operation_t op);
EB_PRIVATE eb_operation_t eb_find_read(eb_operation_t op);

#endif
