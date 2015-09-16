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
using System.Configuration;
using System.Data;
using System.Linq;
using System.Windows;
using VSCOKeys.View;
using Hardcodet.Wpf.TaskbarNotification;
using VSCOKeys.Model;
using System.ComponentModel;
using System.Threading;
using System.Reflection;
using System.IO.Pipes;
using System.Text;
using System.IO;
using System.Diagnostics;

namespace VSCOKeys
{
    /// <summary>
    /// Interaction logic for App.xaml
    /// </summary>
    public partial class App : Application
    {
        private Action<string> processFileDelegate;
        private string logDir;
        private string traceFilePath;
        internal KeyControl KeyControl { get; set; }

        private void Application_Startup(object sender, StartupEventArgs e)
        {
            ExceptionCatch.ToolName = "VSCOKeys";
            ExceptionCatch.ToolOwner = "support@visualsupply.co";
            AppDomain.CurrentDomain.UnhandledException += new UnhandledExceptionEventHandler(ExceptionCatch.HandleException);

            this.TraceLoggingSetup();
            ExceptionCatch.TraceFile = this.traceFilePath;

            string openedFilename = null;
            this.processFileDelegate = new Action<string>(this.ProcessFile);

            if (e.Args != null && e.Args.Length > 0)
            {
                openedFilename = e.Args[0];
            }

            if (!this.HandleProgramSingularity(openedFilename))
            {
                return;
            }

            this.UpgradeSettingsFile();

            Application.Current.ShutdownMode = System.Windows.ShutdownMode.OnExplicitShutdown;

            App.SetAllowUnsafeHeaderParsing20();

            this.KeyControl = new KeyControl();

            if (!this.KeyControl.Initialize())
            {
                return;
            }

            this.KeyControl.statusThread = new BackgroundWorker();

            this.KeyControl.statusThread.DoWork += new DoWorkEventHandler(statusThread_DoWork);
            this.KeyControl.statusThread.RunWorkerAsync();

            this.KeyControl.StartUpEventLoop();

            this.ProcessFile(openedFilename);
        }

        private void UpgradeSettingsFile()
        {
            System.Reflection.Assembly a = System.Reflection.Assembly.GetExecutingAssembly();
            Version appVersion = a.GetName().Version;
            string appVersionString = appVersion.ToString();

            if (VSCOKeys.Properties.Settings.Default.ApplicationVersion != appVersion.ToString())
            {
                VSCOKeys.Properties.Settings.Default.Upgrade();
                VSCOKeys.Properties.Settings.Default.ApplicationVersion = appVersionString;
            }
        }

        private void TraceLoggingSetup()
        {
            this.logDir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments), "VSCOKeysLogs");
            Directory.CreateDirectory(this.logDir);
            this.traceFilePath = Path.Combine(this.logDir, string.Format("VSCOKeysRunTrace_{0}.log", DateTime.Now.ToString("yyyy-M-d-HH-mm-ss")));
            Debug.Listeners.Add(new TextWriterTraceListener(File.CreateText(this.traceFilePath)));
            Trace.AutoFlush = true;
            this.RemoveExcessLogs();
        }

        private void RemoveExcessLogs()
        {
            string[] files = Directory.GetFiles(this.logDir, "VSCOKeysRunTrace_*.log");

            var descSorted = from file in files
                             orderby file descending
                             select file;

            for (int i = Constants.RUNTRACE_MAX_FILE_COUNT; i < descSorted.Count(); i++)
            {
                try
                {
                    File.Delete(descSorted.ElementAt(i));
                }
                catch (IOException e)
                {
                    KeyControl.TraceLine(string.Format("IOException cleaning up logs: {0}", e));
                }
            }
        }

        private bool HandleProgramSingularity(string openedFilename)
        {
            try
            {
                NamedPipeClientStream pipe = new NamedPipeClientStream(".", Constants.PIPE_NAME, PipeDirection.Out);
                pipe.Connect(1000);
                if (openedFilename == null)
                {
                    openedFilename = string.Empty;
                }

                StreamString ss = new StreamString(pipe);
                ss.WriteString(openedFilename);

                this.Shutdown();
                return false;
            }
            catch (Exception)
            {
                BackgroundWorker listener = new BackgroundWorker();
                listener.DoWork += new DoWorkEventHandler(listener_DoWork);
                listener.RunWorkerAsync();
            }

            return true;
        }

        void listener_DoWork(object sender, DoWorkEventArgs e)
        {
            while (true)
            {
                NamedPipeServerStream pipe = new NamedPipeServerStream(Constants.PIPE_NAME, PipeDirection.In, 1);

                pipe.WaitForConnection();

                StreamString ss = new StreamString(pipe);

                string openedFilename = ss.ReadString();

                this.Dispatcher.Invoke(this.processFileDelegate, openedFilename);

                pipe.Close();
            }
        }

        private void ProcessFile(string openedFilename)
        {
            if (!string.IsNullOrEmpty(openedFilename))
            {
                this.KeyControl.ImportKeyfile(openedFilename);
            }
            else if (openedFilename != null) // empty string comes from second instance of app getting opened
            {
                this.KeyControl.ShowMainWindow(null, null);
            }
        }

        private class StreamString
        {
            private Stream ioStream;
            private UTF8Encoding streamEncoding;

            public StreamString(Stream ioStream)
            {
                this.ioStream = ioStream;
                streamEncoding = new UTF8Encoding();
            }

            public string ReadString()
            {
                int len = 0;

                len = ioStream.ReadByte() * 256;
                len += ioStream.ReadByte();
                byte[] inBuffer = new byte[len];
                ioStream.Read(inBuffer, 0, len);

                return streamEncoding.GetString(inBuffer);
            }

            public int WriteString(string outString)
            {
                byte[] outBuffer = streamEncoding.GetBytes(outString);
                int len = outBuffer.Length;
                if (len > UInt16.MaxValue)
                {
                    len = (int)UInt16.MaxValue;
                }
                ioStream.WriteByte((byte)(len / 256));
                ioStream.WriteByte((byte)(len & 255));
                ioStream.Write(outBuffer, 0, len);
                ioStream.Flush();

                return outBuffer.Length + 2;
            }
        }

        void statusThread_DoWork(object sender, DoWorkEventArgs e)
        {
            while (true)
            {
                this.Dispatcher.Invoke(new Action(this.KeyControl.StatusBarUpdate));

                Thread.Sleep(500);
            }
        }

        // This is to allow .net to communicate with my shoddy http server code.
        public static bool SetAllowUnsafeHeaderParsing20()
        {
            //Get the assembly that contains the internal class
            Assembly aNetAssembly = Assembly.GetAssembly(typeof(System.Net.Configuration.SettingsSection));
            if (aNetAssembly != null)
            {
                //Use the assembly in order to get the internal type for the internal class
                Type aSettingsType = aNetAssembly.GetType("System.Net.Configuration.SettingsSectionInternal");
                if (aSettingsType != null)
                {
                    //Use the internal static property to get an instance of the internal settings class.
                    //If the static instance isn't created allready the property will create it for us.
                    object anInstance = aSettingsType.InvokeMember("Section",
                    BindingFlags.Static | BindingFlags.GetProperty | BindingFlags.NonPublic, null, null, new object[] { });
                    if (anInstance != null)
                    {
                        //Locate the private bool field that tells the framework is unsafe header parsing should be allowed or not
                        FieldInfo aUseUnsafeHeaderParsing = aSettingsType.GetField("useUnsafeHeaderParsing", BindingFlags.NonPublic | BindingFlags.Instance);
                        if (aUseUnsafeHeaderParsing != null)
                        {
                            aUseUnsafeHeaderParsing.SetValue(anInstance, true);
                            return true;
                        }
                    }
                }
            }
            return false;
        }

        private void Application_Exit(object sender, ExitEventArgs e)
        {
            VSCOKeys.Properties.Settings.Default.Save();
        }
    }
}
