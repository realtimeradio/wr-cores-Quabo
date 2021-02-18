/** @file posix-tcp.h
 *  @brief This implements a TCP binding using posix sockets.
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

#ifndef EB_POSIX_TCP_H
#define EB_POSIX_TCP_H

#include "posix-ip.h"
#include "../transport/transport.h"

#define EB_POSIX_TCP_MTU 0

EB_PRIVATE eb_status_t eb_posix_tcp_open(struct eb_transport* transport, const char* port);
EB_PRIVATE void eb_posix_tcp_close(struct eb_transport* transport);
EB_PRIVATE eb_status_t eb_posix_tcp_connect(struct eb_transport* transport, struct eb_link* link, const char* address, int passive);
EB_PRIVATE void eb_posix_tcp_disconnect(struct eb_transport* transport, struct eb_link* link);
EB_PRIVATE void eb_posix_tcp_fdes(struct eb_transport*, struct eb_link* link, eb_user_data_t data, eb_descriptor_callback_t cb);
EB_PRIVATE int eb_posix_tcp_accept(struct eb_transport*, struct eb_link* result_link, eb_user_data_t data, eb_descriptor_callback_t ready);
EB_PRIVATE int eb_posix_tcp_poll(struct eb_transport* transportp, struct eb_link* linkp, eb_user_data_t data, eb_descriptor_callback_t ready, uint8_t* buf, int len);
EB_PRIVATE int eb_posix_tcp_recv(struct eb_transport* transportp, struct eb_link* linkp, uint8_t* buf, int len);
EB_PRIVATE void eb_posix_tcp_send(struct eb_transport* transportp, struct eb_link* linkp, const uint8_t* buf, int len);
EB_PRIVATE void eb_posix_tcp_send_buffer(struct eb_transport* transportp, struct eb_link* linkp, int on);

struct eb_posix_tcp_transport {
  /* Contents must fit in 9 bytes */
  eb_posix_sock_t port4; /* IPv4 */
#ifndef EB_DISABLE_IPV6
  eb_posix_sock_t port6; /* IPv6 */
#endif
};

struct eb_posix_tcp_link {
  /* Contents must fit in 12 bytes */
  eb_posix_sock_t socket;
};

#endif
