;***************************************************************************
; Illini Dancing Revolution (IDR) Final Submission Code
; IDR is an imitation of the game we love, Dance Dance Revolution
;
; Team Members:
; Kuangwei Hwang  (Most of the time comment says "kw's code begin/end here")
; Cindy Chang
; Adam Kim
; Krista Eichhorn
; Game Completed: 5/5/03
; Game Submitted: 5/7/03
; Total Development Hours: 250+ Hour



%include "lib291.inc"

	BITS 32

	GLOBAL _main


;******************** SECTION 1: Define Constants ***************************

;-----picture file attributes-----

SCREEN_WIDTH		equ	640
SCREEN_HEIGHT		equ	640		
;gives 70 units leeway on top, 90 on bottom for scrolling purposes

PIC_WIDTH			equ 640
PIC_HEIGHT			equ 480

fArrows_WIDTH		equ 254
fArrows_HEIGHT		equ 62

mArrow_WIDTH		equ	64
mArrow_HEIGHT		equ 64

SIXTEENArrow_HEIGHT	equ 1024
SIXTEENArrow_WIDTH	equ 256

Number_WIDTH        equ 20
Number_HEIGHT       equ 20

NumberLine_WIDTH    equ 240

Comments_WIDTH      equ 175
Comments_HEIGHT     equ 175

PAUSE_WIDTH			equ 300
PAUSE_HEIGHT		equ 80

;-----keyboard constants-----

LCTRL	equ	2
RCTRL	equ	3
LALT	equ	4
RALT	equ	5
LSHIFT	equ	6
RSHIFT	equ	7
CAPS	equ	1
BKSP	equ	8
ENTR	equ	13
ESC		equ	127
TAB		equ 9
DEL		equ	10
HOME	equ	11
UP		equ	30
PGUP	equ	12
LEFT	equ	28
RIGHT	equ	29
END		equ	14
DOWN	equ	31
PGDN	equ	15
INS		equ	16
SPACE	equ	32

;-----flags (for choosing song/difficulty level-----
LeftFlag	equ		00001000b	; LeftFlag is bit 3
DownFlag	equ		00000100b	; DownFlag is bit 2
UpFlag		equ		00000010b	; UpFlag is bit 1
RightFlag	equ		00000001b	; UpFlag

;-----timing constants that we need-----
timerSet	equ 2
TIMER_IRQ	equ	8


;-----various array/queue sizes-----
MAX				EQU	20	; Capacity of keyboard queue
QUEUE_MAX		equ 20
ArraySize		equ 50


;***----kw's Code Begin-----
;---Arguement Length Declaration For C Style Invoked Functions---

; Declare global the user functions, not needed if we are using one file
; for example:
; global _copyBuffer2BufferWithAlpha, _markAttached, _countMatched
;------------ Constants, Regular Stuff like scan code-------
; Design Decision to make all wav file uniform at 16bit Sample Mode for
; higher quality sound mixing
BG_Sample8_16	equ	16	

; DMA Buffer tracking Flags
DMA_Refill_Flag	equ	00000001b  ; bit0 = 0 tells _DMA_Refill to refill 1st half
				   ; bit0 = 1 tells _DMA_Refill  to refill 2nd half
DMA_Empty	equ	00000010b  ; bit1 = 0 means no DMA refill needed
				   ; bit1 = 1 means DMA refill required


;***----Adam's constants-----
_stepSize		equ 20*1024
_DMAbuff		equ 6176	;***Config HERE! To Synchronize Songs
_DMASbuff		equ 1544	;***Config HERE!

_BPMconstHot	equ 156		; For HotLImit
_BPMconstCant	equ 170		; For Can't Speed

_Multiplier		equ 161





;********************* SECTION 2: Unitialized Data Section *****************
struc Arrow
	.YCoord		resd	1
	.type		resb	1
	.exist		resb	1
	.miss		resd	1
endstruc


	SECTION .bss
_CommentFlag		resd 1	;for comment display during game play
_CommentCount		resd 1
_CommentChoice		resd 1
_scrollingTop		resd 1
_loadBarCount		resd 1	;for loading screen
_loadBarPosition	resd 1	
_creditInc			resd 1	;credit increment
	
_YPosition			resd 1	;Coordinate that indicates where to copy from within  from _SIXTEENArrowOff

_escFlag			resb 1	
_pauseFlag			resb 1	
_arrowArray			resb ArraySize*Arrow_size
_ArrowFlag			resb 1	;if array is not empty, flag set to 1


_leftHitFlag		resb 1
_downHitFlag		resb 1
_upHitFlag			resb 1
_rightHitFlag		resb 1

_leftPressFlag		resb 1
_downPressFlag		resb 1
_upPressFlag		resb 1
_rightPressFlag		resb 1

_graphicsMode		resw 1	; ex291 graphics mode

							;variables to store "offset" of fixed arrows
_screenleft			resd 1	;dest left(from screen)
_screentop			resd 1	;dest top (from screen)
_sourceleft			resd 1	;source top

							;fixed arrow offset
_screendown			resd 1
_screenup			resd 1
_screenright		resd 1


							
_screenOff			resd 1	; pointer to screen buffer

_BackgroundOff		resd 1	;offset to different backgrouns
_MatrixOff			resd 1
_DragonballOff		resd 1
_SkyBlueOff			resd 1
_FF8BGOff			resd 1

							;offset to various images
_fArrowsOff			resd 1		
_SIXTEENArrowOff	resd 1
_UPfArrowsOff		resd 1
_LEFTfArrowsOff		resd 1
_RIGHTfArrowsOff	resd 1
_DOWNfArrowsOff		resd 1
_startScrnOff		resd 1
_hitArrowsOff		resd 1
_resultsOff			resd 1
_pauseOff			resd 1
_creditsOff			resd 1
_FlashFArrowsOff	resd 1
_pressArrowsOff		resd 1
_LoadingScreenOff	resd 1
_LoadBarOff			resd 1
_scrollingBackOff	resd 1
_selectSongOff		resd 1
_NumberOff			resd 1
_CommentsOff		resd 1


							;scoring number offsets
HThousand	  resd    1
TThousand	  resd    1
Thousand	  resd    1
Hundred		 resd    1
Ten			 resd    1
One			 resd    1





;timer and mouse are not used
_MouseSeg	resw	1       ; real mode segment for MouseCallback
_MouseOff	resw	1		; real mode offset for MouseCallback
_timerCount	resd	1		; 

;keyboard
keyboardData_begin
_keyboardINT	resb	1	; mapped keyboard interrupt
_keyboardIRQ	resb	1	; mapped keyboard irq
_keyboardPort	resw	1	; mapped keyboard port
_keyStatusTable	resb	128 	; table for 128 possible keys
keyboardData_end

;queue 
queueFront	resd	1	
queueRear	resd	1
queueCount	resd	1
queueBegin	resd	QUEUE_MAX	
queueEnd	resd	0		

ArrowBuffer	resb	1


;********************* kw's Code Begin *****************
;StepFile/SongSelection Tracking Flags

; DMA Buffer tracking flags
DMA_Flags	resb	1   ; Flag used to hold DMA status
SongSize	resd	1   ; Keeps track of current Song size, decrement at 
			    ; each DMA_Refill
FGSize		resd	1   ; Keeps track of current Sound FX Size, decrement 
			    ; at each DMA_Refill


;DMASel		resw	1	; original DMA Selector
DMASel_1411kbps	resw	1	; Specific Selector values saved for 
DMASel_705kbps	resw	1	; the 3 Specific DMA sizes allocated
DMASel_352kbps	resw	1	; to play different bit rate music at 30 int/sec


;DMAAddr	resd	1 	; original DMA Address
DMAAddr_1411kbps resd	1	; Specific Address values saved for 
DMAAddr_705kbps	resd	1	; the 3 Specific DMA sizes allocated
DMAAddr_352kbps	resd	1	; to play different bit rate music at 30 int/sec

;DMAChan	resb	1 	; original DMA Channel
DMAChan_1411kbps   resb	1 ; Specific DMA Channel values saved for
DMAChan_705kbps	   resb	1 ; the 3 Specific DMA sizes allocated
DMAChan_352kbps	   resb	1 ; to play different bit rate music at 30 int/sec

; Play Back Control
CurrentPlaySampleFreq 	resd	1
CurrentPlayStereoMono	resd	1	; for for Mono, 1 for Stereo
CurrentDMAChannel	resw 	1
CurrentDMASel		resw	1
CurrentDMAAddress	resd	1
CurrentDMASize		resd	1

Current_BG_File_Size	resd	1   ; Holds Background File Size	
Current_FG_File_Size	resd	1   ; Holds Foreground File Size
FirstFilePlayed_Flag	resd	1	

; File Control
BG_File_Off	resd	1   ; File Buffer offset for loading the Background
			    ; wav file
BG_File_Index	resd	1   ; Index for Background Buffer file

FG_File_Off	resd	1   ; File Buffer offset for loading the Foreground
			    ; wav file
FG_File_Index	resd	1   ; Index for Foreground Buffer file
;********************* kw's Code Ends *****************

_stepOff	resd	1	; offset of stepfile data
_stepIndex	resd	1



;********************* SECTION 3: Initilized Data Section *****************
	SECTION .data	

;***-----Keyboard Lookup table----- (from MP3 written by Agnes Lo)
Qwerty
	db	0	; filler
	db	ESC,'1','2','3','4','5','6','7','8','9','0','-','=',BKSP
	db	TAB, 'q','w','e','r','t','y','u','i','o','p','[',']',ENTR
	db	LCTRL,'a','s','d','f','g','h','j','k','l',';',"'","`"
	db	LSHIFT,'\','z','x','c','v','b','n','m',",",'.','/',RSHIFT,'*'
	db	LALT, SPACE, CAPS, 0,0,0,0,0,0,0,0,0,0 ; F1-F10
	db	0,0	; numlock, scroll lock
	db	HOME, UP, PGUP, '-'
	db	LEFT, 0, RIGHT, '+'
	db	END, DOWN, PGDN, INS
	db	DEL, 0; sysrq



;***-----kw's Code Begin-----
; Messages for output
PlaySongErrmsg	db	"[PlaySong() Failed to Initialize!", 0
PlaySoundFXErrmsg db	"[PlaySoundFX() Failed to Initialize!", 0
InitBufferErr	db	"[InitBuffer() Failed to Initialize!", 0
NoBitRateMatchErrmsg db	"[PlaySong() Can't find a Matching BitRate!", 0


dmalloc		db	"[DMA_Alloc_Mem...", 0
errmsg		db	" Failed!]", 13,10,"Error", 13, 10, 0
dmastart	db	"[DMA_Start...", 0
sbstart		db	"[SB16_Start...", 0
sbstartsc	db	"[SB16_Start (Single Cycle)...", 0
sbinit		db	"[SB16_Init...", 0
sbgetch		db	"[SB16_GetChannel...", 0
sbsetf		db	"[SB16_SetFormat...", 0
sbsetmix	db	"[SB16_SetMixers...", 0
dmastop		db	"[DMA_Stop...",0
sbstop		db	"[SB16_Stop...",0
sbexit		db	"[SB16_Exit...",0
done		db	" Done]", 13, 10, 0
info		db	"[D%d H%d]", 13, 10, 0
ver		db	"[V%d]", 13, 10, 0
inttimes	db	"[Interrupted %d times]", 13, 10, 0
dmatodo		db	"**: DMA Todo: %d", 13, 10, 0

; Other variables
ISR_Count  	dd	0

_CDChangeFX	db	'CDChangeFX.wav',0
_BumbleBee	db	'BumbleBee22k16b.wav',0
_tsLoop		db	'tsloop.wav',0	
_Brilliant2U	db	'DDR-Brilliant2U-44k16b.wav',0
_Title		db	'Title.wav',0
_DiscSelect	db	'DiscSelectFX.wav',0
_HotLimit	db	'hotlimit44k16.wav',0
_GreatSong	db	'ThisIsAGreatSong.wav',0
_CantSpeed	db	'cantspeed.wav',0

; Initialized Flags
TitlePlayed	dd	0
SoundFXPlayed	dd	0
EndOfSong_Flag	dd	0	; set the end of the song
Repeat_Flag	dd	0	;*** Set Repeat Mode  
BG_Playing_Flag	dd	0	; Set the flag if the BG song is playing
FG_Mix_Flag	dd	0	; Set the flag to request a FG Sound FX Mix
Next_Frame_Flag	dd	0	; Advances game logic next 1/30th of a second
				; 0 to wait, 1 to advance
SongSel_Flags	dd	0	;*** Current Menu Selections
				; 0 - Hotlimit (Hard)
				; 1 - Hotlimit (Easy)
				; 2 - Can't Speed (Hard)
				; 3 - Can't Speed (Easy)
				
;***------kw's Code End------



;------Scoring Variables-----
Miss			dd	0
Boo				dd	0
Good			dd	0
Great			dd	0
Perfect			dd	0

Total			dd	0
PerfectTotal	dd 0
GreatTotal		dd 0
GoodTotal		dd 0
BooTotal		dd 0
MissTotal		dd 0


;------Image Files-----	
;scoring
_Numbers		db 'Numbers.png',0		
_Comments		db  'comments.png', 0

;backgrounds
_Background		db	'DragonBallBG.png',0	
_Matrix			db	'MatrixKeanuWeird.png',0
_DragonBall		db	'DragonBallBG.png',0
_BlueSky		db	'skyblue.png',0
_FF8BG			db	'ff8BG.png',0

_fixedArrows		db	'fixedArrows1.png',0
_moveArrow		db	'16moveArrow.png',0
_UPfixedArrows		db	'UPfixedArrows1.png', 0
_LEFTfixedArrows	db	'LEFTfixedArrows1.png',0
_RIGHTfixedArrows	db 	'RIGHTfixedArrows1.png', 0
_DOWNfixedArrows	db 	'DOWNfixedArrows1.png', 0
_startScrn		db	'MenuScreen.png', 0
_hitArrows		db	'hitArrows.png', 0
_results		db 	'results.png', 0
_pause			db	'pause.png',0
_credits		db	'IDR_credits.png',0
_FlashFArrows		db	'FlashFArrows.png',0
_pressArrows		db	'pressArrows.png',0
_LoadingScreen		db	'LoadingScreen.png', 0
_LoadBar		db	'LoadBarFinal.png', 0
_scrollingBack		db	'ScrollingCode.png', 0
_selectSong		db	'selections.png', 0

_roundingFactor dd	000800080h, 00000080h



;-----Music Step Files (Adam)-----
_stepFN0	db	"hotlimith.step", 0
_stepFN1	db	"hotlimite.step", 0
_stepFN2	db	"cantspeedh.step", 0
_stepFN3	db	"cantspeede.step", 0
_stepFN		db	"hotlimith.step", 0

;***  Default tempo loaded
_fptemp1	dd	_BPMconstHot*_Multiplier	
_fptemp2	dd	68978
_fptemp4	dd	0
;_fptemp5	dd	0.0866666666666666667






	SECTION .text


;*** Void _Main ***************************************************************
; Inputs:	None
; Outputs:	None
; Calls:	_LibInit, _ReadFileIntoMem, _initTempArray, _AllocMem,
;		_InitGraphics, _FindGraphicsMode, _installKeyboardISR, 
;		_SetGraphicsMode, _finalMain, _UnsetGraphicsMode, 
;		_removeKeyboardISR, _ExitGraphics
; Purpose:	To begin loading all libraries and setup the graphics
;		display and install ISRs, also allocates the Buffers needed
; 		for sound play back.
;******************************************************************************

_main
	call	_LibInit

	call	_AllocateMem
;*** Cut and paste the follow three lines to get different step file
;	mov	dword[_stepFN], _stepFN2
;	call	_ReadFileIntoMem
;	call	_initTempArray
	
	;*** kw's code here
	; Allocate crucial DMA Buffers and Temp File Buffers for sound.
	invoke	_InitBuffers, dword 1024*1024*25, dword 1024*1024*20	
	;*** kw's code end

;-----from MP5 (Derek TA)-----
	; Allocate Screen Buffer
	invoke	_AllocMem, dword SCREEN_WIDTH*SCREEN_HEIGHT*4	
	cmp	eax, -1
	je	near .memerror
	mov	[_screenOff], eax

	; Graphics Init
	invoke	_InitGraphics, dword _keyboardINT, dword _keyboardIRQ, \
							dword _keyboardPort
	test	eax, eax
	jnz	near .graphicserror

	; Find Graphics Mode: 640x480x32, allow driver-emulated modes
	invoke	_FindGraphicsMode, word 640, word 480, word 32, dword 1
	mov	[_graphicsMode], ax

	; Mouse/Keyboard init
	call	_installKeyboardISR
	invoke	_SetGraphicsMode, word [_graphicsMode]
	
	call	_loadImages
	cmp		eax, -1
	je		near .memerror

	call	_finalMain	

.mouseerror:
	call	_UnsetGraphicsMode
	call	_removeKeyboardISR

.graphicserror:
	call	_ExitGraphics

.memerror:
	ret

;-----end use of MP5 stuff-----	

;*** Void _finalMain **********************************************************
; Inputs:	None
; Outputs:	None
; Calls:	_clearQueue, _loadImages, _startScreen, _dequeue, _copyBuffer2Buffer,
;		_CopyToScreen, _displayFirstScrn, _PlaySong, _PlaySoundFX, _setScrn
;		_checkKeyPress, _copyMovingArrows, _checkOffScreen, _checkEmpty
;		_copyBuffer2BufferWithAlpha, _StopSong, _finish

; Purpose:	To begin loading all libraries and setup the graphics
;			display and install ISRs, also allocates the Buffers needed
; 			for sound play back.
;******************************************************************************
proc _finalMain

.GameStart:
	call	_initFlags
	call	_displayLoadingScreen	

.start:
.GameStart2:		;Game Starts for the second time, RESET EVERYTHING!
	call	_initFlags
.BackFromCredits:
	call	_startScreen

.waitToPlay:
	cmp	dword [BG_Playing_Flag], 1
	je	.chooseNextFunction
	invoke 	_PlaySong, dword _tsLoop, dword 688436, dword 705, dword 44100, \
				dword 0, dword 1
	
.chooseNextFunction:
	cmp		dword [queueCount], 0
	je 		near .waitToPlay
	invoke  	_dequeue			
	cmp		al, SPACE
	je 		near .next
	cmp		al, ESC
	je 		near .error
	cmp		al, 'c'
	je 		near .credit
	cmp		al, RIGHT
	je		.switchSong
	
	cmp		al, LEFT
	je		.switchSong
	
	cmp		al, DOWN
	je		near .switchLevel
	cmp		al, UP
	je		near .switchLevel
	
	jmp	.waitToPlay
		
.switchSong:
	invoke	_switchSongFunction
	jmp		.waitToPlay
	
.switchLevel:
	invoke	_switchLevelFunction
	jmp		.waitToPlay
	
.credit:
	invoke	_displayCreditScreen
	jmp		near .BackFromCredits
	
.next:
	;*** kw's code
	invoke  _PlaySoundFX, dword _GreatSong, dword 132930
.SoundFXWait:
	cmp	dword [FG_Mix_Flag], 1
	je	.SoundFXWait
	;*** SoundFX finished playing at this point

	;*** Load Player Selected song depending on dword [SongSel_Flags]
	;*** Current Menu Selections
				; 0 - Hotlimit (Hard)
				; 1 - Hotlimit (Easy)
				; 2 - Can't Speed (Hard)
				; 3 - Can't Speed (Easy)

	mov	dword [BG_Playing_Flag], 0
	invoke	_StopSong
	cmp	dword [SongSel_Flags], 1
	jg	.play2ndSong
	invoke	_PlaySong, dword _HotLimit, dword 16280110, dword 705, \
		dword 44100, dword 0, dword 0
	jmp	.LoadSteps
	.play2ndSong:
	invoke	_PlaySong, dword _CantSpeed, dword 8027182, dword 705, dword 44100,\
		 dword 0, dword 0

.LoadSteps	
	call	_LoadStepFunction

	; Ready to read file now
.ReadStepFile:
	call	_displayFirstScrn
	call	_ReadFileIntoMem
	call	_initTempArray

	;*** Setup the appropriate tempo for the song
	cmp	dword [SongSel_Flags], 1
	jg	.CantSpeed_Tempo
	mov	eax, _BPMconstHot
	mov	ecx, _Multiplier
	mul	ecx
	mov	dword[_fptemp1], eax
	jmp	.mainLoop


.CantSpeed_Tempo:
	mov	eax, _BPMconstCant	; bpm for can't speed is 170
	mov	ecx, _Multiplier	; 161 to get the right tempo
	mul	ecx
	mov	dword [_fptemp1], eax	; 170*161



;*** MAIN LOOP START HERE!
.mainLoop:
	; Only run mainLoop again if Next_Frame_Flag is set to 1
	cmp	dword [EndOfSong_Flag], 1
	je	near .finish
	cmp	dword [Next_Frame_Flag], 1
	jne	.mainLoop	

	cmp	dword[_CommentCount], 15
	jge	.clearCommentCount
	
.checkSecondTimer	
	cmp	dword[_timerCount], 16*timerSet
	jge	.clearTimerCount
	jmp	.next2

.clearCommentCount
	mov	dword[_CommentCount], 0
	mov	dword[_CommentFlag], 0
	jmp	.checkSecondTimer

.clearTimerCount:
	mov	dword[_timerCount], 0
	jmp	.next2	
		
		
.next2:	
	inc	dword[_timerCount]
	inc	dword[_CommentCount]
		
	cmp 	byte [_escFlag], 1
	je 	near .finish
	
	cmp	byte [_pauseFlag], 0
	jne 	near .pause
	
.next1:	
	call	_setScrn
	call	 _ReadMemIntoArray	
	call	_displayNewFixedArrows	
	call	_copyMovingArrows
	call	_checkKeyPress

	cmp	byte[_CommentFlag], 0
	je	.noComment
	call	_displayComment

.noComment
	call	_copyMovingBackground
		
	;displays screen with arrow in new position
	invoke _CopyToScreen, dword [_screenOff], PIC_WIDTH*4, \
		dword 0, dword 70, dword PIC_WIDTH, dword PIC_HEIGHT, \
				dword 0, dword 0		
	call	_checkOffScreen
	call	_checkEmpty
		
	; Reset Next_Frame_Flag
	mov	dword [Next_Frame_Flag], 0
	cmp	byte[_ArrowFlag], 1	;if flag 0, then no more arrows, exit
	je	.mainLoop
	jmp	.finish
	

.pause:
	invoke 	_copyBuffer2BufferWithAlpha, dword [_pauseOff], \
		dword PAUSE_WIDTH*4, dword 0, dword 0, dword [_screenOff], \
		dword SCREEN_WIDTH*4, 170, 270, dword PAUSE_WIDTH, \
		dword PAUSE_HEIGHT		

	invoke 	_CopyToScreen, dword [_screenOff], PIC_WIDTH*4, \
		dword 0, dword 70, dword PIC_WIDTH, dword PIC_HEIGHT, \
			dword 0, dword 0		
			
	call	_checkKeyPress
	cmp	byte [_escFlag], 1
	je	.finish
	cmp	byte[_pauseFlag], 0
	jne	.pause

	jmp	.next1
		
;*** Game Over Here!
.finish:
	
;*************Krista's change************
    call    _StopSong	
	call	_displayLastScrn
	mov     byte[PerfectTotal], 0
	mov     byte[GreatTotal], 0
	mov     byte[GoodTotal], 0
	mov     byte[BooTotal], 0
	mov     byte[MissTotal], 0
	mov     byte[Total], 0
	call	_initTempArray       ;***********CHANGE!**5/4/03****
;***************************************
	jmp	.GameStart2

		
.error
	call	_StopSong	; might not be needed
.end:
	ret
endproc
_finalMain_arglen	equ	0






;-----------------------------------------------------------------------------------------------------------
; _load0 (Cindy Chang)
;
; functions:	loads and displays the '0' song onto the screen
; calls/IO:		_copyBuffer2Buffer, _copyBuffer2BufferWithAlpha, _CopyToScreen
;-----------------------------------------------------------------------------------------------------------
_load0
	invoke _copyBuffer2Buffer,dword [_startScrnOff],dword PIC_WIDTH*4,\
		dword 0, dword 0, \
		dword [_screenOff], dword PIC_WIDTH*4, \
		dword 0, dword 70, \
		dword PIC_WIDTH, dword PIC_HEIGHT \
		
	invoke _copyBuffer2BufferWithAlpha, dword[_selectSongOff], dword 1192,\
		dword 0, dword 0, \
		dword[_screenOff], dword PIC_WIDTH*4, \
		dword 40, dword 390, dword 148, dword 42
		
	;display screen buffer to screen (background)
	invoke _CopyToScreen, dword [_screenOff], PIC_WIDTH*4, \
		dword 0, dword 70, \
		dword PIC_WIDTH, dword PIC_HEIGHT, \
		dword 0, dword 0
	ret


;-----------------------------------------------------------------------------------------------------------
; _load1 (Cindy Chang)
;
; functions:	loads and displays the '1' song onto the screen
; calls/IO:		_copyBuffer2Buffer, _copyBuffer2BufferWithAlpha, _CopyToScreen
;-----------------------------------------------------------------------------------------------------------
_load1

	invoke _copyBuffer2Buffer,dword [_startScrnOff],dword PIC_WIDTH*4,\
		dword 0, dword 0, \
		dword [_screenOff], dword PIC_WIDTH*4, \
		dword 0, dword 70, \
		dword PIC_WIDTH, dword PIC_HEIGHT \
		
	invoke _copyBuffer2BufferWithAlpha, dword[_selectSongOff], dword 1192,\
		dword 0, dword 43, \
		dword[_screenOff], dword PIC_WIDTH*4, \
		dword 40, dword 390, dword 148, dword 42
		
	;display screen buffer to screen (background)
	invoke _CopyToScreen, dword [_screenOff], PIC_WIDTH*4, \
		dword 0, dword 70, \
		dword PIC_WIDTH, dword PIC_HEIGHT, \
		dword 0, dword 0
	ret



;-----------------------------------------------------------------------------------------------------------
; _load2 (Cindy Chang)
;
; functions:	loads and displays the '2' song onto the screen
; calls/IO:		_copyBuffer2Buffer, _copyBuffer2BufferWithAlpha, _CopyToScreen
;-----------------------------------------------------------------------------------------------------------
_load2
	invoke _copyBuffer2Buffer,dword [_startScrnOff],dword PIC_WIDTH*4,\
		dword 0, dword 0, \
		dword [_screenOff], dword PIC_WIDTH*4, \
		dword 0, dword 70, \
		dword PIC_WIDTH, dword PIC_HEIGHT \
		
	invoke _copyBuffer2BufferWithAlpha, dword[_selectSongOff], dword 1192,\
		dword 148, dword 0, \
		dword[_screenOff], dword PIC_WIDTH*4, \
		dword 40, dword 390, dword 148, dword 42
		

	;display screen buffer to screen (background)
	invoke _CopyToScreen, dword [_screenOff], PIC_WIDTH*4, \
		dword 0, dword 70, \
		dword PIC_WIDTH, dword PIC_HEIGHT, \
		dword 0, dword 0
	ret
		

;-----------------------------------------------------------------------------------------------------------
; _load3 (Cindy Chang)
;
; functions:	loads and displays the '3' song onto the screen
; calls/IO:		_copyBuffer2Buffer, _copyBuffer2BufferWithAlpha, _CopyToScreen
;-----------------------------------------------------------------------------------------------------------
_load3
	invoke _copyBuffer2Buffer,dword [_startScrnOff],dword PIC_WIDTH*4,\
		dword 0, dword 0, \
		dword [_screenOff], dword PIC_WIDTH*4, \
		dword 0, dword 70, \
		dword PIC_WIDTH, dword PIC_HEIGHT \
		
	invoke _copyBuffer2BufferWithAlpha, dword[_selectSongOff], dword 1192,\
		dword 148, dword 43, \
		dword[_screenOff], dword PIC_WIDTH*4, \
		dword 40, dword 390, dword 148, dword 42
		

	;display screen buffer to screen (background)
	invoke _CopyToScreen, dword [_screenOff], PIC_WIDTH*4, \
		dword 0, dword 70, \
		dword PIC_WIDTH, dword PIC_HEIGHT, \
		dword 0, dword 0
	ret
	




;-----------------------------------------------------------------------------------------------------------
; _switchSongFuction (Kuangwei Hwang)
;
; functions:	decides which song user selects, plays clip of the song, sets flags
; calls:		_PlaySoundFX, _PlaySong, _load0, _load1, _load2, _load3
;-----------------------------------------------------------------------------------------------------------	
_switchSongFunction
	invoke  _PlaySoundFX, dword _CDChangeFX, dword 25406
	
	.SoundFXWaitCD:
		cmp		dword [FG_Mix_Flag], 1
		je		.SoundFXWaitCD
		cmp		dword[SongSel_Flags], 0
		je		near .change2
		cmp		dword[SongSel_Flags], 1
		je		near .change3
		cmp		dword[SongSel_Flags], 2
		je		near .change0
		cmp		dword[SongSel_Flags], 3
		je		near .change1

	.change2
		mov		dword[SongSel_Flags], 2
		call	_load2
		invoke	_PlaySong, dword _CantSpeed, dword 8027182, dword 705, dword 44100,\
					dword 0, dword 0		
		jmp		.end
		
	.change3
		mov		dword[SongSel_Flags], 3
		call	_load3
		invoke	_PlaySong, dword _CantSpeed, dword 8027182, dword 705, dword 44100,\
					dword 0, dword 0
		jmp		.end
	
	.change0
		mov		dword[SongSel_Flags], 0
		call	_load0
		; Play Corresponding Songs
		invoke	_PlaySong, dword _HotLimit, dword 16280110, dword 705, \
					dword 44100, dword 0, dword 0
		jmp		.end

	.change1
		mov		dword[SongSel_Flags], 1
		call	_load1
		; Play Corresponding Songs
		invoke	_PlaySong, dword _HotLimit, dword 16280110, dword 705, \
					dword 44100, dword 0, dword 0
		jmp		.end
		
	.end
		ret






;-----------------------------------------------------------------------------------------------------------
; _switchLevelFuction (Cindy Chang)
;
; functions:	sets the level from user input, sets flags
; calls/IO:		_PlaySoundFX, _load0, _load1, _load2, _load3
;-----------------------------------------------------------------------------------------------------------
_switchLevelFunction
	invoke  _PlaySoundFX, dword _CDChangeFX, dword 25406
	cmp		dword[SongSel_Flags], 0
	je		.2change1
	cmp		dword[SongSel_Flags], 1
	je		.2change0
	cmp		dword[SongSel_Flags], 2
	je		.2change3
	cmp		dword[SongSel_Flags], 3
	je		.2change2

	.2change2
		mov		dword[SongSel_Flags], 2
		call	_load2
		jmp		.end
		
	.2change3
		mov		dword[SongSel_Flags], 3
		call	_load3
		jmp		.end
	
	.2change0
		mov		dword[SongSel_Flags], 0
		call	_load0
		jmp		.end

	.2change1
		mov		dword[SongSel_Flags], 1
		call	_load1
		jmp		.end
		
	.end
		ret





;-----------------------------------------------------------------------------------------------------------
; _LoadStepFunction (Kuangwei Hwang)
;
; functions:	loads the appropriate step files depending on flags that are set
; calls/IO:		none
;-----------------------------------------------------------------------------------------------------------
_LoadStepFunction
	;***Load the Appropriate Step File Accordingly
	cmp	dword [SongSel_Flags], 3
	jne	.Song0_2
	mov	dword[_stepFN], _stepFN3
	mov	edx, dword [_DragonballOff]
	mov	dword [_BackgroundOff], edx		; Load Different Background
	jmp	.end				; For different steps
	
	.Song0_2:
	cmp	dword [SongSel_Flags], 2
	jne	.Song0_1
	mov	dword[_stepFN], _stepFN2
	mov	edx, dword [_MatrixOff]
	mov	dword [_BackgroundOff], edx
	jmp	.end

	.Song0_1:
	cmp	dword [SongSel_Flags], 1
	jne	.Song0
	mov	dword[_stepFN], _stepFN1
	mov	edx, dword [_SkyBlueOff]
	mov	dword [_BackgroundOff], edx		; Load Different Background
	jmp	.end
	
	.Song0
	mov	dword[_stepFN], _stepFN0
	mov	edx, dword [_FF8BGOff]
	mov	dword [_BackgroundOff], edx		; Load Different Background
	
	.end
	ret






;-----------------------------------------------------------------------------------------------------------
; _displayCreditScreen (Cindy Chang)
;
; functions:	displays a scrolling credit screen with a random song in the background
; calls/IO:		_PlaySoundFX, _PlaySong, _copyBuffer2Buffer, _CopyToScreen, _deque
;-----------------------------------------------------------------------------------------------------------
_displayCreditScreen
	mov		dword[_creditInc], 0
	invoke  _PlaySoundFX, dword _DiscSelect, dword 35448

.SoundFXWait2:
	cmp		dword [FG_Mix_Flag], 1
	je		.SoundFXWait2

			;*** kw's Code here, first song in credit screen is played, the two songs
			;*** are played ramdomly depending on the position of the DMA_Flags
	test	byte [DMA_Flags], DMA_Refill_Flag
	jnz		.playSecond
	invoke 	_PlaySong, dword _Brilliant2U, dword 16330798, dword 705, dword 44100, \
				dword 0, dword 0
	jmp		.creditWait
.playSecond:
	invoke 	_PlaySong, dword _BumbleBee, dword 17372206, dword 705, dword 22050, \
				dword 1, dword 0
			;*** kw's code end
.creditWait:

			;*** limit loop to 30 times per second
	cmp		dword [BG_Playing_Flag], 1	; First Check if any song is playing
	jne		near .startFX				; otherwise just quit
	cmp		dword [Next_Frame_Flag], 1	; Second check if 1/30 sec passed
	jne		.creditWait					; else wait
	mov		dword [Next_Frame_Flag], 0	; reset flag (SoundISR sets it)

	cmp		dword[_creditInc], 4517
	jge		near .creditDone
	add		dword[_creditInc], 3		; Determines how fast the credit
										; screen scrolls


	invoke 	_copyBuffer2Buffer, dword [_creditsOff], dword PIC_WIDTH*4,\
			dword 0, dword[_creditInc], dword [_screenOff], dword PIC_WIDTH*4, \
			dword 0, dword 70, dword PIC_WIDTH, dword PIC_HEIGHT

			;display screen buffer to screen (background)
	invoke 	_CopyToScreen, dword [_screenOff], PIC_WIDTH*4, \
			dword 0, dword 70, dword PIC_WIDTH, dword PIC_HEIGHT, \
			dword 0, dword 0


.creditDone
	cmp 	dword [queueCount], 0
	je 		near .creditWait

	invoke 	_dequeue

	cmp		al, 'b'
	je		.startFX	;*** kw changed from .start to .startFX for 
						;	cmp	al, ESC		;*** Sound effect
						;	je 	near .error
	jmp		.creditWait

						;*** kw's code begin
.startFX:				; jumps to start after _DiscSelect Played
	invoke  _PlaySoundFX, dword _DiscSelect, dword 35448	; play Disc Change Sound Effect

.SoundFXWait0:			;*** Waits for Sound FX to finish
	cmp		dword [FG_Mix_Flag], 1
	je		.SoundFXWait0
ret
						;*** kw's code end















;-----------------------------------------------------------------------------------------------------------
; _initFlags (Cindy & Kuangwei)
;
; functions:	initializes flags
; calls:		none
;-----------------------------------------------------------------------------------------------------------
_initFlags
	invoke	_clearQueue
	mov		byte[_pauseFlag], 0
	mov 		byte[_escFlag], 0
	mov		dword[_timerCount],0
	mov		dword[_scrollingTop],4510 
	mov		dword[BG_Playing_Flag], 0
	mov		dword[FG_Mix_Flag], 0
	mov		dword[EndOfSong_Flag], 0
	mov		dword[Next_Frame_Flag], 1
	mov		dword[_ArrowFlag], 1		;*** kw's fix
	mov 		edx, [_stepOff]				;save offset!!!
	mov     	[_stepIndex], edx			;save as index
	mov		dword [SongSel_Flags], 0
	mov		dword[_CommentCount], 0
	mov		dword[_CommentFlag], 0
	mov		dword [queueCount], 0
ret

;-----------------------------------------------------------------------------------------------------------
; _displayLoadingScreen (Cindy & Kuangwei)
;
; functions:	displays Loading Screen
; calls:		_PlaySong, _copyBuffer2BufferWithAlpha, _copyToScreen, _dequeue
;-----------------------------------------------------------------------------------------------------------
_displayLoadingScreen
		;displays Loading Screen Background
		invoke _copyBuffer2Buffer,dword [_LoadingScreenOff],dword PIC_WIDTH*4,\
		dword 0, dword 0, \
		dword [_screenOff], dword PIC_WIDTH*4, \
		dword 0, dword 70, \
		dword PIC_WIDTH, dword PIC_HEIGHT \

		;display screen buffer to screen (background)
		invoke _CopyToScreen, dword [_screenOff], PIC_WIDTH*4, \
		dword 0, dword 70, \
		dword PIC_WIDTH, dword PIC_HEIGHT, \
		dword 0, dword 0
				
		; Play the Title Music once it starts
		invoke	_PlaySong, dword _Title, dword 1608246, dword 705, dword 44100, \
						dword 0, dword 0
		; Check if play successful
		cmp		dword [BG_Playing_Flag], 1
		jne		near .end	; if Title music fails, Load Menu Screen
	;*** kw's Code here *** Displays Loading Screen Graphics and Title Song
	;*** (18 secs, press s to jump out)
	.LoadWait:
		cmp		dword [Next_Frame_Flag], 0	; Keeps this loop synched with the sound
		je		.LoadWait		
		mov		dword [Next_Frame_Flag], 0	; reset the flag once per Sound Interrupt

		cmp		dword [EndOfSong_Flag], 1	; If Song is over, 
		je		near .end

		inc		dword[_loadBarCount]
		cmp		dword[_loadBarCount], 20
		jne		.LoadWait
		
		mov		dword[_loadBarCount], 0


		add		dword[_loadBarPosition],12
		
		;displays the updated loading bar
		invoke _copyBuffer2BufferWithAlpha, dword [_LoadBarOff], \
		1152, dword 0, dword 0, \
		dword [_screenOff], SCREEN_WIDTH*4, dword 82, \
		dword dword 429, dword[_loadBarPosition], \
		dword 20
	
		invoke _CopyToScreen, dword [_screenOff], PIC_WIDTH*4, \
		dword 0, dword 70, dword PIC_WIDTH, dword PIC_HEIGHT, \
		dword 0, dword 0
		
		cmp		dword[_loadBarPosition], 288
		je		near .end

		cmp		dword [queueCount], 0
		je 		.LoadWait

		invoke  _dequeue					;stores deque in al	
		cmp		al, 's'
		je 		near .end
		jmp		.LoadWait					; when entering from load screen
		
	.end
		ret










;-----------------------------------------------------------------------------------------------------------
; _copyMovingBackground (Cindy Chang)
;
; functions:	copies scrolling code background when playing into _screenOff buffer
; calls/IO:		_copyBuffer2BufferWithAlpha
;-----------------------------------------------------------------------------------------------------------
_copyMovingBackground
		cmp	dword[_scrollingTop], 5
		jle	.resetScrollingTop
		jmp	.continue
	
	.resetScrollingTop
		mov	dword[_scrollingTop], 4510
		
	.continue
		sub	dword[_scrollingTop], 3

		invoke _copyBuffer2BufferWithAlpha, dword [_scrollingBackOff], \
			dword 1200, dword 0, dword [_scrollingTop], \
			dword [_screenOff], SCREEN_WIDTH*4, dword 3, \
			dword 70, dword 300, \
			dword 480
	ret



;-----------------------------------------------------------------------------------------------------------
; _displayComment (Cindy Chang)
;
; functions:	copies 'comment' into _screenOff when playing
; calls/IO:		_copyBuffer2BufferWithAlpha, _CommentsOff(In), _CommentChoice(In)
;-----------------------------------------------------------------------------------------------------------
_displayComment
	invoke _copyBuffer2BufferWithAlpha, dword [_CommentsOff], \
		dword Comments_WIDTH*4, dword 0, dword [_CommentChoice], \
		dword [_screenOff], SCREEN_WIDTH*4, dword 390, \
		dword 220, dword 174, dword 35
	ret






;-----------------------------------------------------------------------------------------------------------
; _startScreen (Cindy Chang)
;
; functions:	displays start screen
; calls/IO:		_copyBuffer2BufferWithAlpha, _copyBuffer2Buffer, _CopyToScreen, _selectSongOff(In)
;-----------------------------------------------------------------------------------------------------------
_startScreen
	invoke _copyBuffer2Buffer,dword [_startScrnOff],dword PIC_WIDTH*4,\
		dword 0, dword 0, \
		dword [_screenOff], dword PIC_WIDTH*4, \
		dword 0, dword 70, \
		dword PIC_WIDTH, dword PIC_HEIGHT \

	invoke _copyBuffer2BufferWithAlpha, dword[_selectSongOff], dword 1192,\
		dword 0, dword 0, \
		dword[_screenOff], dword PIC_WIDTH*4, \
		dword 40, dword 390, dword 148, dword 43
	
	;display screen buffer to screen (background)
	invoke _CopyToScreen, dword [_screenOff], PIC_WIDTH*4, \
		dword 0, dword 70, \
		dword PIC_WIDTH, dword PIC_HEIGHT, \
		dword 0, dword 0
.end
	ret







;-----------------------------------------------------------------------------------------------------------
; _checkKeyPress	(By Cindy)
;
; functions:	checks whether arrow was pressed, if so, set flag
; calls:	_CopyBuffer2BufferWithAlpha, Deq
;-----------------------------------------------------------------------------------------------------------
_checkKeyPress


.checkQueue
		cmp	dword [queueCount], 0
		je  near	.end
		invoke _dequeue				;stores deque in al
		
		cmp	al, ESC
		je  near	.escape
		
		cmp al, 'p'
		je  near	.pause
		
		cmp	al, UP
		je	near .up
		
		cmp	al, LEFT
		je	near .left
		
		cmp al, RIGHT
		je	near .right
		
		cmp	al, DOWN
		je	near .down
		
		
		jmp .checkQueue

		
		
.up:
	mov	byte[_upPressFlag], 1
	or	byte [ArrowBuffer], UpFlag
	
	invoke _checkHit, 3			
	jmp	.checkQueue
			
.left:
	mov	byte[_leftPressFlag],1
	or	byte [ArrowBuffer], LeftFlag	
	
	invoke _checkHit, 1
	jmp .checkQueue
			
.right:	
	mov	byte[_rightPressFlag], 1
	or	byte [ArrowBuffer], RightFlag
			
	invoke _checkHit, 4
	jmp .checkQueue
				
.down:
	mov	byte[_downPressFlag],1
	or	byte [ArrowBuffer], DownFlag


	invoke _checkHit, 2
	jmp .checkQueue
			
.escape:
	mov	byte[_escFlag], 1
	jmp	.end
.pause:
	not	byte[_pauseFlag]
	jmp	.checkQueue
	;jmp .end
.end:
ret


;-----------------------------------------------------------------------------------------------------------
; _checkHit	(Cindy Chang & Krista Eichhorn)
;
; functions:	checks what score user's key press should receive, sets Hit Flags
;				sets _commentChoice and _commentFlag
; calls/IO:		_CopyBuffer2BufferWithAlpha, _dequeue, _checkHit (which checks whether arrow was hit
;-----------------------------------------------------------------------------------------------------------
proc	_checkHit
.type	arg	4

	push	ecx
	push	eax
	xor	ecx, ecx

.loop:
	cmp	ecx, Arrow_size *ArraySize
	je near	.end
		
	mov	eax, dword[ebp+.type]	;checks whether 'exist' flag is 1
	cmp	al, byte[_arrowArray+ecx+Arrow.type]	;checks whether 'exist' flag is 1
	jne 	near .goToNext

	;*************Scoring Section***********************************
 xor edx, edx
  
  ;How far away are the moving arrows from the stationary arrows?
 
        cmp dword[_arrowArray+ecx+Arrow.YCoord], 116
        jg near  .goToNext
        
		cmp dword[_arrowArray+ecx+Arrow.YCoord], 110
		jge near	.goToBoo
		
		cmp dword[_arrowArray+ecx+Arrow.YCoord], 104
		jge near	.goToGood
		
		cmp dword[_arrowArray+ecx+Arrow.YCoord], 98
		jge near	.goToGreat
		
		cmp dword[_arrowArray+ecx+Arrow.YCoord], 90
		jge near	.goToPerfect
		
		cmp dword[_arrowArray+ecx+Arrow.YCoord], 82
		jge near	.goToGreat
		
		cmp dword[_arrowArray+ecx+Arrow.YCoord], 74
		jge near	.goToGood
		
		cmp dword[_arrowArray+ecx+Arrow.YCoord], 66
		jge near	.goToBoo

		jmp near  .goToNext
		
;Incriment the appropriate score word
				
	.goToBoo
		inc dword[Boo]
		mov eax, dword[Boo]
		mov ebx, 31
		mul ebx
		mov dword[BooTotal], eax
;		mov dword[_CommentChoice], 139
		mov	dword[_CommentChoice], 104
		mov	dword[_CommentFlag], 2
		jmp .hit
		
	.goToGood
		inc dword[Good]
		mov eax, dword[Good]
		mov ebx, 42
		mul ebx
		mov dword[GoodTotal], eax
;		mov dword[_CommentChoice], 104
		mov dword[_CommentChoice], 69
		mov	dword[_CommentFlag], 3
		jmp .hit
		
	.goToGreat
		inc dword[Great]
		mov eax, dword[Great]
		mov ebx, 164
		mul ebx
		mov dword[GreatTotal], eax
;		mov dword[_CommentChoice], 69
		mov dword[_CommentChoice], 34	
		mov	dword[_CommentFlag], 4
		jmp .hit
		
	.goToPerfect
		inc dword[Perfect]
		mov eax, dword[Perfect]
		mov ebx, 1173
		mul ebx
		mov dword[PerfectTotal], eax
;		mov dword[_CommentChoice], 34
		mov dword[_CommentChoice], 0
		mov dword[_CommentFlag], 5
		jmp .hit
;*************end Krista's Change*********************8		
		
.hit:
	cmp	dword[ebp+.type], 1 ;left
	je 	near	.left
		
	cmp	dword[ebp+.type], 2
	je 	near .down
	
	cmp 	dword[ebp+.type], 3
	je 	near .up
		
	cmp 	dword[ebp+.type], 4
	je 	near .right


.left:
	mov byte[_leftHitFlag],1
	jmp	near .back		
		
.down:
	mov byte[_downHitFlag],1
	jmp	near .back		
	
.up:
	mov byte[_upHitFlag],1
	jmp	near .back	
	
.right:
	mov byte[_rightHitFlag],1
	jmp	near .back	
	
.back:
	mov	byte[_arrowArray+ecx+Arrow.exist], 0
	mov	dword[_arrowArray+ecx+Arrow.YCoord], 0				
		
.goToNext:
	add ecx, Arrow_size
	jmp	near .loop

.end:
	pop	eax
	pop ecx
	ret
endproc
_checkHit_arglen equ 4



;------------------------------------------------------------------------------------------------------
; _displayNewFixedArrows	(Cindy Chang)
;
;	function:	displays a flashing yellow arrow for hit and a shrink for press, then resets flags to 0
;	calls/IO:	_copyBuffer2BufferWithAlpha			
;------------------------------------------------------------------------------------------------------
_displayNewFixedArrows

.checkLeft
	cmp	byte[_leftHitFlag], 1
	je near	.leftHit
	cmp	byte[_leftPressFlag], 1
	je near	.leftPress
	
.checkDown
	cmp	byte[_downHitFlag], 1
	je near	.downHit
	cmp	byte[_downPressFlag], 1
	je near	.downPress
	
.checkUp
	cmp	byte[_upHitFlag], 1
	je near	.upHit
	cmp	byte[_upPressFlag], 1
	je near	.upPress
	
.checkRight
	cmp	byte[_rightHitFlag], 1
	je near	.rightHit
	cmp	byte[_rightPressFlag], 1
	je near	.rightPress
	
jmp	.end
	
.leftHit
	mov	byte[_leftHitFlag], 0
	mov byte[_leftPressFlag], 0
	invoke _copyBuffer2BufferWithAlpha, dword [_FlashFArrowsOff], fArrows_WIDTH*4, 0, dword 0, \
			dword [_screenOff], SCREEN_WIDTH*4, dword[_screenleft], dword[_screentop], \
			dword 62, dword fArrows_HEIGHT
	jmp near .checkDown
	
.downHit
	mov	byte[_downHitFlag], 0
	mov byte[_downPressFlag], 0
	invoke _copyBuffer2BufferWithAlpha, dword [_FlashFArrowsOff], fArrows_WIDTH*4, 64, dword 0, \
			dword [_screenOff], SCREEN_WIDTH*4, dword[_screendown], dword[_screentop], \
			dword 62, dword fArrows_HEIGHT
	jmp	near .checkUp
	
.upHit
	mov	byte[_upHitFlag], 0
	mov byte[_upPressFlag], 0
	invoke _copyBuffer2BufferWithAlpha, dword [_FlashFArrowsOff], fArrows_WIDTH*4, 128, dword 0, \
			dword [_screenOff], SCREEN_WIDTH*4, dword[_screenup], dword[_screentop], \
			dword 62, dword fArrows_HEIGHT
	jmp near .checkRight
	
.rightHit
	mov	byte[_rightHitFlag], 0
	mov byte[_rightPressFlag], 0
	invoke _copyBuffer2BufferWithAlpha, dword [_FlashFArrowsOff], fArrows_WIDTH*4, 190, dword 0, \
			dword [_screenOff], SCREEN_WIDTH*4, dword[_screenright], dword[_screentop], \
			dword 62, dword fArrows_HEIGHT
	jmp near .end

	
.leftPress
	mov byte[_leftPressFlag], 0
	invoke _copyBuffer2Buffer, dword[_BackgroundOff], PIC_WIDTH*4, dword[_screenleft], 20, dword[_screenOff], \
			SCREEN_WIDTH*4, dword[_screenleft], dword[_screentop], dword 62, dword fArrows_HEIGHT
	invoke _copyBuffer2BufferWithAlpha, dword [_pressArrowsOff], fArrows_WIDTH*4, 0, 0, dword[_screenOff], \
			SCREEN_WIDTH*4, dword[_screenleft], dword[_screentop], dword 62, dword fArrows_HEIGHT

	jmp	near .checkDown	
.downPress
	mov	byte[_downPressFlag], 0
	invoke _copyBuffer2Buffer, dword[_BackgroundOff], PIC_WIDTH*4, dword[_screendown], 20, dword[_screenOff], \
			SCREEN_WIDTH*4, dword[_screendown], dword[_screentop], dword 62, dword fArrows_HEIGHT
	invoke _copyBuffer2BufferWithAlpha, dword [_pressArrowsOff], fArrows_WIDTH*4, 63, 0, dword[_screenOff], \
			SCREEN_WIDTH*4, dword[_screendown], dword[_screentop], dword 62, dword fArrows_HEIGHT
	
	jmp	near .checkUp
.upPress
	mov byte[_upPressFlag], 0
	invoke _copyBuffer2Buffer, dword[_BackgroundOff], PIC_WIDTH*4, dword[_screenup], 20, dword[_screenOff], \
			SCREEN_WIDTH*4, dword[_screenup], dword[_screentop], dword 62, dword fArrows_HEIGHT
	invoke _copyBuffer2BufferWithAlpha, dword [_pressArrowsOff], fArrows_WIDTH*4, 128, 0, dword[_screenOff], \
			SCREEN_WIDTH*4, dword[_screenup], dword[_screentop], dword 62, dword fArrows_HEIGHT
	jmp	near .checkRight

.rightPress
	mov	byte[_rightPressFlag],0
	invoke _copyBuffer2Buffer, dword[_BackgroundOff], PIC_WIDTH*4, dword[_screenright], 20, dword[_screenOff], \
			SCREEN_WIDTH*4, dword[_screenright], dword[_screentop], dword 62, dword fArrows_HEIGHT
	invoke _copyBuffer2BufferWithAlpha, dword [_pressArrowsOff], fArrows_WIDTH*4, 190, 0, dword[_screenOff], \
			SCREEN_WIDTH*4, dword[_screenright], dword[_screentop], dword 62, dword fArrows_HEIGHT	

;jmp	.end

.end
	ret






;------------------------------------------------------------------------------------------------------
; _initTempArray (Adam)
;
;	function:	Initializes the array (_arrowArray) until stepfile begins
;				
;------------------------------------------------------------------------------------------------------
_initTempArray
	;fill the temporary arrow array

	push ecx
	xor ecx, ecx

.loop:
	cmp	ecx, Arrow_size*ArraySize 	;checks whether entire 
						; array has been run through
	je 	.end
		
	mov		byte[_arrowArray+ecx+Arrow.exist],0				
	add		ecx, Arrow_size									;increments index in array to next arrow
	jmp		.loop

.end:
	pop 	ecx

	push 	esi
	
	mov 	esi, _arrowArray
	
	mov 	dword[esi + Arrow.YCoord],370			; dummy arrow
	mov 	byte[esi + Arrow.type],3
	mov 	byte[esi + Arrow.exist],0
	
	add 	esi, Arrow_size

	mov 	dword[esi+Arrow.YCoord], 420			; dummy arrow
	mov 	byte[esi+Arrow.type],4
	mov 	byte[esi+Arrow.exist],0

	add 	esi, Arrow_size

	mov 	dword[esi+Arrow.YCoord], 470			; dummy arrow
	mov 	byte[esi+Arrow.type],1
	mov 	byte[esi+Arrow.exist],0
	
	add 	esi, Arrow_size

	mov 	dword[esi+Arrow.YCoord], 520			; dummy arrow
	mov 	byte[esi+Arrow.type],2
	mov 	byte[esi+Arrow.exist],0
	
	add 	esi, Arrow_size

	mov 	dword[esi+Arrow.YCoord], 570			; 'fake' arrow of false type
	mov 	byte[esi+Arrow.type],7					; placeholder until actual steps begin
	mov 	byte[esi+Arrow.exist],1
	
	pop 	esi
	
	ret
	


;-----------------------------------------------------------------------------------------------------------
; _displayFirstScrn  (by Cindy)
;
; functions:	displays background.  displays fixed arrows.
;		puts values int _screenleft, _screentop, _sourceleft that represent position of fixed arrows
; calls:	_CopyBuffer2Buffer, _CopyToScreen, _CopyBuffer2BufferWithAlpha
;-----------------------------------------------------------------------------------------------------------
_displayFirstScrn

	;copy background to screen buffer
	invoke _copyBuffer2Buffer,dword [_BackgroundOff],dword PIC_WIDTH*4,\
		dword 0, dword 0, \
		dword [_screenOff], dword PIC_WIDTH*4, \
		dword 0, dword 70, \
		dword PIC_WIDTH, dword PIC_HEIGHT \
	
	;display screen buffer to screen (background)
	invoke _CopyToScreen, dword [_screenOff], PIC_WIDTH*4, \
		dword 0, dword 70, \
		dword PIC_WIDTH, dword PIC_HEIGHT, \
		dword 0, dword 0
		
	push 	edx
	push	eax
	add 	edx, 350
	add	eax, 20
	
	;saves offset of fixed arrows
	mov	dword[_screenleft], edx
	mov 	dword[_screentop], eax
	mov	dword[_sourceleft], ebx
	add	dword[_screentop], 70
	
	add	edx, 63
	mov	dword[_screendown], edx
	add	edx, 62
	add	edx, 3
	mov	dword[_screenup], edx
	add edx, 62
	mov dword[_screenright], edx
	
	
	;copies fixed arrows into background
	invoke _copyBuffer2BufferWithAlpha, dword [_fArrowsOff], \
		fArrows_WIDTH*4, dword[_sourceleft], dword 0, \
		dword [_screenOff], SCREEN_WIDTH*4, dword[_screenleft], \
		dword dword[_screentop], dword fArrows_WIDTH, \
		dword fArrows_HEIGHT
	
	;displays new background	
	invoke _CopyToScreen, dword [_screenOff], PIC_WIDTH*4, \
		dword 0, dword 70, dword PIC_WIDTH, dword PIC_HEIGHT, \
		dword 0, dword 0
				
	pop eax
	pop edx
	
	ret


;------------------------------------------------------------------------
; _setScrn	(by Cindy)
;
; functions:	sets up _ScreenOff buffer with background & fixed arrows
; calls:		_copyBuffer2Buffer, _copyBuffer2BufferWithAlpha 
;
;------------------------------------------------------------------------
_setScrn
	invoke _copyBuffer2Buffer,dword [_BackgroundOff],dword PIC_WIDTH*4,\
	dword 0, dword 0, \
	dword [_screenOff], dword PIC_WIDTH*4, \
	dword 0, dword 70, \
	dword PIC_WIDTH, dword PIC_HEIGHT \

	;copies fixed arrows into background
	invoke _copyBuffer2BufferWithAlpha, dword [_fArrowsOff], \
		fArrows_WIDTH*4, dword [_sourceleft], dword 0, \
		dword [_screenOff], SCREEN_WIDTH*4, dword[_screenleft], \
		dword[_screentop], dword fArrows_WIDTH, dword fArrows_HEIGHT
ret



;*******************Krista's Added Functions*****************************
;-------------------------------------------------------------------------------------------------------
;_CalcScore	(Krista Eichhorn)
;
; functions:	calculates accuracy and total scores and find the numbers to display to the screen
; calls/IO:		none
;----------------------------------------------------------------------------------------------------------

_CalcScore


	push eax
    push ebx
    push ecx
    push edx
    
;Jump to correct calc group
	cmp  eax, 0
	je   .PerfectCalc
	cmp  eax, 1
	je   .GreatCalc
	cmp  eax, 2
	je   .GoodCalc
	cmp  eax, 3
	je   .BooCalc
	cmp  eax, 4
	je   .MissCalc
	cmp  eax, 5 
	je   .TotalCalc
    
    .PerfectCalc
		mov eax, dword[Perfect]
		jmp .Calc
    
    .GreatCalc
		mov eax, dword[Great]
		jmp .Calc
    .GoodCalc
		mov eax, dword[Good]
        jmp .Calc
    .BooCalc
		mov eax, dword[Boo]
        jmp .Calc
    .MissCalc
		mov eax, dword[Miss]
		jmp .Calc

;Add up the total score
    .TotalCalc
		mov eax, dword[PerfectTotal]
		add eax, dword[GreatTotal]
		add eax, dword[GoodTotal]
		;add eax, dword[BooTotal]
		;add eax, dword[MissTotal]
		mov dword[Total], eax
        jmp .Calc

;Find the numbers to display to the screen
	.Calc
		xor ecx, ecx
		xor ebx, ebx
		xor edx, edx
	
	    mov ecx, 20
		mov	ebx, 100000
		div ebx
		mov ebx, edx
		xor edx, edx
		mul ecx
		mov dword[HThousand], eax
		mov eax, ebx
		xor edx, edx
		mov ebx, 10000
		div ebx
		mov ebx, edx
		xor edx, edx
		mul ecx
		mov dword[TThousand], eax
		mov eax, ebx
		xor edx, edx
		mov ebx, 1000
		div ebx
		mov ebx, edx
		xor edx, edx
		mul ecx
		mov dword[Thousand], eax
		mov eax, ebx
		xor edx, edx
		mov ebx, 100
		div ebx
		mov ebx, edx
		xor edx, edx
		mul ecx
		mov dword[Hundred], eax
		mov eax, ebx
		xor edx, edx
		mov ebx, 10
		div ebx
		mov ebx, edx
		xor edx, edx
		mul ecx
		mov dword[Ten], eax
		mov eax, ebx
		xor edx, edx
		mul ecx
		mov dword[One], eax
		
		
		pop edx
		pop ecx
		pop ebx
		pop eax
		
		ret
		
		
		
		
		
;-----------------------------------------------------------------------------------------------------------
; _displayLastScrn - Krista's new function
;
; functions:	displays background.  displays score.
;				
; calls:	_CopyBuffer2Buffer, _CopyToScreen, _CopyBuffer2BufferWithAlpha, _CalcScore
;-----------------------------------------------------------------------------------------------------------
_displayLastScrn

;put the results background up

		invoke _copyBuffer2Buffer,dword [_resultsOff],dword PIC_WIDTH*4,\
		dword 0, dword 0, \
		dword [_screenOff], dword PIC_WIDTH*4, \
		dword 0, dword 70, \
		dword PIC_WIDTH, dword PIC_HEIGHT \

		invoke _CopyToScreen, dword [_screenOff], PIC_WIDTH*4, \
		dword 0, dword 70, \
		dword PIC_WIDTH, dword PIC_HEIGHT, \
		dword 0, dword 0			
		
	push	ecx
	push    ebx
	xor     ebx, ebx
	xor	ecx, ecx	
	xor     eax, eax
	
.ScoreLoop

;display each number by the appropriate score word
    cmp     ecx, 6
    jge  near .wait

    mov   eax, ecx
    	
    call _CalcScore
    
    mov    ebx, 28
    mul    ebx
    add    eax, 230	
    	
	.HundredThousand
		;copies number to the hundred thousand place into screen
		push eax
		invoke _copyBuffer2BufferWithAlpha, dword [_NumberOff], NumberLine_WIDTH*4, dword[HThousand], dword 0, \
				dword [_screenOff], SCREEN_WIDTH*4, 390, dword eax, \
				dword Number_WIDTH, dword Number_HEIGHT
		pop eax
	
	.TenThousand
		;copies number to the ten thousand place into screen
		push eax
		invoke _copyBuffer2BufferWithAlpha, dword [_NumberOff], NumberLine_WIDTH*4, dword[TThousand], dword 0, \
				dword [_screenOff], SCREEN_WIDTH*4, 410, dword eax, \
				dword Number_WIDTH, dword Number_HEIGHT
		pop eax	
	
	.Thousand	
		;copies number to the thousand place into screen
		push eax
		invoke _copyBuffer2BufferWithAlpha, dword [_NumberOff], NumberLine_WIDTH*4, dword[Thousand], dword 0, \
				dword [_screenOff], SCREEN_WIDTH*4, 430, dword eax, \
				dword Number_WIDTH, dword Number_HEIGHT
		pop eax

	.Hundred
		;copies number to the hundred place into screen
		push eax
		invoke _copyBuffer2BufferWithAlpha, dword [_NumberOff], NumberLine_WIDTH*4, dword[Hundred], dword 0, \
				dword [_screenOff], SCREEN_WIDTH*4, 450, dword eax, \
				dword Number_WIDTH, dword Number_HEIGHT
		pop eax
		
	.Ten
		;copies number to the ten place into screen
		push eax
		invoke _copyBuffer2BufferWithAlpha, dword [_NumberOff], NumberLine_WIDTH*4, dword[Ten], dword 0, \
				dword [_screenOff], SCREEN_WIDTH*4, 470, dword eax, \
				dword Number_WIDTH, dword Number_HEIGHT
		pop eax

	.One
		;copies number to the one place into screen into screen
		push eax
		invoke _copyBuffer2BufferWithAlpha, dword [_NumberOff], NumberLine_WIDTH*4, dword[One], dword 0, \
				dword [_screenOff], SCREEN_WIDTH*4, 490, dword eax, \
				dword Number_WIDTH, dword Number_HEIGHT
		pop eax
		
	;displays screen with scores
		push eax
		invoke _CopyToScreen, dword [_screenOff], PIC_WIDTH*4, \
			dword 0, dword 70, \
			dword PIC_WIDTH, dword PIC_HEIGHT, \
			dword 0, dword 0
		pop eax

	.goToNext
		inc ecx
		jmp	.ScoreLoop
	
	.wait
		cmp 	dword [queueCount], 0
		je		.wait
			
	.end
	;Clear the numbers before starting the game over
	mov     byte[Perfect], 0
	mov     byte[Great], 0
	mov     byte[Good], 0
	mov     byte[Boo], 0
	mov     byte[Miss], 0
	mov     byte[PerfectTotal], 0
	mov     byte[GreatTotal], 0
	mov     byte[GoodTotal], 0
	mov     byte[BooTotal], 0
	mov     byte[MissTotal], 0
	mov     byte[Total], 0
		
	pop ebx
	pop ecx	
ret

;*****************end Krista's new functions****************
	
	
;----------------------------------------------------------------------------------------------------------
;_copyMovingArrows	(Cindy Chang)
;
; functions:	updates each arrow in _arrowArray in the _screenOff buffer
; calls/IO:		_copyBuffer2BufferWithAlpha, _updateMovingArrows,  _findYPosition
;----------------------------------------------------------------------------------------------------------	
_copyMovingArrows
	push	ecx
	xor		ecx, ecx	

.loop:
		cmp		ecx, Arrow_size*ArraySize					;checks whether entire array has been run through
		je near		.end
		
		cmp		byte[_arrowArray+ecx+Arrow.exist],0				;checks whether 'exist' flag is 1
		je near	.goToNext
		
		call	_updateMovingArrows							
		
		call	_findYPosition								;finds Y Position to copy from within  from _SIXTEENArrowOff
		
		cmp	byte[_arrowArray+ecx+Arrow.type], 1
		je	.leftMArrow
		
		cmp	byte[_arrowArray+ecx+Arrow.type], 2
		je	.downMArrow
		
		cmp	byte[_arrowArray+ecx+Arrow.type], 3
		je 	near	.upMArrow
		
		cmp	byte[_arrowArray+ecx+Arrow.type], 4
		je 	near	.rightMArrow
	
		jmp 	near .goToNext

.leftMArrow:
	;copies left moving arrow into screen
	invoke _copyBuffer2BufferWithAlpha, dword [_SIXTEENArrowOff], \
		SIXTEENArrow_WIDTH*4, 0, dword [_YPosition], \
		dword [_screenOff], SCREEN_WIDTH*4, 349, \
		dword[_arrowArray+ecx+Arrow.YCoord], dword mArrow_WIDTH, \
		dword mArrow_HEIGHT
	jmp	.goToNext	


.downMArrow:
	;copies down moving arrow into screen
	invoke _copyBuffer2BufferWithAlpha, dword [_SIXTEENArrowOff], \
		SIXTEENArrow_WIDTH*4, 64, dword [_YPosition], \
		dword [_screenOff], SCREEN_WIDTH*4, 413, \
		dword[_arrowArray+ecx+Arrow.YCoord], dword mArrow_WIDTH, \
		dword mArrow_HEIGHT
	jmp	.goToNext

.upMArrow:
	;copies up moving arrow into screen
	invoke _copyBuffer2BufferWithAlpha, dword [_SIXTEENArrowOff], \
		SIXTEENArrow_WIDTH*4, 128, dword [_YPosition], \
		dword [_screenOff], SCREEN_WIDTH*4, 477, \
		dword[_arrowArray+ecx+Arrow.YCoord], dword mArrow_WIDTH, \
		dword mArrow_HEIGHT
	jmp .goToNext
		
.rightMArrow:
	;copies right moving arrow into screen
	invoke _copyBuffer2BufferWithAlpha, dword [_SIXTEENArrowOff], \
		SIXTEENArrow_WIDTH*4, 192, dword [_YPosition], \
		dword [_screenOff], SCREEN_WIDTH*4, 541, \
		dword[_arrowArray+ecx+Arrow.YCoord], \
		dword mArrow_WIDTH, dword mArrow_HEIGHT
	;jmp .goToNext

.goToNext:
	add	ecx, Arrow_size		;increments index in array to next arrow
	jmp	.loop
	
.end:
	pop	ecx
ret




;----------------------------------------------------------------------------------------------------------
;_findYPosition	(Cindy Chang)
;
; functions:	stores in dword[_YPosition] the y coordinate to copy 
;				moving arrow from _SIXTEENArrowOff (different Y Coord = diff colors)
; calls/IO:		none
;----------------------------------------------------------------------------------------------------------	
_findYPosition

	cmp dword[_timerCount], 15*timerSet
	jge near .sixteen
	cmp dword[_timerCount], 14*timerSet
	jge near .fifteen
	cmp dword[_timerCount], 13*timerSet
	jge near .fourteen
	cmp dword[_timerCount], 12*timerSet
	jge near .thirteen
	cmp dword[_timerCount], 11*timerSet
	jge near .twelve
	cmp dword[_timerCount], 10*timerSet
	jge near .eleven
	cmp dword[_timerCount], 09*timerSet
	jge near .ten
	cmp dword[_timerCount], 08*timerSet
	jge near .nine
	cmp dword[_timerCount], 07*timerSet
	jge near .eight
	cmp dword[_timerCount], 06*timerSet
	jge near .seven
	cmp dword[_timerCount], 05*timerSet
	jge near .six
	cmp dword[_timerCount], 04*timerSet
	jge near .five
	cmp dword[_timerCount], 03*timerSet
	jge near .four
	cmp dword[_timerCount], 02*timerSet
	jge near .three
	cmp dword[_timerCount], 01*timerSet
	jge near .two
	cmp dword[_timerCount], 00*timerSet
	jge near .one

	.sixteen
		mov dword[_YPosition], 960
		jmp	near .end
	.fifteen
		mov dword[_YPosition], 896
		jmp	near .end
	.fourteen
		mov dword[_YPosition], 832
		jmp	near .end
	.thirteen
		mov dword[_YPosition], 768
		jmp	near .end
	.twelve
		mov dword[_YPosition], 704
		jmp	near .end
	.eleven
		mov dword[_YPosition], 640
		jmp	near .end
	.ten
		mov dword[_YPosition], 576
		jmp	near .end	
	.nine
		mov dword[_YPosition], 512
		jmp	near .end
	.eight
		mov dword[_YPosition], 448
		jmp	near .end	
	.seven
		mov dword[_YPosition], 384
		jmp	near .end
	.six
		mov dword[_YPosition], 320
		jmp	near .end
	.five
		mov dword[_YPosition], 256
		jmp	near .end
	.four
		mov dword[_YPosition], 192
		jmp	near .end
	.three
		mov dword[_YPosition], 128
		jmp	near .end
	.two
		mov dword[_YPosition], 64
		jmp	near .end
	.one
		mov dword[_YPosition], 0
		jmp	near .end

	.end
		ret
		
;---------------------------------------------------------------------------------------
; _checkOffScreen	(Cindy Chang & Krista Eicchorn)
;
; functions:	checks if arrows go above top of display, if so, set 'exist' flag to 0
; calls/IO:		none
;---------------------------------------------------------------------------------------
_checkOffScreen		
		push    eax
		push    ebx
		push	ecx
		xor		ecx, ecx

	.CheckOffScreen
		cmp		ecx, Arrow_size*ArraySize
		je		.end
		
		cmp		dword[_arrowArray+ecx+Arrow.YCoord], 5
		jle		.clearArrow
		jmp		.nextArrow
		
	.clearArrow
		
;**************Krista's Update 5/4/03*******************
;this will check to see if an arrow has already been 
;counted as off screen, and if not, it will
;increment the Miss total
;
		cmp     byte[_arrowArray+ecx+Arrow.exist], 0
	    	je	 .nextArrow
		mov	byte[_arrowArray+ecx+Arrow.exist], 0
		inc 	dword[Miss]
		mov 	eax, dword[Miss]
		mov 	ebx, 119
		mul 	ebx
		mov 	dword[MissTotal], eax
		;mov 	dword[_CommentChoice], 140
;******************************************************
			
	.nextArrow
		add		ecx, Arrow_size
		jmp		.CheckOffScreen
		
	.end
		pop ecx
		pop ebx
		pop eax
		ret
		
;----------------------------------------------------------------------------
; _checkEmpty (Cindy Chang)
;
; functions:	checks if there are any more arrows in array
;				sets _ArrowFlag=1 if there are more arrows, 0 if not
; calls/IO:		none
;----------------------------------------------------------------------------	
_checkEmpty
	push ecx
	xor ecx, ecx
	
	.loop
		cmp ecx, Arrow_size*ArraySize
		je .empty
		
		cmp byte[_arrowArray+ecx + Arrow.exist], 0
		je	.nextArrow

	.NotEmpty
		mov	byte[_ArrowFlag], 1
		jmp	.end
		
	.nextArrow
		add ecx, Arrow_size
		jmp .loop

	.empty
		mov byte[_ArrowFlag], 0
		
	.end
		pop ecx
		ret	
		
;----------------------------------------------------------------------------
; _updateMovingArrows
;
; functions:	updates position of each Arrow in arrow array
;----------------------------------------------------------------------------			
_updateMovingArrows

		add dword[_arrowArray+ecx+Arrow.YCoord], -8 ; was -8
		ret

_updateMovingArrows_arglen	equ	0






;************************************************************************************************
; (By Adam Kim from MP5)
;int _copyBuffer2BufferWithAlpha(void* src, int srcPitch, int srcLeft, 
;			int srcTop, void* dst,int destPitch int dstLeft, 
;			int dstTop, int width, int height)
;
;functions:
;calls:
;*************************************************************************************************

proc _copyBuffer2BufferWithAlpha
.src		arg	4
.srcPitch	arg	4
.srcLeft	arg	4
.srcTop		arg	4
.dst		arg	4
.dstPitch	arg	4
.dstLeft	arg	4
.dstTop		arg	4
.width		arg	4
.height		arg	4

	push esi
	push edi
	push ecx

	;put starting source address into ebx 
	;esi = width*pitch + (left-1)*4
	mov esi, [ebp + .srcLeft]
	dec esi
	shl esi, 2
	add esi, [ebp + .src]
	mov eax, [ebp + .srcPitch]
	mul dword [ebp + .srcTop]
	add esi, eax

	;put starting destination address into edx 
	;edi = width*pitch + (left-1)*4
	mov edi, [ebp + .dstLeft]
	dec edi
	shl edi, 2
	add edi, [ebp + .dst]
	mov eax, [ebp + .dstPitch]
	mul dword [ebp + .dstTop]
	add edi, eax

	;initialize for loops
	mov ecx, [ebp + .width]
	mov edx, ecx
	mov ebx, [ebp + .height]
	
.verticalLoop
	mov ecx, edx 

.horizontalLoop
	movq mm0, [esi+ecx*4]
	movq mm1, [edi+ecx*4]
	movq mm3, mm0
	movq mm4, mm1
	
	pxor mm2, mm2
	
	punpckhbw mm3, mm2
	punpckhbw mm4, mm2
	punpcklbw mm0, mm2
	punpcklbw mm1, mm2
	
	xor eax, eax

;	pextrw eax, mm0, 3	
	mov al, [esi+ecx*4+3]
;	mov	al, 50
	pinsrw mm2, eax, 0
	pinsrw mm2, eax, 1
	pinsrw mm2, eax, 2
	pinsrw mm2, eax, 3
	
	xor eax, eax
	
;	pextrw eax, mm3, 3
	mov al, [esi+ecx*4+7]
;	mov al, 50
	pinsrw mm5, eax, 0
	pinsrw mm5, eax, 1
	pinsrw mm5, eax, 2
	pinsrw mm5, eax, 3
	pmullw mm0, mm2
	pmullw mm3, mm5
	
	paddw mm0, [_roundingFactor]
	paddw mm3, [_roundingFactor]
	
	psrlw mm0, 8
	psrlw mm3, 8
	paddw mm0, mm1
	paddw mm3, mm4
	pmullw mm1, mm2
	pmullw mm4, mm5
	
	paddw mm1, [_roundingFactor]
	paddw mm4, [_roundingFactor]
	
	psrlw mm1, 8
	psrlw mm4, 8
	psubw mm0, mm1
	psubw mm3, mm4
	packuswb mm0, mm3
	movq [edi+ecx*4], mm0

	dec ecx
	dec ecx
	jnz .horizontalLoop

;end horizontalLoop	
	add esi, [ebp+.srcPitch]
	add edi, [ebp+.dstPitch]
	dec ebx
	jnz .verticalLoop

;end verticalLoop
	pop ecx
	pop edi
	pop esi

	ret
	

endproc	
_copyBuffer2BufferWithAlpha_arglen	equ	40
	



;----------------------------------------------------------------------------------
; _loadImages (Cindy Chang)
;
; functions:	loads the PNG picture files we need inot their respective buffers
; calls I/O:	_AllocMem, _LoadPNG
;-----------------------------------------------------------------------------------	
_loadImages

.start:
	;load test picture 1 (backgroud)
	invoke	_AllocMem, dword PIC_WIDTH*PIC_HEIGHT*4
	cmp	eax, -1
	je 	near .error
	mov	[_BackgroundOff], eax
	invoke	_LoadPNG, dword _Background, dword [_BackgroundOff], dword 0, \
		dword 0
	test	eax, eax
	jnz 	near .error
		
	;load fixed arrow
	invoke	_AllocMem, dword fArrows_WIDTH*fArrows_HEIGHT*4
	cmp	eax, -1
	je 	near	.error
	mov	[_fArrowsOff], eax
	invoke	_LoadPNG, dword _fixedArrows, dword [_fArrowsOff], \
		dword 0, dword 0

	test	eax, eax
	jnz 	near .error
		
; load the four moving arrows to pick from
; invoke	_AllocMem, dword FOURArrow_WIDTH*FOURArrow_HEIGHT*4
; cmp		eax, -1
; je near	.error
; mov		[_FOURArrowOff], eax
; invoke	_LoadPNG, dword _moveArrow, dword [_FOURArrowOff], dword 0, dword 0
;		test	eax, eax
;		jnz	near	.error

	;load the 48 moving arrows to pick from
	invoke	_AllocMem, dword SIXTEENArrow_WIDTH*SIXTEENArrow_HEIGHT*4
	cmp		eax, -1
	je near	.error
	mov		[_SIXTEENArrowOff], eax
	invoke	_LoadPNG, dword _moveArrow, dword [_SIXTEENArrowOff], \
		dword 0, dword 0
	test	eax, eax
	jnz	near	.error

	;load the fixed arrows, with up
	invoke	_AllocMem, dword fArrows_WIDTH*fArrows_HEIGHT*4
	cmp		eax, -1
	je near		.error
	mov		[_UPfArrowsOff], eax
	invoke	_LoadPNG, dword _UPfixedArrows, dword [_UPfArrowsOff], \
		dword 0, dword 0
	test	eax, eax
	jnz near		.error
		
	;load the fixed arrows, with left
	invoke	_AllocMem, dword fArrows_WIDTH*fArrows_HEIGHT*4
	cmp		eax, -1
	je near		.error
	mov		[_LEFTfArrowsOff], eax
	invoke	_LoadPNG, dword _LEFTfixedArrows, dword [_LEFTfArrowsOff], \
		dword 0, dword 0
	test	eax, eax
	jnz near		.error
		
	;load the fixed arrows, with right
	invoke	_AllocMem, dword fArrows_WIDTH*fArrows_HEIGHT*4
	cmp		eax, -1
	je near		.error
	mov		[_RIGHTfArrowsOff], eax
	invoke	_LoadPNG, dword _RIGHTfixedArrows, dword [_RIGHTfArrowsOff], \
		dword 0, dword 0
	test	eax, eax
	jnz near		.error
		
	;load the fixed arrows, with down
	invoke	_AllocMem, dword fArrows_WIDTH*fArrows_HEIGHT*4
	cmp		eax, -1
	je near		.error
	mov		[_DOWNfArrowsOff], eax
	
	invoke	_LoadPNG, dword _DOWNfixedArrows, dword [_DOWNfArrowsOff], \
		dword 0, dword 0
	test	eax, eax
	jnz 	near	.error
		
	;load start screen
	invoke	_AllocMem, dword PIC_WIDTH*PIC_HEIGHT*4
	cmp		eax, -1
	je 	near	.error
	mov	[_startScrnOff], eax
	invoke	_LoadPNG, dword _startScrn, dword [_startScrnOff], dword 0, \
		dword 0
	test	eax, eax
	jnz 	near	.error
		
	;load hit arrows
	invoke	_AllocMem, dword fArrows_WIDTH*fArrows_HEIGHT*4
	cmp		eax, -1
	je 	near	.error
	mov	[_hitArrowsOff], eax
	invoke	_LoadPNG, dword _hitArrows, dword [_hitArrowsOff], dword 0, \
		dword 0
	test	eax, eax
	jnz 	near	.error
		
	;load results screen
	invoke	_AllocMem, dword PIC_WIDTH*PIC_HEIGHT*4
	cmp		eax, -1
	je 	near	.error
	mov		[_resultsOff], eax
	
	invoke	_LoadPNG, dword _results, dword [_resultsOff], dword 0, dword 0
	test	eax, eax
	jnz 	near	.error
	
	
	;**********Krista's new page*******************
		;load Numbers screen
		invoke _AllocMem, dword NumberLine_WIDTH*Number_HEIGHT*4
		cmp   eax, -1
		je near .error
		mov   [_NumberOff], eax
		invoke   _LoadPNG, dword _Numbers, dword [_NumberOff], dword 0, dword 0
		test   eax, eax
		jnz near  .error


		;load Comments Screen
		invoke _AllocMem, dword Comments_WIDTH*Comments_HEIGHT*4
		cmp eax, -1
		je near .error
		mov [_CommentsOff], eax
		invoke   _LoadPNG, dword _Comments, dword [_CommentsOff], dword 0, dword 0
		test eax, eax
		jnz near  .error

   ;*****************************************************
		
	;load pause screen
	invoke	_AllocMem, dword PAUSE_WIDTH*PAUSE_HEIGHT*4
	cmp		eax, -1
	je 	near	.error
	mov		[_pauseOff], eax
	
	invoke	_LoadPNG, dword _pause, dword [_pauseOff], dword 0, dword 0
	test	eax, eax
	jnz 	near	.error
		
	;load credits screen
	invoke	_AllocMem, dword 12800000
	cmp		eax, -1
	je 	near .error
	mov		[_creditsOff], eax
	invoke	_LoadPNG, dword _credits, dword [_creditsOff], dword 0, dword 0
	test	eax, eax
	jnz 	near .error
		
		;load the fixed arrows, with hit
		invoke	_AllocMem, dword fArrows_WIDTH*fArrows_HEIGHT*4
		cmp		eax, -1
		je near		.error
		mov		[_FlashFArrowsOff], eax
		invoke	_LoadPNG, dword _FlashFArrows, dword [_FlashFArrowsOff], dword 0, dword 0
		test	eax, eax
		jnz near		.error
		
		;load fixed pressed arrow
		invoke	_AllocMem, dword fArrows_WIDTH*fArrows_HEIGHT*4
		cmp		eax, -1
		je near		.error
		mov		[_pressArrowsOff], eax
		invoke	_LoadPNG, dword _pressArrows, dword [_pressArrowsOff], dword 0, dword 0
		test	eax, eax
		jnz near	.error


	invoke	_AllocMem, dword PIC_WIDTH*PIC_HEIGHT*4
	cmp	eax, -1
	je 	near .error
	mov	[_LoadingScreenOff], eax
	invoke	_LoadPNG, dword _LoadingScreen, dword [_LoadingScreenOff], dword 0, \
		dword 0
	test	eax, eax
	jnz 	near .error

	invoke	_AllocMem, dword 23040
	cmp	eax, -1
	je 	near .error
	mov	[_LoadBarOff], eax
	invoke	_LoadPNG, dword _LoadBar, dword [_LoadBarOff], dword 0, \
		dword 0
	test	eax, eax
	jnz 	near .error		
	
	
	invoke	_AllocMem, dword 6000000
	cmp	eax, -1
	je 	near .error
	mov	[_scrollingBackOff], eax
	invoke	_LoadPNG, dword _scrollingBack, dword [_scrollingBackOff], dword 0, \
		dword 0
	test	eax, eax
	jnz 	near .error	
		

	invoke	_AllocMem, dword 101320
	cmp	eax, -1
	je 	near .error
	mov	[_selectSongOff], eax
	invoke	_LoadPNG, dword _selectSong, dword [_selectSongOff], dword 0, dword 0
	test	eax, eax
	jnz 	near .error	


;*** kw added new background pictures
	invoke	_AllocMem, dword PIC_WIDTH*PIC_HEIGHT*4
	cmp	eax, -1
	je 	near .error
	mov	[_MatrixOff], eax
	invoke	_LoadPNG, dword _Matrix, dword [_MatrixOff], dword 0, \
		dword 0
	test	eax, eax
	jnz 	near .error

	invoke	_AllocMem, dword PIC_WIDTH*PIC_HEIGHT*4
	cmp	eax, -1
	je 	near .error
	mov	[_DragonballOff], eax
	invoke	_LoadPNG, dword _DragonBall, dword [_DragonballOff], dword 0, \
		dword 0
	test	eax, eax
	jnz 	near .error

	invoke	_AllocMem, dword PIC_WIDTH*PIC_HEIGHT*4
	cmp	eax, -1
	je 	near .error
	mov	[_SkyBlueOff], eax
	invoke	_LoadPNG, dword _BlueSky, dword [_SkyBlueOff], dword 0, \
		dword 0
	test	eax, eax
	jnz 	near .error


	invoke	_AllocMem, dword PIC_WIDTH*PIC_HEIGHT*4
	cmp	eax, -1
	je 	near .error
	mov	[_FF8BGOff], eax
	invoke	_LoadPNG, dword _FF8BG, dword [_FF8BGOff], dword 0, \
		dword 0
	test	eax, eax
	jnz 	near .error
;*** kw added new background pictures ends



	jmp	.exit
	
	.error
		mov		eax, -1
	.exit
ret
		

		
;----------------------------------------------------------------------------
;*** Old Code from mp5 (Derek King)
;int _copyBuffer2Buffer(void* src, int srcPitch, int srcLeft, int srcTop, 
;		void* dst,int destPitch int dstLeft, int dstTop, int width, int height)
;----------------------------------------------------------------------------		
proc _copyBuffer2Buffer

.src		arg	4
.srcPitch	arg	4
.srcLeft	arg	4
.srcTop		arg	4
.dst		arg	4
.dstPitch	arg	4
.dstLeft	arg	4
.dstTop		arg	4
.width		arg	4
.height		arg	4

	push esi
	push edi

	;put starting source address into ebx 
	;esi = width*pitch + (left-1)*4
	mov esi, [ebp + .srcLeft]
	dec esi
	shl esi, 2
	add esi, [ebp + .src]
	mov eax, [ebp + .srcPitch]
	mul dword [ebp + .srcTop]
	add esi, eax

	;put starting destination address into edx 
	;edi = width*pitch + (left-1)*4
	mov edi, [ebp + .dstLeft]
	dec edi
	shl edi, 2
	add edi, [ebp + .dst]
	mov eax, [ebp + .dstPitch]
	mul dword [ebp + .dstTop]
	add edi, eax

	;initialize for loops
	mov ecx, [ebp + .width]
	mov edx, ecx
	mov ebx, [ebp + .height]
	
.verticalLoop
	mov ecx, edx 
.horizontalLoop
	mov eax, dword [esi+ecx*4]
	mov dword [edi+ecx*4], eax 
	.noDraw
	dec ecx
	jnz .horizontalLoop
;end horizontalLoop	
	add esi, [ebp+.srcPitch]
	add edi, [ebp+.dstPitch]
	dec ebx
	jnz .verticalLoop
;end verticalLoop

	pop edi
	pop esi

	ret
endproc	
_copyBuffer2Buffer_arglen		equ	40


;----------------------------------------------------------------------------
;*** Old Code from mp5 (Derek King)
;int installKbdIntHandler(void)
;return 0 for success 1 for failure
;----------------------------------------------------------------------------	
proc _installKeyboardISR
	
	;lock all code/data used by keyboard ISR
	invoke _LockArea, ds, dword keyboardData_begin, dword (keyboardData_end - keyboardData_begin)
	test eax, eax
	jnz .error
	invoke _LockArea, cs, dword keyboardISR, dword (keyboardISR_end - keyboardISR)
	test eax, eax
	jnz .error	

	;install the actual ISR
	movzx eax, byte [_keyboardINT] 
	invoke _Install_Int, eax, dword keyboardISR	
	test eax, eax
	jz .exit

.error	mov eax, -1
.exit
ret
endproc
_installKeyboardISR_arglen	equ 0


;----------------------------------------------------------------------------
;*** Old Code from mp5 (Derek King)
;----------------------------------------------------------------------------	
_removeKeyboardISR	
	;remove the ISR
	movzx eax, byte [_keyboardINT]	
	invoke _Remove_Int, eax  
ret



;----------------------------------------------------------------------------
;*** Old Code from mp5 (Derek King, revised by Kuangwei Hwang & Cindy Chang)
;keyboardISR 
;----------------------------------------------------------------------------	
keyboardISR 
;don't worry about saving/restoring flags here is has already been done for you
;	push eax
;	push edx
;	push ebx	
;	push ecx

	;inc byte [_quit]
	;read in scancode
	xor eax, eax
	xor ecx, ecx
	mov dx, [_keyboardPort]
	in al, dx
	;*** Scancode Imported!
	
	
	
	xor ebx, ebx
		
	;set/unset status in keyStatusTable
	mov dl, al

	mov byte [_keyStatusTable+eax], 0
	test dl, 80h
	jnz .KeyRelease
	not byte [_keyStatusTable+eax]

	;*** KeyPress Case	
	and			al, 7Fh	; Zero out MSB
	movzx		ebx, al
	movzx		eax, byte[Qwerty+ebx]
		
	.justEnqueue:
	invoke		_enqueue, eax
	
	
	
	
	
	.KeyRelease: ;*** KeyRelase Case, ignore this key stroke!
	
	
	.end:
	;ack interupt 
	mov al, 20h
	out 20h, al
	cmp byte [_keyboardIRQ], 8
 	jb .lowIRQ
	out 0A0h, al		;acknowledge 2nd pic
	.lowIRQ
	
	;don't chain 2 old int
	xor eax, eax	
	
;	pop ecx
;	pop ebx
;	pop edx
;	pop eax	
	ret ;use normal ret here
keyboardISR_end






;----------------------------------------------------------------------------
;*** Old Code from mp5 (Derek King, revised by Kuangwei Hwang)
;void _enqueue(int value)
;----------------------------------------------------------------------------
proc _enqueue
.value		arg	4
	cmp		dword [queueCount], QUEUE_MAX	; If queue is full, do nothing		
	jge		.done
	mov		ebx, [queueRear]
	add		ebx, 4
	cmp		ebx, queueEnd
	jb		.insert
	mov		ebx, queueBegin
.insert
	mov		[queueRear], ebx		; New rear pointer
	mov		eax, [ebp + .value]
	mov		[ebx], eax
	inc		dword [queueCount]
.done
	ret
endproc
_enqueue_arglen		equ	4

	
;----------------------------------------------------------------------------
;*** Old Code from mp5 (Derek King)
;void _enqueue(int value)
;int _dequeue(void)
;----------------------------------------------------------------------------	
proc _dequeue
	cmp		dword [queueCount], 0		; If queue is empty, do nothing		
	jle		.done1
	dec		dword [queueCount]
	mov		ebx, [queueFront]
	mov		eax, [ebx]
	add		ebx, 4  ; moves pointer to front of queue
	
	cmp		ebx, queueEnd
	jb		.updataFront
	mov		ebx, queueBegin
.updataFront
	mov		dword [queueFront], ebx
	jmp		.done
.done1
	mov		eax, 0
.done
	ret
endproc
_dequeue_arglen		equ	0


;----------------------------------------------------------------------------
;*** Old Code from mp5 (Derek King)
;int _queueCount(void)
;return the number of elements in the queue
;----------
proc _queueCount

	mov eax, [queueCount]

ret
endproc
_queueCount_arglen		equ	0


;----------------------------------------------------------------------------
;*** Old Code from mp5 (Derek King)
;*** Old Code from mp5
;void _resetQueue(void)
;----------------------------------------------------------------------------
proc _clearQueue
	mov dword [queueFront], queueBegin
	mov dword [queueRear], queueBegin-4
	mov dword [queueCount], 0	
	ret
endproc 
_resetQueue_arglen		equ	0	
	



;********************* kw's (Kuangwei's) Functions Begin!*********************

;*** Void _InitBuffers(int BG_Size, int FG_Size) ************************
; Inputs:	None
; Outputs:	None
; Calls:	AllocateMemory()
; Purpose:	Allocates File Buffer in memory and loads entire song
;		into memory into respective background buffer or foreground
;		buffers for music and sound effects, respectively. (our 
;		songs will be small).  Initializes
;		all DMA and SB16 process to begin playing sound, 
; 		Status Flags set.
proc _InitBuffers
.BG_Size	arg	4
.FG_Size	arg	4

;*** Allocate Different DMA Buffer size for multiple bit rate support at 
;*** 30 interrupts/sec
; Allocate DMA Buffer for 352.8 kbps
	invoke	_DMA_Allocate_Mem, dword 2940, dword DMASel_352kbps, \
						dword DMAAddr_352kbps
	cmp	[DMASel_352kbps], word 0	; Error Checking
	je	near .InitBufferErr
	invoke	_DMA_Lock_Mem		; Lock Mem used by DMA
	
; Allocate DMA Buffer for 705.6 kbps
	invoke	_DMA_Allocate_Mem, dword _DMAbuff, dword DMASel_705kbps, \
						dword DMAAddr_705kbps
	cmp	[DMASel_705kbps], word 0	; Error Checking
	je	near .InitBufferErr
	invoke	_DMA_Lock_Mem		; Lock Mem used by DMA

; Allocate DMA Buffer for 705.6 kbps
	invoke	_DMA_Allocate_Mem, dword 11760, dword DMASel_1411kbps, \
						dword DMAAddr_1411kbps
	cmp	[DMASel_1411kbps], word 0	; Error Checking
	je	near .InitBufferErr
	invoke	_DMA_Lock_Mem		; Lock Mem used by DMA
;***DMA Buffer Initialization Complete!


;***Now Allocating Different File Buffers for Background and Foreground Music
; Allocating Background File Buffer
	mov	eax, dword [ebp+.BG_Size]
	invoke 	_AllocMem, dword eax
	; eax now returns starting offset of the File Buffer
	cmp	eax, -1
	je	near .InitBufferErr	; check for memory allocation error
	mov	dword [BG_File_Off], eax	; save the offset

; Allocating Foreground File Buffer
	mov	eax, dword [ebp+.FG_Size]
	invoke 	_AllocMem, dword eax
	; eax now returns starting offset of the File Buffer
	cmp	eax, -1
	je	near .InitBufferErr	; check for memory allocation error
	mov	dword [FG_File_Off], eax	; save the offset	

;***Setup File Tracking Variables
	mov	dword [BG_File_Index], 0
	mov	dword [FG_File_Index], 0
	mov	dword [FirstFilePlayed_Flag], 0
	jmp	.end


.InitBufferErr

.end:
ret
endproc
_InitBuffers_arglen		equ	8






;-------------------------------------------------------------------------------
;*** Void _PlaySong(char* FileName, int FileSize, int kbps, int SampFreq, 
;*** 							int Stereo, int Repeat)
; Inputs:	Pointer to FileName, FileSize, kbits per second, Sampling 
;		Frequency, StereoMono
; Outputs:	None
; Calls:	OpenFile(), ReadFile(), CloseFile()
; Purpose:	Initializes all DMA and SB16 process to begin playing sound, 
; 		Status Flags set.
;-------------------------------------------------------------------------------
proc _PlaySong
.FileName	arg	4
.FileSize	arg	4
.kbps		arg	4
.SampFreq	arg	4
.Stereo		arg	4
.Repeat		arg	4


;***Make Sure the Previous Song, if any, has been stopped, to play new song
cmp	dword [FirstFilePlayed_Flag], 0
je	near .playSong	
	; Display number of times ISR is called for the previous song
	push	dword [ISR_Count]

	; Stop SB16 play back
	invoke	_SB16_Stop
	; SB16_Stop doesn't report error

	; Stops DMA transfer
	movzx	eax, byte [CurrentDMAChannel]
	invoke	_DMA_Stop, eax
	; DMA_Stop doesn't report error

; Reset the Repeat_Flag, but if this song needs repeat, flag will be set again
; at the botom of the code
	mov	dword [Repeat_Flag], 0
; Reset the EndOfSong_Flag as well
	mov	dword [EndOfSong_Flag], 0
; Reset Number of Interrupts
	mov	dword [ISR_Count], 0




.playSong:
;***Reset FG_Mix_Flag to cut off the any sound effect currently being played
mov	dword [FG_Mix_Flag], 0
mov	dword [BG_Playing_Flag], 1

;***Read File to Memory
mov	ebx, dword [ebp + .FileName]	; Dereference File Name and File Size
mov	ecx, dword [ebp + .FileSize]	; from parameters
mov	dword [Current_BG_File_Size], ecx
invoke 	_OpenFile, dword ebx, dword ecx	; Openfile(FileName, FileSize)
cmp	eax, -1
je	near .error	; check for file opening error
mov	esi, eax	; save DOS handle

; ReadFile(handle, Offset, FileSize)
invoke 	_ReadFile, dword esi, dword [BG_File_Off], dword [ebp + .FileSize] 
cmp	eax, dword [Current_BG_File_Size]
jne	near .error	; compare if amount of bytes read in matches

invoke 	_CloseFile, dword esi	; close file after it has been read
; now BG_File_Off points to our music, copy the file buffer into
; the DMA Buffer


;*** Find out Which DMA buffer to use depending on the 
;*** throughput bit rate in kbps 
mov	eax, dword [ebp + .kbps]
cmp	eax, 352	; if .kbps = 352 kbps
je	.LoadDMASel_352kbps	; Load DMA Selector for specific buffer size
cmp	eax, 705	; if .kbps = 705 kbps
je	.LoadDMASel_705kbps
cmp	eax, 1411	; if .kbps = 1411 kbps
je	.LoadDMASel_1411kbps
jmp	.NoBitRateMatch	; else if no compatible bit rate found, Output errormsg
.LoadDMASel_352kbps:
mov	es, [DMASel_352kbps]
mov	[CurrentDMASel], es
; ecx need to be set to DMA_Size/4 where DMA_Size = 2940 bytes, 2940/4=735
mov	ecx, 735
jmp	.copyFile

.LoadDMASel_705kbps:
mov	es, [DMASel_705kbps]	
mov	[CurrentDMASel], es
; ecx need to be set to DMA_Size/4 where DMA_Size = 5880 bytes, 5880/4=1470
mov	ecx, _DMASbuff
jmp	.copyFile

.LoadDMASel_1411kbps:
mov	es, [DMASel_1411kbps]	
mov	[CurrentDMASel], es
; ecx need to be set to DMA_Size/4 where DMA_Size = 11760 bytes, 11760/4=2940
mov	ecx, 2940


.copyFile:
mov	edi, 0
mov	esi, dword [BG_File_Off]
; Skip first 50B to avoid "clicking sound" from playing the header
add	esi, 50
rep	movsd


; Initializing SB16 and setting its sound ISR
invoke	_SB16_Init, dword _SoundISR
test	eax, eax
jnz	near .error

; Getting Channel
invoke	_SB16_GetChannel
	
;*** 8 bit/16 bit change in here.
;***Find out Which DMA channel to use depending on throughput bit rate
mov	ebx, dword [ebp + .kbps]
cmp	ebx, 352	; if .kbps = 352 kbps
je	.LoadDMAChan_352kbps	; Load DMA Selector for specific buffer size
cmp	ebx, 705	; if .kbps = 705 kbps
je	.LoadDMAChan_705kbps
cmp	ebx, 1411	; if .kbps = 1411 kbps
je	.LoadDMAChan_1411kbps
jmp	.NoBitRateMatch	; else no compatible bit rate is found, Output errorMsg

;*** We decided to use 16 bit only for uniformity and for ease of sound mixing.

.LoadDMAChan_352kbps:
	mov	[DMAChan_352kbps], ah
	mov	[CurrentDMAChannel], ah
	jmp	.setFormat

.LoadDMAChan_705kbps:
	mov	[DMAChan_705kbps], ah
	mov	[CurrentDMAChannel], ah
	jmp	.setFormat
	
.LoadDMAChan_1411kbps:
	mov	[DMAChan_1411kbps], ah
	mov	[CurrentDMAChannel], ah
	jmp	.setFormat	


.setFormat:
	movzx	ecx, al
	movzx	edx, ah

	; Setting format
	; 16 bit 44kHz Stereo sound:
	mov	eax, [ebp + .SampFreq]
	mov	ebx, [ebp + .Stereo]
;*** We decided to use 16 bit only for uniformity and for ease of sound mixing.
; Set format to 16bit sample, and at the desired Sample Frequency, 
; Stereo or Mono Mode
	invoke	_SB16_SetFormat, dword 16, dword eax, dword ebx 
	test	eax, eax
	jnz	near .error

	; Setting Mixer
	invoke	_SB16_SetMixers, word 07fh, word 07fh, word 07fh, word 07fh
	test	eax, eax
	jnz	near .error

;*** Start DMA Transfer
;***Find out Which DMA Channel and Address to start depending on 
;***throughput bit rate
mov	eax, dword [ebp + .kbps]
cmp	eax, 352	; if .kbps = 352 kbps
je	.LoadDMAAddr_352kbps	; Load DMA Selector for specific buffer size
cmp	eax, 705	; if .kbps = 705 kbps
je	.LoadDMAAddr_705kbps
cmp	eax, 1411	; if .kbps = 1411 kbps
je	.LoadDMAAddr_1411kbps
jmp	.NoBitRateMatch	; else no compatible bit rate is found, Output errorMsg

.LoadDMAAddr_352kbps:
	movzx	eax, byte [DMAChan_352kbps]	
	mov	ebx, dword [DMAAddr_352kbps]	
	mov	dword [CurrentDMAAddress], ebx
	mov	ecx, 2940
	jmp	.DMAStart

.LoadDMAAddr_705kbps
	movzx	eax, byte [DMAChan_705kbps]	
	mov	ebx, dword [DMAAddr_705kbps]	
	mov	dword [CurrentDMAAddress], ebx
	mov	ecx, _DMAbuff
	jmp	.DMAStart	

.LoadDMAAddr_1411kbps
	movzx	eax, byte [DMAChan_1411kbps]	
	mov	ebx, dword [DMAAddr_1411kbps]
	mov	dword [CurrentDMAAddress], ebx	
	mov	ecx, 11760
	jmp	.DMAStart


.DMAStart:
	push	ecx	; save the current DMA_Size
	invoke	_DMA_Start, eax, dword ebx, dword ecx, dword 1, dword 1
	; DMA_Start doesn't report error

	; Set SB16 to start
	pop	ecx	; get back DMA_Size from stack
	mov	dword [CurrentDMASize], ecx	; save current DMA size
	shr	ecx, 2	; DMA_Size/4 is the number of samples before we 
			; want to interrupt
	;cmp	dword [BG_Sample8_16], 8
	;je	.bit8start
;*** We decided to use 16 bit only for uniformity and for ease of sound mixing.
	invoke	_SB16_Start, dword ecx, dword 1, dword 1
	jmp	.setup
	;.bit8start:
	;invoke	_SB16_Start, dword SIZE/2, dword 1, dword 1

	.setup:
	test	eax, eax
	jnz	near .error

;*** Setup All Current Play Back Variables
mov	eax, dword [ebp + .SampFreq]
mov	dword [CurrentPlaySampleFreq], eax ; Set Current Sampling Rate Flag
mov 	ebx, dword [ebp + .Stereo]
mov	dword [CurrentPlayStereoMono], ebx ; Set Current StereoMono Status Flag

mov	byte [DMA_Flags], 0	; Reset Flag for normal sound play back
or 	byte [DMA_Flags], DMA_Refill_Flag  ; 1st half played first

mov	eax, dword [Current_BG_File_Size]
mov	ebx, dword [CurrentDMASize]
sub	eax, ebx
sub	eax, 50		; Equivalent to BG_Sound_Size-SIZE-50
mov	dword [SongSize], eax
;mov	dword [SongSize], BG_Sound_Size-SIZE-50
add	ebx, 49		; Equivalent to SIZE+49
mov	dword [BG_File_Index], ebx
;mov	dword [BG_File_Index], SIZE+49
mov 	dword [FirstFilePlayed_Flag], 1
cmp	dword [ebp + .Repeat], 0
je	.end
mov	dword [Repeat_Flag], 1
jmp	.end


.NoBitRateMatch	
mov	dword [EndOfSong_Flag], 1 ; Set end of song flag so that 
				  ; main loop would quit
jmp	.end

.error:
mov	dword [EndOfSong_Flag], 1 ; Set end of song flag so that 
				  ; main loop would quit
mov	dword [BG_Playing_Flag], 0 ; BG is not playing, reset flag

.end:
ret
endproc
_PlaySong_arglen		equ	24






;-------------------------------------------------------------------------------
;*** Void _SoundISR() ************************************************
; Inputs:	None
; OUtputs:	None
; Calls:	Void _BufferRefill(), void _StopSong()
; Purpose:	1) Flips the DMA_Refill_Flag to ensure reading and 
;		   writing from different halves of the buffer
;		2) Sets the Next_Frame_Flag to tell main next frame
;		   has occured
;		3) Counts the number of time called.
;-------------------------------------------------------------------------------
_SoundISR
	;***  Flip DMA_Refill_Flag, 0, refill 1st half of buffer,
	;*** if 1, refill 2nd half of buffer
	xor	byte [DMA_Flags], DMA_Refill_Flag
	call	_DMA_Refill

	;*** Set Next_Frame_Flag
	mov	dword [Next_Frame_Flag], 1

	.end:
	inc	dword [ISR_Count]
ret




;-------------------------------------------------------------------------------
;*** Void _PlaySoundFX(char* FileName, int FileSize)
; Inputs:	Pointer to FileName, FileSize
; Outputs:	None
; Calls:	OpenFile(), ReadFile(), CloseFile()
; Purpose:	Check if current background music is being played,
; 		if not, simply call PlaySong() using the current
;		FileName and FileSize to play sound effect in 
; 		the background.  Otherwise, it will check if the 
; 		song currently played matches the bit rate, frequency
;		of the sound effect to be played.  If so, it will
; 		Load the Foreground music file into memory at offeset
;		FG_File_Off, then set FG_Mix_Flag to request
;		DMA_Refill to mix it.
;		Currently SoundFX files must be at 44kHz, 16bit, Mono
;-------------------------------------------------------------------------------
proc _PlaySoundFX
.FileName	arg	4
.FileSize	arg	4

;*** Check if a SoundFX is already being played
cmp	dword [FG_Mix_Flag], 1
je	near .end

;*** Check if a Background Music is currently being played
cmp	dword [BG_Playing_Flag], 1
jne	near .PlayInBG

;*** Background Music is playing case
; Check if Current Frequency, and Stereo/Mono mode matches the 
; Sound Effect format to be played
cmp	dword [CurrentPlaySampleFreq], 44100
jne	near .end
cmp	dword [CurrentPlayStereoMono], 0
jne	near .end

; Formats Match!
;*** Load Foreground Sound file into Memory
;***Read File to Memory
mov	ebx, dword [ebp + .FileName]	; Dereference File Name and File Size
mov	ecx, dword [ebp + .FileSize]	; from parameters
mov	dword [FGSize], ecx
mov	dword [Current_FG_File_Size], ecx
invoke 	_OpenFile, dword ebx, dword ecx	; Openfile(FileName, FileSize)
cmp	eax, -1
je	near .error	; check for file opening error
mov	esi, eax	; save DOS handle

; ReadFile(handle, Offset, FileSize)
invoke 	_ReadFile, dword esi, dword [FG_File_Off], dword [ebp + .FileSize]
cmp	eax, dword [Current_FG_File_Size]
jne	near .error	; compare if amount of bytes read in matches
	
invoke 	_CloseFile, dword esi	; close file after it has been read
; now BG_File_Off points to our music, copy the file buffer into
; the DMA Buffer

; Set Mix Flag to request to _DMA_Refill to mix sound
mov	dword [FG_Mix_Flag], 1
mov	dword [FG_File_Index], 0 ; make sure file position reset
jmp	.end


.PlayInBG:
mov	eax, dword [ebp+.FileName]	; dereference FileName from parameter
mov	ebx, dword [ebp+.FileSize]	; dereference FileSize from parameter
invoke	_PlaySong, dword eax, dword ebx, dword 705, dword 44100, \
							dword 0, dword 0
jmp	.end


.error:
	mov	dword [FG_Mix_Flag], 0		; reset Mix Flag

.end:
ret
endproc
_PlaySoundFX_arglen		equ	8







;-------------------------------------------------------------------------------
;*** void _DMA_Refill() *********************************************
; Inputs:	None, reads from flags
; Outputs	Refills Buffer, sets EndOfSong_Flag to 1 when song 
; 		is over (user must reset the flag to 0 when desired),
;		Sets BG_Playing_Flag to 1 when song is playing, 
;		resets it when song is over, FG_Mix_Flag is set to 1
;		by _PlaySoundFX to request a sound mix, FG_Mix_Flag
;		is reset to 0 when Sound Mix or BG Music is finished.
;		
; Calls:	NOne
; Purpose:	Reads from flags to determine whether to mix 
;		foreground sound effects to back ground or not, and
;		fills the appropriate halves of the DMA Buffer 
;		according to flag settings.
;-------------------------------------------------------------------------------
_DMA_Refill
pushad

xor	edx, edx	; clear edx for sound mixing use
; Check if SoundFX finished playing, if so, reset FG_Mix_Flag
cmp	dword [FGSize], 0
jg	.checkSongFinish
mov	dword [FG_Mix_Flag], 0
mov 	dword [FG_File_Index], 0

.checkSongFinish	
; Then Check if Song has finished playing
cmp	dword [SongSize], 0
jg	near .CheckLastRefill	; Song not ended yet
mov	dword [FG_Mix_Flag], 0	; stops mixing for the next cycle
mov 	dword [FG_File_Index], 0


;*** Repeat Code here
; If Song has finished playing, repeat flag is on, repeat
cmp	dword [Repeat_Flag], 1
jne	near .BG_Song_Ended	; if flag not set, end immediately


; Refill full buffer length first
invoke	_SB16_Stop
movzx	eax, byte [CurrentDMAChannel]
invoke	_DMA_Stop, dword eax

mov	ecx, [CurrentDMASize]
;shr	ecx, 2	; ecx equivalent to SIZE/4
;mov	ecx,  SIZE/4
mov	es, [CurrentDMASel]
mov	edi, 0
mov	esi, dword [BG_File_Off]
add	esi, 50	; Skip first 50B to skip playing the header
rep	movsb
;Start DMA transfer again
movzx	eax, byte [CurrentDMAChannel]
invoke	_DMA_Start, dword eax, dword [CurrentDMAAddress], \
			dword [CurrentDMASize], dword 1, dword 1

; Start SB16 to AutoCycle Mode again
;cmp	dword [BG_Sample8_16], 8
;je	.bit8set
;*** We are limiting to 16 bit support only for uniformity and 
;*** ease of sound mixing
mov	ebx, dword [CurrentDMASize]
shr	ebx, 2
invoke	_SB16_Start, dword ebx, dword 1, dword 1


; Setup for next cycle
mov	eax, dword [Current_BG_File_Size]
sub	eax, dword [CurrentDMASize]
mov	es, [CurrentDMASel]	;*** Might not be necessary
sub	eax, 50		; equivalent of BG_Sound_Size-SIZE-50 
mov	dword [SongSize], eax ; Filled whole buffer length
;mov	dword [SongSize], BG_Sound_Size-SIZE-50 ; Filled whole buffer length
mov	eax, dword [CurrentDMASize]
add	eax, 49		; equivalent of SIZE+49
mov	dword [BG_File_Index], eax
;mov	dword [BG_File_Index], SIZE+49
or	byte [DMA_Flags], DMA_Refill_Flag ; set Refill Flag to fill 
					  ; 1st half first
jmp	.end
;*** Repeat Code End



.CheckLastRefill:
; Check if SongSize is less than Size/2
mov	eax, dword [CurrentDMASize]
shr	eax, 1	; equivalent of SIZE/2
cmp	dword [SongSize], eax
;cmp	dword [SongSize], SIZE/2
ja	near .AutoCycle
; else, Prepare to switch to SingleCycle
;*** Single Cycle Code Here
mov	dword [FG_Mix_Flag], 0	; reset SoundFX mix flag
; Set to Single Cycle
mov	eax, dword [CurrentDMASize]
shr	eax, 2	; eax=SIZE/4
invoke	_SB16_Start, dword eax, dword 0, dword 1

; calculate remaining samples, at 16bits sample rate, remaining sample
; is SongSize/2, at 8bit sample rate, remaining is SongSize
test	eax, eax
jnz	near .error
mov	ecx, dword [SongSize]
shr	ecx, 2	; ecx=SongSize/4
mov	dword [SongSize], 0	; Set SongSize to zero after it has 
				; finished playing
mov	dword [FGSize], 0
test	byte [DMA_Flags], DMA_Refill_Flag
jnz	.Fill2ndHalfSC

; else Fill 1st half of buffer for Single Cycle
%if 1
mov	es, [CurrentDMASel]
mov	edi, 1
mov	esi, dword [BG_File_Off]
add	esi, dword [BG_File_Index]
rep	movsd
;*** Check if Mixing necessary
cmp	dword [FG_Mix_Flag], 1
jne	near .ClearFlags
mov	ecx, dword [SongSize]	; Get numbers of times to add, 
				; SongSize/2 ; add a word at a time
shr	ecx, 1			; ecx = SongSize/2
mov	edi, 1
mov	esi, dword [FG_File_Off]
add	esi, dword [FG_File_Index]

; Get a word at a time from the DMA Buffer
.MixSC1_Loop:
mov	ax, word [es:edi]	; Get BG Sample
sar	ax, 1			; divide BG by 2 first
mov	bx, word [esi]		; Add it to FG sample
sar	bx, 1			; divide FG by 2 first
add	ax, bx

mov	word [es:edi], ax ;dx	; put it back to DMA Buffer
add	esi, 2
add	edi, 2
loop	.MixSC1_Loop
%endif
jmp	.ClearFlags


.Fill2ndHalfSC:
%if 1
mov	es, [CurrentDMASel]
mov	edi, dword [CurrentDMASize]
shr	edi, 1	; edi = SIZE/2
inc	edi	; edi = SIZE/2 + 1
;mov	edi, SIZE/2+1
mov	esi, dword [BG_File_Off]
add	esi, dword [BG_File_Index]
rep	movsd
;*** Check if Mixing necessary
cmp	dword [FG_Mix_Flag], 1
jne	near .ClearFlags
mov	ecx, dword [SongSize]	; Get numbers of times to add, SongSize/2 
				; add a word at a time
shr	ecx, 1	; ecx = SongSize/2
mov	edi, dword [CurrentDMASize]
shr	edi, 1	; edi = SIZE/2
inc	edi	; edi = SIZE/2 + 1
mov	esi, dword [FG_File_Off]
add	esi, dword [FG_File_Index]
; Get a word at a time from the DMA Buffer
.MixSC2_Loop:
mov	ax, word [es:edi]	; Get BG Sample
sar	ax, 1			; divide BG by 2 first
mov	bx, word [esi]	; Add it to FG sample
sar	bx, 1			; divide FG by 2 first
add	ax, bx

mov	word [es:edi], ax ;dx	; put it back to DMA Buffer
add	esi, 2
add	edi, 2
loop	.MixSC2_Loop
%endif
jmp	.ClearFlags




;*** Auto Cycle code here
.AutoCycle:
mov	ecx, dword [CurrentDMASize]
shr	ecx, 3		; equivalent to ecx = SIZE/8
;mov	ecx, SIZE/8	; ecx = number of times to move: move half of 
			; buffer size, at 4 bytes each, hence SIZE/8
mov	eax, dword [CurrentDMASize]
shr	eax, 1				; equivalent to eax = SIZE/2
sub	dword [SongSize], eax		; get new remaining SongSize
;sub	dword [SongSize], SIZE/2	; get new remaining SongSize
sub	dword [FGSize], eax

.CheckDMA_Flags:
test	byte [DMA_Flags], DMA_Refill_Flag
jnz	near .Fill2ndHalf

; else Fill 1st half of buffer
mov	es, [CurrentDMASel]
mov	edi, 1
mov	esi, dword [BG_File_Off]
add	esi, dword [BG_File_Index]
rep	movsd
mov	eax, dword [CurrentDMASize]
shr	eax, 1	; Equivalent of Size/2
add	dword [BG_File_Index], eax
;*** Check if Mixing necessary
cmp	dword [FG_Mix_Flag], 1
jne	near .ClearFlags
mov	ecx, dword [CurrentDMASize]
shr	ecx, 4	; equivalent to ecx = DMA_Size/4 = number of times to move,
		; half DMA_Size, at 8 byte at a time(MMX), hence DMA_Size/16
mov	edi, 0	; Keep it at Zero!!
mov	esi, dword [FG_File_Off]
add	esi, dword [FG_File_Index]

.MixAC1_Loop:
;*** Mixing Sound using MMX ***
movq	mm1, qword [es:edi]	; get 64 bits (8 bytes at a time)
paddsw	mm1, qword [esi]	; add 64 bit packed words using MMX
movq	qword [es:edi], mm1	; put it back to memory
add	esi, 8
add	edi, 8
loop	.MixAC1_Loop

mov	eax, dword [CurrentDMASize]
shr	eax, 1				; Equivalent of Size/2
add	dword [FG_File_Index], eax	; add number of bytes moved to index
jmp	.ClearFlags


.Fill2ndHalf:
mov	es, [CurrentDMASel]
mov	edi, dword [CurrentDMASize]
shr	edi, 1	; SIZE/2
inc	edi	; equivalent of SIZE/2+1
mov	esi, dword [BG_File_Off]
add	esi, dword [BG_File_Index]
rep	movsd
mov	eax, dword [CurrentDMASize]
shr	eax, 1	; Equivalent of Size/2
add	dword [BG_File_Index], eax
;*** Check if Mixing necessary
mov	es, [CurrentDMASel]	;*** Might not be necessary
cmp	dword [FG_Mix_Flag], 1
jne	near .ClearFlags
mov	ecx, dword [CurrentDMASize]
shr	ecx, 4	 	; equivalent to ecx = DMA_Size/4 = number of times
			; to move, half DMA_Size, at 8 byte at a time(MMX),
			; hence DMA_Size/16
mov	edi, dword [CurrentDMASize]
shr	edi, 1		; SIZE/2
mov	esi, dword [FG_File_Off]
add	esi, dword [FG_File_Index]


.MixAC2_Loop:
;*** Mixing Sound using MMX ***
movq	mm1, qword [es:edi]
paddsw	mm1, qword [esi]
movq	qword [es:edi], mm1

add	esi, 8
add	edi, 8
loop	.MixAC2_Loop

mov	eax, dword [CurrentDMASize]
shr	eax, 1				; Equivalent of Size/2
add	dword [FG_File_Index], eax	; add number of bytes moved to index

.ClearFlags:
; Clear DMA_Empty Flag
and	byte [DMA_Flags], ~DMA_Empty
jmp	.end

.error:
.BG_Song_Ended:
mov	dword [EndOfSong_Flag], 1
mov	dword [BG_Playing_Flag], 0
mov	dword [FG_Mix_Flag], 0

.end:
popad
ret



;-------------------------------------------------------------------------------
;*** void _StopSong() ************************************************
; Inputs:	None
; Outputs:	None
; Calls: 	NOne
; PUrpose:	With the sole purpose or stopping all DMA transfers,
;		SB16 functions.
;-------------------------------------------------------------------------------
_StopSong


	; Stop SB16 play back
	invoke	_SB16_Stop
	; SB16_Stop doesn't report error

	; Stops DMA transfer
	movzx	eax, byte [CurrentDMAChannel]
	invoke	_DMA_Stop, eax
	; DMA_Stop doesn't report error

	; Set Mixer volumes to Zero
	invoke	_SB16_SetMixers, word 0, word 0, word 0, word 0
	test	eax, eax
	jnz	near .error

	; Exits Sound Blaster
	invoke	_SB16_Exit
	test	eax, eax
	jnz	near .error

	; Display number of times ISR is called

ret

.error
;	mov	ax, 10
;	call	_LibExit
	ret
;********************* kw's Functions End!*********************



;------------------------------------------------------------------------------------------------------
; _AllocateMem (by Adam)
;
;	-run only once
;	-allocates memory for stepfile
;	-stores offset of allocated memory into _stepOff and _stepIndex
;------------------------------------------------------------------------------------------------------
_AllocateMem
	push esi
	
	invoke _AllocMem, dword _stepSize
	cmp eax, -1
	je near .error
	mov [_stepOff], eax		;save offset!!!
	mov [_stepIndex], eax		;save as index
.error:
	pop esi
	ret



;------------------------------------------------------------------------------------------------------
; _ReadFileIntoMem (by Adam)
;
;	-run only once per song
;	-writes steps for song into allocated memory
;	-overwrites old steps if necessary
;	-resets _stepIndex to beginning of memory
;------------------------------------------------------------------------------------------------------
_ReadFileIntoMem
	;fill the stepfile buffer
	
	push esi
	
	mov eax, [_stepOff]
	mov [_stepIndex], eax		;save as index
	
	invoke _OpenFile, dword [_stepFN], word 0
	cmp eax, -1
	je near .error
	mov esi, eax
	
	invoke _ReadFile, esi, dword [_stepOff], dword _stepSize
	cmp eax, _stepSize
	jne .error
	
	invoke _CloseFile, esi
	
.error:
	pop esi
	ret




;------------------------------------------------------------------------------------------------------
; _ReadMemIntoArray (by Adam)
;
;	-runs every loop
;	-reads steps from memory and converts to Arrow structure, loads into array
;	-never overwrite an arrow until it is gone
;	-times each arrow with bpm
;------------------------------------------------------------------------------------------------------
_ReadMemIntoArray
	push	ecx
	push	eax
	push	esi
	xor		ecx, ecx	
	
	mov		eax, dword[_fptemp4]
	add		eax, dword[_fptemp1]				; add BPM*multiplier to counter
	cmp		eax, dword[_fptemp2]				; if counter does not exceed preset value, skip function
	mov		dword[_fptemp4], eax
	jl 		near	.end
	sub		eax, dword[_fptemp2]				; otherwise, subtract value from counter and move on
	mov		dword[_fptemp4], eax



	.loop:
		cmp		ecx, Arrow_size*ArraySize									;checks whether entire array has been run through
		je near	.end
		
		cmp		byte[_arrowArray+ecx+Arrow.exist],1					;checks whether 'exist' flag is 1
		je near	.goToNext
		jmp .conversion
		
	.goToNext:
		add		ecx, Arrow_size									;increments index in array to next arrow
		jmp		.loop
	
	.conversion:
		mov eax, ecx
		add eax, _arrowArray
	
	.redo:
		mov esi, [_stepIndex]
		mov cl, byte [esi]
		
		cmp cl, ';'						; end of file, do not increment _stepIndex and quit function
		je near .end
		
;		cmp cl, '('						; for 1/16 beats, not implemented
;		je .doubletime
		
;		cmp cl, ')'
;		je .halftime
		
		mov dword[eax + Arrow.YCoord],550	; sets values for next arrow
		mov byte[eax + Arrow.exist],1

		cmp cl, '0'
		je near .noarrow
		
		cmp cl, '1'
		je near .ldarrow		
		
		cmp cl, '2'
		je near .darrow		
		
		cmp cl, '3'
		je near .rdarrow		
		
		cmp cl, '4'
		je near .larrow		

		cmp cl, '6'
		je near .rarrow		

		cmp cl, '7'
		je near .luarrow		

		cmp cl, '8'
		je near .uarrow		

		cmp cl, '9'
		je near .rdarrow		

		cmp cl, 'A'
		je near .udarrow		

		cmp cl, 'B'
		je near .lrarrow		
		
		inc esi										; if invalid character found, just skip
		;inc esi
		mov byte[eax + Arrow.exist],0
		mov [_stepIndex], esi
		jmp .redo
		
	.doubletime:									; 1/16 beat code, not implemented
		cmp	dword[SongSel_Flags], 1
		jg	.CantSpeedTempoDouble
		mov 	dword[_fptemp1], _BPMconstHot*200		
		jmp	.nextarrow

		.CantSpeedTempoDouble:
		mov	dword[_fptemp1], _BPMconstCant*200
		jmp .nextarrow

		
	.halftime:
		cmp	dword[SongSel_Flags], 1
		jg	.CantSpeedTempoHalf
		mov 	dword[_fptemp1], _BPMconstHot*100
		jmp	.nextarrow
		
		.CantSpeedTempoHalf:
		mov	dword[_fptemp1], _BPMconstCant*100
		jmp .nextarrow


	.noarrow:										; to prevent early quit from loop, input false arrow
		mov byte[eax + Arrow.type],7
		jmp .nextarrow

	.larrow:
		mov byte[eax + Arrow.type],1
		jmp .nextarrow
	
	.darrow:
		mov byte[eax + Arrow.type],2
		jmp .nextarrow
	
	.uarrow:
		mov byte[eax + Arrow.type],3
		jmp .nextarrow
	
	.rarrow:
		mov byte[eax + Arrow.type],4
		jmp .nextarrow
	
	.ldarrow:										; two arrows = two array elements
		mov byte[eax + Arrow.type], 1				; make one arrow, then restart function with the other
		mov byte [esi], '2'
		xor ecx, ecx
		jmp .loop
		
	.rdarrow:										; repeat trend for all occurrences of multiple arrows
		mov byte[eax + Arrow.type], 4
		mov byte [esi], '2'
		xor ecx, ecx
		jmp .loop
		
	.lrarrow:
		mov byte[eax + Arrow.type], 1
		mov byte [esi], '6'
		xor ecx, ecx
		jmp .loop
		
	.luarrow:
		mov byte[eax + Arrow.type], 1
		mov byte [esi], '8'
		xor ecx, ecx
		jmp .loop
		
	.ruarrow:
		mov byte[eax + Arrow.type], 4
		mov byte [esi], '8'
		xor ecx, ecx
		jmp .loop
		
	.udarrow:
		mov byte[eax + Arrow.type], 2
		mov byte [esi], '8'
		xor ecx, ecx
		jmp .loop
		
	.nextarrow:
		;inc esi
		inc esi										; next character in mem
		mov [_stepIndex], esi
		
		

	.end:
		pop		esi
		pop		eax
		pop		ecx
		ret






