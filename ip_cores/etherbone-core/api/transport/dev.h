/** @file dev.h
 *  @brief This implements a charcter device interface.
 *
 *  Copyright (C) 2011-2012 GSI Helmholtz Centre for Heavy Ion Research GmbH 
 *
 *  The transport carries a port for accepting inbound connections.
 *  Passive devices are created for inbound connections.
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

#ifndef EB_DEV_H
#define EB_DEV_H

#include "../transport/transport.h"

#define EB_DEV_MTU 0

EB_PRIVATE eb_status_t eb_dev_open(struct eb_transport* transport, const char* port);
EB_PRIVATE void eb_dev_close(struct eb_transport* transport);
EB_PRIVATE eb_status_t eb_dev_connect(struct eb_transport* transport, struct eb_link* link, const char* address, int passive);
EB_PRIVATE void eb_dev_disconnect(struct eb_transport* transport, struct eb_link* link);
EB_PRIVATE void eb_dev_fdes(struct eb_transport*, struct eb_link* link, eb_user_data_t data, eb_descriptor_callback_t cb);
EB_PRIVATE int eb_dev_accept(struct eb_transport*, struct eb_link* result_link, eb_user_data_t data, eb_descriptor_callback_t ready);
EB_PRIVATE int eb_dev_poll(struct eb_transport* transportp, struct eb_link* linkp, eb_user_data_t data, eb_descriptor_callback_t ready, uint8_t* buf, int len);
EB_PRIVATE int eb_dev_recv(struct eb_transport* transportp, struct eb_link* linkp, uint8_t* buf, int len);
EB_PRIVATE void eb_dev_send(struct eb_transport* transportp, struct eb_link* linkp, const uint8_t* buf, int len);
EB_PRIVATE void eb_dev_send_buffer(struct eb_transport* transportp, struct eb_link* linkp, int on);

struct eb_dev_transport {
  /* Contents must fit in 9 bytes */
};

struct eb_dev_link {
  /* Contents must fit in 12 bytes */
  int fdes;
  int flags;
};

#endif
