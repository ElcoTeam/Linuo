using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LiNuoMes.Model
{
    public class ProcessBeat
    {
        public string Number { set; get; }
        public string Date { set; get; }
        public string Process { set; get; }

        public string DeviceName { set; get; }
        public string BeatMin { set; get; }
        public string BeatMax { set; get; }
        public string BeatPer { set; get; }
    }
}