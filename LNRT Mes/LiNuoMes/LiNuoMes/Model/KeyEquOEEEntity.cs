using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LiNuoMes.Model
{
    public class KeyEquOEEEntity
    {
        public string ID { set; get; }
        public string Number { set; get; }
        public string DATE { set; get; }
        public string DeviceName { set; get; }
        public string Calendar { set; get; }
        public string StopTime { set; get; }
        public string LoadTime { set; get; }
        public string UtilizationRate { set; get; }
        public string EquStopTime { set; get; }
        public string RunTime { set; get; }
        public string TimeUtilizationRate { set; get; }
        public string TheoryCycle { set; get; }
        public string ProcessQty { set; get; }
        public string EfficientRate { set; get; }
        public string DefectiveQty { set; get; }
        public string YieldRate { set; get; }
        public string OEE { set; get; }
    }
}