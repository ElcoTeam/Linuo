using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LiNuoMes.Model
{
    public class MaterialPullEntity
    {
        public string ID { set; get; }
        public string Number { set; get; }
        public string WorkOrderNumber { set; get; }
        public string WorkOrderVersion { set; get; }
        public string Procedure_Name { set; get; }
        public string ItemNumber { set; get; }
        public string ItemDsca { set; get; }
        public string Qty { set; get; }
        public string PullTime { set; get; }
        public string Status { set; get; }
        public string ActionTime { set; get; }
        public string ActionUser { set; get; }
        public string ConfirmTime { set; get; }
        public string ConfirmUser { set; get; }
        public string OTFlag { set; get; }
    }
}