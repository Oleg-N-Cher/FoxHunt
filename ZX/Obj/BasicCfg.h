/*==================== Configuration file of Basic library ===================*/

/*-------------------------------- Interrupt ---------------------------------*/

/* Interrupt mode of your program: DI, IM1, IM2. */
/* For IM 1 mode use SDCC option --reserve-regs-iy */

//#define MODE_DI_inline
#define MODE_IM1_inline
//#define MODE_IM2_inline

/*---------------------------------- OUTPUT ----------------------------------*/

/* Use ROM output (RST 10H, slow, 32x22) or CUSTOM (fast, 32x24) */
#define ROM_OUTPUT

/*--------------------------------- FASTCALL ---------------------------------*/

/* Use fastcall model (the function parameters passed in regs.)  */

//#define AT_fastcall

/*----------------------------------- CLS ------------------------------------*/

/* Use CLS for whole screen (with PAPER attributes in bottom lines): */

#define CLS_FULLSCREEN

/*----------------------------------- RND ------------------------------------*/

/* Use ROM calculator or BetaBasic way for generating a RND value: */

//#define RAND_ROM
