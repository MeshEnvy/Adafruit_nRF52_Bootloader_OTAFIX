#ifndef WDT_FEED_H_
#define WDT_FEED_H_

#include "nrf.h"

// Feed a WDT left running by the app across soft reset. Bootloader never starts WDT itself.
static inline void wdt_feed_if_running(void) {
  if (NRF_WDT->RUNSTATUS) NRF_WDT->RR[0] = 0x6E524635u;
}

#endif // WDT_FEED_H_
