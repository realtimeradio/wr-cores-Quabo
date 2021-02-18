/** @file bigendian.h
 *  @brief Conversion of 16/32/64 bit width registers to/from bigendian.
 *
 *  Copyright (C) 2011-2012 GSI Helmholtz Centre for Heavy Ion Research GmbH 
 *
 *  Default to using system-provided methods wherever possible.
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
 *  License along with this library. If not, see
 * <http://www.gnu.org/licenses/>.
 *******************************************************************************
 */

#ifndef EB_BIGENDIAN_H
#define EB_BIGENDIAN_H

#if defined(__linux__)
#include <endian.h>
#elif defined(__FreeBSD__) || defined(__NetBSD__)
#include <sys/endian.h>
#elif defined(__OpenBSD__)
#include <sys/endian.h>
#define be16toh(x) betoh16(x)
#define be32toh(x) betoh32(x)
#define be64toh(x) betoh64(x)
#endif

#ifndef htobe64
/* Portable version */
#if defined(__WIN32)
#include <winsock2.h>
#elif defined(__lm32__)
/* bigendian */
#define htons(x) x
#define htonl(x) x
#else
#include <arpa/inet.h>
#endif

#define htobe16(x) htons(x)
#define htobe32(x) htonl(x)
#define be16toh(x) htons(x)
#define be32toh(x) htonl(x)

/* Only provide when needed */
#ifdef EB_NEED_BIGENDIAN_64
static uint64_t htobe64(uint64_t x) {
  union {
    uint64_t y;
    uint32_t z[2];
  } u;
  u.z[0] = htonl(x >> 32);
  u.z[1] = htonl(x);
  return u.y;
}

#define be64toh(x) htobe64(x)
#endif

#endif

#endif
