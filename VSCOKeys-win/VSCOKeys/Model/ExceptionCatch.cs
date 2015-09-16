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
using System.Globalization;
using System.IO;
using System.Windows;

namespace VSCOKeys.Model
{
    /// <summary>
    /// To be registered as the domain UE handler:
    ///     VSCOKeys.Model.ExceptionCatch.ToolName = "toolname";
    ///     VSCOKeys.Model.ExceptionCatch.ToolOwner = "ownername";
    ///     AppDomain.CurrentDomain.UnhandledException += new UnhandledExceptionEventHandler(VSCOKeys.Model.ExceptionCatch.HandleException);
    /// </summary>
    public static class ExceptionCatch
    {
        /// <summary>
        /// Gets or sets the name of the tool.
        /// </summary>
        /// <value>The name of the tool.</value>
        public static string ToolName { get; set; }

        /// <summary>
        /// Gets or sets the tool owner.
        /// </summary>
        /// <value>The tool owner.</value>
        public static string ToolOwner { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether this <see cref="ExceptionNet"/> is in debug. Debug makes the system catch errors even if attached with debugger.
        /// </summary>
        /// <value><c>true</c> if debug; otherwise, <c>false</c>.</value>
        public static bool Debug { get; set; }

        public static string TraceFile { get; set; }

        /// <summary>
        /// Handles the exception.
        /// </summary>
        /// <param name="sender">The sender.</param>
        /// <param name="e">The <see cref="System.UnhandledExceptionEventArgs"/> instance containing the event data.</param>
        [System.Diagnostics.CodeAnalysis.SuppressMessage( "Microsoft.Security", "CA2109:ReviewVisibleEventHandlers", Justification = "By Design." )]
        public static void HandleException( object sender, UnhandledExceptionEventArgs e )
        {
            // do not log errors if a debugger is attached
            if ( !Debug && System.Diagnostics.Debugger.IsAttached )
            {
                return;
            }

            string logDir = Path.Combine( Environment.GetFolderPath( Environment.SpecialFolder.MyDocuments ), ToolName + "Logs" );

            Directory.CreateDirectory( logDir );

            FileInfo logfile = new FileInfo( Path.Combine(
                    logDir,
                    string.Format( CultureInfo.InvariantCulture, ToolName + "ErrorLog_{0}.log", DateTime.Now.ToString( "yyyy-M-d-HH-mm-ss", CultureInfo.InvariantCulture ) ) ) );

            StreamWriter logfileStream = logfile.AppendText();

            logfileStream.WriteLine( DateTime.Now );
            logfileStream.WriteLine( Environment.MachineName );
            Exception currException = (Exception)e.ExceptionObject;
            Exception lastException = (Exception)e.ExceptionObject;
            while ( currException != null )
            {
                lastException = currException;
                logfileStream.WriteLine( "Type Name: " + currException.GetType().Name );
                logfileStream.WriteLine( currException.Message );
                logfileStream.WriteLine();
                logfileStream.WriteLine( currException.StackTrace );
                logfileStream.WriteLine();
                logfileStream.WriteLine();
                currException = currException.InnerException;
            }

            logfileStream.Close();

            string formatString =
                "{1} {0}{0}" +
                "The exception has been logged to disk at: {0}" +
                "{2} {0}{0}" +
                "Trace log file is on disk at: {0}" +
                "{3} {0}{0}" +
                "Please send an email to " + ToolOwner + " with the above files attached.{0}" +
                "If you would like to copy the contents of this box, use ctrl + C";

            string errorMsg = string.Format(
                CultureInfo.InvariantCulture,
                formatString,
                Environment.NewLine,
                lastException.Message,
                logfile.FullName,
                ExceptionCatch.TraceFile);

            MessageBox.Show( errorMsg, "An Error Occured" );

            Application.Current.Shutdown();
        }
    }
}
