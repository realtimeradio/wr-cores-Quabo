/** @file cycle.h
 *  @brief The Etherbone cycle data structure.
 *
 *  Copyright (C) 2011-2012 GSI Helmholtz Centre for Heavy Ion Research GmbH 
 *
 *  Record callback information and contain queued operations.
 *  Cycles are queued on a device once closed.
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

#ifndef EB_CYCLE_H
#define EB_CYCLE_H

#include "../etherbone.h"

struct eb_cycle {
  eb_callback_t callback;
  eb_user_data_t user_data;
  
  /* if points to cycle, means OOM */  
  union {
    eb_operation_t first; 
    eb_cycle_t dead;
  } un_ops;
  
  union {
    eb_cycle_t next;
    eb_device_t device;
  } un_link;
};

/* Recursively free the operations. Does not free cycle. */
EB_PRIVATE void eb_cycle_destroy(eb_cycle_t cycle);

#endif
