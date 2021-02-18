/** @file device.h
 *  @brief The Etherbone device data structure.
 *
 *  Copyright (C) 2011-2012 GSI Helmholtz Centre for Heavy Ion Research GmbH 
 *
 *  Devices are all listed with their associated socket.
 *  They record a connection to a specific target/source bus.
 *  Passive devices never have enqueued cycles for sending.
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

#ifndef EB_DEVICE_H
#define EB_DEVICE_H

#include "../etherbone.h"
#include "../transport/transport.h"

struct eb_device {
  eb_socket_t socket;
  eb_device_t next;
  
  union {
    eb_cycle_t ready;
    eb_device_t passive; /* points to self if a 'server' link */
  } un_link;
  
  uint8_t unready;
  uint8_t widths;
  
  eb_link_t link; /* if connection is broken => EB_NULL */
  eb_transport_t transport;
};

/* Create a new slave device */
EB_PRIVATE eb_link_t eb_device_new_slave(eb_socket_t socketp, eb_transport_t transportp, eb_link_t linkp);

#endif
