/** @file handler.h
 *  @brief The Etherbone handler data structure.
 *
 *  Copyright (C) 2011-2012 GSI Helmholtz Centre for Heavy Ion Research GmbH 
 *
 *  Handlers have two halves: eb_handler_address and eb_handler_callback.
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

#ifndef EB_HANDLER_H
#define EB_HANDLER_H

#include "../etherbone.h"

typedef EB_POINTER(eb_handler_callback) eb_handler_callback_t;
struct eb_handler_callback {
  eb_user_data_t data;
  
  eb_status_t (*read) (eb_user_data_t, eb_address_t, eb_width_t, eb_data_t*);
  eb_status_t (*write)(eb_user_data_t, eb_address_t, eb_width_t, eb_data_t);
};

typedef EB_POINTER(eb_handler_address) eb_handler_address_t;
struct eb_handler_address {
  const struct sdb_device* device;
  eb_handler_callback_t callback;
  eb_handler_address_t next;
};

#endif
