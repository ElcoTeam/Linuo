using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LiNuoMes.Model
{
    public class EquAlarmEntity
    {
        public string ID { set; get; }
        public string Number { set; get; }
        public string ProcessName { set; get; }
        public string DeviceName { set; get; }
        public string DealWithResult { set; get; }
        public string AlarmTime { set; get; }
        public string AlarmItem { set; get; }
        public string DealWithTime { set; get; }
        public string DealWithOper { set; get; }
        public string DealWithComment { set; get; }
        public string StopTime { set; get; }
    }
}