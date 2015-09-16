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

using VSCOKeys.Model;
using System.Web.Script.Serialization;
using System.Collections.Generic;
namespace VSCOKeys.Properties {


    // This class allows you to handle specific events on the settings class:
    //  The SettingChanging event is raised before a setting's value is changed.
    //  The PropertyChanged event is raised after a setting's value is changed.
    //  The SettingsLoaded event is raised after the setting values are loaded.
    //  The SettingsSaving event is raised before the setting values are saved.
    internal sealed partial class Settings {

        private JavaScriptSerializer jsSerializer = new JavaScriptSerializer();

        public Settings() {

            this.SettingsSaving += this.SettingsSavingEventHandler;
            this.SettingsLoaded += new System.Configuration.SettingsLoadedEventHandler(Settings_SettingsLoaded);
        }

        void Settings_SettingsLoaded(object sender, System.Configuration.SettingsLoadedEventArgs e)
        {
            Dictionary<string,KeyfileSettings> dict = this.jsSerializer.Deserialize<Dictionary<string,KeyfileSettings>>(this.KeyfileSettingsSerialized);
            if (dict != null)
            {
                this.KeyfileSettings = new KeyfileSettingsDictionary(dict);
            }
            else
            {
                this.KeyfileSettings = new KeyfileSettingsDictionary();
            }
        }

        private void SettingsSavingEventHandler(object sender, System.ComponentModel.CancelEventArgs e)
        {
            this.KeyfileSettingsSerialized = this.jsSerializer.Serialize(this.KeyfileSettings);
        }
    }
}
