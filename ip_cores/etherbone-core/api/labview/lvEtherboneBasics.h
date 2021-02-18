#define MAXLEN              1024			//maximum length of standard items like names
#define MAXSOCKETS			100				//maximum number of sockets used by this library
#define MAXHANDLER			100				//maximun number of handler (virtual devices) used by this library
#define MAXDEVICES			1000			//maximum number of devices used by this library
#define LOGFILENAME			"lvEtherbone.log"//name of log file (for windows)
#define EBWRAPPERPATH		"LVETHERBONE_LOGPATH"//name of environment variable for folder of log file (for windows)

typedef struct
{
	int				eb_socketID;    //identifies a socket (an element of this array) 
	eb_socket_t		eb_socket;      //EB socket
	int				nRead;			//number of detected read cycles since last call of wait4Activity
	int				nWrite;			//number of detected write cycles since last call of wait4Activity
	lveb_activity_t	eb_activity;	//flag for last activity on Etherbone socket (typically from a handler)		
} mySocketT;

typedef struct
{
	int			eb_deviceID;	//identifies a device (an element of this array)
	int			eb_socketID;	//identifies the socket, to which the remote device is attached
	eb_device_t	device;		    //EB device
} myDeviceT;

typedef struct
{
	int			done;			//0: callback not yet called; 1: callback completed
	eb_status_t status;			//status or error received by callback
	int			size;			//expected data size in bytes
	char		*data;			//address where data will be copied to
} myUserDataT;

typedef struct
{	int				eb_handlerID;	//identifies the handler
	int				eb_socketID;	//identifies the socket, to which the handler is attached
	int				lock;			//0: handler unlocked, 1: handler locked
	char			*memMap;		//my mapped memory
	struct eb_handler	handler;	//my handler
} myHandlerT;
