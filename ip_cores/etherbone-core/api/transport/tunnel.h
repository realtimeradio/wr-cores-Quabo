/** @file tunnel.h
 *  @brief This implements a UDP tunnel over TCP.
 *
 *  Copyright (C) 2011-2012 GSI Helmholtz Centre for Heavy Ion Research GmbH 
 *
 *  Etherbone UDP over TCP is implemented using the eb-tunnel tool.
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

#ifndef EB_TUNNEL_H
#define EB_TUNNEL_H

#include "transport.h"
#include "posix-udp.h"

#define EB_TUNNEL_MTU EB_POSIX_UDP_MTU

EB_PRIVATE eb_status_t eb_tunnel_open(struct eb_transport* transport, const char* port);
EB_PRIVATE void eb_tunnel_close(struct eb_transport* transport);
EB_PRIVATE eb_status_t eb_tunnel_connect(struct eb_transport* transport, struct eb_link* link, const char* address, int passive);
EB_PRIVATE void eb_tunnel_disconnect(struct eb_transport* transport, struct eb_link* link);
EB_PRIVATE void eb_tunnel_fdes(struct eb_transport*, struct eb_link* link, eb_user_data_t data, eb_descriptor_callback_t cb);
EB_PRIVATE int eb_tunnel_accept(struct eb_transport*, struct eb_link* result_link, eb_user_data_t data, eb_descriptor_callback_t ready);
EB_PRIVATE int eb_tunnel_poll(struct eb_transport* transportp, struct eb_link* linkp, eb_user_data_t data, eb_descriptor_callback_t ready, uint8_t* buf, int len);
EB_PRIVATE int eb_tunnel_recv(struct eb_transport* transportp, struct eb_link* linkp, uint8_t* buf, int len);
EB_PRIVATE void eb_tunnel_send(struct eb_transport* transportp, struct eb_link* linkp, const uint8_t* buf, int len);
EB_PRIVATE void eb_tunnel_send_buffer(struct eb_transport* transportp, struct eb_link* linkp, int on);

#endif
