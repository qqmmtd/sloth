@echo off

set today=%date:~2,8%

set today=%today:-=%

set note=D:\portable\learn\note\%today%.txt

echo %date:~0,10%>>%note%