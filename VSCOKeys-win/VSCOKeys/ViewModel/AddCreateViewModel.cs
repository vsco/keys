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

namespace VSCOKeys.ViewModel
{
    class AddCreateViewModel : BindableObject
    {
        #region bindings

        private ICommand createCommand;
        public ICommand CreateCommand
        {
            get { return this.createCommand; }
            set
            {
                if (this.createCommand != value)
                {
                    this.createCommand = value;
                    OnPropertyChanged("CreateCommand");
                }
            }
        }


        #endregion

        public KeyControl KeyControl { get; set; }

        public AddCreateViewModel()
        {
            this.CreateCommand = new DelegateCommand<object>((o) => { this.Create(); });
        }

        private void Create()
        {
            Process.Start(Constants.WEB_CREATE_NEW_ENDPOINT);
        }

        internal void Drop(System.Windows.DragEventArgs e)
        {
            if (e.Data.GetDataPresent(DataFormats.FileDrop))
            {
                string[] files = (string[])e.Data.GetData(DataFormats.FileDrop);

                if ( (files.Length > 0 && Path.GetExtension(files[0]) == Constants.KEYFILE_VKEYS_EXTENSION) ||
                    (files.Length > 0 && Path.GetExtension(files[0]) == Constants.KEYFILE_JSON_EXTENSION) )
                {
                    this.KeyControl.ImportKeyfile(files[0]);
                }
            }
        }
    }
}
