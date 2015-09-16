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
    class ListViewModel : BindableObject
    {
        #region bindings

        private ICommand toggleActiveCommand;
        public ICommand ToggleActiveCommand
        {
            get { return this.toggleActiveCommand; }
            set
            {
                if (this.toggleActiveCommand != value)
                {
                    this.toggleActiveCommand = value;
                    OnPropertyChanged("ToggleActiveCommand");
                }
            }
        }

        private ICommand openCommand;
        public ICommand OpenCommand
        {
            get { return this.openCommand; }
            set
            {
                if (this.openCommand != value)
                {
                    this.openCommand = value;
                    OnPropertyChanged("OpenCommand");
                }
            }
        }

        private ICommand showPdfCommand;
        public ICommand ShowPdfCommand
        {
            get { return this.showPdfCommand; }
            set
            {
                if (this.showPdfCommand != value)
                {
                    this.showPdfCommand = value;
                    OnPropertyChanged("ShowPdfCommand");
                }
            }
        }

        private ICommand confirmCommand;
        public ICommand ConfirmCommand
        {
            get { return this.confirmCommand; }
            set
            {
                if (this.confirmCommand != value)
                {
                    this.confirmCommand = value;
                    OnPropertyChanged("ConfirmCommand");
                }
            }
        }

        private ICommand hideConfirmCommand;
        public ICommand HideConfirmCommand
        {
            get { return this.hideConfirmCommand; }
            set
            {
                if (this.hideConfirmCommand != value)
                {
                    this.hideConfirmCommand = value;
                    OnPropertyChanged("HideConfirmCommand");
                }
            }
        }

        private ICommand deleteCommand;
        public ICommand DeleteCommand
        {
            get { return this.deleteCommand; }
            set
            {
                if (this.deleteCommand != value)
                {
                    this.deleteCommand = value;
                    OnPropertyChanged("DeleteCommand");
                }
            }
        }

        private IList<Keyfile> keyfileList;
        public IList<Keyfile> KeyfileList
        {
            get { return this.keyfileList; }
            set
            {
                if (this.keyfileList != value)
                {
                    this.keyfileList = value;
                    OnPropertyChanged("KeyfileList");
                }
            }
        }

        private int selectedIndex;
        public int SelectedIndex
        {
            get { return this.selectedIndex; }
            set
            {
                if (this.selectedIndex != value)
                {
                    this.selectedIndex = value;
                    OnPropertyChanged("SelectedIndex");
                }
            }
        }

        private string nameToDelete;
        public string NameToDelete
        {
            get { return this.nameToDelete; }
            set
            {
                if (this.nameToDelete != value)
                {
                    this.nameToDelete = value;
                    OnPropertyChanged("NameToDelete");
                }
            }
        }

        #endregion

        public KeyControl KeyControl { get; set; }
        public Action<string> OpenDetail { get; set; }

        public ListViewModel()
        {
            this.ToggleActiveCommand = new DelegateCommand<object>((o) => { this.ToggleActive(this.SelectedIndex); });
            this.OpenCommand = new DelegateCommand<object>((o) => { this.OpenDetail(this.KeyfileList[this.SelectedIndex].uuid); });
            this.ShowPdfCommand = new DelegateCommand<object>((o) => { this.ShowPdfKeyfile(); });
            this.ConfirmCommand = new DelegateCommand<object>((o) => { this.ConfirmDeleteKeyfile(); });
            this.HideConfirmCommand = new DelegateCommand<object>((o) => { this.HideConfirmDeleteKeyfile(); });
            this.DeleteCommand = new DelegateCommand<object>((o) => { this.DeleteKeyfile(); });
        }

        private void ToggleActive(int p)
        {
            this.HideConfirmDeleteKeyfile();
            this.KeyControl.ToggleIsActive(this.KeyfileList[this.SelectedIndex].uuid);
            this.Setup();
        }

        private void ShowPdfKeyfile()
        {
            if (this.KeyControl.DoesPdfExist(this.KeyfileList[this.SelectedIndex].uuid))
            {
                Process.Start(this.KeyControl.GetKeyfilePdfPath(this.KeyfileList[this.SelectedIndex].uuid));
            }
        }

        private void ConfirmDeleteKeyfile()
        {
            this.NameToDelete = this.KeyfileList[this.SelectedIndex].uuid;
        }

        private void HideConfirmDeleteKeyfile()
        {
            this.NameToDelete = null;
        }

        private void DeleteKeyfile()
        {
            this.KeyControl.DeleteKeyfile(this.NameToDelete);
            this.HideConfirmDeleteKeyfile();
            this.Setup();
        }

        internal void Setup()
        {
            this.HideConfirmDeleteKeyfile();
            this.KeyfileList = this.KeyControl.GetKeyfileList();
        }
    }
}
