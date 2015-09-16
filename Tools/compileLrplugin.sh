#
#  VSCO Keys for Adobe Lightroom
#  Copyright (C) 2015 Visual Supply Company
#  Licensed under GNU GPLv2 (or any later version).
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License along
#  with this program; if not, write to the Free Software Foundation, Inc.,
#  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

cp -r ../VSCOKeys.lrdevplugin/ ../Build/VSCOKeys.lrplugin/
rm -f ../Build/VSCOKeys.lrplugin/*.log
rm -f ../Build/VSCOKeys.lrplugin/**/*.log
rm -f ../Build/VSCOKeys.lrplugin/skey.key
for file in ../Build/VSCOKeys.lrplugin/*.lua; do ./luac_514_32bit -o $file $file; done;
for file in ../Build/VSCOKeys.lrplugin/**/*.lua; do ./luac_514_32bit -o $file $file; done;