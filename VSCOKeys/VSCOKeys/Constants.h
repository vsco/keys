//
//  Constants.h
//  VSCOKeys
//
//  Created by Sean Gubelman on 7/17/12.
//
//  VSCO Keys for Adobe Lightroom
//  Copyright (C) 2015 Visual Supply Company
//  Licensed under GNU GPLv2 (or any later version).
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//

#ifndef VSCOKeys_Constants_h
#define VSCOKeys_Constants_h

#define PROXIMA_FONT_NAME @"ProximaNovaVSCO-Bold"

#define KEYFILE_AES_KEY "4Nfurb94B6iW64QD"
#define KEYFILE_VKEYS_EXTENSION @"vkeys"
#define KEYFILE_JSON_EXTENSION @"keysjson"
#define KEYFILE_SHEET_EXTENSION @"pdf"
#define KEYFILE_KEYS_NODENAME @"keys"
#define KEYFILE_MODEKEY_NODENAME @"modeKey"
#define KEYFILE_LAYOUTVERSION_NODENAME @"version"
#define KEYFILE_LRVERSION_NODENAME @"lrVersion"
#define KEYFILE_NAME_NODENAME @"name"
#define KEYFILE_AUTHOR_NODENAME @"author"
#define KEYFILE_DESCRIPTION_NODENAME @"description"
#define KEYFILE_UUID_NODENAME @"uuid"
#define KEYFILE_MODIFIERS_NODENAME @"mod"
#define KEYFILE_KEY_NODENAME @"key"
#define KEYFILE_FILENAME_NODENAME @"filename"
#define KEYFILE_ADJUSTMENTS_NODENAME @"adj"
#define KEYFILE_ADJUSTMENT_REMAP_NODENAME @"_RemapKey"

#define DEFAULTS_ACTIVE_KEYFILE @"active_keyfile"
#define DEFAULTS_KEYFILE_ISACTIVE @"isActive"
#define DEFAULTS_KEYFILE_FORMAT @"keyfile_%@"

#define SERVER_UPDATE_ENDPOINT @"http://127.0.0.1:49657/Update/"

#define LIGHTROOM_BUNDLE_LR3 @"com.adobe.Lightroom3"
#define LIGHTROOM_BUNDLE_LR4 @"com.adobe.Lightroom4"
#define LIGHTROOM_BUNDLE_LR5 @"com.adobe.Lightroom5"
#define LIGHTROOM_BUNDLE_LR6 @"com.adobe.Lightroom6"
#define LIGHTROOM_BUNDLE_LR7 @"com.adobe.LightroomClassicCC7"

#define STATUSBAR_UPDATE_RATE 0.25
#define APP_RUNNING_UPDATE_RATE 1

#ifdef DEV_ENDPOINT_MODE

#define AUTH_ENDPOINT @"http://vsco:shooteditshare@vscodev.com/api/license/vscokeys"
#define VERSION_ENDPOINT @"http://vsco:shooteditshare@vscodev.com/api/vscokeys/version/"
#define CREATE_NEW_ENDPOINT @"http://vsco:shooteditshare@vscodev.com/vscokeys/customize"
#define WEB_GET_LICENSE @"http://vsco:shooteditshare@vscodev.com/tools/vscokeys"
#define WEB_USER_KEYS @"http://vsco:shooteditshare@vscodev.com/user/vscokeys/"
#define WEB_TERMS_OF_SERVICE @"http://vsco:shooteditshare@vscodev.com/terms_of_use"
#define WEB_PRIVACY_POLICY @"http://vsco:shooteditshare@vscodev.com/privacy_policy"
#define WEB_SUPPORT @"http://support.vsco.co"
#define WEB_KEYS_ENDPOINT @"http://vsco:shooteditshare@vscodev.com/vscokeys/"
#define WEB_QUICK_START @"http://vsco:shooteditshare@vscodev.com/vscokeys/quickstart/"

#else

#define AUTH_ENDPOINT @"http://vsco.co/api/license/vscokeys"
#define VERSION_ENDPOINT @"http://vsco.co/api/vscokeys/version/"
#define CREATE_NEW_ENDPOINT @"http://vsco.co/vscokeys/customize"
#define WEB_GET_LICENSE @"http://vsco.co/tools/vscokeys"
#define WEB_USER_KEYS @"http://vsco.co/user/vscokeys/"
#define WEB_TERMS_OF_SERVICE @"http://vsco.co/terms_of_use"
#define WEB_PRIVACY_POLICY @"http://vsco.co/privacy_policy"
#define WEB_SUPPORT @"http://support.vsco.co"
#define WEB_KEYS_ENDPOINT @"http://vsco.co/vscokeys/"
#define WEB_QUICK_START @"http://vsco.co/vscokeys/quickstart/"

#endif

#define AUTH_APPID @"b9949d64d1fb109c293590c6ed763a21"
#define AUTH_SECRET @"510faef8f4c470006ab250894ffced24"
#define AUTH_UUID_NAME @"uuid"
#define AUTH_APPID_NAME @"appid"
#define AUTH_TOKEN_NAME @"tkn"
#define AUTH_TIMESTAMP_NAME @"ts"
#define AUTH_LICENSE_NAME @"license"
#define AUTH_RESPONSE_STATUS @"status"
#define AUTH_RESPONSE_MESSAGE @"msg"
#define AUTH_VERSION_NAME @"ver"
#define AUTH_VERSION @"1"
#define AUTH_BLACKLIST_KEY @"X34E5S7"
#define AUTH_BLACKLIST_INVALID @"License is invalid"

#define VERSION_RESPONSE_VERSION @"version"

#define DEFAULTS_LICENSE_NAME @"license_key"
#define LICENSE_REGEX @"[E-H][A-Z,1-9][1-9][A-Z,1-9]-[O-T][A-Z,1-9][A-L][A-Z,1-9]-[A-Z][A-Z,1-9][U-Z][A-Z,1-9]-[M-Z][A-Z,1-9][J-M][A-Z,1-9]"
#define LICENSE_DEFAULT @"XXXX-XXXX-XXXX-XXXX"
#define LICENSE_TRIAL_PREFIX @"TRIAL ENDS IN "
#define LICENSE_TRIAL_SUFFIX @" DAYS"

#define STATUSMENUITEM_REGISTER @"Register"
#define STATUSMENUITEM_ABOUT @"About"
#define STATUSMENUITEM_PREFERENCES @"Settings"
#define STATUSMENUITEM_QUIT @"Quit"
#define STATUSMENUITEM_ACTIVE @"Deactivate (ESC)"
#define STATUSMENUITEM_INACTIVE @"Activate (ESC)"
#define STATUSMENUITEM_ERROR @"An error has occurred. To troubleshoot, please visit vsco.desk.com"

#define IMPORT_KEYFILE_TITLE_ERROR @"Import Error"
#define IMPORT_KEYFILE_TITLE_SUCCESS @"Import Success"

#define IMPORT_KEYFILE_BAD_FORMAT @"This VSCO Keys layout is damaged."
#define IMPORT_KEYFILE_WRONG_VERSION @"This layout is made for LR %@ and you are running LR %@"
#define IMPORT_KEYFILE_SAME_NAME @"This VSCO Keys layout already exists."
#define IMPORT_KEYFILE_NEWER_LAYOUT @"The VSCO Keys layout that you are trying to import is for a newer version of the application. Please update to the latest version."
#define IMPORT_KEYFILE_SUCCESS @"VSCO Keys layout %@ added successfully."

#define MODIFIER_SHIFT_NAME @"SHIFT"
#define MODIFIER_CONTROL_NAME @"CTRL"
#define MODIFIER_OPTION_NAME @"OPT"
#define MODIFIER_COMMAND_NAME @"CMD"

enum MODIFIERS {
    kModifierShift = 1,
    kModifierControl = 2,
    kModifierOption = 4,
    kModifierCommand = 8
};

#define LRVERSION_LR3 @"3"
#define LRVERSION_LR4 @"4"
#define LRVERSION_UNKNOWN @"UNKNOWN"

#define UPDATE_ALERT_TITLE @"VSCO Keys Update Available"
#define UPDATE_ALERT_TEXT @"A new version of VSCO Keys is available.  Click OK to update."

#define LIST_PDF_NAME @"pdf"
#define LIST_DELETE_NAME @"delete"
#define LIST_PDF @"VIEW LAYOUT PDF"
#define LIST_DELETE @"DELETE"

#define VIEW_COMMAND_NAME @"command"
#define VIEW_ADJUSTMENT_NAME @"adjustment"
#define VIEW_AMOUNT_NAME @"amount"
#define VIEW_PADDING 20.0

#define VIEW_TITLE_VIEW_PDF @"VIEW PDF LAYOUT"
#define VIEW_TITLE_DOWNLOAD_PDF @"DOWNLOAD PDF LAYOUT"
#define VIEW_TITLE_DOWNLOAD_FAILED_PDF @"DOWNLOAD FAILED"
#define VIEW_DOWNLOAD_UPDATE_RATE 0.5 // seconds
#define VIEW_DOWNLOAD_DURATION 5 // seconds

#define WEB_KEYS_CUSTOMIZE @"customize"
#define WEB_KEYS_SHEET @"sheet"

#ifdef DEV_ENDPOINT_MODE

#define ABOUT_VERSION_FORMAT @"%@ / VERSION %@ DEV"

#else

#define ABOUT_VERSION_FORMAT @"%@ / VERSION %@"

#endif

#define VERSION_SKU @"VSCOKEYS-1"

#define OS_VERSION_MIN_MAJOR 10
#define OS_VERSION_MIN_MINOR 7
#define OS_VERSION_MIN_BUGFIX 0

#define RUNTRACE_MAX_FILE_COUNT 10

#endif
