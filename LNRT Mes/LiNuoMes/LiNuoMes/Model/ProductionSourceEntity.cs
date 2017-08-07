using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LiNuoMes.Model
{
    public class ProductionSourceEntity
    {
        public string Number { set; get; }
        public string OrderCode { set; get; }
        public string MES { set; get; }
        public string ProcessName { set; get; }
        public string ProduceTime { set; get; }
        public string ItemNumber { set; get; }
        public string DeviceName { set; get; }
        public string ProductionProcess { set; get; }
    }
}