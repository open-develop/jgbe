SRCDIR   :=./src
DEPSDIR  :=./.deps
CLASSDIR :=./classes
JARDIR   :=./jar
BUILDDIR :=./build
ROMSRCDIR:=$(SRCDIR)/test-rom

JPPFILES     :=$(shell ls $(SRCDIR)/*.jpp)
GJAVAFILES   :=$(JPPFILES:.jpp=.java)
CLASSFILES   :=$(GJAVAFILES:$(SRCDIR)/%.java=$(CLASSDIR)/%.class)
ROM_ASMFILES :=$(shell ls $(ROMSRCDIR)/*.asm)
ROM_FILES    :=$(ROM_ASMFILES:$(ROMSRCDIR)/%.asm=$(BUILDDIR)/%.gb)
MAKEFILES :=Makefile Makefile.inc Makefile.config $(shell cat Makefile.inc 2> /dev/null | sed "s:-include ::")
BOOTROM   :=$(shell find -iname boot.rom | head -1)

VERSION  := $(shell sh generate-svnrev.sh "$(SRCDIR)")

NATIVEPATHSEPARATOR:=:
CYGPATH:=echo
PROGUARD:=$(shell which proguard 2> /dev/null)
ifeq ($(shell uname -o),Cygwin)
	NATIVEPATHSEPARATOR:=;
	CYGPATH:=cygpath -pws
endif

ifeq ($(CLASSPATH),)
	CLASSPATH:=.
endif

SRCPATH  :=$(SRCDIR)

JAVA_XCB_HACK := $(shell ls LIBXCB_ALLOW_SLOPPY_LOCK > /dev/null 2>&1 /dev/null && echo "LIBXCB_ALLOW_SLOPPY_LOCK=1")
AOSS:=$(shell which aoss 2> /dev/null)
JAVA_BIN := $(JAVA_XCB_HACK) $(AOSS) java

GB_ASM  := rgbasm
GB_LINK := xlink
GB_FIX  := rgbfix

-include Makefile.config
ifneq ($(EXTRACLASSPATH),)
	CLASSPATH:="$(CLASSPATH):$(EXTRACLASSPATH)"
endif
-include Makefile.inc

ifeq ($(P7Z),)
	P7Z:=$(shell which 7z 2> /dev/null || which 7za 2> /dev/null)
endif
ifeq ($(JARSIZEOPTIMIZER),)
	ifeq ($(P7Z),)
		JARSIZEOPTIMIZER:=cp
	endif
	ifneq ($(P7Z),)
		JARSIZEOPTIMIZER:=bash "$(shell pwd)/zipopt.bash" --7zip "$(P7Z)"
	endif
endif

# compiler choose targets
help:
	@echo '**********************************************'
	@echo Use one of the following to choose a compiler:
	@echo - make javac
	@echo - make jikes
	@echo - make gcj
	@echo Use the following to display this message:
	@echo - make help
	@echo '**********************************************'

javac: clean
	@echo "-include Makefile.javac" > Makefile.inc

jikes: clean
	@echo "-include Makefile.jikes" > Makefile.inc

gcj: clean
	@echo "-include Makefile.gcj" > Makefile.inc

# common targets

version:
	@[ "$(VERSION)" == "" ] || echo "$(VERSION)"

preprocess: version $(GJAVAFILES)

applet: $(JARDIR)/sjgbe.jar

$(JARDIR)/sjgbe.jar: $(JARDIR)/jgbe.jar
	@echo [signing] applet
	@keytool -delete -alias signFiles -keystore jgbestore -keypass kpi135 -storepass ab987c > /dev/null || true
	@keytool -genkey -alias signFiles -keystore jgbestore -keypass kpi135 -dname "cn=JGBE" -storepass ab987c
	@jarsigner -keystore jgbestore -storepass ab987c -keypass kpi135 -signedjar jar/sjgbe.jar jar/jgbe.jar signFiles > /dev/null

fun: all
	cd $(CLASSDIR) && $(JAVA_BIN) swinggui -lastcart

silence: all
	cd $(CLASSDIR) && $(JAVA_BIN) swinggui -lastcart -nosound

run: all
	cd $(CLASSDIR) && $(JAVA_BIN) swinggui -lastcart -debug

userrun: all
	cd $(CLASSDIR) && $(JAVA_BIN) swinggui

debug: all
	cd $(CLASSDIR) && $(JAVA_BIN) swinggui -lastcart -nosound -debug

debugserver: all
	cd $(CLASSDIR) && $(JAVA_BIN) DebugServer

remotedebug.%: all
	cd $(CLASSDIR) && $(JAVA_BIN) swinggui -lastcart -nosound -debug -log 'tcp://127.0.0.1' -rdo $*

debuglog: all
	cd $(CLASSDIR) && $(JAVA_BIN) swinggui -lastcart -nosound -debug -log statelog.txt

runlog: all
	cd $(CLASSDIR) && $(JAVA_BIN) swinggui -lastcart -nosound -log statelog.txt

oglfun: all
	cd $(CLASSDIR) && $(JAVA_BIN) -Dsun.java2d.opengl=True swinggui -lastcart

# get PerfAnal.jar at
# http://java.sun.com/developer/technicalArticles/Programming/perfanal/PerfAnal.jar
profile: all
	cd $(CLASSDIR) && $(JAVA_BIN) -agentlib:hprof=cpu=samples,depth=6,thread=y,interval=1 swinggui -lastcart -nosound
	$(JAVA_BIN) -jar PerfAnal.jar $(CLASSDIR)/java.hprof.txt

link: all
	cd $(CLASSDIR) && $(JAVA_BIN) swinggui -nosound

tester: all
	cd $(CLASSDIR) && $(JAVA_BIN) TestSuite ~/gbroms/Turtles\ 3.zip

rndCartridge: $(SRCDIR)/rndCartridge.cpp
	g++ -O3 $(SRCDIR)/rndCartridge.cpp -o rndCartridge

$(SRCDIR)/%.java: $(SRCDIR)/%.jpp
	@echo "[jpp  -> java ] $*"
	@cat $(SRCDIR)/Autogen.txt > $@
	@gcc -MD -MF $*.d -E $(PPFLAGS) -x c $< >> $@ || (rm -f $@ && false)
# remove comments (lines starting with #)
	@sed -i "s:^#.*$$::" $@
# split up cases to seperate lines
	@sed -i "s:\;[ 	]*case:\;\\n	case:g" $@
# replace ".o" with ".java"
	@sed -i "s=\.o:=\.java:=g" $*.d
# prepend $(SRCDIR)
	@sed -i "s=^[^:]*:=$(SRCDIR)/\0=" $*.d

# next line from http://make.paulandlesley.org/autodep.html
	@cp $*.d $*.dd; \
	  sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
	  -e '/^$$/ d' -e 's/$$/ :/' < $*.dd >> $*.d; \
	  rm -f $*.dd
	@mkdir -p $(DEPSDIR)
	@mv $*.d $(DEPSDIR)/

jarrun: $(JARDIR)/jgbe.jar
	cd $(JARDIR) && $(JAVA_BIN) -jar jgbe.jar -lastcart

$(JARDIR)/jgbe.jar: $(GJAVAFILES) $(CLASSFILES)
	@echo "[packing] jgbe.jar"
	@echo "Manifest-Version: 1.2" > $(CLASSDIR)/MANIFEST.MF.in
	@echo "Main-Class: swinggui" >> $(CLASSDIR)/MANIFEST.MF.in
	@cd $(CLASSDIR) && jar cmf MANIFEST.MF.in jgbe.jar *.class icon.gif jgbe_logo.png VeraMono.ttf $(BOOTROM)
	@mkdir -p $(JARDIR)
	@mv $(CLASSDIR)/jgbe.jar $(JARDIR)/jgbe.jar

jar: $(JARDIR)/jgbe.jar

jarzip: $(CLASSFILES)
	@echo "[packing] jgbe.jar (zip) - (Warning: needs 1.6 JVM)"
	@mkdir -p $(CLASSDIR)/META-INF
	@echo "Manifest-Version: 1.2\r\n" > $(CLASSDIR)/META-INF/MANIFEST.MF
	@echo "Created-By: 1.5.0_12 (Sun Microsystems Inc.)\r\n" >> $(CLASSDIR)/META-INF/MANIFEST.MF
	@echo "Main-Class: swinggui" >> $(CLASSDIR)/META-INF/MANIFEST.MF
	@echo "" >> $(CLASSDIR)/META-INF/MANIFEST.MF
	@cd $(CLASSDIR) && zip -r -9 jgbe.zip META-INF *.class icon.gif jgbe_logo.png VeraMono.ttf $(BOOTROM)
	@mkdir -p $(JARDIR)
	@mv $(CLASSDIR)/jgbe.zip $(JARDIR)/jgbe.jar


$(JARDIR)/%.jar: $(SRCDIR)/%.jar.info $(GJAVAFILES) $(CLASSFILES) proguard.conf
	@echo "[packing] $*.jar"
	@cp "$(shell cat $(SRCDIR)/$*.jar.info | grep "^manifest=" | sed "s:^[^=]*=::")" "$(CLASSDIR)/MANIFEST.MF.in"
	@cat "$(SRCDIR)/$*.jar.info" | grep  "^vfsjar=" | sed "s:^[^=]*=::" > $(CLASSDIR)/vfsjar.idx
	@cd $(CLASSDIR) && jar cmf MANIFEST.MF.in $*.jar $(shell cat "$(SRCDIR)/$*.jar.info" | grep  "^vfsjar=" | sed "s:^[^=]*=::") $(shell cat "$(SRCDIR)/$*.jar.info" | grep -v "^[a-z]*=") $(shell cd $(CLASSDIR) && ls *.class -s | grep -v "^ *0 " | sed "s: *[0-9]* ::" | sed 's:\$$:\\\$$:')

	@echo "[obfuscating] $*.jar"
	@$(PROGUARD) @proguard.conf $(EXTRAPROGUARDOPTIONS) -printusage -libraryjars '$(shell $(CYGPATH) "$(CLASSPATH)" | sed "s=\.[;:]==")' -injars $(CLASSDIR)/$*.jar -outjar $(CLASSDIR)/$*-obf.jar -keep public class "$(shell cat $(SRCDIR)/$*.jar.info | grep "^keep=" | sed "s:^[^=]*=::")"

	@echo "[minimizing] $*.jar"
	@cd $(CLASSDIR) && $(JARSIZEOPTIMIZER) $*-obf.jar $*-ps.jar

#	@echo "[signing] $*.jar"
#	@"$(KEYTOOL)" -delete -alias signFiles -keystore jgbekeystore -keypass kpi135 -storepass ab987c > /dev/null || true
#	@"$(KEYTOOL)" -genkey -alias signFiles -keystore jgbekeystore -keypass kpi135 -dname "cn=JGBE" -storepass ab987c
#	@"$(JARSIGNER)" -keystore jgbekeystore -storepass ab987c -keypass kpi135 -signedjar $(JARDIR)/$*.jar $(JARDIR)/$*-ps.jar signFiles > /dev/null
	@mv $(CLASSDIR)/$*-ps.jar $(JARDIR)/$*.jar


$(JARDIR)/%.jad: $(JARDIR)/%.jar $(SRCDIR)/%.jar.info
	@echo [creating] $*.jad
	@cp "$(shell cat "$(SRCDIR)/$*.jar.info" | grep "^manifest=" | sed "s:^[^=]*=::")" "$(JARDIR)/$*.jad"
	@stat "$(JARDIR)/$*.jar" -c "%s" | sed "s=^=MIDlet-Jar-Size: =" >> "$(JARDIR)/$*.jad"

jad: $(JARDIR)/jmgbe.jad

.PRECIOUS: $(JARDIR)/%.jar $(JARDIR)/%.jad

jademu: jmgbe.emu

%.emu: $(JARDIR)/%.jad $(JARDIR)/%.jar
	@echo "[emulating] $*"
	@cd $(JARDIR) && time $(J2MEEMULATOR) -Xheapsize:512K -Xdescriptor:./$*.jad -Xdomain:maximum -classpath "$*.jar$(NATIVEPATHSEPARATOR)$(CLASSPATH)"


# # # # # # # # # # #
#  T e s t   R o m  #
# # # # # # # # # # #

$(BUILDDIR)/%.o: $(ROMSRCDIR)/%.asm
	@echo "[assembling] $*"
	@mkdir -p $(BUILDDIR)
	@$(GB_ASM) -i$(ROMSRCDIR)/ -o$@ $< > $(BUILDDIR)/$*.o.out || (cat $(BUILDDIR)/$*.o.out ; false)
	@rm -f $(BUILDDIR)/$*.link

$(BUILDDIR)/%.link:
	@echo "# Linkfile for $*.gb" > $@
	@echo "[Objects]" >> $@
	@echo -ne "./build/$*.o\n" >> $@
	@echo "[Libraries]" >> $@
	@echo "[Output]" >> $@
	@echo "$(BUILDDIR)/$*.gb.in" >> $@

$(BUILDDIR)/%.gb.in: $(BUILDDIR)/%.o $(BUILDDIR)/%.link
	@echo "[linking   ] $*"
	@$(GB_LINK) -m$(BUILDDIR)/$*.map -tg $(BUILDDIR)/$*.link


$(BUILDDIR)/%.gb: $(BUILDDIR)/%.gb.in
	@echo "[validating] $*"
	@rm -f $(BUILDDIR)/$*.gb
	@cp $(BUILDDIR)/$*.gb.in $(BUILDDIR)/$*.gb
	@$(GB_FIX) -p -t`echo '$*' | tr '[:lower:]' '[:upper:]'` -v $(BUILDDIR)/$*.gb > /dev/null

roms: $(ROM_FILES)
	@echo "[done      ]"

# # # # # # # # # # #

clean:
	rm -f $(CLASSDIR)/*.class
	rm -f $(DEPSDIR)/*.d
	rm -f $(JARDIR)/jgbe.jar
	rm -f $(CLASSDIR)/jgbe.zip
	rm -f $(SRCDIR)/svnrev.inc
	rm -f $(GJAVAFILES)
	touch $(JPPFILES)

cleaner: clean
	rm -f $(CLASSDIR)/*.class
	rm -f $(DEPSDIR)/*
	rm -f $(GJAVAFILES)
	rm -f Makefile.inc

$(GJAVAFILES): Makefile.config
#$(CLASSFILES): $(MAKEFILES)
#$(CLASSFILES): $(GJAVAFILES)

-include $(JPPFILES:$(SRCDIR)/%.jpp=$(DEPSDIR)/%.d)
