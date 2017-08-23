using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LiNuoMes.Model
{
    public class ProductionStatisticEntity
    {
        public string Number { set; get; }
        public string WorkOrderNumber { set; get; }
        public string WorkOrderVersion { set; get; }
        public string StartTime { set; get; }
        public string FinishTime { set; get; }
        public string ItemNumber { set; get; }
        public string ItemDsca { set; get; }
        public string UOM { set; get; }
        public string ErpPlanQty { set; get; }
        public string MesFinishQty { set; get; }
        public string UnFinishQty { set; get; }
        public string BackQty { set; get; }
        public string FinishRate { set; get; }
    }

    public class AbnormalInfo
    {
        public string ProcessName { set; get; }
        public string RejectQty { set; get; }
        public string UnFinishQty { set; get; }
        public string RepairQty { set; get; }
        public string SumAbnormalQty { set; get; }
    }

    public class EquAlarmInfo
    {
        public string ProcessName { set; get; }
        public string DeviceName { set; get; }
        public string AlarmItem { set; get; }
        public string AlarmTimes { set; get; }

    }

    public class MaterialPullInfo
    {
        public string ProcessName { set; get; }
        public string ItemName { set; get; }
        public string PullTimes { set; get; }
        public string OverTimes { set; get; }
    }
}