/* REXX SMPEJOB - build and submit a one-step GIMSMP job            */
/* Usage: SMPEJOB zone command                                     */
/* Example: SMPEJOB TGT1 APPLY SELECT(UA00001) CHECK .             */
parse arg zone cmd
if zone = '' | cmd = '' then do
  say 'Usage: SMPEJOB zone command'
  exit 8
end
hlq = 'SMPE.LAB'
uid = userid()
tmp = uid'.SMPEJOB.JCL'
jcl.1  = '//'left(uid'S',8)" JOB (ACCT),'SMPE',CLASS=A,MSGCLASS=H"
jcl.2  = '//SMP      EXEC PGM=GIMSMP,REGION=0M,PARM='||"'DATE=U'"
jcl.3  = '//SMPOUT   DD SYSOUT=*'
jcl.4  = '//SMPRPT   DD SYSOUT=*'
jcl.5  = '//SMPLIST  DD SYSOUT=*'
jcl.6  = '//SMPSNAP  DD SYSOUT=*'
jcl.7  = '//SMPDEBUG DD SYSOUT=*'
jcl.8  = '//SMPCSI   DD DISP=SHR,DSN='hlq'.CSI'
jcl.9  = '//SMPCNTL  DD *'
jcl.10 = '  SET BDY('zone') .'
jcl.11 = '  'cmd
jcl.12 = '/*'
jcl.0  = 12
"ALLOC F(SMPJCL) DA('"tmp"') NEW CATALOG REUSE",
      "RECFM(F B) LRECL(80) BLKSIZE(3120) SPACE(1 1) TRACKS"
"EXECIO" jcl.0 "DISKW SMPJCL (STEM jcl. FINIS)"
"FREE F(SMPJCL)"
"SUBMIT '"tmp"'"
exit rc
