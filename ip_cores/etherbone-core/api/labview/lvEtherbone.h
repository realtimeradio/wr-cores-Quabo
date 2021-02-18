// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the ETHERBONE_EXPORTS
// symbol defined on the command line. this symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// ETHERBONE_API functions as being imported from a DLL, whereas this DLL sees symbols
// defined with this macro as being exported.
#ifdef WIN32
#ifdef ETHERBONE_EXPORTS
#define ETHERBONE_API __declspec(dllexport)
#else
#define ETHERBONE_API __declspec(dllimport)
#endif
#define getpid() _getpid()
#endif
#ifdef LINUX
#define ETHERBONE_API
#endif

#ifdef LINUX
void __attribute__ ((constructor)) my_init(void);
void __attribute__ ((destructor)) my_fini(void);
#endif

#include "../etherbone.h"

typedef enum lveb_status { 
	LVEB_OK=0,			//success
	LVEB_UNKNOWN,		//unknown error
	LVEB_OS,			//operating system forbids access
	LVEB_PORT,			//port in use or unavailable
	LVEB_ID,			//ID invalid or out of resources
	LVEB_SOCKET,		//socket invalid or unavailable
	LVEB_EB,			//remote address is not Etherbone conformant
	LVEB_IP,			//bad format of network address
	LVEB_PORTWIDTH,		//port width error
	LVEB_DEVICEBUSY,	//Etherbone device still busy
	LVEB_DEVICEFAIL,	//operation on Wishbone device failed
	LVEB_DEVICEEXIST,	//Etherbone device already exists, overlaps, or does not exist
	LVEB_TIMEDOUT,		//a timeout occurred
	LVEB_OVERFLOW,		//payload of Etherbone exceeded
	LVEB_ADDRESS,		//bad address
	LVEB_ADDRESSWITDH	//address width error
} lveb_status_t;

typedef enum lveb_activity {
	EBACT_UNKNOWN=0,	//unknown activity on Etherbone socket
	EBACT_TIMEDOUT,		//no activity on socket
	EBACT_READ,			//somebody read data from the virtual device
	EBACT_WRITE,		//somebody wrote data to the virtual device
	EBACT_RW			//somebody did read and write on the virtual device
} lveb_activity_t;

//-----------------------------------------------------------------------------------
// author  : Dietrich Beck, GSI-Darmstadt
// purpose : Open an Etherbone socket for communicating with remote devices.
//           The port parameter is optional; 0 lets the operating system choose.
//			 The socket_ID must be kept for releasing allocated resources.
// returns : lveb_status_t
//-----------------------------------------------------------------------------------
ETHERBONE_API int lveb_socket_open(	int		port,		//port number
									int	flags,			//flags 
									int	*eb_socketID	//very important socket ID
								   );

//-----------------------------------------------------------------------------------
// author  : Dietrich Beck, GSI-Darmstadt
// purpose : Close the Etherbone socket
// returns : lveb_status_t
//-----------------------------------------------------------------------------------
ETHERBONE_API int lveb_socket_close(int eb_socketID	//very important socket ID
				 				   );

//-----------------------------------------------------------------------------------
// author  : Dietrich Beck, GSI-Darmstadt
// purpose : wait for activity on the Etherbone socket. This function MUST be called,
//           if a virtual device has been set up by using a handler
// returns : lveb_status_t
//-----------------------------------------------------------------------------------
ETHERBONE_API int lveb_socket_wait4Activity(int eb_socketID,	//very important socket ID
											int timeout,		//timeout [ms]
											int *lastActivity,	//last activity on socket
											int *nRead,			//nOf read cycles
											int *nWrite			//nOf write cycles
				 							);

//-----------------------------------------------------------------------------------
// author  : Dietrich Beck, GSI-Darmstadt
// purpose : Add a device to the virtual bus.
//           This handler receives all reads and writes to the specified address.
//           the address range [0x0, 0x7fff) is reserved for internal use. 
// returns : lveb_status_t
//-----------------------------------------------------------------------------------
ETHERBONE_API int lveb_handler_attach(	int				eb_socketID,	//Etherbone socket ID
										eb_address_t	baseAddress,	//base address of THIS device
										eb_address_t	maskAddress,	//memory mask (range) of THIS device
										int				*eb_handlerID	//ID of the handler of THIS device
									 );

//-----------------------------------------------------------------------------------
// author  : Dietrich Beck, GSI-Darmstadt
// purpose : Detach the device from the virtual bus.
// returns : lveb_status_t
//-----------------------------------------------------------------------------------
ETHERBONE_API int lveb_handler_detach(int eb_handlerID			//ID of handler
									 );

//-----------------------------------------------------------------------------------
// author  : Dietrich Beck, GSI-Darmstadt
// purpose : Retrieve data from the memory map of THIS virtual device 
//           by copying it from the memory map to a "data" buffer.
//			 It is the responsibility of the caller to pre-allocate
//			 sufficient memory for the data buffer prior calling this routine.
// returns : lveb_status_t
//-----------------------------------------------------------------------------------
ETHERBONE_API int lveb_handler_getMap(	int				eb_handlerID,	//ID of the handler of THIS device
										eb_address_t	address,		//address where to read from
										int				size,			//size of data to read
										char			*data			//buffer containing read-data
									  );

//-----------------------------------------------------------------------------------
// author  : Dietrich Beck, GSI-Darmstadt
// purpose : Copy data from the "data" buffer to the memory map of THIS
//           virtual device. 
// returns : lveb_status_t
//-----------------------------------------------------------------------------------
ETHERBONE_API int lveb_handler_setMap( int			eb_handlerID,	//ID of the handler of THIS device
									   eb_address_t	address,		//address where to data is written to
									   int			size,			//size of data to write
									   char			*data			//buffer containing write-data
									   );

//-----------------------------------------------------------------------------------
// author  : Dietrich Beck, GSI-Darmstadt
// purpose : Open a remote Etherbone device.
//			 This resolves the address and performs Etherbone end-point discovery.
//			 From the mask of proposed bus address widths, one will be selected.
//			 From the mask of proposed bus port    widths, one will be selected.
//			 The timeout value has a granularity of 3000 milliseconds.
//			 The default port is taken as 0xEBD0.
// returns : lveb_status_t
//-----------------------------------------------------------------------------------
ETHERBONE_API int lveb_device_open(	int		eb_socketID,			//Etherbone socket ID
									char	*ip_port,				//IP port in the format "IP:PORT"
									int		proposed_addr_widths,	//widths of addresses (range)
									int		proposed_port_widths,	//widths of port ("data type")
									int		timeout,				//timeout [ms]
									int		*eb_deviceID			//Etherbone device ID
								   );

//-----------------------------------------------------------------------------------
// author  : Dietrich Beck, GSI-Darmstadt
// purpose : Close a remote Etherbone device.
// returns : lveb_status_t
//-----------------------------------------------------------------------------------
ETHERBONE_API int lveb_device_close(int eb_deviceID		//ID of Wishbone devie
								   );
//-----------------------------------------------------------------------------------
// author  : Dietrich Beck, GSI-Darmstadt
// purpose : Recover the negotiated data width of the target device.
// returns : lveb_status_t
//-----------------------------------------------------------------------------------
ETHERBONE_API int lveb_device_width(int eb_deviceID,	//ID of Wishbone device
									int	*width			//width of bus (eb_width_t)
								   );

//-----------------------------------------------------------------------------------
// author  : Dietrich Beck, GSI-Darmstadt
// purpose : Flush commands queued on the device out the socket.
// returns : lveb_status_t
//-----------------------------------------------------------------------------------
ETHERBONE_API int lveb_device_flush(int eb_deviceID		//ID of Wishbone device
								    );

//-----------------------------------------------------------------------------------
// author  : Dietrich Beck, GSI-Darmstadt
// purpose : Perform a single-read wishbone cycle.
//			 Semantically equivalent to cycle_open, cycle_read, cycle_close, device_flush.
//			 The given address is read on the remote device.
// returns : lveb_status_t
//-----------------------------------------------------------------------------------
/*ETHERBONE_API int lveb_device_read_single(	int			eb_deviceID,	//ID of Wishbone device
											uint64_t	address,		//address to read
											uint64_t	*data,			//data that is read
											int			timeout			//timeout [ms]
										  );*/

//-----------------------------------------------------------------------------------
// author  : Dietrich Beck, GSI-Darmstadt
// purpose : Perform a single-write wishbone cycle.
//			 Semantically equivalent to cycle_open, cycle_write, cycle_close, device_flush.
//			 data is written to the given address on the remote device.
// returns : lveb_status_t
//-----------------------------------------------------------------------------------
/*ETHERBONE_API int lveb_device_write_single(int			eb_deviceID,	//ID of Wishbone device
											uint64_t	address,		//address to write
											uint64_t	data			//data that is written
										   );	*/

//-----------------------------------------------------------------------------------
// author  : Dietrich Beck, GSI-Darmstadt
// purpose : Performs reading and writing to a Etherbone device
//           It is the responsibility of the caller to allocate memory for dataR (dataW)
//           The (preallocated) memory must have a size of 8*nR (8*nW) bytes. 
// returns : lveb_status_t
//-----------------------------------------------------------------------------------
ETHERBONE_API int lveb_device_read_write(	int			eb_deviceID,	//ID of Wishbone device
											uint64_t	addressR,		//address to read
											int			modeR,			//mode for reading (eb_mode_t)
											int			nR,				//number of read operations; no reading if 0
											uint64_t	*dataR,			//data that is read
											uint64_t	addressW,		//address to write
											int			modeW,			//mode for writing (eb_mode_t)
											int			nW,				//number of write operations; no writing if 0
											uint64_t	*dataW,			//data that is written
											int			timeout			//timeout in [ms]
										 );
//-----------------------------------------------------------------------------------
// author  : Dietrich Beck, GSI-Darmstadt
// purpose : obtains version information about Etherbone shared library software.
//           The caller must preallocate sufficient memory.
// returns : void
//-----------------------------------------------------------------------------------
ETHERBONE_API void lveb_get_version(	char	*lvebVersion,				//version of lvEtherbone library
										char	*ebVersion					//version of Etherbone API
									);
