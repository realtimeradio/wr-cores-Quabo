/** @file memory.h
 *  @brief (De-)allocation routines for Etherbone heap objects.
 *
 *  Copyright (C) 2011-2012 GSI Helmholtz Centre for Heavy Ion Research GmbH 
 *
 *  The particular implementation is selected by macro definition.
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

#ifndef EB_MEMORY_H
#define EB_MEMORY_H

#include "../etherbone.h"
#include "../glue/operation.h"
#include "../glue/cycle.h"
#include "../glue/device.h"
#include "../glue/socket.h"
#include "../glue/handler.h"
#include "../glue/sdb.h"
#include "../transport/transport.h"

#include "memory-malloc.h"
#include "memory-array.h"

/* These return EB_NULL on out-of-memory */
EB_PRIVATE eb_operation_t eb_new_operation(void);
EB_PRIVATE eb_cycle_t eb_new_cycle(void);
EB_PRIVATE eb_device_t eb_new_device(void);
EB_PRIVATE eb_handler_callback_t eb_new_handler_callback(void);
EB_PRIVATE eb_handler_address_t eb_new_handler_address(void);
EB_PRIVATE eb_response_t eb_new_response(void);
EB_PRIVATE eb_socket_t eb_new_socket(void);
EB_PRIVATE eb_socket_aux_t eb_new_socket_aux(void);
EB_PRIVATE eb_transport_t eb_new_transport(void);
EB_PRIVATE eb_link_t eb_new_link(void);
EB_PRIVATE eb_sdb_scan_t eb_new_sdb_scan(void);
EB_PRIVATE eb_sdb_record_t eb_new_sdb_record(void);

EB_PRIVATE void eb_free_operation(eb_operation_t x);
EB_PRIVATE void eb_free_cycle(eb_cycle_t x);
EB_PRIVATE void eb_free_device(eb_device_t x);
EB_PRIVATE void eb_free_handler_callback(eb_handler_callback_t x);
EB_PRIVATE void eb_free_handler_address(eb_handler_address_t x);
EB_PRIVATE void eb_free_response(eb_response_t x);
EB_PRIVATE void eb_free_socket(eb_socket_t x);
EB_PRIVATE void eb_free_socket_aux(eb_socket_aux_t x);
EB_PRIVATE void eb_free_transport(eb_transport_t x);
EB_PRIVATE void eb_free_link(eb_link_t x);
EB_PRIVATE void eb_free_sdb_scan(eb_sdb_scan_t x);
EB_PRIVATE void eb_free_sdb_record(eb_sdb_record_t x);

#endif
