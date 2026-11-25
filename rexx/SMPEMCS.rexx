/* REXX SMPEMCS - syntax pre-check for an MCS package               */
/* Usage: SMPEMCS 'dataset(member)'                                  */
/* Checks: each ++ statement ends with a period, SYSMOD and hold IDs */
/* have 7 characters, each SYSMOD header is followed by ++VER before */
/* the next header, non-function SYSMODs name an FMID.               */
/* Exit code: 0 clean, 4 warnings, 8 errors.                         */
parse arg dsn
if dsn = '' then do
  say 'Usage: SMPEMCS dataset(member)'
  exit 8
end
"ALLOC F(MCSIN) DA("dsn") SHR REUSE"
"EXECIO * DISKR MCSIN (STEM ln. FINIS)"
"FREE F(MCSIN)"
errs = 0
warns = 0
open = 0
needver = 0
curkw = ''
hdrline = 0
stline = 0
stmt = ''
depth = 0
do i = 1 to ln.0
  txt = ln.i
  if open = 1 & left(txt,2) = '++' then do
    say 'ERROR line' stline': statement has no terminating period'
    errs = errs + 1
    call ANALYZE
    open = 0
  end
  if open = 0 then do
    if left(txt,2) <> '++' then iterate
    stmt = ''
    depth = 0
    stline = i
    open = 1
  end
  stmt = stmt strip(txt)
  done = 0
  do k = 1 to length(txt)
    c = substr(txt,k,1)
    if c = '(' then depth = depth + 1
    else if c = ')' then depth = depth - 1
    else if c = '.' & depth = 0 then do
      done = 1
      leave
    end
  end
  if done = 1 then do
    open = 0
    call ANALYZE
  end
end
if open = 1 then do
  say 'ERROR line' stline': statement has no terminating period'
  errs = errs + 1
  call ANALYZE
end
if needver = 1 then do
  say 'ERROR line' hdrline': SYSMOD header has no ++VER'
  errs = errs + 1
end
say 'Lines read :' ln.0
say 'Errors     :' errs
say 'Warnings   :' warns
if errs > 0 then exit 8
if warns > 0 then exit 4
exit 0

ANALYZE:
  parse upper var stmt kw '(' id ')' .
  kw = strip(kw)
  id = strip(id)
  select
    when kw = '++FUNCTION' | kw = '++PTF' | kw = '++APAR',
       | kw = '++USERMOD' then do
      if needver = 1 then do
        say 'ERROR line' hdrline': header has no ++VER before line' stline
        errs = errs + 1
      end
      call CHKID
      needver = 1
      hdrline = stline
      curkw = kw
    end
    when kw = '++VER' then do
      if needver = 0 then do
        say 'WARNING line' stline': ++VER without a SYSMOD header before it'
        warns = warns + 1
      end
      needver = 0
      if curkw <> '++FUNCTION' & pos('FMID(',stmt) = 0 then do
        say 'WARNING line' stline': no FMID (only base functions may omit it)'
        warns = warns + 1
      end
    end
    when kw = '++HOLD' | kw = '++RELEASE' then call CHKID
    otherwise nop
  end
  return

CHKID:
  if length(id) <> 7 then do
    say 'ERROR line' stline': ID' id 'in' kw 'is not 7 characters'
    errs = errs + 1
  end
  return
