# RobocopyContext
Context Menu commands for Robocopy in Windows Explorer. Through context menu it adds selected files and directorie to a staging txt then when bringing up the context menu on the empty space in a folder you can paste as Large files (no multithreading) or Small files (automatic multithreading).

## Robocopy flags used in robocopy_paste_profile.ps1
if Large files or HDD paste:
- if directories staged: /E /J /R:2 /W:5 /TEE
- if no directories staged: /J /R:2 /W:5 /TEE

if small files paste:
- if directories staged: /E /MT# /R:2 /W:2 /TEE
- if no directories staged: /MT# /R:2 /W:2 /TEE

## Installation

You need to either install [scoop.sh](https://scoop.sh) and run

~~~
scoop install https://raw.githubusercontent.com/saturdayxiii/RobocopyContext/refs/heads/main/robocopycontext.json
~~~

or uncompress the release .zip into %userprofile%/scoop/apps/robocopycontext and run the install.ps1

## Limitations

Does occasionally fail to stage the selected files.  Just select "copy" again if nothing pastes.

Not yet tasted for 
- giant complex directories
- extremely long paths/filenames
- interupts and general weird situations

If multiple Explorer windows/tabs open each with selections it will only stage the selection from the earliest open window/tab.
