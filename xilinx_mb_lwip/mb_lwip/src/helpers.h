/*
 * helpers.h
 *
 *  Created on: Dec 30, 2017
 *      Author: johns
 */

#ifndef SRC_HELPERS_H_
#define SRC_HELPERS_H_

#include "xgpio.h"
#include "xintc.h"
#include "xllfifo.h"

#include "stdio.h"

#define MAX_FRAME_SIZE 1506
#define WORD_SIZE 4

extern XGpio gpio_1;
extern XGpio gpio_2;

extern XLlFifo fifo_1;
extern XLlFifo fifo_2;

extern XIntc intController;

void echoData32(XLlFifo *fifo);
void echoData_U8(XLlFifo *fifo);
void processIncomingFrame(XLlFifo *fifo_1, XLlFifo *fifo_2);
void processOutgoingFrame(XLlFifo *fifo_1, XLlFifo *fifo_2);

void handler_0(void *CallbackRef);
void handler_1(void *CallbackRef);
int Intc_Setup(u16 DeviceId);
int init_all();

#endif /* SRC_HELPERS_H_ */
