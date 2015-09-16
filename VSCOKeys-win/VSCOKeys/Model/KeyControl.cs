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
using System.Web.Script.Serialization;
using Hardcodet.Wpf.TaskbarNotification;
using System.Windows.Controls;
using VSCOKeys.View;
using System.IO;
using System.Security.Cryptography;
using System.Threading;
using System.Windows;
using System.Diagnostics;
using System.Runtime.InteropServices;
using VSCOKeys.ViewModel;
using System.ComponentModel;
using System.Net;
using System.Text.RegularExpressions;
using System.Net.NetworkInformation;
using System.Web;
using System.Reflection;
using System.Management;
using Microsoft.Win32;

namespace VSCOKeys.Model
{
    class KeyControl
    {
        private bool authSuccess;
        public bool authContinueTrial;
        private TaskbarIcon statusBar;
        private JavaScriptSerializer jsSerializer;
        public Dictionary<string, string> keyMapping;
        public Dictionary<string, string> adjustmentMapping;
        private Dictionary<string, string> winKeyMapping;
        public MainWindow mainWindow;
        public AboutWindow aboutWindow;
        private string activeKeyfile;
        private MenuItem ToggleMenuItem { get; set; }
        private Dictionary<string, Keyfile> keyfileList;
        private bool isServerAvailable;
        public QuickWindow quickWindow;
        private Int32 controlToggleKey;
        public BackgroundWorker statusThread;
        private bool isKeyControlActive;
        private IntPtr hookID;
        private LowLevelKeyboardProc hookProc;
        private bool isLWinKeyDown;
        private bool isRWinKeyDown;
        private List<KeyCommand> keysDict;
        private string authUUID;
        private string authToken;
        private string authTimestamp;
        private List<SentKey> sentKeys = new List<SentKey>();
        public string keyfileDirectory;
        private LRVersion lrVersion = LRVersion.UNSET;
        private bool isAuthPromptShown;
        private bool lrWindowWasClosed;

        private delegate void SendUpdateDelegate(Dictionary<string,string> dict);
        private SendUpdateDelegate sendUpdateDelegate;

        public bool IsDead { get; set; }

        public KeyControl()
        {
        }

        public bool Initialize()
        {
            if (Properties.Settings.Default.KeyfileSettings == null)
            {
                Properties.Settings.Default.KeyfileSettings = new KeyfileSettingsDictionary();
            }

            this.sendUpdateDelegate = new SendUpdateDelegate(this.SendUpdate);

            this.authSuccess = true;
            this.authContinueTrial = false;
            this.isAuthPromptShown = false;

            this.jsSerializer = new JavaScriptSerializer();
            this.CreateAndVerifyKeyfileDirectory();

            if (this.QuitIfLRClosed())
            {
                return false;
            }

            this.lrVersion = this.GetLRVersion();

            this.InitMappings();

            this.LoadAllKeyfiles();

            this.statusBar = new TaskbarIcon();
            this.statusBar.Icon = Properties.Resources.StatusBarIcon_Inactive;
            this.statusBar.ToolTipText = Constants.STATUSMENU_HOVER_INACTIVE;
            this.statusBar.TrayMouseDoubleClick += new RoutedEventHandler(statusBar_TrayMouseDoubleClick);

            this.ResetStatusMenu();

            this.MakeLRActive();

            return true;
        }

        public static void TraceLine(string line)
        {
            Trace.WriteLine(string.Format("{0}: {1}", DateTime.Now.ToString("u"), line));
        }

        #region Server Connection

        private void SendUpdate(Dictionary<string, string> update)
        {
            HttpWebRequest req = (HttpWebRequest)WebRequest.Create(Constants.SERVER_UPDATE_ENDPOINT);

            string json = this.jsSerializer.Serialize(update);
            byte[] bytes = Encoding.UTF8.GetBytes(json);

            req.ContentLength = bytes.Length;
            req.ContentType = "application/json";

            req.Method = "POST";

            try
            {
                Stream dataStream = req.GetRequestStream();
                dataStream.Write(bytes, 0, bytes.Length);

                dataStream.Close();

                HttpWebResponse response = (HttpWebResponse)req.GetResponse();

                KeyControl.TraceLine(string.Format("SendUpdate success: {0}", update.Aggregate(string.Empty, (output, kv) => { return string.Format("{0}{1} = {2}{3}", output, kv.Key.ToString(), kv.Value.ToString(), Environment.NewLine); }, (output) => { return string.Format("{{ {0}{1} }}", Environment.NewLine, output); })));
                this.isServerAvailable = true;

                response.Close();
            }
            catch (WebException e)
            {
                KeyControl.TraceLine(string.Format("Server connect failed: {0}", e.Message));
                this.isServerAvailable = false;
            }
        }

        private void CheckServerAvailability()
        {
            this.statusBar.Dispatcher.BeginInvoke(this.sendUpdateDelegate, new Dictionary<string, string>());
        }

        #endregion

        #region Menu

        void statusBar_TrayMouseDoubleClick(object sender, RoutedEventArgs e)
        {
            this.ShowMainWindow(sender, e);
        }

        public void ShowMainWindow(object sender, System.Windows.RoutedEventArgs e)
        {
            if (this.mainWindow == null)
            {
                this.mainWindow = new MainWindow();
                (this.mainWindow.DataContext as MainWindowViewModel).KeyControl = this;
                this.mainWindow.Show();
                this.mainWindow.Activate();
            }
        }

        private void ShowDetailWindow()
        {
            this.ShowMainWindow(null, null);
            (this.mainWindow.DataContext as MainWindowViewModel).OpenDetail(this.activeKeyfile);
        }

        private void ShowAboutWindow(object sender, System.Windows.RoutedEventArgs e)
        {
            if (this.aboutWindow == null)
            {
                this.aboutWindow = new AboutWindow();
                (this.aboutWindow.DataContext as AboutWindowViewModel).KeyControl = this;
                this.aboutWindow.Show();
                this.aboutWindow.Activate();
            }
        }

        private void ShowQuickList()
        {
            if (this.DoesPdfExist(this.keyfileList[this.activeKeyfile].uuid))
            {
                Process.Start(this.GetKeyfilePdfPath(this.keyfileList[this.activeKeyfile].uuid));
            }
            else
            {
                this.ShowDetailWindow();
            }
        }

        private void DismissQuickList()
        {
            if (this.quickWindow != null)
            {
                this.quickWindow.Close();
            }
        }

        public void QuitApplication()
        {
            App.Current.Shutdown();
        }

        private void QuitApplication(object sender, System.Windows.RoutedEventArgs e)
        {
            this.QuitApplication();
        }

        private void BringLicenseWindowToFront(object sender, System.Windows.RoutedEventArgs e)
        {

        }

        private void MenuToggleKeysActive(object sender, System.Windows.RoutedEventArgs e)
        {
            this.ToggleKeyControlActive();
        }

        private void SetMenuForKeyFileActive()
        {
            if (this.statusBar == null)
            {
                return;
            }

            foreach (object obj in this.statusBar.ContextMenu.Items)
            {
                MenuItem item = obj as MenuItem;

                if (item == null)
                {
                    continue;
                }

                string keyfile = item.Header as string;

                if (keyfile != null)
                {
                    if (keyfile == this.keyfileList[this.activeKeyfile].name)
                    {
                        item.IsChecked = true;
                    }
                    else
                    {
                        item.IsChecked = false;
                    }
                }
            }
        }

        private void KeyfileMenuSelected(object sender, System.Windows.RoutedEventArgs e)
        {
            MenuItem item = sender as MenuItem;

            string keyfileName = item.Header as string;

            var query = from keyfile in this.keyfileList.Values
                        where keyfile.name == keyfileName
                        select keyfile.uuid;

            this.activeKeyfile = query.FirstOrDefault();

            Properties.Settings.Default.ActiveKeyfile = this.activeKeyfile;

            this.SetMenuForKeyFileActive();

            this.LoadDictionaryFromActiveKeysFile();

            this.MakeLRActive();
        }

        private MenuItem AddItemToMenu(string title, ContextMenu menu, System.Windows.RoutedEventHandler handler)
        {
            MenuItem mi = new MenuItem();
            mi.Header = title;
            mi.Click += handler;
            menu.Items.Add(mi);

            return mi;
        }

        private void ResetStatusMenu()
        {
            ContextMenu menu = new ContextMenu();
            /*
            if (!this.authSuccess)
            {
                this.AddItemToMenu(Constants.STATUSMENUITEM_REGISTER, menu, new System.Windows.RoutedEventHandler(this.BringLicenseWindowToFront));
            }
            else
            {*/
                this.ToggleMenuItem = this.AddItemToMenu(Constants.STATUSMENUITEM_INACTIVE, menu, new System.Windows.RoutedEventHandler(this.MenuToggleKeysActive));
                this.AddItemToMenu(Constants.STATUSMENUITEM_PREFERENCES, menu, new System.Windows.RoutedEventHandler(this.ShowMainWindow));
                menu.Items.Add(new Separator());

                List<string> keys = new List<string>();
                if (this.keyfileList != null)
                {
                    keys = this.keyfileList.Keys.ToList();
                    keys.Sort((key1, key2) => { return this.keyfileList[key1].name.CompareTo(this.keyfileList[key2].name); });
                }

                foreach (string key in keys)
                {
                    Keyfile keyfile = this.keyfileList[key];

                    if (!keyfile.isActive)
                    {
                        continue;
                    }

                    this.AddItemToMenu(keyfile.name, menu, new System.Windows.RoutedEventHandler(this.KeyfileMenuSelected));
                }

                menu.Items.Add(new Separator());

                this.AddItemToMenu(Constants.STATUSMENUITEM_ABOUT, menu, new System.Windows.RoutedEventHandler(this.ShowAboutWindow));
            //}

            this.AddItemToMenu(Constants.STATUSMENUITEM_QUIT, menu, new System.Windows.RoutedEventHandler(this.QuitApplication));

            if (this.statusBar != null)
            {
                this.statusBar.ContextMenu = menu;
            }

            if (this.authSuccess)
            {
                this.SetMenuForKeyFileActive();
            }
        }

        public void StatusBarUpdate()
        {
            if (this.CheckIsKeySystemEngaged())
            {
                if (this.isServerAvailable)
                {
                    this.statusBar.Icon = Properties.Resources.StatusBarIcon_Active;
                    this.statusBar.ToolTipText = Constants.STATUSMENU_HOVER_ACTIVE;
                    this.ToggleMenuItem.Header = Constants.STATUSMENUITEM_ACTIVE;
                }
                else
                {
                    this.statusBar.Icon = Properties.Resources.StatusBarIcon_Error;
                    this.statusBar.ToolTipText = Constants.STATUSMENU_HOVER_ERROR;
                    this.ToggleMenuItem.Header = Constants.STATUSMENUITEM_ERROR;
                }
            }
            else
            {
                this.statusBar.Icon = Properties.Resources.StatusBarIcon_Inactive;
                this.statusBar.ToolTipText = Constants.STATUSMENU_HOVER_INACTIVE;

                if (this.ToggleMenuItem != null)
                {
                    this.ToggleMenuItem.Header = Constants.STATUSMENUITEM_INACTIVE;
                }
            }

            this.QuitIfLRClosed();

            this.ReportHookFailure();
        }

        #endregion

        #region Importing

        public void ImportKeyfile(string keyfilePath)
        {
            Keyfile keyfile = null;

            try
            {
                keyfile = this.jsSerializer.Deserialize<Keyfile>(this.DecryptFile(keyfilePath));
            }
            catch (InvalidOperationException e)
            {
                MessageBox.Show(string.Format(Constants.IMPORT_KEYFILE_BAD_FORMAT, e.Message), Constants.IMPORT_KEYFILE_TITLE_ERROR);
                return;
            }

            if (Assembly.GetEntryAssembly().GetName().Version.ToString().CompareTo(keyfile.version) < 0)
            {
                MessageBox.Show(Constants.IMPORT_KEYFILE_NEWER_LAYOUT, Constants.IMPORT_KEYFILE_TITLE_ERROR);
                return;
            }

            if (keyfile.lrVersion != this.lrVersion)
            {
                MessageBox.Show(string.Format(Constants.IMPORT_KEYFILE_WRONG_VERSION, keyfile.lrVersion, this.lrVersion), Constants.IMPORT_KEYFILE_TITLE_ERROR);
                return;
            }

            string filenameVKEYS = keyfile.uuid + Constants.KEYFILE_VKEYS_EXTENSION;
            string toPathVKEYS = Path.Combine(this.keyfileDirectory, filenameVKEYS);

            if (File.Exists(toPathVKEYS))
            {
                File.Delete(toPathVKEYS);
                return;
            }

            string filenameJSON = keyfile.uuid + Constants.KEYFILE_JSON_EXTENSION;
            string toPathJSON = Path.Combine(this.keyfileDirectory, filenameJSON);

            if (File.Exists(toPathJSON))
            {
                File.Delete(toPathJSON);
                return;
            }

            File.Move(keyfilePath, toPathJSON);

            this.LoadAllKeyfiles();
            this.LoadDictionaryFromActiveKeysFile();
            this.ResetStatusMenu();

            this.DeletePdfFile(keyfile.uuid);

            MessageBox.Show(string.Format(Constants.IMPORT_KEYFILE_SUCCESS, keyfile.name), Constants.IMPORT_KEYFILE_TITLE_SUCCESS);
        }

        #endregion

        #region Lightroom Integration

        private Process GetLRRunningInstance()
        {
            Process[] processes = Process.GetProcessesByName(Constants.LIGHTROOM_EXE_NAME);

            if (processes.Length > 0)
            {
                return processes[0];
            }

            return null;
        }

        #region dll imports
        [StructLayout(LayoutKind.Sequential)]
        internal struct Rect
        {
            public int Left;
            public int Top;
            public int Right;
            public int Bottom;
        }

        [StructLayout(LayoutKind.Sequential)]
        internal struct GuiThreadInfo
        {
            public int cbSize;
            public uint flags;
            public IntPtr hwndActive;
            public IntPtr hwndFocus;
            public IntPtr hwndCapture;
            public IntPtr hwndMenuOwner;
            public IntPtr hwndMoveSize;
            public IntPtr hwndCaret;
            public Rect rcCaret;
        }

        [DllImport("user32.dll", SetLastError = true)]
        internal static extern bool GetGUIThreadInfo(uint idThread, ref GuiThreadInfo lpgui);

        static IntPtr GetFocusedHandle()
        {
            var info = new GuiThreadInfo();
            info.cbSize = Marshal.SizeOf(info);
            if (!GetGUIThreadInfo(0, ref info))
                throw new Win32Exception();
            return info.hwndFocus;
        }

        [DllImportAttribute("user32.dll", EntryPoint = "SetForegroundWindow")]
        [return: MarshalAsAttribute(UnmanagedType.Bool)]
        public static extern bool SetForegroundWindow([InAttribute()] IntPtr hWnd);

        [DllImportAttribute("user32.dll", EntryPoint = "GetForegroundWindow")]
        public static extern IntPtr GetForegroundWindow();

        [DllImportAttribute("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);

        [DllImportAttribute("user32.dll", EntryPoint = "IsIconic")]
        [return: MarshalAsAttribute(UnmanagedType.Bool)]
        public static extern bool IsIconic([InAttribute()] IntPtr hWnd);

        [DllImportAttribute("user32.dll", EntryPoint = "ShowWindow")]
        [return: MarshalAsAttribute(UnmanagedType.Bool)]
        public static extern bool ShowWindow([InAttribute()] IntPtr hWnd, int nCmdShow);

        [DllImportAttribute("user32.dll", EntryPoint = "GetWindowThreadProcessId")]
        public static extern uint GetWindowThreadProcessId([InAttribute()] IntPtr hWnd, IntPtr lpdwProcessId);

        [DllImportAttribute("kernel32.dll", EntryPoint = "GetCurrentThreadId")]
        public static extern uint GetCurrentThreadId();

        [DllImportAttribute("user32.dll", EntryPoint = "AttachThreadInput")]
        [return: MarshalAsAttribute(UnmanagedType.Bool)]
        public static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, [System.Runtime.InteropServices.MarshalAsAttribute(UnmanagedType.Bool)] bool fAttach);

        [DllImportAttribute("user32.dll", EntryPoint = "BringWindowToTop")]
        [return: MarshalAsAttribute(UnmanagedType.Bool)]
        public static extern bool BringWindowToTop([InAttribute()] IntPtr hWnd);

        #endregion

        private bool IsForegroundProcess(Process proc)
        {
            IntPtr hwnd = KeyControl.GetForegroundWindow();
            if (hwnd == IntPtr.Zero) return false;

            uint foregroundPid = KeyControl.GetWindowThreadProcessId(hwnd, IntPtr.Zero);
            if (foregroundPid == 0)
            {
                return false;
            }

            uint mainPid = KeyControl.GetWindowThreadProcessId(proc.MainWindowHandle, IntPtr.Zero);
            if (mainPid == 0)
            {
                return false;
            }

            return (foregroundPid == mainPid);
        }

        private bool CheckIsLRInForeground()
        {
            Process lr = this.GetLRRunningInstance();

            if (lr != null)
            {
                return this.IsForegroundProcess(lr);
            }

            return false;
        }

        private bool IsLRRunning()
        {
            return this.GetLRRunningInstance() != null;
        }

        private bool IsLRWindowOpen()
        {
            Process lr = this.GetLRRunningInstance();

            if (lr == null)
            {
                return false;
            }

            if (lr.MainWindowHandle == IntPtr.Zero)
            {
                if (this.lrWindowWasClosed)
                {
                    return false;
                }

                this.lrWindowWasClosed = true;

                return true;
            }

            this.lrWindowWasClosed = false;

            return true;
        }

        public void MakeLRActive()
        {
            foreach (Window win in App.Current.Windows)
            {
                if (win.IsVisible)
                {
                    return;
                }
            }

            Process lr = this.GetLRRunningInstance();

            if (lr != null)
            {
                KeyControl.SetForegroundWindow(lr.MainWindowHandle);
            }
        }

        // this is probably slow-- don't run this every frame.
        public LRVersion GetLRVersion()
        {
            Process lr = this.GetLRRunningInstance();

            FileVersionInfo fvi = null;

            var wmiQueryString = "SELECT ProcessId, ExecutablePath, CommandLine FROM Win32_Process";
            using (var searcher = new ManagementObjectSearcher(wmiQueryString))
            using (var results = searcher.Get())
            {
                var query = from mo in results.Cast<ManagementObject>()
                            where lr.Id == (int)(uint)mo["ProcessId"]
                            select (string)mo["ExecutablePath"];

                string filepath = query.SingleOrDefault();

                fvi = FileVersionInfo.GetVersionInfo(filepath);
            }

            if (fvi == null)
            {
                return LRVersion.UNKNOWN;
            }

            if (fvi.ProductMajorPart == 4 || fvi.ProductMajorPart == 5 || fvi.ProductMajorPart == 6)
            {
                return LRVersion.LR4;
            }
            else if (fvi.ProductMajorPart == 3)
            {
                return LRVersion.LR3;
            }

            return LRVersion.UNKNOWN;
        }

        private bool QuitIfLRClosed()
        {
            if (!this.IsLRWindowOpen())
            {
                KeyControl.TraceLine("Lightroom window was detected as closed. Shutting down");
                this.QuitApplication();

                return true;
            }

            return false;
        }

        private bool privateIsInTextBox = false;
        private bool IsInTextBox()
        {
            bool prevIsInTextBox = this.privateIsInTextBox;
            IntPtr focusedHandle = KeyControl.GetFocusedHandle();
            if (focusedHandle != IntPtr.Zero)
            {
                StringBuilder ClassName = new StringBuilder(100);
                int nRet = GetClassName(focusedHandle, ClassName, ClassName.Capacity);

                if (nRet != 0)
                {
                    this.privateIsInTextBox = (string.Compare(ClassName.ToString(), "Edit", true) == 0);
                }
                else
                {
                    this.privateIsInTextBox = false;
                }
            }

            if (!prevIsInTextBox && this.privateIsInTextBox)
            {
                KeyControl.TraceLine("Keys inactive: Textbox was entered.");
            }
            else if (prevIsInTextBox && !this.privateIsInTextBox)
            {
                KeyControl.TraceLine("Keys active: Textbox was exited.");
            }

            return this.privateIsInTextBox;
        }

        #endregion

        #region Keyfile List Management

        private void CreateAndVerifyKeyfileDirectory()
        {
            this.keyfileDirectory = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData, Environment.SpecialFolderOption.DoNotVerify), "VSCOKeyfiles");

            if (!Directory.Exists(this.keyfileDirectory))
            {
                Directory.CreateDirectory(this.keyfileDirectory);
            }

            string baseKeyfileDir = Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), "Keyfiles");
            Array.ForEach(Directory.GetFiles(baseKeyfileDir, "*" + Constants.KEYFILE_VKEYS_EXTENSION), (f) => { this.CopyIfNewer(f, Path.Combine(this.keyfileDirectory, Path.GetFileName(f))); });
            Array.ForEach(Directory.GetFiles(baseKeyfileDir, "*" + Constants.KEYFILE_JSON_EXTENSION), (f) => { this.CopyIfNewer(f, Path.Combine(this.keyfileDirectory, Path.GetFileName(f))); });
        }

        private void CopyIfNewer(string source, string destination)
        {
            if (File.GetLastWriteTimeUtc(source) > File.GetLastWriteTimeUtc(destination) || !File.Exists(destination))
            {
                File.Copy(source, destination, true);
            }
        }

        internal string GetKeyfilePdfPath(string uuid)
        {
            return Path.Combine(this.keyfileDirectory, uuid + ".pdf");
        }

        internal bool DoesPdfExist(string uuid)
        {
            return File.Exists(this.GetKeyfilePdfPath(uuid));
        }

        internal void DeletePdfFile(string uuid)
        {
            File.Delete(this.GetKeyfilePdfPath(uuid));
        }

        internal void ToggleIsActive(string uuid)
        {
            this.keyfileList[uuid].isActive = !this.keyfileList[uuid].isActive;
            Properties.Settings.Default.KeyfileSettings[uuid].isActive = this.keyfileList[uuid].isActive;
            this.ResetStatusMenu();
        }

        internal void DeleteKeyfile(string uuid)
        {
            string filePath = Path.Combine(this.keyfileDirectory, this.keyfileList[uuid].filename);
            File.Delete(filePath);

            this.LoadAllKeyfiles();
            this.ResetStatusMenu();
        }

        public IList<Keyfile> GetKeyfileList()
        {
            var query = from keyfile in this.keyfileList.Values
                        orderby keyfile.name ascending
                        select keyfile;
            return query.ToList();
        }

        internal Keyfile GetKeyfile(string uuid)
        {
            return this.keyfileList[uuid];
        }

        public string DecryptFile(string filePath)
        {

            byte[] fileContents = File.ReadAllBytes(filePath);
            MemoryStream ms = new MemoryStream(fileContents);
            StreamReader sr = new StreamReader(ms);

            if( Path.GetExtension(filePath).Equals(Constants.KEYFILE_VKEYS_EXTENSION, StringComparison.OrdinalIgnoreCase )){
                RijndaelManaged aes128 = new RijndaelManaged();
                ICryptoTransform decryptor = aes128.CreateDecryptor(Encoding.ASCII.GetBytes(Constants.KEYFILE_AES_KEY), new byte[16]);
                CryptoStream cs = new CryptoStream(ms, decryptor, CryptoStreamMode.Read);
                sr = new StreamReader(cs);
            }

            return sr.ReadToEnd();
        }

        private Keyfile GetLatestVersion(string contents)
        {
            Keyfile keyfile = this.jsSerializer.Deserialize<Keyfile>(contents);

            foreach (var key in keyfile.keys)
            {
                if (key.adj.ContainsKey(Constants.KEYFILE_ADJUSTMENT_REMAP_NODENAME))
                {
                    string remapKey = key.adj[Constants.KEYFILE_ADJUSTMENT_REMAP_NODENAME] as string;
                    Modifiers remapMod = Modifiers.None;

                    if (remapKey == null)
                    {
                        Dictionary<string, object> remapDict = key.adj[Constants.KEYFILE_ADJUSTMENT_REMAP_NODENAME] as Dictionary<string, object>;

                        if (remapDict != null)
                        {
                            remapKey = (string)remapDict[Constants.KEYFILE_KEY_NODENAME];
                            remapMod = (Modifiers)int.Parse((string)remapDict[Constants.KEYFILE_MODIFIERS_NODENAME]);

                            if ((remapMod & Modifiers.Windows) == Modifiers.Windows)
                            {
                                remapMod |= Modifiers.Control;
                                remapMod ^= Modifiers.Windows;
                            }
                        }
                    }

                    KeyCommand cmd = new KeyCommand();
                    cmd.mod = remapMod;
                    cmd.key = int.Parse(remapKey);
                    cmd.adj = null;
                    key.adj[Constants.KEYFILE_ADJUSTMENT_REMAP_NODENAME] = cmd;
                }
            }

            return keyfile;
        }

        private void LoadAllKeyfiles()
        {
            this.keyfileList = new Dictionary<string, Keyfile>();

            foreach (string filepath in System.IO.Directory.GetFiles(this.keyfileDirectory, "*.*", SearchOption.AllDirectories).Where(s => s.ToLower().EndsWith(Constants.KEYFILE_VKEYS_EXTENSION) || s.ToLower().EndsWith(Constants.KEYFILE_JSON_EXTENSION) ))
            {
                string contents = this.DecryptFile(filepath);

                Keyfile keyfile = this.GetLatestVersion(contents);

                if (keyfile == null || keyfile.lrVersion != this.lrVersion)
                {
                    continue;
                }

                keyfile.filename = Path.GetFileName(filepath);

                if (Properties.Settings.Default.KeyfileSettings.ContainsKey(keyfile.uuid))
                {
                    keyfile.isActive = Properties.Settings.Default.KeyfileSettings[keyfile.uuid].isActive;
                }
                else
                {
                    keyfile.isActive = true;
                    Properties.Settings.Default.KeyfileSettings[keyfile.uuid] = new KeyfileSettings();
                    Properties.Settings.Default.KeyfileSettings[keyfile.uuid].isActive = true;
                }

                if (!this.keyfileList.ContainsKey(keyfile.uuid))
                {
                    this.keyfileList.Add(keyfile.uuid, keyfile);
                }
                else
                {
                    KeyControl.TraceLine(string.Format("Keyfile id {0} already exists. Skipping file load.", keyfile.uuid));
                }
            }

            this.InitActiveKeyfile();
        }

        private void InitActiveKeyfile()
        {
            if (this.keyfileList.ContainsKey(Properties.Settings.Default.ActiveKeyfile) && this.keyfileList[Properties.Settings.Default.ActiveKeyfile].isActive)
            {
                this.activeKeyfile = Properties.Settings.Default.ActiveKeyfile;
            }
            else if (this.keyfileList.Count > 0)
            {
                this.activeKeyfile = this.keyfileList.Keys.First();
                Properties.Settings.Default.ActiveKeyfile = this.activeKeyfile;
            }

            this.SetMenuForKeyFileActive();
        }

        private int TranslateKey(int macKey)
        {
            return this.TranslateKey(macKey.ToString());
        }

        private int TranslateKey(string macKey)
        {
            int winKey = int.Parse(this.winKeyMapping[macKey], System.Globalization.NumberStyles.HexNumber);

            return winKey;
        }

        public void LoadDictionaryFromActiveKeysFile()
        {
            this.isKeyControlActive = false;

            List<KeyCommand> keys = this.keyfileList[this.activeKeyfile].keys;

            // convert the settings into windows data
            this.keysDict = new List<KeyCommand>(keys.Count);
            foreach (KeyCommand command in keys)
            {
                KeyCommand newCommand = (KeyCommand)command.Clone();
                newCommand.key = this.TranslateKey(newCommand.key);
                this.keysDict.Add(newCommand);
            }

            this.controlToggleKey = this.TranslateKey(this.keyfileList[this.activeKeyfile].modeKey);
        }

        private void InitMappings()
        {
            this.keyMapping = this.jsSerializer.Deserialize<Dictionary<string, string>>(File.ReadAllText(Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), "Resources/Mapping/KeyMapping.json")));
            this.adjustmentMapping = this.jsSerializer.Deserialize<Dictionary<string, string>>(File.ReadAllText(Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), "Resources/Mapping/AdjustmentMapping.json")));
            this.winKeyMapping = this.jsSerializer.Deserialize<Dictionary<string, string>>(File.ReadAllText(Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location), "Resources/Mapping/WinKeyMapping.json")));
        }

        public string GetCommandStringForCommand(KeyCommand command)
        {
            StringBuilder sb = new StringBuilder();

            if ((command.mod & Modifiers.Shift) == Modifiers.Shift)
                sb.Append("SHIFT + ");

            if ((command.mod & Modifiers.Control) == Modifiers.Control)
                sb.Append("CONTROL + ");

            if ((command.mod & Modifiers.Alt) == Modifiers.Alt)
                sb.Append("ALT + ");

            if ((command.mod & Modifiers.Windows) == Modifiers.Windows)
                sb.Append("WINDOWS + ");

            string keyname = this.keyMapping[command.key.ToString()];

            if (!string.IsNullOrEmpty(keyname))
            {
                sb.Append(keyname);
            }
            else
            {
                sb.Append("?");
            }

            return sb.ToString();
        }

        public string GetAmountString(string amount, bool isRemap)
        {
            string stringValue = amount;

            if (isRemap)
            {
                stringValue = this.keyMapping[amount];
            }

            // handle coloring, etc.

            return stringValue;
        }

        public void UpdateDefaults()
        {
            foreach (Keyfile keyfile in this.keyfileList.Values)
            {
                Properties.Settings.Default.KeyfileSettings[keyfile.uuid].isActive = keyfile.isActive;
            }

            this.ResetStatusMenu();

            this.InitActiveKeyfile();
        }

        #endregion

        #region Key Loop

        private bool CheckIsKeySystemEngaged()
        {
            return this.isKeyControlActive && this.authSuccess && this.CheckIsLRInForeground() && !this.IsInTextBox();
        }

        private void ToggleKeyControlActive()
        {
            this.isKeyControlActive = !this.isKeyControlActive;
            KeyControl.TraceLine(string.Format("KeyControl Active: {0}", this.isKeyControlActive));

            this.CheckServerAvailability();


        }

        public void PrintKeyDebug(Int32 key, Modifiers mod, bool isKeyDown)
        {
            KeyCommand command = new KeyCommand();
            string winKeyStr = "0x" + key.ToString("x2");
            string commandStr = winKeyStr;

            if (this.winKeyMapping.ContainsValue(winKeyStr))
            {
                string macKeyStr = this.winKeyMapping.FirstOrDefault(x => x.Value == winKeyStr).Key;
                KeyControl.TraceLine(string.Format(winKeyStr + " : " + macKeyStr));

                command.key = int.Parse(macKeyStr);
                command.mod = mod;

                commandStr = this.GetCommandStringForCommand(command);
            }

            if (isKeyDown)
            {
                KeyControl.TraceLine(string.Format("Key Down: {0}", commandStr));
            }
            else
            {
                KeyControl.TraceLine(string.Format("Key Up: {0}", commandStr));
            }
        }

        #region Dll imports

        internal struct KBDLLHOOKSTRUCT
        {
            public int vkCode;
            int scanCode;
            public int flags;
            int time;
            int dwExtraInfo;
        }

        internal delegate IntPtr LowLevelKeyboardProc(int nCode, IntPtr wParam, ref KBDLLHOOKSTRUCT lParam);

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        internal static extern IntPtr SetWindowsHookEx(int idHook, LowLevelKeyboardProc lpfn, IntPtr hMod, uint dwThreadId);

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        internal static extern bool UnhookWindowsHookEx(IntPtr hhk);

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        internal static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, ref KBDLLHOOKSTRUCT lParam);

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        internal static extern short GetKeyState(int nVirtKey);

        [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern IntPtr GetModuleHandle(string lpModuleName);

        public enum KeyboardFlag : uint // UInt32
        {
            EXTENDEDKEY = 0x0001,
            KEYUP = 0x0002,
            UNICODE = 0x0004,
            SCANCODE = 0x0008,
        }

        public enum InputType : uint // UInt32
        {
            MOUSE = 0,
            KEYBOARD = 1,
            HARDWARE = 2,
        }

        struct HARDWAREINPUT
        {
            public UInt32 Msg;
            public UInt16 ParamL;
            public UInt16 ParamH;
        }

        struct MOUSEINPUT
        {
            public Int32 X;
            public Int32 Y;
            public UInt32 MouseData;
            public UInt32 Flags;
            public UInt32 Time;
            public IntPtr ExtraInfo;
        }

        struct KEYBDINPUT
        {
            public UInt16 Vk;
            public UInt16 Scan;
            public UInt32 Flags;
            public UInt32 Time;
            public IntPtr ExtraInfo;
        }

        [StructLayout(LayoutKind.Explicit)]
        struct MOUSEKEYBDHARDWAREINPUT
        {
            [FieldOffset(0)]
            public MOUSEINPUT Mouse;

            [FieldOffset(0)]
            public KEYBDINPUT Keyboard;

            [FieldOffset(0)]
            public HARDWAREINPUT Hardware;
        }

        struct INPUT
        {
            public UInt32 Type;
            public MOUSEKEYBDHARDWAREINPUT Data;
        }

        [DllImport("user32.dll", SetLastError = true)]
        static extern UInt32 SendInput(UInt32 numberOfInputs, INPUT[] inputs, Int32 sizeOfInputStructure);

        #endregion

        private Modifiers GetModifiers()
        {
            Modifiers mod = Modifiers.None;

            if ((KeyControl.GetKeyState(Constants.VK_SHIFT) & 0x8000) != 0)
            {
                mod |= Modifiers.Shift;
            }

            if ((KeyControl.GetKeyState(Constants.VK_CONTROL) & 0x8000) != 0)
            {
                mod |= Modifiers.Control;
            }

            if ((KeyControl.GetKeyState(Constants.VK_MENU) & 0x8000) != 0)
            {
                mod |= Modifiers.Alt;
            }

            if (this.isLWinKeyDown || this.isRWinKeyDown)
            {
                mod |= Modifiers.Windows;
            }

            return mod;
        }

        private bool GetIsModifierKey(int key)
        {
            if (
                key == Constants.VK_LSHIFT ||
                key == Constants.VK_RSHIFT ||
                key == Constants.VK_LCONTROL ||
                key == Constants.VK_RCONTROL ||
                key == Constants.VK_LMENU ||
                key == Constants.VK_RMENU ||
                key == Constants.VK_LWIN ||
                key == Constants.VK_RWIN
                )
            {
                return true;
            }

            return false;
        }

        private class SentKey : IEquatable<SentKey>
        {
            public int Key { get; set; }
            public bool IsKeyDown { get; set; }

            public SentKey(int key, bool isKeyDown)
            {
                this.Key = key;
                this.IsKeyDown = isKeyDown;
            }

            public bool Equals(SentKey other)
            {
                return this.Key == other.Key && this.IsKeyDown == other.IsKeyDown;
            }
        }

        private void SendKey(int key, bool isDown)
        {
            var input = new INPUT();
            input.Type = (UInt32)InputType.KEYBOARD;
            input.Data.Keyboard = new KEYBDINPUT();
            input.Data.Keyboard.Vk = (UInt16)key;
            input.Data.Keyboard.Scan = 0;
            input.Data.Keyboard.Flags = (isDown) ? 0 : (UInt32)KeyboardFlag.KEYUP;
            input.Data.Keyboard.Time = 0;
            input.Data.Keyboard.ExtraInfo = IntPtr.Zero;

            INPUT[] inputList = new INPUT[1];
            inputList[0] = input;

            SentKey sent = new SentKey(key, isDown);

            this.sentKeys.Add(sent);

            uint numberOfSuccessfulSimulatedInputs = SendInput(1, inputList, Marshal.SizeOf(typeof(INPUT)));
            if (numberOfSuccessfulSimulatedInputs == 0)
            {
                KeyControl.TraceLine(string.Format("Failed to send key {0}", key));
                this.sentKeys.Remove(sent);
            }
        }

        private void SendModifiers(Modifiers modifiers, bool isKeyDown)
        {
            if ((modifiers & Modifiers.Shift) == Modifiers.Shift)
                this.SendKey(Constants.VK_SHIFT, isKeyDown);

            if ((modifiers & Modifiers.Control) == Modifiers.Control)
                this.SendKey(Constants.VK_CONTROL, isKeyDown);

            if ((modifiers & Modifiers.Alt) == Modifiers.Alt)
                this.SendKey(Constants.VK_MENU, isKeyDown);

            if ((modifiers & Modifiers.Windows) == Modifiers.Windows)
                this.SendKey(Constants.VK_LWIN, isKeyDown);
        }

        private bool IsSentKey(int key, bool isKeyDown)
        {
            SentKey sent = new SentKey(key, isKeyDown);

            if (this.sentKeys.Contains(sent))
            {
                this.sentKeys.Remove(sent);
                return true;
            }

            return false;
        }

        private void ReportHookFailure()
        {
            if (this.startTime >= 0)
            {
                if (this.isPossiblyDead)
                {
                    KeyControl.TraceLine(string.Format("Last hook execution was cut off. StartTime: {0}", this.startTime));
                    this.startTime = -1;
                }
                else
                {
                    this.isPossiblyDead = true;
                }
            }
            else
            {
                this.isPossiblyDead = false;
            }
        }

        private Stopwatch stopWatch = Stopwatch.StartNew();
        private long startTime = -1;
        private long maxTime = 0;
        private bool isPossiblyDead = false;
        private void StartTiming()
        {
            if (this.startTime >= 0)
            {
                KeyControl.TraceLine(string.Format("Last hook execution was cut off. StartTime: {0}", this.startTime));
            }

            this.startTime = this.stopWatch.ElapsedMilliseconds;
        }

        private void EndTiming(string position)
        {
            long total = this.stopWatch.ElapsedMilliseconds - this.startTime;
            this.startTime = -1;

            if (total > this.maxTime)
            {
                this.maxTime = total;

                if (!Constants.HOOK_PERF_DETAIL)
                {
                    KeyControl.TraceLine(string.Format("Max Hooktime: {0}ms", this.maxTime));
                }
            }

            if (Constants.HOOK_PERF_DETAIL)
            {
                KeyControl.TraceLine(string.Format("Hooktime ({2}): {0}ms / {1}ms", total, this.maxTime, position));
            }
        }

        private IntPtr HookCallBack(int nCode, IntPtr wParam, ref KBDLLHOOKSTRUCT lParam)
        {
            this.StartTiming();

            int keyState = (int)wParam;
            bool isKeyUp = keyState == Constants.WM_KEYUP || (keyState == Constants.WM_SYSKEYUP);
            bool isKeyDown = keyState == Constants.WM_KEYDOWN || (keyState == Constants.WM_SYSKEYDOWN);

            // MSDN documentation indicates that nCodes less than 0 should always invoke CallNextHookEx.
            //  skip if the message is not a keyup or down
            if (nCode < 0 || !(isKeyUp || isKeyDown))
            {
                this.EndTiming("code 0");
                return KeyControl.CallNextHookEx(this.hookID, nCode, wParam, ref lParam);
            }

            Int32 key = lParam.vkCode;
            Modifiers modifiers = this.GetModifiers();

            // capture windows key
            if (key == Constants.VK_LWIN)
            {
                this.isLWinKeyDown = isKeyDown;
            }

            if (key == Constants.VK_RWIN)
            {
                this.isRWinKeyDown = isKeyDown;
            }

            // disable if we are active
            if (key == Constants.VK_LWIN || key == Constants.VK_RWIN)
            {
                if (this.CheckIsKeySystemEngaged())
                {
                    this.EndTiming("WIN key");
                    return new IntPtr(1);
                }
            }

            // pass through keys that were remapped by the application
            if (this.IsSentKey(key, isKeyDown))
            {
                this.EndTiming("Sent key");
                return KeyControl.CallNextHookEx(this.hookID, nCode, wParam, ref lParam);
            }

            // capture and pass through straight modifier keys
            if (this.GetIsModifierKey(key))
            {
                this.EndTiming("Straight mod");
                return KeyControl.CallNextHookEx(this.hookID, nCode, wParam, ref lParam);
            }

            //this.PrintKeyDebug(key, modifiers, isKeyDown);

            // mode switch for app
            if (this.authSuccess && modifiers == Modifiers.None && key == this.controlToggleKey && this.CheckIsLRInForeground())
            {
                if (isKeyDown)
                {
                    this.ToggleKeyControlActive();
                }

                this.EndTiming("Mode switch");
                return new IntPtr(1);
            }

            // show/hide quick keylist ( CONTROL + / )
            if (this.isKeyControlActive && (modifiers & Modifiers.Control) == Modifiers.Control && key == 0xbf)
            {
                if (isKeyUp)
                {
                    if (this.CheckIsKeySystemEngaged())
                    {
                        this.ShowQuickList();
                    }
                    else
                    {
                        this.DismissQuickList();
                    }
                }

                this.EndTiming("Quick Ref");
                return new IntPtr(1);
            }

            if (this.CheckIsKeySystemEngaged())
            {
                if (this.keysDict != null)
                {
                    foreach (KeyCommand command in this.keysDict)
                    {
                        if (key == command.key && modifiers == command.mod)
                        {
                            if (command.adj.ContainsKey(Constants.KEYFILE_ADJUSTMENT_REMAP_NODENAME))
                            {
                                KeyCommand newKey = command.adj[Constants.KEYFILE_ADJUSTMENT_REMAP_NODENAME] as KeyCommand;

                                if (newKey == null)
                                {
                                    KeyControl.TraceLine(string.Format("Failed to map {0} {2} to {1}", key, this.TranslateKey(newKey.key), (isKeyDown) ? "Down" : "Up"));
                                    this.EndTiming("Remap failed");
                                    return new IntPtr(1);
                                }

                                KeyControl.TraceLine(string.Format("Mapping {0} {2} to {1}", key, this.GetCommandStringForCommand(newKey), (isKeyDown) ? "Down" : "Up"));

                                this.EndTiming("Remap");

                                this.SendModifiers(modifiers, false);

                                this.SendModifiers(newKey.mod, true);

                                this.SendKey(this.TranslateKey(newKey.key), isKeyDown);

                                this.SendModifiers(newKey.mod, false);

                                this.SendModifiers(modifiers, true);

                                return new IntPtr(1);
                            }

                            if (isKeyDown)
                            {
                                if (command.adj != null && command.adj.Count > 0)
                                {
                                    Dictionary<string, string> adjustments = command.adj.ToDictionary((o) => o.Key, (o) => (string)o.Value);
                                    KeyControl.TraceLine("Key Command Executed");
                                    this.statusBar.Dispatcher.BeginInvoke(this.sendUpdateDelegate, adjustments);
                                }
                            }

                            this.EndTiming("Key command");
                            return new IntPtr(1);
                        }
                    }
                }
            }

            this.EndTiming("Pass through");
            return KeyControl.CallNextHookEx(this.hookID, nCode, wParam, ref lParam);
        }

        public void StartUpEventLoop()
        {
            this.LoadDictionaryFromActiveKeysFile();

            this.hookProc = new LowLevelKeyboardProc(this.HookCallBack);

            using (Process curProcess = Process.GetCurrentProcess())
            using (ProcessModule curModule = curProcess.MainModule)
            {
                this.hookID = KeyControl.SetWindowsHookEx(
                    Constants.WH_KEYBOARD_LL,
                    this.hookProc,
                    KeyControl.GetModuleHandle(curModule.ModuleName),
                    0);
            }
            if (this.hookID == IntPtr.Zero)
            {
                throw new Win32Exception(Marshal.GetLastWin32Error());
            }
        }

        #endregion
    }
}
