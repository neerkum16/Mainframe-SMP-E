/* REXX SMPESCAN - count GIM messages by severity in SMPOUT         */
/* Usage: SMPESCAN 'your.smpout.dataset'                            */
parse arg dsn
if dsn = '' then do
  say 'Usage: SMPESCAN dataset'
  exit 8
end
"ALLOC F(SMPIN) DA("dsn") SHR REUSE"
"EXECIO * DISKR SMPIN (STEM ln. FINIS)"
"FREE F(SMPIN)"
sev. = 0
highrc = ''
do i = 1 to ln.0
  w = word(ln.i,1)
  if left(w,3) = 'GIM' & length(w) = 9 then do
    s = right(w,1)
    sev.s = sev.s + 1
    if s = 'E' | s = 'S' then say strip(ln.i)
  end
  p = pos('HIGHEST RETURN CODE WAS',ln.i)
  if p > 0 then highrc = word(substr(ln.i,p+23),1)
end
say 'Information :' sev.I
say 'Warnings    :' sev.W
say 'Errors      :' sev.E
say 'Severe      :' sev.S
say 'Highest RC  :' highrc
if sev.S > 0 then exit 16
if sev.E > 0 then exit 8
if sev.W > 0 then exit 4
exit 0
