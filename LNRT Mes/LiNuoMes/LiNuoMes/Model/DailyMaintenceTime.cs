using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LiNuoMes.Model
{
    public class DailyMaintenceTime
    {
        public string MaintenceDate { get; set; }
        public string TotalTime { get; set; }  
    }

    public class ResultMsg_DailyMaintenceTime
    {
        public string result { set; get; }
        public string msg { set; get; }
        public DailyMaintenceTime data { set; get; }
    }
}