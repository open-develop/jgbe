# copied from http://www.cmake.org/Wiki/CMakeMacroListOperations#LIST_CONTAINS
MACRO(LIST_CONTAINS var value)
	SET(${var})
	FOREACH(value2 ${ARGN})
		IF(${value} STREQUAL ${value2})
			SET(${var} TRUE)
		ENDIF()
	ENDFOREACH()
ENDMACRO()

# copied from http://www.cmake.org/Wiki/CMakeMacroParseArguments
MACRO(PARSE_ARGUMENTS prefix arg_names option_names)
	SET(DEFAULT_ARGS)
	FOREACH(arg_name ${arg_names})
		SET(${prefix}_${arg_name})
	ENDFOREACH()
	FOREACH(option ${option_names})
		SET(${prefix}_${option} FALSE)
	ENDFOREACH()

	SET(current_arg_name DEFAULT_ARGS)
	SET(current_arg_list)
	FOREACH(arg ${ARGN})
		LIST_CONTAINS(is_arg_name ${arg} ${arg_names})
		IF(is_arg_name)
			SET(${prefix}_${current_arg_name} ${current_arg_list})
			SET(current_arg_name ${arg})
			SET(current_arg_list)
		ELSE()
			LIST_CONTAINS(is_option ${arg} ${option_names})
			IF (is_option)
				SET(${prefix}_${arg} TRUE)
			ELSE()
				SET(current_arg_list ${current_arg_list} ${arg})
			ENDIF()
		ENDIF()
	ENDFOREACH()
	SET(${prefix}_${current_arg_name} ${current_arg_list})
ENDMACRO()

#find various programs and files
FIND_PROGRAM(JAVA_COMPILER_JIKES NAMES jikes)
FIND_PROGRAM(JAVA_COMPILER_JAVAC NAMES javac PATHS ${CUSTOM_JAVA_PATHS})
FIND_PROGRAM(JAVA_CMD_PROGUARD NAMES proguard PATHS)
FIND_PROGRAM(JAVA_CMD_PROGUARD_JAR NAMES proguard.jar PATHS .. ${CUSTOM_JAVA_PATHS})
FIND_PROGRAM(JAVA_CMD_ZIPOPT NAMES zipopt.bash PATHS ${CUSTOM_JAVA_PATHS})
FIND_PROGRAM(JAVA_CMD_WC NAMES wc)
FIND_PROGRAM(JAVA_CMD_ZIP NAMES zip)
FIND_PROGRAM(JAVA_CMD_GCC NAMES gcc)
FIND_PROGRAM(JAVA_CMD_SED NAMES sed)
FIND_PROGRAM(JAVA_CMD_JAVA NAMES java)
FIND_PROGRAM(JAVA_CMD_PREVERIFY NAMES preverify PATHS ${CUSTOM_JAVA_PATHS})
FIND_PROGRAM(JAVA_CMD_EMULATOR NAMES emulator PATHS ${CUSTOM_JAVA_PATHS})

IF(JAVA_CMD_PROGUARD_JAR AND NOT JAVA_CMD_PROGUARD AND JAVA_CMD_JAVA)
	SET(JAVA_CMD_PROGUARD "${JAVA_CMD_JAVA}")
	IF(CYGWIN)
		execute_process(
			COMMAND "${JAVA_CMD_CYGPATH}" -w "${JAVA_CMD_PROGUARD_JAR}"
			OUTPUT_VARIABLE JAVA_CMD_PROGUARD_JAR OUTPUT_STRIP_TRAILING_WHITESPACE
		)
	ENDIF()
	SET(JAVA_CMD_PROGUARD_OPTPREFIX -jar "${JAVA_CMD_PROGUARD_JAR}")
ELSE()
	SET(JAVA_CMD_PROGUARD_OPTPREFIX)
ENDIF()

IF(CYGWIN)
	FIND_PROGRAM(JAVA_CMD_CYGPATH NAMES cygpath)

	# emulator.exe doesn't like spaces in its path
	# on cygwin we can use cygpath to remove these
	execute_process(
		COMMAND "${JAVA_CMD_CYGPATH}" -ws "${JAVA_CMD_EMULATOR}"
		OUTPUT_VARIABLE JAVA_CMD_EMULATOR_1 OUTPUT_STRIP_TRAILING_WHITESPACE
	)
	execute_process(
		COMMAND "${JAVA_CMD_CYGPATH}" -u "${JAVA_CMD_EMULATOR_1}"
		OUTPUT_VARIABLE JAVA_CMD_EMULATOR_2 OUTPUT_STRIP_TRAILING_WHITESPACE
	)
	SET(JAVA_CMD_EMULATOR "${JAVA_CMD_EMULATOR_2}")
ENDIF()

FIND_FILE(JAVA_JAR_RT_PATH "rt.jar" PATHS ${CUSTOM_JAVA_PATHS})

IF(JAVA_COMPILER_JIKES)
	SET(JAVA_COMPILER_DEFAULT "JIKES")
ELSEIF(JAVA_COMPILER_JAVAC)
	SET(JAVA_COMPILER_DEFAULT "JAVAC")
ENDIF()

SET(JAVA_COMPILER "${JAVA_COMPILER_DEFAULT}" CACHE STRING "Compiler to use for java")
IF("${JAVA_COMPILER}" STREQUAL "JIKES")
	SET(JAVA_COMPILER_PATH "${JAVA_COMPILER_JIKES}")
ELSEIF("${JAVA_COMPILER}" STREQUAL "JAVAC")
	SET(JAVA_COMPILER_PATH "${JAVA_COMPILER_JAVAC}")
ELSE()
	MESSAGE(ERROR "choose compiler")
ENDIF()

MACRO(ADD_JAVA_JAR jarname)
	SET(AJJ_jarname "${jarname}")
	SET(AJJ_result)
	PARSE_ARGUMENTS(AJJ
		"MAINCLASS;NAME;CLASSPATH;OFILEPATH;DEPENDS;INCLUDE_DIRECTORIES;DEFINES;SOURCEVER;TARGETVER"
		"VERIFY;OBFUSCATE;ZIPOPTIMIZE"
		"${ARGN}"
	)
	
	
	make_directory("${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir")
	#make_directory("${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/META-INF")
	
	SET(JAVA_CLASSPATH ".:${JAVA_JAR_RT_PATH}")
	SET(JAVA_CLASSPATHV "")
	IF(CYGWIN)
		execute_process(COMMAND "${JAVA_CMD_CYGPATH}" -ws "${JAVA_JAR_RT_PATH}" OUTPUT_VARIABLE JAVA_JAR_RT_WPATH OUTPUT_STRIP_TRAILING_WHITESPACE)
		SET(JAVA_CLASSPATHW ".\;${JAVA_JAR_RT_WPATH}")
		SET(JAVA_CLASSPATHV -libraryjars "${JAVA_JAR_RT_WPATH}")
	ELSE()
		SET(JAVA_CLASSPATHW "${JAVA_CLASSPATH}")
		SET(JAVA_CLASSPATHV -libraryjars "${JAVA_JAR_RT_PATH}")
	ENDIF()
	FOREACH(CPJAR ${AJJ_CLASSPATH})
		SET(JAVA_CLASSPATH "${JAVA_CLASSPATH}:${CPJAR}")
		IF(CYGWIN)
			execute_process(COMMAND "${JAVA_CMD_CYGPATH}" -ws "${CPJAR}" OUTPUT_VARIABLE CPJARW OUTPUT_STRIP_TRAILING_WHITESPACE)
			SET(JAVA_CLASSPATHV ${JAVA_CLASSPATHV} -libraryjars "${CPJARW}")
			SET(JAVA_CLASSPATHW "${JAVA_CLASSPATHW}\;${CPJARW}")
		ELSE()
			SET(JAVA_CLASSPATHV ${JAVA_CLASSPATHV} -libraryjars "${CPJAR}")
			SET(JAVA_CLASSPATHW "${JAVA_CLASSPATHW}\;${CPJAR}")
		ENDIF()
	ENDFOREACH()
	
	IF("${JAVA_COMPILER}" STREQUAL "JIKES")
		IF(NOT AJJ_SOURCEVER)
			SET(AJJ_SOURCEVER "1.4")
		ENDIF()
		IF(NOT AJJ_TARGETVER)
			SET(AJJ_TARGETVER "1.4")
		ENDIF()
		SET(JAVA_COMPILER_OPTS -classpath "${JAVA_CLASSPATH}" -target "${AJJ_TARGETVER}" -source "${AJJ_SOURCEVER}")
	ELSEIF("${JAVA_COMPILER}" STREQUAL "JAVAC")
		IF(NOT AJJ_SOURCEVER)
			SET(AJJ_SOURCEVER "1.6")
		ENDIF()
		IF(NOT AJJ_TARGETVER)
			SET(AJJ_TARGETVER "1.6")
		ENDIF()
		SET(JAVA_COMPILER_OPTS -classpath "${JAVA_CLASSPATHW}" -target "${AJJ_TARGETVER}" -source "${AJJ_SOURCEVER}")
	ENDIF()
	
	SET(JAVA_PREPROCESS_OPTS "-DJAVA_SOURCEVER_${AJJ_SOURCEVER}")
	STRING(REPLACE "." "" JAVA_PREPROCESS_OPTS ${JAVA_PREPROCESS_OPTS})
	FOREACH(PPINCDIR ${AJJ_INCLUDE_DIRECTORIES})
		SET(JAVA_PREPROCESS_OPTS ${JAVA_PREPROCESS_OPTS} -I "${PPINCDIR}")
	ENDFOREACH()
	FOREACH(PPDEF ${AJJ_DEFINES})
		SET(JAVA_PREPROCESS_OPTS ${JAVA_PREPROCESS_OPTS} -D "${PPDEF}")
	ENDFOREACH()

	add_custom_target(${jarname} ALL DEPENDS ${jarname}.jar)
	add_custom_target(${jarname}-jar DEPENDS ${jarname}.jar)
	add_custom_target(${jarname}-run DEPENDS ${jarname}.run)
	add_custom_target(${jarname}-jad DEPENDS ${jarname}.jad)
	add_custom_target(${jarname}-jademu DEPENDS ${jarname}.jademu)
	SET(JAVA_FILES "")
	SET(CLASS_FILES "")
	SET(RCLASS_FILES "")
	SET(OTHER_FILES "")
	SET(OTHER_RFILES "")
	FOREACH(name ${AJJ_DEFAULT_ARGS})
		IF("${name}" MATCHES "(.*)\\.([^.]*)")
			SET(AJJ_BASENAME "${CMAKE_MATCH_1}")
			string(TOLOWER "${CMAKE_MATCH_2}" AJJ_EXT)
		ELSE()
			SET(AJJ_BASENAME "${name}")
			SET(AJJ_EXT "")
		ENDIF()
		
		SET(sname "${CMAKE_CURRENT_SOURCE_DIR}/${name}")
		
		IF(AJJ_EXT MATCHES "java")
			SET(jname "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/${name}")
			add_custom_command(OUTPUT "${jname}"
				DEPENDS "${name}"
				COMMAND "${CMAKE_COMMAND}" ARGS -E copy "${sname}" "${jname}"
			)
		ELSEIF(AJJ_EXT MATCHES "jpp")
			SET(jname "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/${AJJ_BASENAME}.java")
		
			add_custom_command(OUTPUT "${jname}"
				DEPENDS "${sname}" ${AJJ_DEPENDS}
				IMPLICIT_DEPENDS C "${sname}"
				COMMAND "${JAVA_CMD_GCC}" ARGS -E -x c "${sname}" -o "${jname}" ${JAVA_PREPROCESS_OPTS}
				COMMAND "${JAVA_CMD_SED}" ARGS -i "'s:^\#.*$$::'" "${jname}"
			)
		ELSE()
		ENDIF()

		IF(AJJ_EXT MATCHES "java|jpp")
			SET(cname "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/${AJJ_BASENAME}.class")
			SET(JAVA_FILES ${JAVA_FILES} "${jname}")
			SET(CLASS_FILES ${CLASS_FILES} "${cname}")
			SET(RCLASS_FILES ${RCLASS_FILES} "${AJJ_BASENAME}.class")
			add_custom_command(OUTPUT "${cname}"
				DEPENDS "${jname}"
				VERBATIM
				WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/"
				COMMAND "${JAVA_COMPILER_PATH}" ARGS "${AJJ_BASENAME}.java" ${JAVA_COMPILER_OPTS}
			)
		ELSE()
			SET(oname "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/${name}")
			add_custom_command(OUTPUT "${oname}"
				DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${AJJ_OFILEPATH}${name}"
				COMMAND "${CMAKE_COMMAND}" ARGS -E copy "${CMAKE_CURRENT_SOURCE_DIR}/${AJJ_OFILEPATH}${name}" "${oname}"
			)
			SET(OTHER_FILES ${OTHER_FILES} "${oname}")
			SET(OTHER_RFILES ${OTHER_RFILES} "${name}")
		ENDIF()
	ENDFOREACH()
	FILE(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/writemanifest.cmake"
"
#create manifest
FILE(WRITE manifest.out.temp \"Manifest-Version: 1.2\\r\\n\")
FILE(APPEND manifest.out.temp \"Created-By: 1.5.0_12 (Sun Microsystems Inc.)\\r\\n\")
FILE(APPEND manifest.out.temp \"Main-Class: ${AJJ_MAINCLASS}\\r\\n\")

FILE(APPEND manifest.out.temp \"MicroEdition-Profile: MIDP-1.0\\r\\n\")
FILE(APPEND manifest.out.temp \"MicroEdition-Configuration: CLDC-1.0\\r\\n\")

FILE(APPEND manifest.out.temp \"MIDlet-Name: ${AJJ_NAME}\\r\\n\")
FILE(APPEND manifest.out.temp \"MIDlet-Version: ${AJJ_TARGETVER}\\r\\n\")
FILE(APPEND manifest.out.temp \"MIDlet-Vendor: Vendor\\r\\n\")
FILE(APPEND manifest.out.temp \"MIDlet-Jar-URL: ${jarname}.jar\\r\\n\")
FILE(APPEND manifest.out.temp \"MIDlet-1: ${AJJ_NAME}, , ${AJJ_MAINCLASS}\\r\\n\")
"
	)
	
	FILE(WRITE "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/writejadfile.cmake"
"
execute_process(COMMAND \"${JAVA_CMD_WC}\" -c \"${jarname}.jar\"
    OUTPUT_VARIABLE _size OUTPUT_STRIP_TRAILING_WHITESPACE)
STRING(REGEX REPLACE \" .*\" \"\" _size \"\${_size}\")
FILE(APPEND jadfile.out.temp \"MIDlet-Jar-Size: \${_size}\\r\\n\")
"
	)

	add_custom_command(OUTPUT "${jarname}.jad"
		DEPENDS "${jarname}.jar" "${jarname}.jar-dir/META-INF/MANIFEST.MF"
		COMMAND "${CMAKE_COMMAND}" ARGS -E copy "${jarname}.jar-dir/META-INF/MANIFEST.MF" jadfile.out.temp
		COMMAND "${CMAKE_COMMAND}" ARGS -P "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/writejadfile.cmake"
		COMMAND "${CMAKE_COMMAND}" ARGS -E copy jadfile.out.temp "${jarname}.jad"
		COMMAND "${CMAKE_COMMAND}" ARGS -E remove jadfile.out.temp
	)

	add_custom_command(OUTPUT "${jarname}.jademu"
		VERBATIM
		DEPENDS "${jarname}.jad"
		COMMAND "${JAVA_CMD_EMULATOR}" ARGS "-Xdescriptor:./${jarname}.jad" -Xdomain:maximum -classpath "${jarname}.jar"

	)
	add_custom_command(OUTPUT "${jarname}.run"
		VERBATIM
		DEPENDS "${jarname}.jar"
		WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/"
		COMMAND "${JAVA_CMD_JAVA}" ARGS -classpath "${JAVA_CLASSPATHW}" "${AJJ_MAINCLASS}"
	)

	add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/META-INF/MANIFEST.MF"
		COMMAND "${CMAKE_COMMAND}" ARGS -P "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/writemanifest.cmake"
		COMMAND "${CMAKE_COMMAND}" ARGS -E copy manifest.out.temp "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/META-INF/MANIFEST.MF"
		COMMAND "${CMAKE_COMMAND}" ARGS -E remove manifest.out.temp
	)

	SET(jarnext "${jarname}.1.jar")
	add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/${jarnext}"
		VERBATIM
		DEPENDS ${JAVA_FILES} ${CLASS_FILES} ${OTHER_FILES} "${jarname}.jar-dir/META-INF/MANIFEST.MF"
		WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/"
		COMMAND "${CMAKE_COMMAND}" ARGS -E remove "temp.jar"
		COMMAND "${JAVA_CMD_ZIP}" ARGS -q "temp.jar" ${OTHER_RFILES} "META-INF/MANIFEST.MF"
		COMMAND "${CMAKE_COMMAND}" ARGS -E copy "temp.jar" "${jarnext}"
	)

	SET(jarprev "${jarnext}")
	SET(jarnext "${jarname}.2.jar")
	add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/${jarnext}"
		#VERBATIM - Don't use this as it breaks the *.class glob in the command
		DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/${jarprev}"
		WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/"
		COMMAND "${CMAKE_COMMAND}" ARGS -E copy "${jarprev}" "temp.jar"
		COMMAND "${JAVA_CMD_ZIP}" ARGS -q "temp.jar" *.class
		COMMAND "${CMAKE_COMMAND}" ARGS -E copy "temp.jar" "${jarnext}"
	)
	
	SET(RUN_PROGUARD FALSE)
	SET(PROGUARD_ARGS_OBFUSCATE)
	SET(PROGUARD_ARGS_VERIFY)
	IF (AJJ_VERIFY AND JAVA_CMD_PROGUARD)
		SET(RUN_PROGUARD TRUE)
		SET(AJJ_VERIFY FALSE)
		SET(PROGUARD_ARGS_VERIFY -microedition)
		SET(PROGUARD_ARGS_OBFUSCATE -dontshrink -dontoptimize -dontobfuscate)
	ENDIF()
	IF (AJJ_OBFUSCATE)
		SET(RUN_PROGUARD TRUE)
		SET(PROGUARD_ARGS_OBFUSCATE -keep "public class ${AJJ_MAINCLASS}" -optimizationpasses 3 -allowaccessmodification -mergeinterfacesaggressively -overloadaggressively)
	ENDIF()

	IF(RUN_PROGUARD)
		SET(jarprev "${jarnext}")
		SET(jarnext "${jarname}.proguard.jar")

		add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/${jarnext}"
			VERBATIM
			DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/${jarprev}"
			WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/"
			COMMAND "${JAVA_CMD_PROGUARD}" ARGS ${JAVA_CMD_PROGUARD_OPTPREFIX}
				-injars "${jarprev}" -outjars "${jarnext}" ${JAVA_CLASSPATHV}
				${PROGUARD_ARGS_VERIFY}
				${PROGUARD_ARGS_OBFUSCATE}
		)
	ENDIF()

	IF(AJJ_VERIFY)
		SET(jarprev "${jarnext}")
		SET(jarnext "${jarname}.verify.jar")

		add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/${jarnext}"
			VERBATIM
			DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/${jarprev}"
			WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/"
			COMMAND "${CMAKE_COMMAND}" ARGS -E copy "${jarprev}" "temp.jar"
			COMMAND "${JAVA_CMD_PREVERIFY}" ARGS -d . -target CLDC1.1 -classpath ${JAVA_CLASSPATHW} temp.jar
			COMMAND "${CMAKE_COMMAND}" ARGS -E copy "temp.jar" "${jarnext}"
		)
	ENDIF()

	IF (AJJ_ZIPOPTIMIZE)
		SET(jarprev "${jarnext}")
		SET(jarnext "${jarname}.zipopt.jar")

		add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/${jarnext}"
			VERBATIM
			DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/${jarprev}"
			WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/"
			COMMAND "${JAVA_CMD_ZIPOPT}" ARGS "${jarprev}" "${jarnext}"
		)
	ENDIF()

	IF (AJJ_SIGN)
	ENDIF()

	add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar"
		DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/${jarnext}"
		COMMAND "${CMAKE_COMMAND}" ARGS -E copy "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar-dir/${jarnext}" "${CMAKE_CURRENT_BINARY_DIR}/${jarname}.jar"
	)
ENDMACRO()
