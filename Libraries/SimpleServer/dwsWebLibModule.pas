{**********************************************************************}
{                                                                      }
{    "The contents of this file are subject to the Mozilla Public      }
{    License Version 1.1 (the "License"); you may not use this         }
{    file except in compliance with the License. You may obtain        }
{    a copy of the License at http://www.mozilla.org/MPL/              }
{                                                                      }
{    Software distributed under the License is distributed on an       }
{    "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express       }
{    or implied. See the License for the specific language             }
{    governing rights and limitations under the License.               }
{                                                                      }
{    Copyright Creative IT.                                            }
{    Current maintainer: Eric Grange                                   }
{                                                                      }
{**********************************************************************}
unit dwsWebLibModule;

interface

uses
   Windows, WinInet, Variants,
   SysUtils, Classes, StrUtils,
   dwsUtils, dwsComp, dwsExprs, dwsWebEnvironment, dwsExprList, dwsSymbols,
   SynZip, SynCrtSock, SynCommons;

type
  TdwsWebLib = class(TDataModule)
    dwsWeb: TdwsUnit;
    procedure dwsWebClassesWebRequestMethodsURLEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesWebRequestMethodsMethodEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesWebRequestMethodsPathInfoEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesWebRequestMethodsQueryStringEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesWebRequestMethodsRemoteIPEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesWebResponseMethodsContentDataEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesWebResponseMethodsContentTypeEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesWebResponseMethodsContentEncodingEval(
      Info: TProgramInfo; ExtObject: TObject);
    procedure dwsWebClassesWebRequestMethodsHeaderEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesWebRequestMethodsHeadersEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesWebRequestMethodsCookieEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesWebRequestMethodsCookiesEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesWebRequestMethodsQueryFieldEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesWebRequestMethodsQueryFieldsEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesWebResponseMethodsSetContentTextEval(
      Info: TProgramInfo; ExtObject: TObject);
    procedure dwsWebClassesWebRequestMethodsSecureEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesWebRequestMethodsUserAgentEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesWebRequestMethodsAuthenticatedUserEval(
      Info: TProgramInfo; ExtObject: TObject);
    procedure dwsWebClassesWebResponseMethodsSetStatusCodeEval(
      Info: TProgramInfo; ExtObject: TObject);
    procedure dwsWebClassesWebResponseMethodsSetHeaderEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesWebRequestMethodsAuthenticationEval(
      Info: TProgramInfo; ExtObject: TObject);
    procedure dwsWebClassesWebResponseMethodsRequestAuthenticationEval(
      Info: TProgramInfo; ExtObject: TObject);
    procedure dwsWebClassesWebRequestMethodsHasQueryFieldEval(
      Info: TProgramInfo; ExtObject: TObject);
    procedure dwsWebClassesWebResponseMethodsSetCookieEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesWebResponseMethodsSetCookie2Eval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesWebResponseMethodsSetCompressionEval(
      Info: TProgramInfo; ExtObject: TObject);
    procedure dwsWebClassesWebRequestMethodsContentTypeEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesWebRequestMethodsContentDataEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesWebRequestMethodsContentLengthEval(
      Info: TProgramInfo; ExtObject: TObject);
    function dwsWebFunctionsDeflateCompressFastEval(
      const args: TExprBaseListExec): Variant;
    function dwsWebFunctionsDeflateDecompressionFastEval(
      const args: TExprBaseListExec): Variant;
    procedure dwsWebClassesWebRequestMethodsGetContentFieldEval(
      Info: TProgramInfo; ExtObject: TObject);
    procedure dwsWebClassesWebRequestMethodsHasContentFieldEval(
      Info: TProgramInfo; ExtObject: TObject);
    procedure dwsWebClassesHttpQueryMethodsGetDataEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesHttpQueryMethodsGetTextEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesHttpQueryMethodsPostDataEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesWebRequestMethodsIfModifiedSinceEval(
      Info: TProgramInfo; ExtObject: TObject);
    procedure dwsWebClassesWebResponseMethodsSetLastModifiedEval(
      Info: TProgramInfo; ExtObject: TObject);
    procedure dwsWebClassesHttpQueryMethodsSetCredentialsEval(
      Info: TProgramInfo; ExtObject: TObject);
    procedure dwsWebClassesHttpQueryMethodsClearCredentialsEval(
      Info: TProgramInfo; ExtObject: TObject);
    procedure dwsWebClassesHttpQueryMethodsPutDataEval(Info: TProgramInfo;
      ExtObject: TObject);
    procedure dwsWebClassesHttpQueryMethodsDeleteEval(Info: TProgramInfo;
      ExtObject: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

type
   THttpQueryMethod = (hqmGET, hqmPOST, hqmPUT, hqmDELETE);

   TdwsWinHTTP = class (TWinHTTP)
      FAuthScheme : TWebRequestAuthentication;
      FUserName : String;
      FPassword : String;
      procedure InternalSendRequest(const aData: RawByteString); override;
   end;

function WinHttpSetCredentials(hRequest: HINTERNET;
   AuthTargets: DWORD; AuthScheme: DWORD;
   pwszUserName: PWideChar; pwszPassword: PWideChar;
   pAuthParams: Pointer) : BOOL; stdcall; external 'winhttp.dll';

const
   WINHTTP_AUTH_TARGET_SERVER    = 0;
   WINHTTP_AUTH_TARGET_PROXY     = 1;

   WINHTTP_AUTH_SCHEME_BASIC     = $00000001;
   WINHTTP_AUTH_SCHEME_NTLM      = $00000002;
   WINHTTP_AUTH_SCHEME_PASSPORT  = $00000004;
   WINHTTP_AUTH_SCHEME_DIGEST    = $00000008;
   WINHTTP_AUTH_SCHEME_NEGOTIATE = $00000010;

   cWinHttpCredentials : TGUID = '{FB60EB3D-1085-4A88-9923-DE895B5CAB76}';

// InternalSendRequest
//
procedure TdwsWinHTTP.InternalSendRequest(const aData: RawByteString);
var
   winAuth : DWORD;
begin
   if FAuthScheme<>wraNone then begin
      case FAuthScheme of
         wraBasic : winAuth := WINHTTP_AUTH_SCHEME_BASIC;
         wraDigest : winAuth := WINHTTP_AUTH_SCHEME_DIGEST;
         wraNegotiate : winAuth := WINHTTP_AUTH_SCHEME_NEGOTIATE;
      else
         raise EWinHTTP.CreateFmt('Unsupported request authentication scheme (%d)',
                                  [Ord(FAuthScheme)]);
      end;
      if not WinHttpSetCredentials(fRequest, WINHTTP_AUTH_TARGET_SERVER,
                                   winAuth, PChar(FUserName), PChar(FPassword), nil) then
         RaiseLastOSError;
   end;
   inherited InternalSendRequest(aData);
end;

function HttpQuery(method : THttpQueryMethod; const url : RawByteString;
                   const requestData : RawByteString;
                   const requestContentType : RawByteString;
                   var replyData : String; asText : Boolean;
                   const credentials : Variant) : Integer; overload;
const
   cContentType : RawUTF8 = 'Content-Type:';
var
   query : TdwsWinHTTP;
   uri : TURI;
   headers, buf, mimeType : RawByteString;
   p1, p2 : Integer;
begin
   if uri.From(url) then begin
      query:=TdwsWinHTTP.Create(uri.Server, uri.Port, uri.Https);
      try
         if VarIsArray(credentials, False) then begin
            query.FAuthScheme:=TWebRequestAuthentication(credentials[0]);
            query.FUserName:=credentials[1];
            query.FPassword:=credentials[2];
         end;
         case method of
            hqmGET : begin
               Assert(requestData='');
               Result:=query.Request(uri.Address, 'GET', 0, '', '', '', headers, buf);
            end;
            hqmPOST : begin
               Result:=query.Request(uri.Address, 'POST', 0, '', requestData, requestContentType, headers, buf);
            end;
            hqmPUT : begin
               Result:=query.Request(uri.Address, 'PUT', 0, '', requestData, requestContentType, headers, buf);
            end;
            hqmDELETE : begin
               Result:=query.Request(uri.Address, 'PUT', 0, '', '', '', headers, buf);
            end;
         else
            Result:=0;
            Assert(False);
         end;
         if asText then begin
            p1:=Pos(cContentType, RawUTF8(headers));
            if p1>0 then begin
               Inc(p1, Length(cContentType));
               p2:=PosEx(#13, headers, p1);
               if p2>p1 then
                  mimeType:=Copy(headers, p1, p2-p1);
            end;
            if StrIEndsWithA(mimeType, 'charset=utf-8') then
               replyData:=UTF8DecodeToUnicodeString(buf)
            else RawByteStringToScriptString(buf, replyData);
         end else RawByteStringToScriptString(buf, replyData);
      finally
         query.Free;
      end;
   end else Result:=0;
end;

function HttpQuery(method : THttpQueryMethod; const url : RawByteString;
                   var replyData : String; asText : Boolean;
                   const credentials : Variant) : Integer; overload;
begin
   Result:=HttpQuery(method, url, '', '', replyData, asText, credentials);
end;

procedure TdwsWebLib.dwsWebClassesHttpQueryMethodsDeleteEval(Info: TProgramInfo;
  ExtObject: TObject);
var
   buf : String;
begin
   Info.ResultAsInteger:=HttpQuery(hqmDELETE, Info.ParamAsDataString[0], buf, False,
                                   Info.Execution.CustomStates[cWinHttpCredentials]);
end;

procedure TdwsWebLib.dwsWebClassesHttpQueryMethodsGetDataEval(
  Info: TProgramInfo; ExtObject: TObject);
var
   buf : String;
begin
   Info.ResultAsInteger:=HttpQuery(hqmGET, Info.ParamAsDataString[0], buf, False,
                                   Info.Execution.CustomStates[cWinHttpCredentials]);
   Info.ParamAsString[1]:=buf;
end;

procedure TdwsWebLib.dwsWebClassesHttpQueryMethodsGetTextEval(
  Info: TProgramInfo; ExtObject: TObject);
var
   buf : String;
begin
   Info.ResultAsInteger:=HttpQuery(hqmGET, Info.ParamAsDataString[0], buf, True,
                                   Info.Execution.CustomStates[cWinHttpCredentials]);
   Info.ParamAsString[1]:=buf;
end;

procedure TdwsWebLib.dwsWebClassesHttpQueryMethodsPostDataEval(
  Info: TProgramInfo; ExtObject: TObject);
var
   buf : String;
begin
   Info.ResultAsInteger:=HttpQuery(
      hqmPOST, Info.ParamAsDataString[0],
      Info.ParamAsDataString[1], Info.ParamAsDataString[2], buf, False,
      Info.Execution.CustomStates[cWinHttpCredentials]);
   Info.ParamAsString[3]:=buf;
end;

procedure TdwsWebLib.dwsWebClassesHttpQueryMethodsPutDataEval(
  Info: TProgramInfo; ExtObject: TObject);
var
   buf : String;
begin
   Info.ResultAsInteger:=HttpQuery(
      hqmPUT, Info.ParamAsDataString[0],
      Info.ParamAsDataString[1], Info.ParamAsDataString[2], buf, False,
      Info.Execution.CustomStates[cWinHttpCredentials]);
end;

procedure TdwsWebLib.dwsWebClassesHttpQueryMethodsSetCredentialsEval(
  Info: TProgramInfo; ExtObject: TObject);
var
   v : Variant;
begin
   v:=VarArrayCreate([0, 2], varVariant);
   v[0]:=Info.ParamAsInteger[0];
   v[1]:=Info.ParamAsString[1];
   v[2]:=Info.ParamAsString[2];
   Info.Execution.CustomStates[cWinHttpCredentials]:=v;
end;

procedure TdwsWebLib.dwsWebClassesHttpQueryMethodsClearCredentialsEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.Execution.CustomStates[cWinHttpCredentials]:=Unassigned;
end;

procedure TdwsWebLib.dwsWebClassesWebRequestMethodsAuthenticatedUserEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.ResultAsString:=Info.WebRequest.AuthenticatedUser;
end;

procedure TdwsWebLib.dwsWebClassesWebRequestMethodsAuthenticationEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.ResultAsInteger:=Ord(Info.WebRequest.Authentication);
end;

procedure TdwsWebLib.dwsWebClassesWebRequestMethodsContentDataEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.ResultAsDataString:=Info.WebRequest.ContentData;
end;

procedure TdwsWebLib.dwsWebClassesWebRequestMethodsContentLengthEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.ResultAsInteger:=Length(Info.WebRequest.ContentData);
end;

procedure TdwsWebLib.dwsWebClassesWebRequestMethodsContentTypeEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.ResultAsDataString:=Info.WebRequest.ContentType;
end;

procedure TdwsWebLib.dwsWebClassesWebRequestMethodsCookieEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.ResultAsString:=Info.WebRequest.Cookies.Values[Info.ParamAsString[0]];
end;

procedure TdwsWebLib.dwsWebClassesWebRequestMethodsCookiesEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.ResultAsString:=Info.WebRequest.Cookies.Text;
end;

procedure TdwsWebLib.dwsWebClassesWebRequestMethodsGetContentFieldEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.ResultAsString:=Info.WebRequest.ContentFields.Values[Info.ParamAsString[0]];
end;

procedure TdwsWebLib.dwsWebClassesWebRequestMethodsHasContentFieldEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.ResultAsBoolean:=Info.WebRequest.HasContentField(Info.ParamAsString[0]);
end;

procedure TdwsWebLib.dwsWebClassesWebRequestMethodsHasQueryFieldEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.ResultAsBoolean:=Info.WebRequest.HasQueryField(Info.ParamAsString[0]);
end;

procedure TdwsWebLib.dwsWebClassesWebRequestMethodsHeaderEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.ResultAsString:=Info.WebRequest.Header(Info.ParamAsString[0]);
end;

procedure TdwsWebLib.dwsWebClassesWebRequestMethodsHeadersEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.ResultAsString:=Info.WebRequest.Headers.Text;
end;

procedure TdwsWebLib.dwsWebClassesWebRequestMethodsIfModifiedSinceEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.ResultAsFloat:=Info.WebRequest.IfModifiedSince;
end;

procedure TdwsWebLib.dwsWebClassesWebRequestMethodsMethodEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.ResultAsString:=Info.WebRequest.Method;
end;

procedure TdwsWebLib.dwsWebClassesWebRequestMethodsPathInfoEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.ResultAsString:=Info.WebRequest.PathInfo;
end;

procedure TdwsWebLib.dwsWebClassesWebRequestMethodsQueryFieldEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.ResultAsString:=Info.WebRequest.QueryFields.Values[Info.ParamAsString[0]];
end;

procedure TdwsWebLib.dwsWebClassesWebRequestMethodsQueryFieldsEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.ResultAsString:=Info.WebRequest.QueryFields.Text;
end;

procedure TdwsWebLib.dwsWebClassesWebRequestMethodsQueryStringEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.ResultAsString:=Info.WebRequest.QueryString;
end;

procedure TdwsWebLib.dwsWebClassesWebRequestMethodsRemoteIPEval(
  Info: TProgramInfo; ExtObject: TObject);
var
   cloudflareIP : String;
begin
   cloudflareIP:=Info.WebRequest.Header('CF-Connecting-IP');
   if cloudflareIP<>'' then
      Info.ResultAsString:=cloudflareIP
   else Info.ResultAsString:=Info.WebRequest.RemoteIP;
end;

procedure TdwsWebLib.dwsWebClassesWebRequestMethodsSecureEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.ResultAsString:=Info.WebRequest.Security;
end;

procedure TdwsWebLib.dwsWebClassesWebRequestMethodsURLEval(Info: TProgramInfo;
  ExtObject: TObject);
begin
   Info.ResultAsString:=Info.WebRequest.URL;
end;

procedure TdwsWebLib.dwsWebClassesWebRequestMethodsUserAgentEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.ResultAsString:=Info.WebRequest.UserAgent;
end;

procedure TdwsWebLib.dwsWebClassesWebResponseMethodsContentDataEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.WebResponse.ContentData:=Info.ParamAsDataString[0];
end;

procedure TdwsWebLib.dwsWebClassesWebResponseMethodsContentEncodingEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.WebResponse.ContentEncoding:=Info.ParamAsDataString[0];
end;

procedure TdwsWebLib.dwsWebClassesWebResponseMethodsContentTypeEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.WebResponse.ContentType:=Info.ParamAsDataString[0];
end;

procedure TdwsWebLib.dwsWebClassesWebResponseMethodsRequestAuthenticationEval(
  Info: TProgramInfo; ExtObject: TObject);
var
   wra : TWebRequestAuthentication;
begin
   wra:=TWebRequestAuthentication(Info.ParamAsInteger[0]);
   Info.WebResponse.Headers.Values['WWW-Authenticate']:=cWebRequestAuthenticationToString[wra];
   Info.WebResponse.StatusCode:=401;
end;

procedure TdwsWebLib.dwsWebClassesWebResponseMethodsSetCompressionEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.WebResponse.Compression:=Info.ParamAsBoolean[0];
end;

procedure TdwsWebLib.dwsWebClassesWebResponseMethodsSetContentTextEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.WebResponse.ContentText[Info.ParamAsDataString[0]]:=Info.ParamAsString[1];
end;

procedure TdwsWebLib.dwsWebClassesWebResponseMethodsSetCookieEval(
  Info: TProgramInfo; ExtObject: TObject);
var
   cookie : TWebResponseCookie;
begin
   cookie:=Info.WebResponse.Cookies.AddCookie(Info.ParamAsString[0]);
   cookie.Value:=Info.ParamAsString[1];
   cookie.ExpiresGMT:=Info.ParamAsFloat[2];
end;

procedure TdwsWebLib.dwsWebClassesWebResponseMethodsSetCookie2Eval(
  Info: TProgramInfo; ExtObject: TObject);
var
   cookie : TWebResponseCookie;
begin
   cookie:=Info.WebResponse.Cookies.AddCookie(Info.ParamAsString[0]);
   cookie.Value:=Info.ParamAsString[1];
   cookie.ExpiresGMT:=Info.ParamAsFloat[2];
   cookie.Path:=Info.ParamAsString[3];
   cookie.Domain:=Info.ParamAsString[4];
   cookie.Flags:=Info.ParamAsInteger[5];
end;

procedure TdwsWebLib.dwsWebClassesWebResponseMethodsSetHeaderEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.WebResponse.Headers.Values[Info.ParamAsString[0]]:=Info.ParamAsString[1];
end;

procedure TdwsWebLib.dwsWebClassesWebResponseMethodsSetLastModifiedEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.WebResponse.LastModified:=Info.ParamAsFloat[0];
end;

procedure TdwsWebLib.dwsWebClassesWebResponseMethodsSetStatusCodeEval(
  Info: TProgramInfo; ExtObject: TObject);
begin
   Info.WebResponse.StatusCode:=Info.ParamAsInteger[0];
end;

// DeflateCompress
//
procedure DeflateCompress(var data : RawByteString; compressionLevel : Integer);
var
   strm : TZStream;
   tmp : RawByteString;
begin
   strm.Init;
   strm.next_in := Pointer(data);
   strm.avail_in := Length(data);
   SetString(tmp, nil, strm.avail_in+256+strm.avail_in shr 3); // max mem required
   strm.next_out := Pointer(tmp);
   strm.avail_out := Length(tmp);
   if deflateInit2_(strm, compressionLevel, Z_DEFLATED, -MAX_WBITS, DEF_MEM_LEVEL,
                    Z_DEFAULT_STRATEGY, ZLIB_VERSION, SizeOf(strm))<0 then
      raise Exception.Create('deflateInit2_ failed');
   try
      Check(deflate(strm,Z_FINISH),[Z_STREAM_END]);
   finally
      deflateEnd(strm);
   end;
   SetString(data, PAnsiChar(Pointer(tmp)), strm.total_out);
end;

// DeflateDecompress
//
procedure DeflateDecompress(var data : RawByteString);
var
   strm : TZStream;
   code, len : integer;
   tmp : RawByteString;
begin
   strm.Init;
   strm.next_in := Pointer(data);
   strm.avail_in := Length(data);
   len := (strm.avail_in*20) shr 3; // initial chunk size = comp. ratio of 60%
   SetString(tmp,nil,len);
   strm.next_out := Pointer(tmp);
   strm.avail_out := len;
   if inflateInit2_(strm, -MAX_WBITS, ZLIB_VERSION, SizeOf(strm))<0 then
      raise Exception.Create('inflateInit2_ failed');
   try
      repeat
         code := Check(inflate(strm, Z_FINISH),[Z_OK,Z_STREAM_END,Z_BUF_ERROR]);
         if strm.avail_out=0 then begin
            // need to increase buffer by chunk
            SetLength(tmp,length(tmp)+len);
            strm.next_out := PAnsiChar(pointer(tmp))+length(tmp)-len;
            strm.avail_out := len;
         end;
      until code=Z_STREAM_END;
   finally
      inflateEnd(strm);
   end;
   SetString(data, PAnsiChar(Pointer(tmp)), strm.total_out);
end;

function TdwsWebLib.dwsWebFunctionsDeflateCompressFastEval(
  const args: TExprBaseListExec): Variant;
var
   data : RawByteString;
   lvl : Integer;
begin
   data:=args.AsDataString[0];
   lvl := args.AsInteger[1];
   if (lvl<0) or (lvl>9) then
      raise Exception.CreateFmt('Invalid deflate compression level %d', [lvl]);
   DeflateCompress(data, lvl);
   Result:=RawByteStringToScriptString(data);
end;

function TdwsWebLib.dwsWebFunctionsDeflateDecompressionFastEval(
  const args: TExprBaseListExec): Variant;
var
   data : RawByteString;
begin
   data:=args.AsDataString[0];
   DeflateDecompress(data);
   Result:=RawByteStringToScriptString(data);
end;

end.
