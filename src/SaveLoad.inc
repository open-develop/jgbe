#ifndef SAVELOAD_INC
#define SAVELOAD_INC

import java.io.*;

#define SL_MAGIX            (0x4a374a53)      // Incorrect spelling of 'JGBS', spells 'J7JS'
#define SL_SAVE_VERSION     (23)              // version we save, change when changing savestate format
#define SL_LOAD_MIN_VERSION (0)               // oldest version we can handle
#define SL_LOAD_MAX_VERSION (SL_SAVE_VERSION) // newest version we can handle, normally the same as what we save

#define SL_GUI_SWING_MAGIX (0x53475549)                            // JGBS = <S>wing <G><U><I> in ascii hex
#define SL_GUI_SWING_SAVE_VERSION (0)                              // version we save, change when changing savestate format
#define SL_GUI_SWING_LOAD_MIN_VERSION (0)                          // oldest version we can handle
#define SL_GUI_SWING_LOAD_MAX_VERSION (SL_SAVE_VERSION_GUI_SWING)  // newest version we can handle, normally the same as what we save

#define SL_LOAD_COMPRESS_VERSION 5 // first version to use compression

#define SAVELOAD_FUNCTION \
	protected void stateSaveLoad(boolean save, int version, DataOutputStream dostream, DataInputStream distream) throws IOException

#define SL_SAVE (save)
#define SL_LOAD (!save)


#define SL_UINT8(var) {\
	if (SL_SAVE) \
		dostream.writeByte((var)&0xff); \
	else \
		var = distream.readUnsignedByte(); \
}

#define SL_UINT8B(var) {\
	if (SL_SAVE) \
		dostream.writeByte(B2I((var)&0xff)); \
	else \
		var = I2B(distream.readUnsignedByte()); \
}

#define SL_UINT16(var) {\
	if (SL_SAVE) \
		dostream.writeShort((var)&0xffff); \
	else \
		var = distream.readUnsignedShort(); \
}

#define SL_INT SL_INT32
#define SL_INT32(var) {\
	if (SL_SAVE) \
		dostream.writeInt((int)var); \
	else \
		var = distream.readInt(); \
}

#define SL_LONG SL_INT64
#define SL_INT64(var) {\
	if (SL_SAVE) \
		dostream.writeLong(var); \
	else \
		var = distream.readLong(); \
}

#define SL_BOOL(var) {\
	if (SL_SAVE) \
		dostream.writeBoolean(var); \
	else \
		var = distream.readBoolean(); \
}

#define SL_STRING(var) {\
	if (SL_SAVE) \
		dostream.writeUTF(var); \
	else \
		var = distream.readUTF(); \
}

#define SL_ARR(type, var, len) {\
	for (int sl_i = 0; sl_i < (len); ++sl_i) \
		SL_ ## type (var[sl_i]); \
}

#define SL_ARR_2D(type, var, len1, len2) {\
	for (int sl_i = 0; sl_i < (len1); ++sl_i) \
		for (int sl_j = 0; sl_j < (len2); ++sl_j) \
			SL_ ## type (var[sl_i][sl_j]); \
}

#define SL_ARR_3D(type, var, len1, len2, len3) {\
	for (int sl_i = 0; sl_i < (len1); ++sl_i) \
		for (int sl_j = 0; sl_j < (len2); ++sl_j) \
			for (int sl_k = 0; sl_k < (len3); ++sl_k) \
				SL_ ## type (var[sl_i][sl_j][sl_k]); \
}

#define SL_IF_VERSION(min, max) \
	if ( ((min == -1) || (min <= version)) && ((max == -1) || (version <= max)) )

#define SL_SKIP(type, len) { \
	int tempskip = 0; \
	for (int sl_i = 0; sl_i < (len); ++sl_i) \
		SL_ ## type (tempskip); \
}

#define SL_OBJ(obj) \
	(obj).stateSaveLoad(save, version, dostream, distream);

#define SL_TYPE_BOOL boolean
#define SL_TYPE_INIT_BOOL false
#define SL_TYPE_INT  int
#define SL_TYPE_INIT_INT 0

#define SL_GETSET(type, var, getter, setter) {\
	if (SL_SAVE) { \
		SL_TYPE_ ## type sl_v = var.getter(); \
		SL_ ## type (sl_v); \
	} else { \
		SL_TYPE_ ## type sl_v = SL_TYPE_INIT_ ## type; \
		SL_ ## type (sl_v); \
		var.setter(sl_v); \
	} \
}

#endif//SAVELOAD_INC
