// THUnitsDefine.h

#import <Cocoa/Cocoa.h>

//--------------------------------------------------------------------------------------------------------------------------------------------
#define TH_Kio (1024ULL)
#define TH_Mio (1024ULL*TH_Kio)
#define TH_Gio (1024ULL*TH_Mio)
#define TH_Tio (1024ULL*TH_Gio)

#define TH_Ko (1000ULL)
#define TH_Mo (1000ULL*TH_Ko)
#define TH_Go (1000ULL*TH_Mo)
#define TH_To (1000ULL*TH_Go)

#define TH_KB TH_Kio
#define TH_MB TH_Mio
#define TH_GB TH_Gio

#define TH_SEC 1.0
#define TH_MIN (60.0*TH_SEC)
#define TH_HOUR (60.0*TH_MIN)
#define TH_DAY (24.0*TH_HOUR)
//--------------------------------------------------------------------------------------------------------------------------------------------
