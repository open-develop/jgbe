cmake_minimum_required(VERSION 2.6)

PROJECT(JGBE)

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/")

SET(CUSTOM_JAVA_PATHS
	"/cygdrive/c/Program Files/Java/jdk1.6.0_11/jre/lib"
	"/cygdrive/d/Program Files/Java/jdk1.6.0_11/jre/lib"
	"/cygdrive/c/Program Files/Java/jre6/lib"
	"/cygdrive/d/Program Files/Java/jre6/lib"
	"/cygdrive/c/Program Files/Java/WTK25/lib/"
	"/cygdrive/d/Program Files/Java/WTK25/lib/"
	
	"/cygdrive/c/Program Files/Java/jdk1.6.0_11/bin"
	"/cygdrive/d/Program Files/Java/jdk1.6.0_11/bin"
	"/cygdrive/c/Program Files/Java/jdk1.6.0_11/jre/bin"
	"/cygdrive/d/Program Files/Java/jdk1.6.0_11/jre/bin"
	"/cygdrive/c/Program Files/Java/jre6/bin"
	"/cygdrive/d/Program Files/Java/jre6/bin"
	"/cygdrive/c/Program Files/Java/WTK25/bin/"
	"/cygdrive/d/Program Files/Java/WTK25/bin/"

	"${CMAKE_SOURCE_DIR}"
)
FIND_PACKAGE(CustomJava)

ADD_SUBDIRECTORY(src)
