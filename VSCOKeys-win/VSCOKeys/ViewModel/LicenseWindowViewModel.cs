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

namespace VSCOKeys.ViewModel
{
    class LicenseWindowViewModel : BindableObject
    {
        private bool isOkPressed;
        private Regex editingRegex;
        private Regex daysFindRegex;
        private Regex dashRemoveRegex;
        private Regex dashRegex;

        #region bindings

        private bool isValid;
        public bool IsValid
        {
            get { return this.isValid; }
            set
            {
                if (this.isValid != value)
                {
                    this.isValid = value;
                    OnPropertyChanged("IsValid");
                }
            }
        }

        private bool isTrial;
        public bool IsTrial
        {
            get { return this.isTrial; }
            set
            {
                if (this.isTrial != value)
                {
                    this.isTrial = value;
                    OnPropertyChanged("IsTrial");
                }
            }
        }

        private string error;
        public string Error
        {
            get { return this.error; }
            set
            {
                if (this.error != value)
                {
                    this.error = value;
                    OnPropertyChanged("Error");
                }
            }
        }

        private string license;
        public string License
        {
            get { return this.license; }
            set
            {
                if (this.license != value)
                {
                    this.license = value;
                    OnPropertyChanged("License");
                }
            }
        }

        private ImageSource validImage;
        public ImageSource ValidImage
        {
            get { return this.validImage; }
            set
            {
                if (this.validImage != value)
                {
                    this.validImage = value;
                    OnPropertyChanged("ValidImage");
                }
            }
        }

        private ICommand okCommand;
        public ICommand OkCommand
        {
            get { return this.okCommand; }
            set
            {
                if (this.okCommand != value)
                {
                    this.okCommand = value;
                    OnPropertyChanged("OkCommand");
                }
            }
        }

        private ICommand getLicenseCommand;
        public ICommand GetLicenseCommand
        {
            get { return this.getLicenseCommand; }
            set
            {
                if (this.getLicenseCommand != value)
                {
                    this.getLicenseCommand = value;
                    OnPropertyChanged("GetLicenseCommand");
                }
            }
        }

        private ICommand enterKeyCommand;
        public ICommand EnterKeyCommand
        {
            get { return this.enterKeyCommand; }
            set
            {
                if (this.enterKeyCommand != value)
                {
                    this.enterKeyCommand = value;
                    OnPropertyChanged("EnterKeyCommand");
                }
            }
        }

        private ICommand continueTrialCommand;
        public ICommand ContinueTrialCommand
        {
            get { return this.continueTrialCommand; }
            set
            {
                if (this.continueTrialCommand != value)
                {
                    this.continueTrialCommand = value;
                    OnPropertyChanged("ContinueTrialCommand");
                }
            }
        }

        #endregion

        public KeyControl KeyControl { get; set; }
        public Window Window { get; set; }

        public LicenseWindowViewModel()
        {
            this.isOkPressed = false;
            this.editingRegex = new Regex("[^A-Z,1-9]");
            this.dashRegex = new Regex("^([A-Z,1-9]{0,4})([A-Z,1-9]{0,4})([A-Z,1-9]{0,4})([A-Z,1-9]{0,4})");
            this.dashRemoveRegex = new Regex("-+$");
            this.daysFindRegex = new Regex("[0-9]+.*$");

            this.OkCommand = new DelegateCommand<object>(e => this.OkButtonClicked());
            this.GetLicenseCommand = new DelegateCommand<object>(e => this.GetLicenseButtonClicked());
            this.EnterKeyCommand = new DelegateCommand<object>(e => this.EnterKeyButtonClicked());
            this.ContinueTrialCommand = new DelegateCommand<object>(e => this.ContinueTrialClicked());
        }

        private void SetState()
        {
            if (!this.IsTrial)
            {
                this.IsValid = true; //this.KeyControl.IsValidLicenseRegex(this.License);
            }
        }

        internal void WindowClosing()
        {
            this.KeyControl.MakeLRActive();

            if (!this.isOkPressed)
            {
                KeyControl.TraceLine("License prompt was closed");
                this.KeyControl.QuitApplication();
            }
        }

        private void OkButtonClicked()
        {
            //this.KeyControl.CheckLicenseRegex(this.License);

            this.isOkPressed = true;

            this.Window.Close();
        }

        private void GetLicenseButtonClicked()
        {
            Process.Start(Constants.WEB_GET_LICENSE);
        }

        private void EnterKeyButtonClicked()
        {
            this.IsTrial = false;
            this.SetState();
            this.Error = "ENTER LICENSE";
        }

        private void ContinueTrialClicked()
        {
            this.KeyControl.authContinueTrial = true;

            this.OkButtonClicked();
        }

        public void LicenseDidChange()
        {
            string newLicense = this.License;
            // make upcase
            newLicense = newLicense.ToUpperInvariant();

            // remove non-alphanum characters
            newLicense = this.editingRegex.Replace(newLicense, string.Empty);

            // limit to 16 chars
            int maxLen = 16;
            if (newLicense.Length > maxLen)
            {
                newLicense = newLicense.Substring(0, maxLen);
            }

            // add dashes every four digits (4,8,12)
            Match match = this.dashRegex.Match(newLicense);
            newLicense = match.Groups[1].Value + "-" + match.Groups[2].Value + "-" + match.Groups[3].Value + "-" + match.Groups[4].Value;
            newLicense = this.dashRemoveRegex.Replace(newLicense, string.Empty);

            this.License = newLicense;

            this.SetState();
        }
    }
}
