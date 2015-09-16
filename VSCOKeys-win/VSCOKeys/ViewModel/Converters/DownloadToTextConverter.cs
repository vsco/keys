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

namespace VSCOKeys.ViewModel
{
    public sealed class DownloadToTextConverter : IValueConverter
    {
        public object Convert(object value, Type targetType, object parameter, CultureInfo culture)
        {
            double? downloadAmount = value as double?;

            if (downloadAmount != null && downloadAmount.HasValue)
            {
                if (downloadAmount <= 0)
                {
                    return "DOWNLOAD PDF LAYOUT";
                }
                else if (downloadAmount >= 100)
                {
                    return "VIEW PDF LAYOUT";
                }
                else
                {
                    return string.Format("DOWNLOADING {0:0.}%", downloadAmount);
                }
            }

            return "DOWNLOAD PDF LAYOUT";
        }

        public object ConvertBack(object value, Type targetType, object parameter, CultureInfo culture)
        {
            throw new NotImplementedException();
        }
    }
}
