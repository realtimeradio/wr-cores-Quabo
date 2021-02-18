/** @file posix-ip.h
 *  @brief Common methods for UDP/TCP.
 *
 *  Copyright (C) 2011-2012 GSI Helmholtz Centre for Heavy Ion Research GmbH 
 *
 *  Implements common IPv4/6 agnostic socket handling.
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

#ifndef EB_POSIX_IP_H
#define EB_POSIX_IP_H

#ifdef __WIN32
#define _WIN32_WINNT 0x0501
#include <winsock2.h>
#include <ws2tcpip.h>
#include <sys/time.h>
#include "../etherbone.h"
typedef int socklen_t;
typedef SOCKET eb_posix_sock_t;
#else
#define _POSIX_C_SOURCE 1
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <sys/select.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <netdb.h>
#include <unistd.h>
#include <errno.h>
#include "../etherbone.h"
typedef eb_descriptor_t eb_posix_sock_t;
#endif

#if defined(MSG_DONTWAIT)
#define EB_POSIX_IP_NON_BLOCKING_NOOP
#else
#define MSG_DONTWAIT 0
#endif

EB_PRIVATE void eb_posix_ip_close(eb_posix_sock_t sock);
EB_PRIVATE eb_posix_sock_t eb_posix_ip_open(int family, int type, const char* port);
EB_PRIVATE socklen_t eb_posix_ip_resolve(const char* prefix, const char* address, int family, int type, struct sockaddr_storage* out);
EB_PRIVATE void eb_posix_ip_non_blocking(eb_posix_sock_t sock, unsigned long on);
EB_PRIVATE void eb_posix_ip_force_non_blocking(eb_posix_sock_t sock, unsigned long on);
EB_PRIVATE void eb_posix_ip_set_buffer(eb_posix_sock_t sock, int on);
EB_PRIVATE int eb_posix_ip_ewouldblock(void); /* is errno = EAGAIN? */

#endif
