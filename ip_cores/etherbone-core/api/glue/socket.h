/** @file socket.h
 *  @brief The Etherbone socket data structure.
 *
 *  Copyright (C) 2011-2012 GSI Helmholtz Centre for Heavy Ion Research GmbH 
 *
 *  Etherbone sockets are composed of two halves: eb_socket and eb_socket_aux.
 *  This split was made so that every dynamically allocated object is roughly
 *  the same size, easing the internal memory management implementation.
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

#ifndef EB_SOCKET_H
#define EB_SOCKET_H

#include "../etherbone.h"
#include "../transport/transport.h"
#include "handler.h"

/* The size of space that sdb_offset points to */
#define SDB_REQUIRED_SIZE 65536

typedef EB_POINTER(eb_response) eb_response_t;
struct eb_response {
  /* xxxxxxxxxxxxxxxL
   * L=0 means read-back
   * L=1 means status-back
   */
  uint16_t address;
  uint16_t deadline; /* Low 16-bits of a UTC seconds counter */
  
  eb_response_t next;
  eb_cycle_t cycle;
  
  eb_operation_t write_cursor;
  eb_operation_t status_cursor;
};

typedef EB_POINTER(eb_socket_aux) eb_socket_aux_t;
struct eb_socket_aux {
  eb_address_t sdb_offset;
  uint32_t time_cache;
  uint16_t rba;
  
  eb_transport_t first_transport;
};

struct eb_socket {
  eb_device_t first_device;
  eb_handler_address_t first_handler; /* in ascending order, non-overlapping */
  
  /* Functional-style queue using lists */
  eb_response_t first_response;
  eb_response_t last_response;
  
  eb_socket_aux_t aux;
  uint8_t widths;
};

/* Invert last_response, suitable for attaching to the end of first_response */
EB_PRIVATE eb_response_t eb_response_flip(eb_response_t firstp);

/* Kill all responses inflight for this device */
EB_PRIVATE void eb_socket_kill_inflight(eb_socket_t socketp, eb_device_t devicep);

#endif
