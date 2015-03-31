# Obtaining the source #

You can get the latest development sources from svn:

- svn checkout http://jgbe.googlecode.com/svn/trunk/ jgbe


Or you can download a source release from the following url:

todo.link.to.latest.source.release


# .jpp Files, wtf do i do with those? #

We decided to use the C preprocessor to enhance java and get macro-powers.

To generate the .java files from the .jpp files, you need gcc.

When compiling by using our Makefile, this is done automagically.

Our source releases also include the .java files so you can compile
those with your favourite java compiler without having to bother
with preprocessors.

# Makefile #

Targets:
  * jikes     - configures makefile to use jikes as compiler
  * javac     - configures makefile to use javac as compiler
  * gcj       - configures makefile to use gcj as compiler (currently broken)

Compiling with jikes should work under cygwin.

# Other info #

The main class is swinggui, so compile that if you use another compiler.