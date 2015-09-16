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
    class KeyCommandViewModel : BindableObject
    {
        #region bindings


        private string command;
        public string Command
        {
            get { return this.command; }
            set
            {
                if (this.command != value)
                {
                    this.command = value;
                    OnPropertyChanged("Command");
                }
            }
        }

        private string adjustment;
        public string Adjustment
        {
            get { return this.adjustment; }
            set
            {
                if (this.adjustment != value)
                {
                    this.adjustment = value;
                    OnPropertyChanged("Adjustment");
                }
            }
        }

        private string amount;
        public string Amount
        {
            get { return this.amount; }
            set
            {
                if (this.amount != value)
                {
                    this.amount = value;
                    OnPropertyChanged("Amount");
                }
            }
        }

        #endregion

        public KeyCommandViewModel()
        {

        }
    }
}
