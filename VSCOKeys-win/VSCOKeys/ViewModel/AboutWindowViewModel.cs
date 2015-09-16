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
using System.Text.RegularExpressions;
using System.Windows;
using System.Diagnostics;
using System.Windows.Media;
using System.Reflection;

namespace VSCOKeys.ViewModel
{
    class AboutWindowViewModel : BindableObject
    {
        #region bindings

        private string version;
        public string Version
        {
            get { return this.version; }
            set
            {
                if (this.version != value)
                {
                    this.version = value;
                    OnPropertyChanged("Version");
                }
            }
        }

        private ICommand tosCommand;
        public ICommand TOSCommand
        {
            get { return this.tosCommand; }
            set
            {
                if (this.tosCommand != value)
                {
                    this.tosCommand = value;
                    OnPropertyChanged("TOSCommand");
                }
            }
        }

        private ICommand privPolicyCommand;
        public ICommand PrivPolicyCommand
        {
            get { return this.privPolicyCommand; }
            set
            {
                if (this.privPolicyCommand != value)
                {
                    this.privPolicyCommand = value;
                    OnPropertyChanged("PrivPolicyCommand");
                }
            }
        }

        private ICommand supportCommand;
        public ICommand SupportCommand
        {
            get { return this.supportCommand; }
            set
            {
                if (this.supportCommand != value)
                {
                    this.supportCommand = value;
                    OnPropertyChanged("SupportCommand");
                }
            }
        }

        #endregion

        public KeyControl KeyControl { get; set; }
        public Window Window { get; set; }

        public AboutWindowViewModel()
        {
            this.TOSCommand = new DelegateCommand<object>(e => this.TOSButtonClicked());
            this.PrivPolicyCommand = new DelegateCommand<object>(e => this.PrivPolicyButtonClicked());
            this.SupportCommand = new DelegateCommand<object>(e => this.SupportButtonClicked());

            Version vers = Assembly.GetEntryAssembly().GetName().Version;
            this.Version = string.Format(Constants.ABOUT_WINDOW_VERSION_FORMAT, Constants.VERSION_SKU, vers.ToString());
        }

        internal void WindowClosing()
        {
            this.KeyControl.aboutWindow = null;
            this.KeyControl.MakeLRActive();
        }

        private void TOSButtonClicked()
        {
            Process.Start(Constants.WEB_TERMS_OF_SERVICE);
        }

        private void PrivPolicyButtonClicked()
        {
            Process.Start(Constants.WEB_PRIVACY_POLICY);
        }

        private void SupportButtonClicked()
        {
            Process.Start(Constants.WEB_SUPPORT);
        }

    }
}
