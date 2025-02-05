{$IFDEF FPC}
  {$IFDEF FPC_DELPHI_MODE}
    {$MODE delphi}
  {$ELSE FPC_DELPHI_MODE}
    {$MODE objfpc}
  {$ENDIF FPC_DELPHI_MODE}

  {$MODESWITCH AdvancedRecords}
  {$MODESWITCH NestedProcVars}
  {$MODESWITCH NESTEDCOMMENTS}
  {$NOTES OFF}
  {$STACKFRAMES OFF}
  {$COPERATORS OFF}
  {$GOTO ON}
  {$INLINE ON}
  {$MACRO ON}
  {$HINTS ON}
  {$IEEEERRORS OFF}

  {$DEFINE LITTLE_ENDIAN}
  {$UNDEF BIG_ENDIAN}
  {$IFDEF FPC_BIG_ENDIAN}
    {$UNDEF LITTLE_ENDIAN}
    {$DEFINE BIG_ENDIAN}
  {$ENDIF}

  {$UNDEF FirstCharInZero}

  {$UNDEF Delphi}

  // nativeint as int or int64 type variable when Modifier is overload
  {$UNDEF OVERLOAD_NATIVEINT}

  // fast MD5 only delphi supported, https://github.com/PassByYou888/FastMD5
  {$UNDEF FastMD5}

  // stream is MemoryStream64 or MemoryStream, usage fastMD5 or PurePascal MD5
  // be associate api: UnicodeMixedLib.umlStreamMD5, Fast_MD5.FastMD5
  {$DEFINE OptimizationMemoryStreamMD5}

  // multi thread Parallel switch.
  {$IFDEF CPUARM}
    {$UNDEF Parallel}
  {$ELSE CPUARM}
    {$DEFINE Parallel}
  {$ENDIF CPUARM}

  // Parallel for fold make better use CPU of multi core
  // if rem this "FoldParallel" parallel for block program, thread can use linear address
  {$DEFINE FoldParallel}

  // MT19937 of seed in the startup TCompute is 0
  {$DEFINE MT19937SeedOnTComputeThreadIs0}

  // automated loading common AI datasets on boot-time
  {$DEFINE Z_AI_Dataset_Build_In}

  // With SMALL_RASTER_FONT_Build_In and LARGE_RASTER_FONT_Build_In, boot-time memory usage increase by 100M-200M and start-up time to be delay 100ms
  {$DEFINE SMALL_RASTER_FONT_Build_In}
  // {$DEFINE LARGE_RASTER_FONT_Build_In}

  // ZDB_BACKUP is automatically made and replica caching is enabled.
  // usage ZDB_BACKUP so slows the open of large size ZDB file, after time, but does is high performance.
  // {$DEFINE ZDB_BACKUP}

  // ZDB Flush() uses physical IO as the temp storage device
  // {$DEFINE ZDB_PHYSICAL_FLUSH}

  // used Critical Simulate Atomic with TMonitor.Enter(obj) and TMonitor.Exit(obj)
  // CriticalSimulateAtomic defined so performance to be reduced
  {$DEFINE CriticalSimulateAtomic}

  // used soft Simulate Critical(ring)
  // SoftCritical defined so performance to be reduced
  // {$DEFINE SoftCritical}
  // {$DEFINE ANTI_DEAD_ATOMIC_LOCK}

  {$UNDEF debug}
  {$DEFINE release}
  {$DEFINE INLINE_ASM}
  {$R-}
  {$I-}
  {$S-}
{$ELSE FPC} { IF DELPHI }
  {$DEFINE Delphi}

  {$DEFINE LITTLE_ENDIAN}
  {$UNDEF BIG_ENDIAN}

  {$IFDEF ANDROID}
    {$DEFINE FirstCharInZero}
  {$ENDIF ANDROID}

  {$IFDEF IOS}
    {$DEFINE FirstCharInZero}
  {$ENDIF IOS}

  // nativeint as int or int64 type variable when Modifier is overload
  {$DEFINE OVERLOAD_NATIVEINT}

  // fast MD5 only delphi supported, https://github.com/PassByYou888/FastMD5
  {$DEFINE FastMD5}

  // stream is MemoryStream64 or MemoryStream, usage fastMD5 or PurePascal MD5
  // be associate api: UnicodeMixedLib.umlStreamMD5, Fast_MD5.FastMD5
  {$DEFINE OptimizationMemoryStreamMD5}

  // multi thread Parallel switch.
  {$IFDEF CPUARM}
    {$UNDEF Parallel}
  {$ELSE CPUARM}
    {$DEFINE Parallel}
  {$ENDIF CPUARM}

  // Parallel for fold make better use CPU of multi core
  // if rem this "FoldParallel" is parallel for block program, thread can use linear address
  {$DEFINE FoldParallel}

  // Parallel programs use the delphi default TParallel
  // {$DEFINE SystemParallel}

  // paper: Mersenne Twister: A 623-dimensionallyequidistributed uniformpseudorandom number generator
  // Using this paper replace of Delphi Random() and Randomize() function, work on xe 10.3 or laster
  {$UNDEF InstallMT19937CoreToDelphi}

  // delphi 10.3
  {$IFDEF VER330}
    {$DEFINE InstallMT19937CoreToDelphi}
  {$ENDIF VER330}

  // delphi 10.4
  {$IFDEF VER340}
    {$DEFINE InstallMT19937CoreToDelphi}
    {$UNDEF FirstCharInZero}
  {$ENDIF VER340}

  // delphi 11.0
  {$IFDEF VER350}
    {$DEFINE InstallMT19937CoreToDelphi}
    {$UNDEF FirstCharInZero}
  {$ENDIF VER350}

  // delphi 11.x
  {$IFDEF VER360}
    {$DEFINE InstallMT19937CoreToDelphi}
    {$UNDEF FirstCharInZero}
  {$ENDIF VER360}

  // MT19937 of seed in the startup TCompute is 0
  {$DEFINE MT19937SeedOnTComputeThreadIs0}

  // automated loading common AI datasets on boot-time
  // {$DEFINE Z_AI_Dataset_Build_In}

  // With SMALL_RASTER_FONT_Build_In and LARGE_RASTER_FONT_Build_In, boot-time memory usage increase by 100M-200M and start-up time to be delay 100ms
  // {$DEFINE SMALL_RASTER_FONT_Build_In}
  // {$DEFINE LARGE_RASTER_FONT_Build_In}

  {$IF Defined(Android) or Defined(IOS)}
    {$DEFINE SMALL_RASTER_FONT_Build_In}
  {$ENDIF}

  // ZDB_BACKUP is automatically made and replica caching is enabled.
  // usage ZDB_BACKUP so slows the open of large size ZDB file, after time, but does is high performance.
  // {$DEFINE ZDB_BACKUP}

  // ZDB Flush() uses physical IO as the temp storage device
  // {$DEFINE ZDB_PHYSICAL_FLUSH}

  // used Critical Simulate Atomic with TMonitor.Enter(obj) and TMonitor.Exit(obj)
  // CriticalSimulateAtomic defined so performance to be reduced
  // {$DEFINE CriticalSimulateAtomic}

  // used soft Simulate Critical(ring)
  // SoftCritical defined so performance to be reduced
  // {$DEFINE SoftCritical}
  // {$DEFINE ANTI_DEAD_ATOMIC_LOCK}

  {$IFDEF release}
    {$DEFINE INLINE_ASM}
    {$R-} { range check }
    {$I-} { Input output checking }
    {$IF Defined(Android) or Defined(IOS)}
      {$O-} { close optimization }
    {$ELSE}
      {$O+} { open optimization }
      {$INLINE AUTO} { inline }
    {$IFEND}
  {$ELSE}
    {$UNDEF INLINE_ASM}
    {$O-} { close optimization }
    {$R-} { range check }
    {$I+} { Input output checking }
    {$D+} { debug information }
  {$ENDIF}

  {$IF Defined(Android)}
    {$DEFINE SMALL_RASTER_FONT_Build_In}
    {$DEFINE PhysicsIO_On_CrossSocket}
    // {$DEFINE PhysicsIO_On_Indy}
  {$ELSEIF Defined(IOS)}
    {$DEFINE SMALL_RASTER_FONT_Build_In}
    {$DEFINE PhysicsIO_On_Indy}
  {$ELSE}
    // PhysicsIO interface
    // {$DEFINE PhysicsIO_On_ICS}
    {$DEFINE PhysicsIO_On_CrossSocket}
    // {$DEFINE PhysicsIO_On_DIOCP}
    // {$DEFINE PhysicsIO_On_Indy}
    // {$DEFINE PhysicsIO_On_Synapse}
  {$IFEND}

  {$X+} { Extended syntax }
  {$Z1} { Minimum enum size }
{$ENDIF FPC}

// Using fillchar replace of FillPtr
// Maybe fillchar works on MMX / SSE2,
// {$Define FillPtr_Used_FillChar}

// Using Move replace of CopyPtr
// {$Define CopyPtr_Used_Move}

// Sequence packets default are opened in Physics-IO
// Sequence package can support multi platform keep-alive mode
// building a network CS system, the symmetry of compiler(FPC/Delphi) "UsedSequencePacket"
{$DEFINE UsedSequencePacket}

// Sequence package can support multi platform keep-alive mode
// building a network CS system, the symmetry of compiler(FPC/Delphi) "UsedSequencePacketOnP2PVM"
// Sequence packets default are closed in P2PVM-IO
{$UNDEF UsedSequencePacketOnP2PVM}

// CommunicationFramework used QuietMode
{$UNDEF Communication_QuietMode}

{$IFDEF DEBUG}
  // initialization status prompt
  {$DEFINE initializationStatus}
  // warning prompt
  {$WARNINGS ON}
  // JPEG support can output debug info
  {$UNDEF JPEG_Debug}
{$ELSE DEBUG}
  // initialization status prompt
  {$UNDEF initializationStatus}
  // warning prompt
  {$IFDEF FPC}
    {$WARNINGS ON}
  {$ELSE FPC}
    {$WARNINGS OFF}
  {$ENDIF FPC}
  // JPEG support can output debug info
  {$UNDEF JPEG_Debug}
{$ENDIF DEBUG}

{$IFDEF Parallel}
  // TMemoryRaster Parallel switch.
  {$UNDEF MemoryRaster_Parallel}
  // TRasterVertex Parallel switch.
  {$UNDEF Vertex_Parallel}
  // TMorphomatics Parallel switch.
  {$DEFINE Morphomatics_Parallel}
  // TMorphologyBinaryzation Parallel switch.
  {$DEFINE MorphologyBinaryzation_Parallel}
{$ENDIF Parallel}

{$HINTS OFF}
{$C+} { Assertions }
{$M-} { Run-Time Type Information }
{$H+} { long string }
{$A+} { Word Align Data }
{$Q-} { Overflow checking }
{$B-} { Complete boolean evaluation }
{$J-} { Writeable typed constants }

(*
  Pointer math is simply treating any given typed pointer in some narrow,
  instances as a scaled ordinal where you can perform simple arithmetic operations directly on the pointer variable.
*)
{$POINTERMATH OFF}

{$UNDEF CPU64}

{$IFDEF CPU64BITS}
  {$DEFINE CPU64}
{$ELSE CPU64BITS}
  {$IFDEF CPUX64}
    {$DEFINE CPU64}
  {$ENDIF CPUX64}
{$ENDIF CPU64BITS}

{$IFNDEF CPU64}
  {$DEFINE CPU32}
{$ENDIF CPU64}

{$IFDEF BIG_ENDIAN}
  {$MESSAGE FATAL 'Big-endian system not supported'}
{$ENDIF BIG_ENDIAN}

{$IFOPT R+}
  {$DEFINE RangeCheck}
{$ENDIF}

{$IFOPT Q+}
  {$DEFINE OverflowCheck}
{$ENDIF}

