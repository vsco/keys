/**
 * VSCO Keys for Adobe Lightroom
 * Copyright (C) 2015 Visual Supply Company
 * Licensed under GNU GPLv2 (or any later version).
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 */

[System.Flags]
enum Modifiers {
    None = 0,
    Shift = 1,
    Control = 2,
    Alt = 4,
    Windows = 8
}

enum LRVersion
{
    UNSET,
    LR4 = 4,
    LR3 = 3,
    UNKNOWN
}

static class Constants
{
    public const string KEYFILE_AES_KEY = "4Nfurb94B6iW64QD";
    public const string KEYFILE_VKEYS_EXTENSION = ".vkeys";
    public const string KEYFILE_JSON_EXTENSION = ".keysjson";
    public const string KEYFILE_SHEET_EXTENSION = "pdf";
    public const string KEYFILE_KEYS_NODENAME = "keys";
    public const string KEYFILE_MODEKEY_NODENAME = "modeKey";
    public const string KEYFILE_NAME_NODENAME = "name";
    public const string KEYFILE_AUTHOR_NODENAME = "author";
    public const string KEYFILE_DESCRIPTION_NODENAME = "description";
    public const string KEYFILE_UUID_NODENAME = "uuid";
    public const string KEYFILE_MODIFIERS_NODENAME = "mod";
    public const string KEYFILE_KEY_NODENAME = "key";
    public const string KEYFILE_FILENAME_NODENAME = "filename";
    public const string KEYFILE_ADJUSTMENTS_NODENAME = "adj";
    public const string KEYFILE_ADJUSTMENT_REMAP_NODENAME = "_RemapKey";

    public const string DEFAULTS_ACTIVE_KEYFILE = "active_keyfile";
    public const string DEFAULTS_KEYFILE_ISACTIVE = "isActive";
    public const string DEFAULTS_KEYFILE_FORMAT = "keyfile_%@";

    public const string SERVER_UPDATE_ENDPOINT = "http://127.0.0.1:49657/Update/";

    public const string LIGHTROOM_EXE_NAME = "lightroom";

#if DEV_ENDPOINT_MODE

    public const string AUTH_ENDPOINT = "http://vscodev.com/api/license/vscokeys";
    public const bool AUTH_ENDPOINT_HAS_AUTH = true;
    public const string AUTH_AUTH_USER = "vsco";
    public const string AUTH_AUTH_PASSWORD = "shooteditshare";
    public const string VERSION_ENDPOINT = "http://vscodev.com/api/vscokeys/version/";
    public const bool VERSION_ENDPOINT_HAS_AUTH = true;
    public const string VERSION_AUTH_USER = "vsco";
    public const string VERSION_AUTH_PASSWORD = "shooteditshare";
    public const string WEB_GET_LICENSE = "http://vsco:shooteditshare@vscodev.com/tools/vscokeys";
    public const string WEB_CREATE_NEW_ENDPOINT = "http://vsco:shooteditshare@vscodev.com/vscokeys/customize";
    public const string WEB_USER_KEYS = "http://vsco:shooteditshare@vscodev.com/user/vscokeys/";
    public const string WEB_TERMS_OF_SERVICE = "http://vsco:shooteditshare@vscodev.com/terms_of_use";
    public const string WEB_PRIVACY_POLICY = "http://vsco:shooteditshare@vscodev.com/privacy_policy";
    public const string WEB_SUPPORT = "http://support.vsco.co";
    public const string WEB_KEYS_ENDPOINT = "http://vscodev.com/vscokeys/";
    public const bool WEB_KEYS_ENDPOINT_HAS_AUTH = true;
    public const string WEB_KEYS_ENDPOINT_USER = "vsco";
    public const string WEB_KEYS_ENDPOINT_PASSWORD = "shooteditshare";
    public const string WEB_QUICK_START = "http://vsco:shooteditshare@vscodev.com/vscokeys/quickstart/";

#else

    public const string AUTH_ENDPOINT = "http://vsco.co/api/license/vscokeys";
    public const bool AUTH_ENDPOINT_HAS_AUTH = false;
    public const string AUTH_AUTH_USER = "";
    public const string AUTH_AUTH_PASSWORD = "";
    public const string VERSION_ENDPOINT = "http://vsco.co/api/vscokeys/version/";
    public const bool VERSION_ENDPOINT_HAS_AUTH = false;
    public const string VERSION_AUTH_USER = "";
    public const string VERSION_AUTH_PASSWORD = "";
    public const string WEB_GET_LICENSE = "http://vsco.co/tools/vscokeys";
    public const string WEB_CREATE_NEW_ENDPOINT = "http://vsco.co/vscokeys/customize";
    public const string WEB_USER_KEYS = "http://vsco.co/user/vscokeys/";
    public const string WEB_TERMS_OF_SERVICE = "http://vsco.co/terms_of_use";
    public const string WEB_PRIVACY_POLICY = "http://vsco.co/privacy_policy";
    public const string WEB_SUPPORT = "http://support.vsco.co";
    public const string WEB_KEYS_ENDPOINT = "http://vsco.co/vscokeys/";
    public const bool WEB_KEYS_ENDPOINT_HAS_AUTH = false;
    public const string WEB_KEYS_ENDPOINT_USER = "";
    public const string WEB_KEYS_ENDPOINT_PASSWORD = "";
    public const string WEB_QUICK_START = "http://vsco.co/vscokeys/quickstart/";

#endif

    public const string AUTH_APPID = "b9949d64d1fb109c293590c6ed763a21";
    public const string AUTH_SECRET = "510faef8f4c470006ab250894ffced24";
    public const string AUTH_UUID_NAME = "uuid";
    public const string AUTH_APPID_NAME = "appid";
    public const string AUTH_TOKEN_NAME = "tkn";
    public const string AUTH_TIMESTAMP_NAME = "ts";
    public const string AUTH_LICENSE_NAME = "license";
    public const string AUTH_RESPONSE_STATUS = "status";
    public const string AUTH_RESPONSE_MESSAGE = "msg";
    public const string AUTH_VERSION_NAME = "ver";
    public const string AUTH_VERSION = "1";
    public const string AUTH_BLACKLISTED_KEY = "License is invalid";

    public const string AUTH_PLUGIN_UUID_NAME = "_AuthUUID";
    public const string AUTH_PLUGIN_TOKEN_NAME = "_AuthToken";
    public const string AUTH_PLUGIN_TIMESTAMP_NAME = "_AuthTimestamp";
    public const string AUTH_PLUGIN_SERIAL_NAME = "_AuthSerial";

    public const string VERSION_RESPONSE_VERSION = "winversion";

    public const string DEFAULTS_LICENSE_NAME = "license_key";
    public const string LICENSE_REGEX = "[E-H][A-Z,1-9][1-9][A-Z,1-9]-[O-T][A-Z,1-9][A-L][A-Z,1-9]-[A-Z][A-Z,1-9][U-Z][A-Z,1-9]-[M-Z][A-Z,1-9][J-M][A-Z,1-9]";
    public const string LICENSE_DEFAULT = "XXXX-XXXX-XXXX-XXXX";
    public const string LICENSE_TRIAL_PREFIX = "TRIAL ENDS IN ";
    public const string LICENSE_TRIAL_SUFFIX = " DAYS";

    public const string MODIFIER_SHIFT_NAME = "SHIFT";
    public const string MODIFIER_CONTROL_NAME = "CTRL";
    public const string MODIFIER_OPTION_NAME = "OPT";
    public const string MODIFIER_COMMAND_NAME = "CMD";

    public const string UPDATE_ALERT_TEXT = "A new version of VSCO Keys is available.  Click OK to update.";
    public const string UPDATE_ALERT_TITLE = "VSCO Keys Update Available";

    public const string IMPORT_KEYFILE_TITLE_ERROR = "Import Error";
    public const string IMPORT_KEYFILE_TITLE_SUCCESS = "Import Success";
    public const string IMPORT_KEYFILE_BAD_FORMAT = "This VSCO Keys layout is damaged: {0}";
    public const string IMPORT_KEYFILE_WRONG_VERSION = "This VSCO Keys layout is made for {0} and you are running {1}";
    public const string IMPORT_KEYFILE_NEWER_LAYOUT = "The VSCO Keys layout that you are trying to import is for a newer version of the application. Please update to the latest version.";
    public const string IMPORT_KEYFILE_SUCCESS = "VSCO Keys layout {0} added successfully.";

    public const string STATUSMENU_HOVER_ACTIVE = "Active";
    public const string STATUSMENU_HOVER_INACTIVE = "Inactive";
    public const string STATUSMENU_HOVER_ERROR = "An error has occurred. To troubleshoot, please visit http://vsco.desk.com";

    public const string STATUSMENUITEM_ACTIVE = "Deactivate (ESC)";
    public const string STATUSMENUITEM_INACTIVE = "Activate (ESC)";
    public const string STATUSMENUITEM_ERROR = "An error has occurred. To troubleshoot, please visit http://vsco.desk.com";
    public const string STATUSMENUITEM_REGISTER = "Register";
    public const string STATUSMENUITEM_PREFERENCES = "Settings";
    public const string STATUSMENUITEM_ABOUT = "About";
    public const string STATUSMENUITEM_QUIT = "Quit";

    public const string LIST_PDF_NAME = "pdf";
    public const string LIST_DELETE_NAME = "delete";
    public const string LIST_PDF = "VIEW LAYOUT PDF";
    public const string LIST_DELETE = "DELETE";

    public const string VIEW_COMMAND_NAME = "command";
    public const string VIEW_ADJUSTMENT_NAME = "adjustment";
    public const string VIEW_AMOUNT_NAME = "amount";
    public const double VIEW_PADDING = 20.0;

    public const string VIEW_TITLE_VIEW_PDF = "VIEW PDF LAYOUT";
    public const string VIEW_TITLE_DOWNLOAD_PDF = "DOWNLOAD PDF LAYOUT";
    public const string VIEW_TITLE_DOWNLOAD_FAILED_PDF = "DOWNLOAD FAILED";
    public const double VIEW_DOWNLOAD_UPDATE_RATE = 0.5; // seconds
    public const double VIEW_DOWNLOAD_DURATION = 5; // seconds

    public const string WEB_KEYS_CUSTOMIZE = "customize";
    public const string WEB_KEYS_SHEET = "sheet";

    public const string VERSION_SKU = "VSCOKEYS-1";

#if DEV_ENDPOINT_MODE
    public const string ABOUT_WINDOW_VERSION_FORMAT = "{0} / VERSION {1} DEV";
#else
    public const string ABOUT_WINDOW_VERSION_FORMAT = "{0} / VERSION {1}";
#endif

    public const string PIPE_NAME = "VSCOKeysPipe";

    public const int KEY_PRESSED = 0x8000;
    public const int WM_KEYDOWN = 0x0100;
    public const int WM_KEYUP = 0x0101;
    public const int WM_SYSKEYDOWN = 0x0104;
    public const int WM_SYSKEYUP = 0x0105;
    public const int WH_KEYBOARD_LL = 13;

    public const int VK_SHIFT = 0x10;
    public const int VK_CONTROL = 0x11;
    public const int VK_MENU = 0x12;
    public const int VK_LSHIFT = 0xA0;
    public const int VK_RSHIFT = 0xA1;
    public const int VK_LCONTROL = 0xA2;
    public const int VK_RCONTROL = 0xA3;
    public const int VK_LMENU = 0xA4;
    public const int VK_RMENU = 0xA5;
    public const int VK_LWIN = 0x5B;
    public const int VK_RWIN = 0x5C;

#if DEV_ENDPOINT_MODE
    public const bool HOOK_PERF_DETAIL = true;
#else
    public const bool HOOK_PERF_DETAIL = false;
#endif

    public const bool BYPASS_AUTH = false;

    public const int RUNTRACE_MAX_FILE_COUNT = 10;
}
