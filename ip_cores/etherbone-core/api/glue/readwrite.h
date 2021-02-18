/** @file readwrite.h
 *  @brief Process inbound read/write operations.
 *
 *  Copyright (C) 2011-2012 GSI Helmholtz Centre for Heavy Ion Research GmbH 
 *
 *  All methods can assume eb_width_refined.
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

#ifndef EB_READ_WRITE_H
#define EB_READ_WRITE_H

#include "../etherbone.h"

/* Process inbound read/write requests */
EB_PRIVATE eb_data_t eb_socket_read        (eb_socket_t socket, eb_width_t width, eb_address_t addr_b, eb_address_t addr_l,                  uint64_t* error);
EB_PRIVATE void      eb_socket_write       (eb_socket_t socket, eb_width_t width, eb_address_t addr_b, eb_address_t addr_l, eb_data_t value, uint64_t* error);
EB_PRIVATE eb_data_t eb_socket_read_config (eb_socket_t socket, eb_width_t width, eb_address_t addr,                  uint64_t  error);
EB_PRIVATE int       eb_socket_write_config(eb_socket_t socket, eb_width_t width, eb_address_t addr, eb_data_t value);

#endif
