/** @file transport.h
 *  @brief An abstract interface transport bindings can implement.
 *
 *  Copyright (C) 2011-2012 GSI Helmholtz Centre for Heavy Ion Research GmbH 
 *
 *  The eb_transport_ops serves the purpose of a manual C++ vtable.
 *  All supported transports are included in the global eb_transports[].
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

#ifndef EB_TRANSPORT_H
#define EB_TRANSPORT_H

#include "../etherbone.h"

/* The exact use of these 12-bytes is specific to the transport */
typedef EB_POINTER(eb_link) eb_link_t;
struct eb_link {
  uint8_t raw[12];
};

/* The exact use of these 8-bytes is specific to the transport */
typedef EB_POINTER(eb_transport) eb_transport_t;
struct eb_transport {
  uint8_t raw[9];
  uint8_t link_type;
  eb_transport_t next;
};

/* Each transport provides these methods */
struct eb_transport_ops {
   int mtu; /* if 0, streaming is assumed */
   
   /* ADDRESS -> simply not included. Other errors reported to user. */
   eb_status_t (*open) (struct eb_transport* transport, const char* port);
   void        (*close)(struct eb_transport* transport);

   /* ADDRESS -> simply not used. Other errors reported to user. */
   eb_status_t (*connect)   (struct eb_transport*, struct eb_link* link, const char* address, int passive); 
   void        (*disconnect)(struct eb_transport*, struct eb_link* link);
   
   /* File descriptor to wait on */
   void (*fdes)(struct eb_transport*, struct eb_link* link, eb_user_data_t data, eb_descriptor_callback_t cb);
   
   /* IO functions. -1 means close link. 0 means no data at the moment. */
   int  (*accept)(struct eb_transport*, struct eb_link* out,  eb_user_data_t data, eb_descriptor_callback_t ready);
   int  (*poll)  (struct eb_transport*, struct eb_link* link, eb_user_data_t data, eb_descriptor_callback_t ready, uint8_t* buf, int len);
   int  (*recv)  (struct eb_transport*, struct eb_link* link,                                                      uint8_t* buf, int len);
   
   /* We flushing a device, we do: send_buffer(1) send() send() send() send_buffer(0) */
   /* This allows for a clear demarkation of where the socket should enable/disable buffering */
   void (*send)(struct eb_transport*, struct eb_link* link, const uint8_t* buf, int len);
   void (*send_buffer)(struct eb_transport*, struct eb_link* link, int start); /* upon creation, should be 0 */
};

/* The table of all supported transports */
EB_PRIVATE extern struct eb_transport_ops eb_transports[];
EB_PRIVATE extern const unsigned int eb_transport_size;

#endif
