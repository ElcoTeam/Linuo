using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LiNuoMes.Model
{
    public class ProductThroughRateEntity
    {
        public string Number { set; get; }
        public string Date { set; get; }
        public string ProcessName { set; get; }
        public string ProcessQty { set; get; }
        public string ScrapQty { set; get; }
        public string UnFinishQty { set; get; }
        public string RepairQty { set; get; }
        public string PassRate { set; get; }
        public string DailyThroughRate { set; get; }
    }
}