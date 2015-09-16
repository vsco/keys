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

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Input;
using System.Windows.Controls;
using VSCOKeys.Model;
using System.Diagnostics;
using System.Windows;
using System.IO;
using System.Collections.ObjectModel;

namespace VSCOKeys.ViewModel
{
    class QuickWindowViewModel : BindableObject
    {
        #region bindings

        private IList<KeyCommandViewModel> keys;
        public IList<KeyCommandViewModel> Keys
        {
            get { return this.keys; }
            set
            {
                if (this.keys != value)
                {
                    this.keys = value;
                    OnPropertyChanged("Keys");
                }
            }
        }


        #endregion

        public KeyControl KeyControl { get; set; }
        public Window Window { get; set; }

        public QuickWindowViewModel()
        {

        }

        internal void Setup(string uuid)
        {
            Keyfile keyfile = this.KeyControl.GetKeyfile(uuid);

            List<KeyCommandViewModel> keys = new List<KeyCommandViewModel>();

            foreach (KeyCommand key in keyfile.keys)
            {
                string commandString = this.KeyControl.GetCommandStringForCommand(key);

                List<string> normalizedAdjustmentNames = new List<string>();
                foreach (KeyValuePair<string, object> adj in key.adj)
                {
                    KeyCommandViewModel newKey = new KeyCommandViewModel();

                    string normalAdjustmentName = (string)this.KeyControl.adjustmentMapping[adj.Key];

                    if (normalizedAdjustmentNames.Contains(normalAdjustmentName))
                    {
                        continue;
                    }

                    normalizedAdjustmentNames.Add(normalAdjustmentName);

                    newKey.Command = commandString;
                    newKey.Adjustment = normalAdjustmentName;
                    newKey.Amount = (adj.Key == Constants.KEYFILE_ADJUSTMENT_REMAP_NODENAME) ? this.KeyControl.GetCommandStringForCommand((KeyCommand)adj.Value) : (string)adj.Value;

                    keys.Add(newKey);
                }
            }

            this.Keys = new ObservableCollection<KeyCommandViewModel>(keys);
        }

        internal void Close()
        {
            this.KeyControl.quickWindow = null;
            this.KeyControl.MakeLRActive();
        }
    }
}
