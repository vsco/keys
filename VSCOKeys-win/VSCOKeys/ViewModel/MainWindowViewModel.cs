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

namespace VSCOKeys.ViewModel
{
    class MainWindowViewModel : BindableObject
    {
        #region bindings

        private ICommand openListCommand;
        public ICommand OpenListCommand
        {
            get { return openListCommand; }
            set
            {
                if (openListCommand != value)
                {
                    openListCommand = value;
                    OnPropertyChanged("OpenListCommand");
                }
            }
        }

        private ICommand openAddCommand;
        public ICommand OpenAddCommand
        {
            get { return openAddCommand; }
            set
            {
                if (openAddCommand != value)
                {
                    openAddCommand = value;
                    OnPropertyChanged("OpenAddCommand");
                }
            }
        }

        private int selectedTab;
        public int SelectedTab
        {
            get { return selectedTab; }
            set
            {
                if (selectedTab != value)
                {
                    selectedTab = value;
                    OnPropertyChanged("SelectedTab");
                }
            }
        }

        private AddCreateViewModel addCreate;
        public AddCreateViewModel AddCreate
        {
            get { return this.addCreate; }
            set
            {
                if (this.addCreate != value)
                {
                    this.addCreate = value;
                    OnPropertyChanged("AddCreate");
                }
            }
        }


        private ListViewModel list;
        public ListViewModel List
        {
            get { return this.list; }
            set
            {
                if (this.list != value)
                {
                    this.list = value;
                    OnPropertyChanged("List");
                }
            }
        }

        private DetailViewModel detail;
        public DetailViewModel Detail
        {
            get { return this.detail; }
            set
            {
                if (this.detail != value)
                {
                    this.detail = value;
                    OnPropertyChanged("Detail");
                }
            }
        }

        #endregion

        private KeyControl keyControl;
        public KeyControl KeyControl
        {
            get { return this.keyControl; }
            set
            {
                this.keyControl = value;
                this.AddCreate.KeyControl = value;
                this.List.KeyControl = value;
                this.Detail.KeyControl = value;
            }
        }

        public MainWindowViewModel()
        {
            this.AddCreate = new AddCreateViewModel();
            this.List = new ListViewModel();
            this.List.OpenDetail = new Action<string>(this.OpenDetail);
            this.Detail = new DetailViewModel();

            this.OpenListCommand = new DelegateCommand<object>((o) => { this.OpenList(); });
            this.OpenAddCommand = new DelegateCommand<object>((o) => { this.OpenAdd(); });
        }

        public void Close()
        {
            this.KeyControl.mainWindow = null;
            this.KeyControl.MakeLRActive();
        }

        private void OpenAdd()
        {
            this.SelectedTab = 0;
        }

        private void OpenList()
        {
            this.List.Setup();
            this.SelectedTab = 1;
        }

        public void OpenDetail(string uuid)
        {
            this.Detail.Setup(uuid);
            this.SelectedTab = 2;
        }
    }
}
