FIND_FILE(JAR_CLDCAPI_PATH "cldcapi10.jar" PATHS ${CUSTOM_JAVA_PATHS})
FIND_FILE(JAR_CLDCAPI11_PATH "cldcapi11.jar" PATHS ${CUSTOM_JAVA_PATHS})
FIND_FILE(JAR_MIDPAPI_PATH "midpapi20.jar" PATHS ${CUSTOM_JAVA_PATHS})
FIND_FILE(JAR_MIDPAPI21_PATH "midpapi21.jar" PATHS ${CUSTOM_JAVA_PATHS})
FIND_FILE(JAR_JSR75_PATH "jsr75.jar" PATHS ${CUSTOM_JAVA_PATHS})
FIND_FILE(JAR_JSR082_PATH "jsr082.jar" PATHS ${CUSTOM_JAVA_PATHS})
FIND_FILE(JAR_MMAPI_PATH "mmapi.jar" PATHS ${CUSTOM_JAVA_PATHS})

#shared between jgbe/jmgbe
SET(JGBE_CORE_SOURCES
	IntVector.jpp
	IVideoListener.java
	FHandler.jpp
	Version.jpp
	CPU.jpp
	Cartridge.jpp
	Bios.jpp
	Format142.jpp
	Tables.java
	ShTablesRRC.jpp
	ShTablesRLC.jpp
	ShTablesRL.jpp
	ShTablesRR.jpp
	ShTablesSLA.jpp
	ShTablesSRA.jpp
	ShTablesSRL.jpp
	IAudioListener.jpp
	AudioController.jpp
)

#shared between jmgbe/meboy
SET(JGBE_VFS_SOURCES
	MeBoyVFS.jpp
	IVFSNode.jpp
	VFSRoot.jpp
	VFSRecStore.jpp
	VFSJar.jpp
	VFS_JSR75.jpp
	DirectByteArrayOutputStream.jpp
)

ADD_JAVA_JAR(jgbe
	swinggui.jpp
	
	${JGBE_CORE_SOURCES}

	AdvancedAudioPropertiesDialog.jpp
	VideoController.jpp
	AudioDriver.jpp
	CheatCodeEditor.jpp
	ColorSelectorComponent.jpp
	TimedKeyListener.jpp
	ColorSelector.jpp
	JColoredSlider.jpp
	TriGradientPaint.jpp
	CPURunner.java
	RDParser.jpp
	Debugger.jpp
	Disassembler.jpp
	
	LZInputStream.jpp
	LZOutputStream.jpp

	icon.gif jgbe_logo.png VeraMono.ttf
	
	MAINCLASS swinggui
	NAME JGBE
	OFILEPATH "../classes/"
	INCLUDE_DIRECTORIES "${CMAKE_CURRENT_BINARY_DIR}"
)

ADD_JAVA_JAR(jmgbe
	jmgbe.jpp

	${JGBE_CORE_SOURCES}
	${JGBE_VFS_SOURCES}
	
	MobileVideoController.jpp
	
	MAINCLASS jmgbe
	NAME JGBE
	OFILEPATH "../classes/"
	INCLUDE_DIRECTORIES "${CMAKE_CURRENT_BINARY_DIR}"
	DEFINES USE_JAVA_MOBILE
	CLASSPATH "${JAR_CLDCAPI_PATH};${JAR_MIDPAPI_PATH};${JAR_JSR75_PATH}"
	VERIFY OBFUSCATE ZIPOPTIMIZE SOURCEVER 1.4 TARGETVER 1.4
)

ADD_JAVA_JAR(MeBoy
	MeBoy.jpp
	GBCanvas.jpp
	Dmgcpu.jpp
	GraphicsChip.jpp
	SimpleGraphicsChip.jpp
	AdvancedGraphicsChip.jpp
	Bluetooth.jpp

	${JGBE_VFS_SOURCES}
	
	lang/index.txt lang/0.txt lang/1.txt lang/2.txt lang/3.txt lang/4.txt lang/5.txt lang/6.txt
	lang/7.txt lang/8.txt lang/9.txt lang/11.txt lang/12.txt lang/13.txt lang/14.txt
	OFILEPATH "../classes/"

	MAINCLASS MeBoy
	NAME MeBoy
	DEFINES COMPILE_MEBOY;USE_JAVA_MOBILE
	CLASSPATH "${JAR_CLDCAPI_PATH};${JAR_MIDPAPI_PATH};${JAR_JSR75_PATH};${JAR_JSR082_PATH};${JAR_MMAPI_PATH}"
	VERIFY SOURCEVER 1.4 TARGETVER 1.4
)

add_custom_target(JGBE-Version ALL
	VERBATIM
	DEPENDS "${PROJECT_SOURCE_DIR}/svnversion.sh"
	COMMAND "${PROJECT_SOURCE_DIR}/svnversion.sh" "${PROJECT_SOURCE_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/svnrev.tmp"
	COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${CMAKE_CURRENT_BINARY_DIR}/svnrev.tmp" "${CMAKE_CURRENT_BINARY_DIR}/svnrev.inc"
)
add_custom_target(JGBE-Version-Update ALL DEPENDS svnrev.mark)
add_custom_command(OUTPUT svnrev.mark
	VERBATIM
	DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/svnrev.inc"
	COMMAND "${CMAKE_COMMAND}" -E touch "${CMAKE_CURRENT_SOURCE_DIR}/Version.jpp"
	COMMAND "${CMAKE_COMMAND}" -E touch "${CMAKE_CURRENT_BINARY_DIR}/svnrev.mark"
)
