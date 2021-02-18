/** @file memory-array.h
 *  @brief Dynamic memory allocation using an array with fixed record type.
 *
 *  Copyright (C) 2011-2012 GSI Helmholtz Centre for Heavy Ion Research GmbH 
 *
 *  To keep memory management simple, all dynamic objects occupy the same space.
 *  Pointer types can be compactly represented using 16-bit array indexes.
 *  Type-safety is maintained using a gigantic union.
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

#ifndef EB_MEMORY_ARRAY_H
#define EB_MEMORY_ARRAY_H
#ifndef EB_USE_MALLOC

struct eb_free_item {
  EB_POINTER(eb_free_item) next;
};

union eb_memory_item {
  struct eb_operation operation;
  struct eb_cycle cycle;
  struct eb_device device;
  struct eb_socket socket;
  struct eb_socket_aux socket_aux;
  struct eb_handler_callback handler_callback;
  struct eb_handler_address handler_address;
  struct eb_response response;
  struct eb_transport transport;
  struct eb_link link;
  struct eb_sdb_scan sdb_scan;
  struct eb_sdb_record sdb_record;
  struct eb_free_item free_item;
};

#define EB_END_OF_FREE EB_NULL

#ifdef EB_USE_STATIC
EB_PRIVATE extern union eb_memory_item eb_memory_array[];
#else
EB_PRIVATE extern union eb_memory_item* eb_memory_array;
#endif
EB_PRIVATE extern EB_POINTER(eb_memory_item) eb_memory_free;

EB_PRIVATE int eb_expand_array(void);

#define EB_OPERATION(x) (&eb_memory_array[x].operation)
#define EB_CYCLE(x) (&eb_memory_array[x].cycle)
#define EB_DEVICE(x) (&eb_memory_array[x].device)
#define EB_SOCKET(x) (&eb_memory_array[x].socket)
#define EB_SOCKET_AUX(x) (&eb_memory_array[x].socket_aux)
#define EB_HANDLER_CALLBACK(x) (&eb_memory_array[x].handler_callback)
#define EB_HANDLER_ADDRESS(x) (&eb_memory_array[x].handler_address)
#define EB_RESPONSE(x) (&eb_memory_array[x].response)
#define EB_FREE_ITEM(x) (&eb_memory_array[x].free_item)
#define EB_TRANSPORT(x) (&eb_memory_array[x].transport)
#define EB_LINK(x) (&eb_memory_array[x].link)
#define EB_SDB_SCAN(x) (&eb_memory_array[x].sdb_scan)
#define EB_SDB_RECORD(x) (&eb_memory_array[x].sdb_record)

#endif
#endif
