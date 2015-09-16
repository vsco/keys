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
using System.Windows.Data;
using System.Globalization;
using System.Windows;
using VSCOKeys.Model;
using System.Drawing;

namespace VSCOKeys.ViewModel
{
    public sealed class AmountToColorConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            if (value != null && value is string)
            {
                string amount = (string)value;

                float floatVal = 0;
                if (float.TryParse(amount, out floatVal))
                {
                    if (floatVal > 0)
                    {
                        return "#a7a648";
                    }
                    else if (floatVal < 0)
                    {
                        return "#ff3300";
                    }

                }
            }

            return "Black";
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}
