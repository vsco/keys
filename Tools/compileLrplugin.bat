REM
REM  VSCO Keys for Adobe Lightroom
REM  Copyright (C) 2015 Visual Supply Company
REM  Licensed under GNU GPLv2 (or any later version).
REM
REM  This program is free software; you can redistribute it and/or modify
REM  it under the terms of the GNU General Public License as published by
REM  the Free Software Foundation; either version 2 of the License, or
REM  (at your option) any later version.
REM
REM  This program is distributed in the hope that it will be useful,
REM  but WITHOUT ANY WARRANTY; without even the implied warranty of
REM  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
REM  GNU General Public License for more details.
REM
REM  You should have received a copy of the GNU General Public License along
REM  with this program; if not, write to the Free Software Foundation, Inc.,
REM  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
REM

xcopy /E /I /H /Y ..\VSCOKeys.lrdevplugin ..\Build\VSCOKeys.lrplugin
del /F /S ..\Build\VSCOKeys.lrplugin\*.log
for %%f in (..\Build\VSCOKeys.lrplugin\*.lua) do ( luac_514_32bit.exe -o %%f %%f )
for %%f in (..\Build\VSCOKeys.lrplugin\halfway_server\*.lua) do ( luac_514_32bit.exe -o %%f %%f )