﻿{******************************************************************************}
{                                                                              }
{       Delphi cross platform socket library                                   }
{                                                                              }
{       Copyright (c) 2017 WiNDDRiVER(soulawing@gmail.com)                     }
{                                                                              }
{       Homepage: https://github.com/winddriver/Delphi-Cross-Socket            }
{                                                                              }
{******************************************************************************}
unit Z.Net.CrossSocket;

interface

uses
  Z.Net.CrossSocket.Base,
  {$IFDEF MSWINDOWS}
  Z.Net.CrossSocket.Iocp
  {$ELSEIF defined(MACOS) or defined(IOS)}
  Z.Net.CrossSocket.Kqueue
  {$ELSEIF defined(LINUX) or defined(ANDROID)}
  Z.Net.CrossSocket.Epoll
  {$ENDIF};

type
  TCrossListen =
    {$IFDEF MSWINDOWS}
    TIocpListen
    {$ELSEIF defined(MACOS) or defined(IOS)}
    TKqueueListen
    {$ELSEIF defined(LINUX) or defined(ANDROID)}
    TEpollListen
    {$ENDIF};

  TCrossConnection =
    {$IFDEF MSWINDOWS}
    TIocpConnection
    {$ELSEIF defined(MACOS) or defined(IOS)}
    TKqueueConnection
    {$ELSEIF defined(LINUX) or defined(ANDROID)}
    TEpollConnection
    {$ENDIF};

  TCrossSocket =
    {$IFDEF MSWINDOWS}
    TIocpCrossSocket
    {$ELSEIF defined(MACOS) or defined(IOS)}
    TKqueueCrossSocket
    {$ELSEIF defined(LINUX) or defined(ANDROID)}
    TEpollCrossSocket
    {$ENDIF};

implementation

end.
