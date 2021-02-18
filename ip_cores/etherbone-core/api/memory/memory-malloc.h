/** @file memory-malloc.h
 *  @brief Dynamic memory allocation using traditional malloc/free.
 *
 *  Copyright (C) 2011-2012 GSI Helmholtz Centre for Heavy Ion Research GmbH 
 *
 *  Pointer types are simple C point types.
 *  Allocation uses non-deterministic malloc, typically using a free list.
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

#ifndef EB_MEMORY_MALLOC_H
#define EB_MEMORY_MALLOC_H
#ifdef EB_USE_MALLOC

#define EB_OPERATION(x) (x)
#define EB_CYCLE(x) (x)
#define EB_DEVICE(x) (x)
#define EB_SOCKET(x) (x)
#define EB_SOCKET_AUX(x) (x)
#define EB_HANDLER_CALLBACK(x) (x)
#define EB_HANDLER_ADDRESS(x) (x)
#define EB_RESPONSE(x) (x)
#define EB_TRANSPORT(x) (x)
#define EB_LINK(x) (x)
#define EB_SDB_SCAN(x) (x)
#define EB_SDB_RECORD(x) (x)

#endif
#endif
