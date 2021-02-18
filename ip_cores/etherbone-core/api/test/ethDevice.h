/*
 * ethDevice.h
 *
 *  Created on: 13.03.2012
 *      Author: zweig
 */

#ifndef ETHDEVICE_H_
#define ETHDEVICE_H_

#include <math.h>
#include <time.h>
#include <cstdio>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>


#include "../etherbone.h"

using namespace etherbone;


// etherbone/device einstellungen
//----------------------------------------
struct Teth_settings {
	const char* netaddress;
	eb_address_t address;
	eb_address_t address_range;

	int attempts;
	int probe;
	int addr_step;

	eb_width_t address_width;
	eb_width_t data_width;
	eb_width_t endian_width;

	Socket		socket;
	Device      device;
};


// daten und datenbreite die gesendet werden sollen
//----------------------------------------------------------
struct Tsend_data {
	eb_data_t  data;
	eb_width_t data_width;
	eb_address_t adress;
};

// fehlerhafte daten
//----------------------------------------------------------
struct Terror_data {
	eb_data_t  wr_data;
	eb_data_t  rd_data;
	eb_width_t data_width;
	eb_address_t adress;
};

// daten die gesendet wurden / daten die empfangen wurden
//-----------------------------------------------------------
struct Tread_data {
	eb_data_t  data;
};

class test_cycle {
  public:

	test_cycle();

	etherbone::Cycle myCycle;

	void complete(Device, Operation, status_t);
	bool ready() const;
	eb_status_t cycle_rd_stat();
	void cycle_res_stat();

  private:
	 eb_status_t flush_status;
	 bool fertig;

};


test_cycle::test_cycle(){
	fertig = false;
};

bool test_cycle::ready() const {
	return fertig;
}

void test_cycle::cycle_res_stat(){
	fertig = false;
};

eb_status_t test_cycle:: cycle_rd_stat(){
	return(flush_status);
};

void test_cycle::complete(Device dev, Operation op, status_t st){
   // printf("done %x\n", this);

	flush_status = st;
	fertig = true;
};

#endif /* ETHDEVICE_H_ */
