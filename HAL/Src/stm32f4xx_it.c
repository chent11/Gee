#include "stm32f4xx_it.h"
/******************************************************************************/
/*           Cortex-M4 Processor Interruption and Exception Handlers          */
/******************************************************************************/
/**
 * @brief This function handles Non maskable interrupt.
 */
void NMI_Handler(void) {

}

/**
 * @brief This function handles Hard fault interrupt.
 */
void HardFault_Handler(void) {
	while (1) {

	}
}

/**
 * @brief This function handles Memory management fault.
 */
void MemManage_Handler(void) {
	while (1) {
	}
}

/**
 * @brief This function handles Pre-fetch fault, memory access fault.
 */
void BusFault_Handler(void) {
	/* CODE BEGIN BusFault_IRQn 0 */

	/* CODE END BusFault_IRQn 0 */
	while (1) {
		/* CODE BEGIN W1_BusFault_IRQn 0 */
		/* CODE END W1_BusFault_IRQn 0 */
	}
}

/**
 * @brief This function handles Undefined instruction or illegal state.
 */
void UsageFault_Handler(void) {
	/* CODE BEGIN UsageFault_IRQn 0 */

	/* CODE END UsageFault_IRQn 0 */
	while (1) {
		/* CODE BEGIN W1_UsageFault_IRQn 0 */
		/* CODE END W1_UsageFault_IRQn 0 */
	}
}

/**
 * @brief This function handles System service call via SWI instruction.
 */
void SVC_Handler(void) {
	/* CODE BEGIN SVCall_IRQn 0 */

	/* CODE END SVCall_IRQn 0 */
	/* CODE BEGIN SVCall_IRQn 1 */

	/* CODE END SVCall_IRQn 1 */
}

/**
 * @brief This function handles Debug monitor.
 */
void DebugMon_Handler(void) {
	/* CODE BEGIN DebugMonitor_IRQn 0 */

	/* CODE END DebugMonitor_IRQn 0 */
	/* CODE BEGIN DebugMonitor_IRQn 1 */

	/* CODE END DebugMonitor_IRQn 1 */
}

/**
 * @brief This function handles Pendable request for system service.
 */
void PendSV_Handler(void) {
	/* CODE BEGIN PendSV_IRQn 0 */

	/* CODE END PendSV_IRQn 0 */
	/* CODE BEGIN PendSV_IRQn 1 */

	/* CODE END PendSV_IRQn 1 */
}

/**
 * @brief This function handles System tick timer.
 */
void SysTick_Handler(void) {
	/* CODE BEGIN SysTick_IRQn 0 */

	/* CODE END SysTick_IRQn 0 */
	HAL_IncTick();
	/* CODE BEGIN SysTick_IRQn 1 */

	/* CODE END SysTick_IRQn 1 */
}

/**
 * @brief  This function is executed in case of error occurrence.
 */
void Error_Handler(void) {
	while (1);
}

/******************************************************************************/
/* STM32F4xx Peripheral Interrupt Handlers                                    */
/* Add here the Interrupt Handlers for the used peripherals.                  */
/* For the available peripheral interrupt handler names,                      */
/* please refer to the startup file (startup_stm32f4xx.s).                    */
/******************************************************************************/

/* CODE BEGIN 1 */

/* CODE END 1 */
/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
