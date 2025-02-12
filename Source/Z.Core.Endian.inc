{$IFDEF OverflowCheck}{$Q-}{$ENDIF}
{$IFDEF RangeCheck}{$R-}{$ENDIF}


function ROL8(const Value: Byte; Shift: Byte): Byte;
begin
  Shift := Shift and $07;
  Result := Byte((Value shl Shift) or (Value shr (8 - Shift)));
end;

function ROL16(const Value: Word; Shift: Byte): Word;
begin
  Shift := Shift and $0F;
  Result := Word((Value shl Shift) or (Value shr (16 - Shift)));
end;

function ROL32(const Value: Cardinal; Shift: Byte): Cardinal;
begin
  Shift := Shift and $1F;
  Result := Cardinal((Value shl Shift) or (Value shr (32 - Shift)));
end;

function ROL64(const Value: UInt64; Shift: Byte): UInt64;
begin
  Shift := Shift and $3F;
  Result := UInt64((Value shl Shift) or (Value shr (64 - Shift)));
end;

function ROR8(const Value: Byte; Shift: Byte): Byte;
begin
  Shift := Shift and $07;
  Result := UInt8((Value shr Shift) or (Value shl (8 - Shift)));
end;

function ROR16(const Value: Word; Shift: Byte): Word;
begin
  Shift := Shift and $0F;
  Result := Word((Value shr Shift) or (Value shl (16 - Shift)));
end;

function ROR32(const Value: Cardinal; Shift: Byte): Cardinal;
begin
  Shift := Shift and $1F;
  Result := Cardinal((Value shr Shift) or (Value shl (32 - Shift)));
end;

function ROR64(const Value: UInt64; Shift: Byte): UInt64;
begin
  Shift := Shift and $3F;
  Result := UInt64((Value shr Shift) or (Value shl (64 - Shift)));
end;

function Endian(const Value: SmallInt): SmallInt;
begin
  { the extra Word type cast is necessary because the "Value shr 8" }
  { is turned into "Integer(Value) shr 8", so if Value < 0 then }
  { the sign bits from the upper 16 bits are shifted in rather than }
  { zeroes. }
  Result := SmallInt((Word(Value) shr 8) or (Word(Value) shl 8));
end;

function Endian(const Value: Word): Word;
begin
  Result := Word((Value shr 8) or (Value shl 8));
end;

function Endian(const Value: Integer): Integer;
begin
  Result := ((Cardinal(Value) shl 8) and $FF00FF00) or ((Cardinal(Value) shr 8) and $00FF00FF);
  Result := (Cardinal(Result) shl 16) or (Cardinal(Result) shr 16);
end;

function Endian(const Value: Cardinal): Cardinal;
begin
  Result := ((Value shl 8) and $FF00FF00) or ((Value shr 8) and $00FF00FF);
  Result := (Result shl 16) or (Result shr 16);
end;

function Endian(const Value: Int64): Int64;
begin
  Result := ((UInt64(Value) shl 8) and $FF00FF00FF00FF00) or ((UInt64(Value) shr 8) and $00FF00FF00FF00FF);
  Result := ((UInt64(Result) shl 16) and $FFFF0000FFFF0000) or ((UInt64(Result) shr 16) and $0000FFFF0000FFFF);
  Result := (UInt64(Result) shl 32) or ((UInt64(Result) shr 32));
end;

function Endian(const Value: UInt64): UInt64;
begin
  Result := ((Value shl 8) and $FF00FF00FF00FF00) or ((Value shr 8) and $00FF00FF00FF00FF);
  Result := ((Result shl 16) and $FFFF0000FFFF0000) or ((Result shr 16) and $0000FFFF0000FFFF);
  Result := (Result shl 32) or ((Result shr 32));
end;

function BE2N(const Value: SmallInt): SmallInt;
begin
{$IFDEF BIG_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

function BE2N(const Value: Word): Word;
begin
{$IFDEF BIG_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

function BE2N(const Value: Integer): Integer;
begin
{$IFDEF BIG_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

function BE2N(const Value: Cardinal): Cardinal;
begin
{$IFDEF BIG_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

function BE2N(const Value: Int64): Int64;
begin
{$IFDEF BIG_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

function BE2N(const Value: UInt64): UInt64;
begin
{$IFDEF BIG_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

function LE2N(const Value: SmallInt): SmallInt;
begin
{$IFDEF LITTLE_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

function LE2N(const Value: Word): Word;
begin
{$IFDEF LITTLE_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

function LE2N(const Value: Integer): Integer;
begin
{$IFDEF LITTLE_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

function LE2N(const Value: Cardinal): Cardinal;
begin
{$IFDEF LITTLE_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

function LE2N(const Value: Int64): Int64;
begin
{$IFDEF LITTLE_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

function LE2N(const Value: UInt64): UInt64;
begin
{$IFDEF LITTLE_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

function N2BE(const Value: SmallInt): SmallInt;
begin
{$IFDEF BIG_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

function N2BE(const Value: Word): Word;
begin
{$IFDEF BIG_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

function N2BE(const Value: Integer): Integer;
begin
{$IFDEF BIG_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

function N2BE(const Value: Cardinal): Cardinal;
begin
{$IFDEF BIG_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

function N2BE(const Value: Int64): Int64;
begin
{$IFDEF BIG_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

function N2BE(const Value: UInt64): UInt64;
begin
{$IFDEF BIG_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

function N2LE(const Value: SmallInt): SmallInt;
begin
{$IFDEF LITTLE_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

function N2LE(const Value: Word): Word;
begin
{$IFDEF LITTLE_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

function N2LE(const Value: Integer): Integer;
begin
{$IFDEF LITTLE_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

function N2LE(const Value: Cardinal): Cardinal;
begin
{$IFDEF LITTLE_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

function N2LE(const Value: Int64): Int64;
begin
{$IFDEF LITTLE_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

function N2LE(const Value: UInt64): UInt64;
begin
{$IFDEF LITTLE_ENDIAN}
  Result := Value;
{$ELSE}
  Result := Endian(Value);
{$ENDIF}
end;

procedure Swap(var v1, v2: Byte);
var
  v: Byte;
begin
  v := v1;
  v1 := v2;
  v2 := v;
end;

procedure Swap(var v1, v2: Word);
var
  v: Word;
begin
  v := v1;
  v1 := v2;
  v2 := v;
end;

procedure Swap(var v1, v2: Integer);
var
  v: Integer;
begin
  v := v1;
  v1 := v2;
  v2 := v;
end;

procedure Swap(var v1, v2: Cardinal);
var
  v: Cardinal;
begin
  v := v1;
  v1 := v2;
  v2 := v;
end;

procedure Swap(var v1, v2: Int64);
var
  v: Int64;
begin
  v := v1;
  v1 := v2;
  v2 := v;
end;

procedure Swap(var v1, v2: UInt64);
var
  v: UInt64;
begin
  v := v1;
  v1 := v2;
  v2 := v;
end;

{$IFDEF OVERLOAD_NATIVEINT}


procedure Swap(var v1, v2: NativeInt);
var
  v: NativeInt;
begin
  v := v1;
  v1 := v2;
  v2 := v;
end;

procedure Swap(var v1, v2: NativeUInt);
var
  v: NativeUInt;
begin
  v := v1;
  v1 := v2;
  v2 := v;
end;
{$ENDIF OVERLOAD_NATIVEINT}


procedure Swap(var v1, v2: string);
var
  v: string;
begin
  v := v1;
  v1 := v2;
  v2 := v;
end;

procedure Swap(var v1, v2: Single);
var
  v: Single;
begin
  v := v1;
  v1 := v2;
  v2 := v;
end;

procedure Swap(var v1, v2: Double);
var
  v: Double;
begin
  v := v1;
  v1 := v2;
  v2 := v;
end;

procedure Swap(var v1, v2: Pointer);
var
  v: Pointer;
begin
  v := v1;
  v1 := v2;
  v2 := v;
end;

procedure SwapVariant(var v1, v2: Variant);
var
  v: Variant;
begin
  v := v1;
  v1 := v2;
  v2 := v;
end;

function Swap(const v: Word): Word;
begin
  Result := Endian(v);
end;

function Swap(const v: Cardinal): Cardinal;
begin
  Result := Endian(v);
end;

function Swap(const v: UInt64): UInt64;
begin
  Result := Endian(v);
end;

function SAR16(const Value: SmallInt; const Shift: Byte): SmallInt;
begin
  Result := SmallInt(
    Word(Word(Word(Value) shr (Shift and 15)) or
    (Word(SmallInt(Word(0 - Word(Word(Value) shr 15)) and Word(SmallInt(0 - (Ord((Shift and 15) <> 0)))))) shl (16 - (Shift and 15)))));
end;

function SAR32(const Value: Integer; Shift: Byte): Integer;
begin
  Result := Integer(
    Cardinal(Cardinal(Cardinal(Value) shr (Shift and 31)) or
    (Cardinal(Integer(Cardinal(0 - Cardinal(Cardinal(Value) shr 31)) and Cardinal(Integer(0 - (Ord((Shift and 31) <> 0)))))) shl (32 - (Shift and 31)))));
end;

function SAR64(const Value: Int64; Shift: Byte): Int64;
begin
  Result := Int64(
    UInt64(UInt64(UInt64(Value) shr (Shift and 63)) or
    (UInt64(Int64(UInt64(0 - UInt64(UInt64(Value) shr 63)) and UInt64(Int64(0 - (Ord((Shift and 63) <> 0)))))) shl (64 - (Shift and 63)))));
end;

function MemoryAlign(addr: Pointer; alignment_: NativeUInt): Pointer;
var
  tmp: NativeUInt;
begin
  tmp := NativeUInt(addr) + (alignment_ - 1);
  Result := Pointer(tmp - (tmp mod alignment_));
end;

{$IFDEF OverflowCheck}{$Q+}{$ENDIF}
{$IFDEF RangeCheck}{$R+}{$ENDIF}


function if_(const bool_: Boolean; const True_, False_: Boolean): Boolean;
begin
  if bool_ then
      Result := True_
  else
      Result := False_;
end;

function if_(const bool_: Boolean; const True_, False_: ShortInt): ShortInt;
begin
  if bool_ then
      Result := True_
  else
      Result := False_;
end;

function if_(const bool_: Boolean; const True_, False_: SmallInt): SmallInt;
begin
  if bool_ then
      Result := True_
  else
      Result := False_;
end;

function if_(const bool_: Boolean; const True_, False_: Integer): Integer;
begin
  if bool_ then
      Result := True_
  else
      Result := False_;
end;

function if_(const bool_: Boolean; const True_, False_: Int64): Int64;
begin
  if bool_ then
      Result := True_
  else
      Result := False_;
end;

function if_(const bool_: Boolean; const True_, False_: Byte): Byte;
begin
  if bool_ then
      Result := True_
  else
      Result := False_;
end;

function if_(const bool_: Boolean; const True_, False_: Word): Word;
begin
  if bool_ then
      Result := True_
  else
      Result := False_;
end;

function if_(const bool_: Boolean; const True_, False_: Cardinal): Cardinal;
begin
  if bool_ then
      Result := True_
  else
      Result := False_;
end;

function if_(const bool_: Boolean; const True_, False_: UInt64): UInt64;
begin
  if bool_ then
      Result := True_
  else
      Result := False_;
end;

function if_(const bool_: Boolean; const True_, False_: Single): Single;
begin
  if bool_ then
      Result := True_
  else
      Result := False_;
end;

function if_(const bool_: Boolean; const True_, False_: Double): Double;
begin
  if bool_ then
      Result := True_
  else
      Result := False_;
end;

function if_(const bool_: Boolean; const True_, False_: string): string;
begin
  if bool_ then
      Result := True_
  else
      Result := False_;
end;

function ifv_(const bool_: Boolean; const True_, False_: Variant): Variant;
begin
  if bool_ then
      Result := True_
  else
      Result := False_;
end;

function GetOffset(p_: Pointer; offset_: NativeInt): Pointer;
begin
  Result := Pointer(NativeUInt(p_) + offset_);
end;

function GetPtr(p_: Pointer; offset_: NativeInt): Pointer;
begin
  Result := Pointer(NativeUInt(p_) + offset_);
end;
