#include "boards.h"
#include "nrfx_glue.h"

#define BEEP_MS        80
#define BEEP_GAP_MS    100
#define BEEP_HALF_US   250   // ~2 kHz square wave for the passive buzzer

static void buzzer_beep(uint32_t pin, uint32_t duration_ms) {
  nrf_gpio_cfg_output(pin);

  uint32_t toggles = duration_ms * 4;
  for (uint32_t i = 0; i < toggles; i++) {
    nrf_gpio_pin_toggle(pin);
    NRFX_DELAY_US(BEEP_HALF_US);
  }

  nrf_gpio_pin_clear(pin);
}

void board_dfu_enter(void) {
  for (int i = 0; i < 3; i++) {
    buzzer_beep(PIN_BUZZER, BEEP_MS);
    if (i < 2) {
      NRFX_DELAY_MS(BEEP_GAP_MS);
    }
  }
}
