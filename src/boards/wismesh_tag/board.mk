MCU_SUB_VARIANT = nrf52840
CFLAGS += -DDEVICE_NAME='"RTAG_DFU"'
C_SRC += src/boards/wismesh_tag/board_dfu.c