﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace LiNuoMes.Model
{
    public class MonthCompletionRateEntity
    {
        public List<string> BudgetedQty { get; set; }  //每月预算产量

        public List<string> FinishQty { get; set; }   //完成产量

        public List<string> BudgetedCompletionRate { get; set; } //预算完成率

        public List<string> DesignYield { get; set; }  //设计产能

        public List<string> CapacityRate { get; set; } //产能发挥率

        public List<string> ERPPlanYield { get; set; }  //ERP计划产量

        public List<string> ERPCompleteRate { get; set; }  //ERP完成率

    }

    public class MonthBudget
    {
        public string CurrentMonth { get; set; }
        public string BudgetedQty { get; set; }  //每月预算产量
    }

    public class ResultMsg_MonthBudget
    {
        public string result { set; get; }
        public string msg { set; get; }
        public MonthBudget data { set; get; }
    }
}