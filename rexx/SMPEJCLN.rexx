/* REXX SMPEJCLN - pre-check JCLIN input and preview its entries    */
/* Usage: SMPEJCLN 'dataset(member)'                                 */
/* Reads a JCL member, or an MCS member that holds a ++JCLIN section. */
/* Classifies each step as assembly, link-edit, copy or update by its */
/* program name, and prints the entries the JCLIN command is expected */
/* to create. This is a prediction made from the step text; SMP/E     */
/* decides what it really creates. It does not run any step.          */
/* Checks: no EXEC found, link-edit step without SYSLMOD, assembly    */
/* step without a SYSLIN member, SYSLIB on a link-edit step without a */
/* CALLLIBS comment, program names JCLIN does not recognize.          */
/* Exit code: 0 clean, 4 warnings, 8 errors.                          */
parse arg dsn
if dsn = '' then do
  say 'Usage: SMPEJCLN dataset(member)'
  exit 8
end
"ALLOC F(JCLIN) DA("dsn") SHR REUSE"
"EXECIO * DISKR JCLIN (STEM ln. FINIS)"
"FREE F(JCLIN)"
asmlist  = 'ASMBLR ASMA90 IEUASM IEV90 IFOX00 ASMS'
lkedlist = 'HEWL HEWLH096 HEWLKED IEWBLINK IEWL LINKEDIT LINKS'
errs = 0
warns = 0
mcsmode = 0
do i = 1 to ln.0
  if left(ln.i,2) = '++' then mcsmode = 1
end
if mcsmode = 1 then injcl = 0
else injcl = 1
nstep = 0
indata = 0
curdd = ''
calllibs = 0
stepname. = ''
pgm. = ''
kind. = ''
syslmod. = ''
syslin. = ''
syslib. = 0
sysin. = 0
includes. = ''
names. = ''
copywhat. = ''
copyall. = 0
copysel. = 0
do i = 1 to ln.0
  txt = ln.i
  if mcsmode = 1 & left(txt,2) = '++' then do
    kw = word(txt,1)
    parse var kw k1 '(' .
    if translate(k1) = '++JCLIN' then injcl = 1
    else injcl = 0
    indata = 0
    iterate
  end
  if injcl = 0 then iterate
  if indata = 1 then do
    if left(txt,2) = '/*' then do
      indata = 0
      iterate
    end
    if left(txt,2) = '//' then indata = 0
    else do
      call DATALINE
      iterate
    end
  end
  if left(txt,3) = '//*' then do
    if pos('CALLLIBS=YES',translate(txt)) > 0 then calllibs = 1
    iterate
  end
  if left(txt,2) <> '//' then iterate
  body = substr(txt,3)
  if left(body,1) = ' ' then do
    name = ''
    rest = strip(body)
  end
  else do
    parse var body name rest
    rest = strip(rest)
  end
  parse var rest op operands
  op = translate(op)
  uops = translate(operands)
  if op = 'EXEC' then do
    nstep = nstep + 1
    stepname.nstep = name
    p = pos('PGM=',uops)
    if p > 0 then do
      tail = substr(uops,p+4)
      parse var tail prog ',' .
      pgm.nstep = word(prog,1)
    end
    else do
      parse var uops prog ',' .
      pgm.nstep = word(prog,1)
    end
    if wordpos(pgm.nstep,asmlist) > 0 then kind.nstep = 'ASM'
    else if wordpos(pgm.nstep,lkedlist) > 0 then kind.nstep = 'LKED'
    else if pgm.nstep = 'IEBCOPY' then kind.nstep = 'COPY'
    else if pgm.nstep = 'IEBUPDTE' then kind.nstep = 'UPDATE'
    else kind.nstep = 'OTHER'
  end
  else if op = 'DD' & nstep > 0 then do
    d = ''
    p = pos('DSN=',uops)
    if p > 0 then do
      tail = substr(uops,p+4)
      parse var tail d ',' .
      d = word(d,1)
    end
    ddn = translate(name)
    if ddn = 'SYSLMOD' then syslmod.nstep = d
    if ddn = 'SYSLIN' then syslin.nstep = d
    if ddn = 'SYSLIB' then syslib.nstep = 1
    if ddn = 'SYSIN' then sysin.nstep = 1
    first = word(uops,1)
    if first = '*' | left(first,4) = 'DATA' then do
      indata = 1
      curdd = ddn
    end
  end
end
if nstep = 0 then do
  say 'ERROR: no EXEC statement found in the JCLIN input'
  errs = errs + 1
end
do n = 1 to nstep
  say 'Step' n':' stepname.n 'program' pgm.n 'class' kind.n
  if kind.n = 'ASM' then do
    parse var syslin.n lib '(' mem ')'
    if mem = '' then do
      say '  WARN: SYSLIN has no library member; the module is not named'
      warns = warns + 1
    end
    else say '  expect ASSEM entry and MOD entry:' mem
    if sysin.n = 0 then do
      say '  WARN: no SYSIN DD; there is no assembler input to save'
      warns = warns + 1
    end
  end
  else if kind.n = 'LKED' then do
    if syslmod.n = '' then do
      say '  ERROR: link-edit step has no SYSLMOD DD'
      errs = errs + 1
    end
    else say '  target library data set:' syslmod.n
    if names.n = '' then do
      say '  WARN: no NAME statement; the load module is not named'
      warns = warns + 1
    end
    else say '  expect LMOD entry:' names.n
    if includes.n <> '' then say '  expect MOD entries for:' includes.n
    if syslib.n = 1 & calllibs = 0 then do
      say '  WARN: SYSLIB ignored: no CALLLIBS operand or comment'
      warns = warns + 1
    end
  end
  else if kind.n = 'COPY' then do
    if copysel.n = 1 then say '  copy with SELECT: MOD and LMOD from members'
    else if copyall.n = 1 then say '  total copy: expect DLIB entry:' copywhat.n
    else do
      say '  WARN: no COPY statement found in SYSIN'
      warns = warns + 1
    end
  end
  else if kind.n = 'UPDATE' then say '  update step (IEBUPDTE)'
  else do
    say '  WARN: program not recognized by JCLIN as assembler, linker,'
    say '        copy or update utility'
    warns = warns + 1
  end
end
say 'Steps    :' nstep
say 'Warnings :' warns
say 'Errors   :' errs
if errs > 0 then exit 8
if warns > 0 then exit 4
exit 0

DATALINE:
  t = translate(strip(txt))
  w1 = word(t,1)
  if kind.nstep = 'LKED' & curdd = 'SYSLIN' then do
    if w1 = 'INCLUDE' then includes.nstep = includes.nstep word(t,2)
    if w1 = 'NAME' then do
      parse var t . nm .
      parse var nm lm '(' .
      names.nstep = names.nstep lm
    end
  end
  if kind.nstep = 'COPY' & curdd = 'SYSIN' then do
    if w1 = 'COPY' then do
      copyall.nstep = 1
      p = pos('INDD=',t)
      if p > 0 then do
        tail = substr(t,p+5)
        parse var tail ind ',' .
        copywhat.nstep = word(ind,1)
      end
    end
    if w1 = 'SELECT' then copysel.nstep = 1
  end
  return
