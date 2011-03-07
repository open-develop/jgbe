INCLUDE "gbhw.inc"
INCLUDE "ibmpc1.inc"
INCLUDE "memory.inc"

SECTION "IVT40",HOME[$40] ; vblank
	jp vblank

SECTION "IVT48",HOME[$48] ; lcdc
	jp lcdc

SECTION "Org $100",HOME[$100]
	di
	jp   begin
	ROM_HEADER      ROM_NOMBC, ROM_SIZE_32KBYTE, RAM_SIZE_0KBYTE

begin:
	; set bg-map addr to $9c00, enable sprites & wnd, get tiles from $8000
	ld hl, $ff40 ; HL
	ld a, [hl]
	and a, %11111011
	or  a, %11111011
	ld [hl], a

	call setPallettes

	; disable lcd so we can access vram
	call ScreenOff

	call BGMap
	call spriteClear


	; set sprites 0 & 1
	ld hl, $fe00 ; OAM start

	ld [hl], 144/2 + 4 + 8 ; \
	inc hl                 ;  > center of screen ??
	ld [hl], 160/2 + 4 - 8 ; /
	inc hl
	ld [hl], 1 ; tile 1 = circle
	inc hl
	ld [hl], 0 ; above bg, not flipped, pal 0
	inc hl
	ld [hl], 144/2 + 4 + 8 ; \
	inc hl                 ;  > center of screen ??
	ld [hl], 160/2 + 4 + 8 ; /
	inc hl
	ld [hl], 2 ; tile 1 = circle
	inc hl
	ld [hl], $80 ; below bg, not flipped, pal 0

	; enable lcd
	ld hl, $ff40
	ld a, [hl]
	or a, %10000000
	ld [hl], a

	; lyc = 0
	ld  hl, $ff45
	ld  [hl], 0
	ld  hl, $ff41
	ld  a, [hl]
	or  %01000000 ; enable LYC=LY
	ld  [hl], a


	; enable window
	ld  hl, $ff4a ; wy
	ld  [hl], 111
	inc hl
	ld  [hl], 80 + 7 ; wx

	; position bg
	ld  hl, $ff42
	ld  [hl], 96

	; init variables
	ld  hl, framecnt
	ld  [hl], 0
	ld  hl, delay
	ld  [hl], 1

	; enable interrupts
	ld hl, $ffff
	ld [hl], %00000011 ; enable vblank, lcdc
	ei

endless:
	jp endless

vblank:
	; reset lyc
	ld  hl, $ff45
	ld [hl], 0

	; update framecnt
	ld hl, framecnt
	inc [hl]


	call readjoypad ; b=arrows, c=buttons
	ld  a, $ff
	xor c
	and a, %00000011 ; mask buttons
	jp  nz, .buttonpressed

	ld  hl, delay
	ld  a, [hl]
	dec a
	ld  [hl], a
	jp  nz, .exit
	ld  [hl], 1
	ld  a, $ff
	xor c
	and a, %00001100 ; mask start/select
	jp  z, .exit
	ld  [hl], 10
	; select - switch prios
	; start  - toggle bg enable
	ld  d, a
	and a, %00001000 ; start
	sra a
	sra a
	sra a
	ld  e, a
	ld  hl, $ff40
	ld  a, [hl]
	xor a, e
	ld  [hl], a

	ld  a, d
	and a, %00000100 ; select
	jp  z, .exit
	ld  hl, $fe00 ; OAM start
	inc hl
	inc hl
	inc hl
	ld  a, [hl]
	xor a, %10000000
	ld  [hl], a
	inc hl
	inc hl
	inc hl
	inc hl
	ld  a, [hl]
	xor a, %10000000
	ld  [hl], a

.buttonpressed:
	; joypad reads are inverted (e.g. button A pressed == 0)
	ld  a, $ff
	xor b ; b = b^$ff = ~b
	ld  b, a
	ld  a, $ff
	xor c ; c = c^$ff = ~c
	ld  c, a
	ld  a, 1

	and c ; mask A button
	sla a
	sla a
	ld  d, a ; d = masked button A ? 4 : 0
	ld hl, $fe00 ; OAM start

	;add16
	ld a, l
	add a, d
	ld l, a
	ld a, h
	adc a, 0
	ld h, a

	ld  a, %00001000 ; down
	and b ; mask down arrow
	sra a
	sra a
	sra a
	ld  d, a
	ld  a, %00000100 ; up
	and b ; mask up arrow
	sra a
	sra a
	xor a, $ff
	add 1
	add a, d
	ld  e, a
	ld  a, [hl]
	add a, e
	ld  [hl], a

	inc hl
	ld  a, %00000001 ; right
	and b ; mask down arrow
	ld  d, a
	ld  a, %00000010 ; left
	and b ; mask up arrow
	sra a
	xor a, $ff
	add 1
	add a, d
	ld  e, a
	ld  a, [hl]
	add a, e
	ld  [hl], a

.exit:
	reti

lcdc:
	; setup next lyc
	ld  hl, $ff45
	ld  a, [hl]
	inc a
	ld [hl], a
	dec a

	; 0-160 -> 0-255, so div 160 * 255
	ld  b, 0
	ld  c, a
	ld  hl, framecnt
	ld  a, [hl]
	ld  h, 0
	ld  l, a
	add hl, bc
	ld  h, 0
	ld  b, h
	ld  c, l

	ld  hl, sintable
	add hl, bc
	ld  a, [hl]
	ld  hl, $ff43 ; scx
	ld  [hl], a
	reti




readjoypad:
	; read joypad, with 'key-debounce'
	; b=arrows, c=buttons
	ld  a, %00010000
	ld [$ff00], a ; select buttons
	ld a, [$ff00]
	nop
	nop
	ld a, [$ff00]
	nop
	nop
	ld a, [$ff00]
	ld c, a
	ld a, %00100000
	ld [$ff00], a ; select arrows
	ld a, [$ff00]
	nop
	nop
	ld a, [$ff00]
	nop
	nop
	ld a, [$ff00]
	ld b, a
	ret

spriteClear:
	ld hl, $fe00 ; OAM start
	ld a, $9f
.loop:
	ld [hl], 0 ; y-pos, x-pos, tile no, and attr can all be set to 0
	inc hl
	dec a
	jp nz, .loop
	ret

setPallettes:
	; set palettes
	ld hl, $ff47
	ld [hl], %11100100
	inc hl
	ld [hl], %11100100
	inc hl
	ld [hl], %11100100
	ret

BGTiles:
BGTileEmpty:
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000
	dw `00000000

BGTileCircle:
	dw `00011000
	dw `00133100
	dw `01333310
	dw `13333331
	dw `13333331
	dw `01333310
	dw `00133100
	dw `00011000

BGTileTriangle:
	dw `00011000
	dw `00011000
	dw `00133100
	dw `00133100
	dw `01333310
	dw `01333310
	dw `13333331
	dw `11111111

BGTileSquare:
	dw `00000000
	dw `03333330
	dw `03222230
	dw `03222230
	dw `03222230
	dw `03222230
	dw `03333330
	dw `00000000

BGTileDiagonalStripes:
	dw `12321000
	dw `23210001
	dw `32100012
	dw `21000123
	dw `10001232
	dw `00012321
	dw `00123210
	dw `01232100

BGTileHorizontalStripes:
	dw `12321000
	dw `12321000
	dw `12321000
	dw `12321000
	dw `12321000
	dw `12321000
	dw `12321000
	dw `12321000

BGMap:
BGMapTiles:
	; copy tiles to ram
	ld hl, $8000
	ld de, BGTiles
	ld bc, BGMap
.loop:
	ld a, [de]
	ld [hl], a
	inc de
	inc hl
	ld a, d
	cp b
	jp nz, .loop
	ld a, e
	cp c
	jp nz, .loop

BGMapMap:
	; set bg map
	ld hl, $9c00
	ld de, 32*12
.loopwnd:
	;ld [hl], 3 ; tile 3, square
	ld [hl], 4 ; tile 4, diagonal stripes
	;ld [hl], 5 ; tile 5, horizontal stripes
	inc hl
	dec de

	ld a, d
	cp 0
	jp nz, .loopwnd
	ld a, e
	cp 0
	jp nz, .loopwnd

	ld de, 32*20
.loopbg:
	ld [hl], 3 ; tile 3, square
	;ld [hl], 4 ; tile 4, diagonal stripes
	;ld [hl], 5 ; tile 5, horizontal stripes
	inc hl
	dec de

	ld a, d
	cp 0
	jp nz, .loopbg
	ld a, e
	cp 0
	jp nz, .loopbg

	ret

ScreenOff:
	ld    hl, rLCDC
	bit   7, [hl]     ; Is LCD already off?
	ret   z          ; yes, exit

	ld    a, [rIE]
	push af
	res   0, a
	ld    [rIE], a   ; Disable vblank interrupt if enabled

.loop:
	ld    a, [rLY]   ; Loop until in first part of vblank
	cp    145
	jr    nz, .loop

	res   7, [hl]    ; Turn the screen off

	pop   af
	ld    [rIE], a   ; Restore the state of vblank interrupt
	ret

FontTiles:
	chr_IBMPC1      1,8

InitSprData: ; y, x, tile, attr
	db 144/2 + 4 + 8, 160/2 + 4, 1, %00000000
	db 144/2 + 4 + 8, 160/2 + 4, 2, %10000000

; Generate a 256 byte sine table with values between 0 and 128
sintable:
ANGLE SET 0.001
	REPT 256
	DB    (MUL(16.0, SIN(ANGLE)))>>16
ANGLE SET ANGLE+256.0 ; NOTE: variables(macros?) should be the first thing on a line, otherwise the assembler will crash and burn
	ENDR

SECTION "RAM", BSS
framecnt: db
delay: db
