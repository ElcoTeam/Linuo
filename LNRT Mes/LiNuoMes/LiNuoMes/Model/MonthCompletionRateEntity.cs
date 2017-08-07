using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LiNuoMes.Model
{
    public class MonthCompletionRateEntity
    {
        public string Number { set; get; }
        public string Date { set; get; }
        public string BudgetedQty { set; get; }
        public string FinishQty { set; get; }
        public string BudgetedCompletionRate { set; get; }
        public string DesignYield { set; get; }
        public string CapacityRate { set; get; }
    }
}