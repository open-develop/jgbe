# Introduction #

Here we try to maintain a list of games that we know work with JGBE, and more importantly, those that don't function properly, if at all. Currently the list is not very extensive (we have tested many more games without adding them to the list), but with your help we hope to have a comprehensive list here pretty soon. :-)


# Nice ASCII-art list #
```
    :                                                                      :
.---'---[ 4x4 World Trophy (E) (M5) [C][!].gbc ]---------------------------'---.
| MD5    : 5878a145e365fa1841b22e837c3226ff                                    |
| Status : PLAYABLE                                                            |
| Notes  : JGBE and KIGB are the only emulator who can emulate this game       |
|          perfectly, in all other emulators it runs far too slow.             |
'---.----------------------------------------------------------------------.---'
    |                                                                      |
.---'---[ Altered Space (U).gb ]-------------------------------------------'---.
| MD5    : 012ee0a196c03cca91a43a9eadbecfb6                                    |
| Status : PLAYABLE BUG                                                        |
| Notes  : Intro appears to work correctly, ingame may not: According to KIGB  |
|           - changing rooms blanks the screen completely, not half way.       |
|           - falling objects should not make sound.                           |
|           - When starting stage 1, the intro text appears to be cut off on   |
|             the top. KIGB does this too.                                     |
'---.----------------------------------------------------------------------.---'
    |                                                                      |
.---'---[ Apocalypse Now Demo (PD) [a1].gb ]-------------------------------'---.
| MD5    : b5458c8dad082ab6cb98081c7cd3a61b                                    |
| Status : PLAYABLE                                                            |
| Notes  : Appears to hang at start until keypress, this is normal             |
'---.----------------------------------------------------------------------.---'
    |                                                                      |
.---'---[ Armageddon Video Trailer (GBTK Video) (PD).gb ]------------------'---.
| MD5    : bff88c7ccc6e21f79d7dec9a4e2ea299                                    |
| Status : PLAYABLE BUG                                                        |
| Notes  : Restarts after a while with mis-aligned image                       |
'---.----------------------------------------------------------------------.---'
    |                                                                      |
.---'---[ Big Scroller Demo (PD).gb ]--------------------------------------'---.
| MD5    : d6d839eaac2d01ff3db44caebeaa6882                                    |
| Status : PLAYABLE                                                            |
| Notes  : Screen blinks like crazy, this is normal. This Demo appears to      |
|          require inter-frame blending (kigb 'mix-frame' mode)                |
'---.----------------------------------------------------------------------.---'
    |                                                                      |
.---'---[ Castelian (U).gb ]-----------------------------------------------'---.
| MD5    : 21cc47b68fc7c9c56ef3393dbe528600                                    |
| Status : PLAYABLE BUG                                                        |
| Notes  : The last line of the status bar constantly blinks.                  |
'---.----------------------------------------------------------------------.---'
    |                                                                      |
.---'---[ Commando (PD).gb ]-----------------------------------------------'---.
| MD5    : 7857c923a55ca8d2d35fc5092663cf0e                                    |
| Status : PLAYABLE BUG                                                        |
| Notes  : There are large black tiles (NOT Gameboy Background black, but pure |
|          black, so it looks like a bug in the video controller?)             |
'---.----------------------------------------------------------------------.---'
    |                                                                      |
.---'---[ Earthworm Jim (U) [!].gb ]---------------------------------------'---.
| MD5    : 0d24eeff28040ff2a8f63de5bc8cbea2                                    |
| Status : BUG PLAYABLE                                                        |
| Notes  : Player dies once immediately after starting level 1                 |
'---.----------------------------------------------------------------------.---'
    |                                                                      |
.---'---[ Effigy (PD).gb ]-------------------------------------------------'---.
| MD5    : 1a219d32986e4607bd534ca4c031158f                                    |
| Status : PLAYABLE BUG                                                        |
| Notes  : This is a gameboy mono demo, yet is has some CGB aspects, such as a |
|          black and white background, but 'normal' DMG sprite colors.         |
'---.----------------------------------------------------------------------.---'
    |                                                                      |
.---'---[ Emulators Unlimited Demo (PD).gb ]-------------------------------'---.
| MD5    : 041e6968ee041df2c452755418cc9e1e                                    |
| Status : PLAYABLE BUG                                                        |
| Notes  : Similar behaviour as 1a219d32986e4607bd534ca4c031158f               |
'---.----------------------------------------------------------------------.---'
    |                                                                      |
.---'---[ F-1 Race (JUE) (V1.0) [!].gb ]-----------------------------------'---.
| MD5    : 3ad6a2e9c2872cd8f92d86e18332262c                                    |
| Status : PARTIALLY                                                           |
| Notes  : 'Grand Prix' and 'Time Trials' modes do not seem to work (lots of   |
|          messages about the RAM being disabled, then returns to main menu),  |
|          but the 'Multi Game' mode does work.                                |
'---.----------------------------------------------------------------------.---'
    |                                                                      |
.---'---[ F-1 Race (JUE) (V1.1) [!].gb ]-----------------------------------'---.
| MD5    : 8ac5c061641b2a8b4c44b46ef693aeef                                    |
| Status : PARTIALLY                                                           |
| Notes  : Identical behaviour as 3ad6a2e9c2872cd8f92d86e18332262c             |
'---.----------------------------------------------------------------------.---'
    |                                                                      |
.---'---[ F-1 Racing 2000 Demo (PD).gb ]-----------------------------------'---.
| MD5    : c11067d13fb13c80b65136d61d29b177                                    |
| Status : PLAYABLE BUG                                                        |
| Notes  : Demo resets when pressing A or B (probably because of missing MBC0) |
'---.----------------------------------------------------------------------.---'
    |                                                                      |
.---'---[ Final Fantasy Adventure (U) [!].gb ]-----------------------------'---.
| MD5    : 24cd3bdf490ef2e1aa6a8af380eccd78                                    |
| Status : PLAYABLE                                                            |
'---.----------------------------------------------------------------------.---'
    |                                                                      |
.---'---[ Gabe Edit V0.1 (PD).gb ]-----------------------------------------'---.
| MD5    : 75c1c215431b01538f1ee570be007e8e                                    |
| Status : PLAYABLE                                                            |
| Notes  : Does not appear to do anything after initial screen. The same       |
|          happens in KIGB, so it seems to be normal.                          |
'---.----------------------------------------------------------------------.---'
    |                                                                      |
.---'---[ Galaga\ Demo\ \(PD\).gb ]----------------------------------------'---.
| MD5    : e2bb160c5649167291613b0d7c183ad6                                    |
| Status : PLAYABLE                                                            |
| Notes  : Bottom part of the world appears corrupted. The same happens in     |
|          KIGB, so it seems to be normal.                                     |
'---.----------------------------------------------------------------------.---'
    |                                                                      |
.---'---[ Smurfs, The (UE) (V1.0) (M4) [!].gb ]----------------------------'---.
| MD5    : 4528d42eae39a3fa756eefa29d52ef55                                    |
| Status : PLAYABLE                                                            |
'---.----------------------------------------------------------------------.---'
    |                                                                      |
.---'---[ Smurfs, The (UE) (V1.1) (M3) [S][!].gb ]-------------------------'---.
| MD5    : a574e5f7119b31e5112221c3a0ada813                                    |
| Status : PLAYABLE                                                            |
'---.----------------------------------------------------------------------.---'
    |                                                                      |
.---'---[ Teenage Mutant Ninja Turtles III - Radical Rescue (U).gb ]-------'---.
| MD5    : e6104df1feb1318ff1764c791eb4ce0e                                    |
| Status : PLAYABLE                                                            |
| Notes  : Confirmed finishable                                                |
'---.----------------------------------------------------------------------.---'
    |                                                                      |
.---'---[ Yoshi (U) [!].gb ]-----------------------------------------------'---.
| MD5    : a8804c8514619cc918960c2008ed65d1                                    |
| Status : BUG BROKEN                                                          |
| Notes  : Only displays vertical lines while writing 0x00 and 0x27 to         |
|          alternating adresses.                                               |
'---.----------------------------------------------------------------------.---'
    :                                                                      :
```