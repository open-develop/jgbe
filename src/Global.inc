#ifndef GLOBAL_INC
#define GLOBAL_INC

//#define JGBE_VERSION 0.4.2
//#define JGBE_VERSION_STRING "0.4.2"

//#define USE_JAVA_MOBILE
//#define USE_JAVA_142
//#define ENABLE_RECOMPILER

#define LINK_CABLE_TCP_PORT 0x4321

#if JAVA_SOURCEVER_14
	#ifndef USE_JAVA_142
		#define USE_JAVA_142
	#endif
#endif
	
#ifdef USE_JAVA_MOBILE
	#ifndef USE_JAVA_142
		#error must use USE_JAVA_142
	#endif
#endif


#ifdef USE_JAVA_MOBILE
	#define BTYPE byte
	//#define B2I(val) ((val)+128)
	//#define I2B(val) ((byte)((val)-128))
	#define B2I(val) ((val)+128)
	#define I2B(val) ((byte)((val)-128))
#else
	#define BTYPE int
	#define B2I(val) (val)
	#define I2B(val) (val)
#endif

#define DEBUG

#define YIELD { \
	try { \
		Thread.sleep(100); /*100?*/ \
	} \
	catch (Exception e) { \
	} \
}

#ifdef NODEBUG
#ifdef DEBUG
#undef DEBUG
#endif
#endif

#define IF_STAT (1<<1)
#define IF_VBLANK (1<<0)

#ifdef DEBUG
	#define ASSERT(cond) \
		if (!(cond)) throw new Error("Assertion failed: " + #cond)
	// java way
	//#define ASSERT(cond) \
	//	assert (cond)
#else //DEBUG
	#define ASSERT(cond)
#endif //DEBUG

#define BUTTON_RIGHT  (1<<0)
#define BUTTON_LEFT   (1<<1)
#define BUTTON_UP     (1<<2)
#define BUTTON_DOWN   (1<<3)
#define BUTTON_A      (1<<4)
#define BUTTON_B      (1<<5)
#define BUTTON_SELECT (1<<6)
#define BUTTON_START  (1<<7)

#ifdef USE_JAVA_MOBILE
	#define PRINTFREEMEM(x)  { PRINTLN("in "+x+": Free Memory="+(Runtime.getRuntime().freeMemory()/1024) + "  used = "+((Runtime.getRuntime().totalMemory()-Runtime.getRuntime().freeMemory())/1024)); }
#else
	#define PRINTFREEMEM(x)
#endif

#ifdef USE_JAVA_142
	#define STRFORMAT(x, y...) Format142.strformat(x, new int[] { y })
	#define PRINTF(x, y...) Format142.strprintf(x, new int[] { y })
	#define VECTOR(t) ArrayList
	#define FOREACH_CAT_HELPER(x, y) x ## y
	#define FOREACH_CAT(a, b) FOREACH_CAT_HELPER(a,b)
	#define FOREACH(type, var, vec) \
		for (int FOREACH_CAT(foreach, __LINE__) = 0; FOREACH_CAT(foreach, __LINE__) < (vec).size(); ++ FOREACH_CAT(foreach, __LINE__) ) \
			for (type var = (type)((vec).get(FOREACH_CAT(foreach, __LINE__))); var != null; var = null)
#else
	#define STRFORMAT(x...) String.format(x)
	#define PRINTF(x...) System.out.printf(x)
	#define VECTOR(t) ArrayList<t>
	#define FOREACH(type, var, vec) \
		for (type var : vec)
#endif

#ifndef DEBUG
	#undef PRINTF
	#define PRINTF(x...) /*System.out.printf(x)*/
#endif

#ifdef DEBUG
	#define PRINTLN(x) System.out.println(x)
	#define PRINT(x) System.out.print(x)
#else
	#define PRINTLN(x)
	#define PRINT(x)
#endif

/* first one nearly 10% faster! (sometimes :-p)*/
#define MAX(a,b) ((a)<(b)?(b):(a))
//#define MAX(a,b) (Math.max((a), (b))

#define MIN(a,b) ((a)>(b)?(b):(a))
//#define MIN(a,b) (Math.min((a), (b))

#endif//GLOBAL_INC
