/** @file sdb.c
 *  @brief Implement the SDB data structure on the local bus.
 *
 *  Copyright (C) 2011-2012 GSI Helmholtz Centre for Heavy Ion Research GmbH 
 *
 *  We reserved the low 8K memory region for this device.
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

#ifndef SDB_H
#define SDB_H

#include "../etherbone.h"

typedef EB_POINTER(eb_sdb_scan) eb_sdb_scan_t;
struct eb_sdb_scan {
  eb_user_data_t user_data;
  sdb_callback_t cb;
  eb_address_t bus_base;
};

typedef EB_POINTER(eb_sdb_record) eb_sdb_record_t;
struct eb_sdb_record {
  eb_sdb_scan_t scan;
  eb_operation_t ops;
  int32_t status;
  uint16_t pending;
  uint16_t records;
};

EB_PRIVATE eb_data_t eb_sdb(eb_socket_t socket, eb_width_t width, eb_address_t addr);

#endif
