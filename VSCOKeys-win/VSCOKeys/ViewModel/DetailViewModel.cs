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
using System.Collections.ObjectModel;
using System.Net;
using System.Timers;
using System.Windows.Data;

namespace VSCOKeys.ViewModel
{
    class DetailViewModel : BindableObject
    {
        #region bindings

        private ICommand createCommand;
        public ICommand CreateCommand
        {
            get { return this.createCommand; }
            set
            {
                if (this.createCommand != value)
                {
                    this.createCommand = value;
                    OnPropertyChanged("CreateCommand");
                }
            }
        }

        private ICommand toggleCommand;
        public ICommand ToggleCommand
        {
            get { return this.toggleCommand; }
            set
            {
                if (this.toggleCommand != value)
                {
                    this.toggleCommand = value;
                    OnPropertyChanged("ToggleCommand");
                }
            }
        }

        private ICommand downloadCommand;
        public ICommand DownloadCommand
        {
            get { return this.downloadCommand; }
            set
            {
                if (this.downloadCommand != value)
                {
                    this.downloadCommand = value;
                    OnPropertyChanged("DownloadCommand");
                }
            }
        }

        private Keyfile keyfile;
        public Keyfile Keyfile
        {
            get { return this.keyfile; }
            set
            {
                if (this.keyfile != value)
                {
                    this.keyfile = value;
                    OnPropertyChanged("Keyfile");
                }
            }
        }

        private ObservableCollection<KeyCommandViewModel> keys;
        public ObservableCollection<KeyCommandViewModel> Keys
        {
            get { return this.keys; }
            set
            {
                if (this.keys != value)
                {
                    this.keys = value;
                    OnPropertyChanged("Keys");
                }
            }
        }


        private double downloadAmount;
        public double DownloadAmount
        {
            get { return this.downloadAmount; }
            set
            {
                if (this.downloadAmount != value)
                {
                    this.downloadAmount = value;
                    OnPropertyChanged("DownloadAmount");
                }
            }
        }

        private string filter;
        public string Filter
        {
            get { return this.filter; }
            set
            {
                if (this.filter != value)
                {
                    this.filter = value;
                    OnPropertyChanged("Filter");
                }
            }
        }

        private ListCollectionView viewSource;
        public ListCollectionView ViewSource
        {
            get { return this.viewSource; }
            set
            {
                if (this.viewSource != value)
                {
                    this.viewSource = value;
                    OnPropertyChanged("ViewSource");
                }
            }
        }

        #endregion

        public KeyControl KeyControl { get; set; }

        private Timer downloadTimer;
        private Random rand;

        public DetailViewModel()
        {
            this.CreateCommand = new DelegateCommand<object>((o) => { this.Create(); });
            this.DownloadCommand = new DelegateCommand<object>((o) => { this.Download(); });
            this.ToggleCommand = new DelegateCommand<object>((o) => { this.ToggleActive(); });

            this.rand = new Random();
        }

        void DetailViewModel_PropertyChanged(object sender, System.ComponentModel.PropertyChangedEventArgs e)
        {
            switch (e.PropertyName)
            {
                case "Filter":
                    if (this.ViewSource != null)
                    {
                        this.ViewSource.Refresh();
                    }
                    break;
                default:
                    break;
            }
        }

        internal void Setup(string uuid)
        {
            this.Keyfile = this.KeyControl.GetKeyfile(uuid);

            List<KeyCommandViewModel> keys = new List<KeyCommandViewModel>();

            foreach (KeyCommand key in this.Keyfile.keys)
            {
                string commandString = this.KeyControl.GetCommandStringForCommand(key);

                List<string> normalizedAdjustmentNames = new List<string>();
                foreach (KeyValuePair<string, object> adj in key.adj)
                {
                    KeyCommandViewModel newKey = new KeyCommandViewModel();

                    string normalAdjustmentName = this.KeyControl.adjustmentMapping[adj.Key];

                    if (normalizedAdjustmentNames.Contains(normalAdjustmentName))
                    {
                        continue;
                    }

                    normalizedAdjustmentNames.Add(normalAdjustmentName);

                    newKey.Command = commandString;
                    newKey.Adjustment = normalAdjustmentName;
                    newKey.Amount = (adj.Key == Constants.KEYFILE_ADJUSTMENT_REMAP_NODENAME) ? this.KeyControl.GetCommandStringForCommand((KeyCommand)adj.Value) : (string)adj.Value;

                    keys.Add(newKey);
                }
            }

            this.Keys = new ObservableCollection<KeyCommandViewModel>(keys);

            this.ViewSource = new ListCollectionView(keys);

            this.ViewSource.Filter = (o) =>
            {
                if (string.IsNullOrWhiteSpace(this.Filter))
                {
                    return true;
                }

                KeyCommandViewModel command = o as KeyCommandViewModel;

                string filter = this.Filter.ToLowerInvariant();

                if (command != null && (command.Command.ToLowerInvariant().Contains(filter) || command.Adjustment.ToLowerInvariant().Contains(filter) || command.Amount.ToLowerInvariant().Contains(filter)))
                {
                    return true;
                }

                return false;
            };

            this.PropertyChanged += new System.ComponentModel.PropertyChangedEventHandler(DetailViewModel_PropertyChanged);

            if (File.Exists(this.GetKeyfilePdfPath()))
            {
                this.DownloadAmount = 100;
            }
            else
            {
                this.DownloadAmount = 0;
            }
        }

        private void Create()
        {
            Process.Start(string.Format("{0}{1}/{2}", Constants.WEB_KEYS_ENDPOINT, this.Keyfile.uuid, Constants.WEB_KEYS_CUSTOMIZE));
        }

        private void Download()
        {
            // start download
            if (this.DownloadAmount <= 0)
            {
                this.StartDownload();
            }

            // open file
            if (this.DownloadAmount >= 100)
            {
                if (File.Exists(this.GetKeyfilePdfPath()))
                {
                    Process.Start(this.GetKeyfilePdfPath());
                }
            }
        }

        private void StartDownload()
        {
            string webPath = string.Format("{0}{1}/{2}", Constants.WEB_KEYS_ENDPOINT, this.Keyfile.uuid, Constants.WEB_KEYS_SHEET);
            //string webPath = "http://www.itk.org/ItkSoftwareGuide.pdf";
            WebClient Client = new WebClient();

            if (Constants.WEB_KEYS_ENDPOINT_HAS_AUTH)
            {
                CredentialCache creds = new CredentialCache();
                creds.Add(new Uri(Constants.WEB_KEYS_ENDPOINT), "Basic", new NetworkCredential(Constants.WEB_KEYS_ENDPOINT_USER, Constants.WEB_KEYS_ENDPOINT_PASSWORD));
                Client.Credentials = creds;
            }

            Client.DownloadFileAsync(new Uri(webPath), GetKeyfilePdfPath());

            Client.DownloadFileCompleted += new System.ComponentModel.AsyncCompletedEventHandler(Client_DownloadFileCompleted);

            this.downloadTimer = new Timer(Constants.VIEW_DOWNLOAD_UPDATE_RATE * 1000);
            this.downloadTimer.Elapsed += new ElapsedEventHandler(downloadTimer_Elapsed);
            this.downloadTimer.Start();
        }

        void Client_DownloadFileCompleted(object sender, System.ComponentModel.AsyncCompletedEventArgs e)
        {
            this.downloadTimer.Stop();
            this.downloadTimer = null;

            this.DownloadAmount = 100;
        }

        private void downloadTimer_Elapsed(object sender, ElapsedEventArgs e)
        {
            this.UpdateDownloadStatus();
        }

        private void UpdateDownloadStatus()
        {
            double randomness = 0.3 + this.rand.NextDouble();

            this.DownloadAmount += Constants.VIEW_DOWNLOAD_UPDATE_RATE / Constants.VIEW_DOWNLOAD_DURATION * randomness * 100;
            this.DownloadAmount = Math.Min(this.DownloadAmount, 99);
        }

        private string GetKeyfilePdfPath()
        {
            return this.KeyControl.GetKeyfilePdfPath(this.Keyfile.uuid);
        }

        private void ToggleActive()
        {
            this.KeyControl.ToggleIsActive(this.Keyfile.uuid);

            OnPropertyChanged("Keyfile");
        }
    }
}
