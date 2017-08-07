using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LiNuoMes.Model
{
    public class DailyCompletionRateEntity
    {
        public string Number { set; get; }
        public string Date { set; get; }
        public string DispatchNum { set; get; }
        public string SAPPostNum { set; get; }
        public string PostNum { set; get; }
        public string OrderAccuracy { set; get; }
        public string TimelyRate { set; get; }
        public string AttendanceNum { set; get; }
        public string WorkHour { set; get; }
        public string AttendanceTime { set; get; }
        public string EffectiveTime { set; get; }
        public string EffectiveRate { set; get; }
    }
}