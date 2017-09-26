using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Data.SqlClient;
using clsSql;
using System.IO;
using System.Configuration;
using System.Web;
using System.Web.Services;
using System.Web.SessionState;
using System.Web.Script.Serialization;
using LiNuoMes.Model;

namespace LiNuoMes.Report
{
    /// <summary>
    /// GetReportInfo 的摘要说明
    /// </summary>
    public class GetReportInfo : IHttpHandler, IReadOnlySessionState
    {
        JavaScriptSerializer jsc = new JavaScriptSerializer();
        string Action = "";
        string UserName = "";
        
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            if (context.Session["UserName"] != null)
                UserName = context.Session["UserName"].ToString().ToUpper().Trim();
            else
                UserName = "";
            Action = RequstString("Action");

            if (Action.Length == 0) Action = "";


            #region //设备报警报表
            if (Action == "EquAlarmReport")
            {
                List<EquAlarmEntity> equAlarm= new List<EquAlarmEntity>();
                equAlarm = GetEquAlarmList(equAlarm);
                context.Response.Write(jsc.Serialize(equAlarm));
            }
            #endregion
            #region //设备报警柱状图
            if (Action == "EquAlarmChart")
            {
                EquAlarm equAlarmReport = new EquAlarm();
                equAlarmReport = GetEquAlarmReport(equAlarmReport);
                Chart chart = new Chart();
                
                List<string> catagory = new List<string>();
                List<double> datavalue = new List<double>();

                for (int i = 0; i < equAlarmReport.Device.Count(); i++)
                {
                    catagory.Add(equAlarmReport.Device[i].ToString());

                    datavalue.Add(Convert.ToDouble(equAlarmReport.AlarmCount[i] == "" ? "0" : equAlarmReport.AlarmCount[i].ToString()));
                }
                chart.catagory = catagory;
                chart.datavalue = datavalue;
                context.Response.Write(jsc.Serialize(chart));
            }
            #endregion

            #region//设备详细报警
            if (Action == "EquAlarmDetail")
            {
                List<EquAlarmEntity> equAlarm = new List<EquAlarmEntity>();
                equAlarm = GetEquAlarmDetail(equAlarm);
                context.Response.Write(jsc.Serialize(equAlarm));
            }
            #endregion

            #region //关键设备OEE
            if (Action == "KeyEquOEEReport")
            {
                List<KeyEquOEEEntity> equOEE = new List<KeyEquOEEEntity>();
                //equOEE = GetEquAlarmList(equOEE);
                //context.Response.Write(jsc.Serialize(equOEE));
            }
            #endregion
            #region //设备生产工艺
            if (Action == "ProductArtReport")
            {
                List<ProductArtEntity> productArt = new List<ProductArtEntity>();
                //equOEE = GetEquAlarmList(equOEE);
                //context.Response.Write(jsc.Serialize(equOEE));
            }
            #endregion
            #region//物料拉动
            if (Action == "MaterialPullReport")
            {
                List<MaterialPullEntity> materialPull = new List<MaterialPullEntity>();
                materialPull = GetMaterialPullList(materialPull);
                context.Response.Write(jsc.Serialize(materialPull));
            }
            #endregion
            #region //能耗统计
            if (Action == "EnergyConsumpReport")
            {
                List<EnergyConsumpEntity> energyConsump = new List<EnergyConsumpEntity>();
                energyConsump = GetEnergyList(energyConsump);
                context.Response.Write(jsc.Serialize(energyConsump));
            }
            #endregion
            #region//能耗统计
            if (Action == "GetEnergyChart")
            {
                List<EnergyConsumpEntity> energyConsump = new List<EnergyConsumpEntity>();
                energyConsump = GetEnergyList(energyConsump);
                Chart chart = new Chart();
                List<string> catagory = new List<string>();
                List<double> datavalue = new List<double>();
                foreach(EnergyConsumpEntity en in energyConsump)
                {
                    catagory.Add(en.Date);
                    datavalue.Add(Convert.ToDouble(en.CostValue));
                }
                chart.catagory = catagory;
                chart.datavalue = datavalue;
                context.Response.Write(jsc.Serialize(chart));
            }
            #endregion
            #region //设备保养总统计表
            if (Action == "GetEquTotalReport")
            {
                List<EquManCountEntity> equmancount = new List<EquManCountEntity>();
                equmancount = GetTotalMaintenceList(equmancount);
                context.Response.Write(jsc.Serialize(equmancount));

            }
            #endregion
            #region //每日出勤统计
            if (Action == "UserAttendenceReport")
            { 
                string strJson = "";
                UserAttendence userAttendence = new UserAttendence();
                userAttendence = GetAttendenceData(userAttendence);
                strJson = "{\"page\":1,\"total\": 4 ,\"records\":4,\"rows\":[";
                for (int j = 0; j < 4 ; j++)
                {
                    strJson += "{";
                    strJson += "\"id\":\"" + (j + 1).ToString() + "\",";
                    strJson += "\"cell\":";
                    strJson += "[";
                    if(j==0)
                    {
                        for (int i = 0; i < userAttendence.AttendanceNum.Count()-1; i++)
                        {
                            strJson += "\"" + userAttendence.AttendanceNum[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + userAttendence.AttendanceNum[userAttendence.AttendanceNum.Count()-1].ToString() + "\"";
                    }
                    if (j == 1)
                    {
                        for (int i = 0; i < userAttendence.WorkHours.Count()-1; i++)
                        {
                            strJson += "\"" + userAttendence.WorkHours[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + userAttendence.WorkHours[userAttendence.WorkHours.Count() - 1].ToString().Trim() + "\"";
                    }
                    if (j == 2)
                    {
                        for (int i = 0; i < userAttendence.ActiveWorkHours.Count()-1; i++)
                        {
                            strJson += "\"" + userAttendence.ActiveWorkHours[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + userAttendence.AttendanceNum[userAttendence.ActiveWorkHours.Count() - 1].ToString() + "\"";
                    }
                    if (j == 3)
                    {
                        for (int i = 0; i < userAttendence.TotalAttendenceHours.Count()-1; i++)
                        {
                            strJson += "\"" + userAttendence.TotalAttendenceHours[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + userAttendence.TotalAttendenceHours[userAttendence.TotalAttendenceHours.Count() - 1].ToString().Trim() + "\"";
                    }
                    
                    strJson += "]";
                    strJson += "}";
                    strJson += ",";
                   
                }
                strJson = strJson.Trim().TrimEnd(new char[] { ',' });
                strJson += "]}";
                context.Response.Write(strJson);
            }
            #endregion
            #region //每月出勤人数报表
            if (Action == "GetUserAttendenceChart")
            {
                UserAttendence userAttendence = new UserAttendence();
                userAttendence = GetAttendenceData(userAttendence);
                Chart chart = new Chart();

                List<string> catagory = new List<string>();
                List<double> datavalue = new List<double>();

                for (int i = 1; i < userAttendence.AttendanceNum.Count(); i++ )
                {
                    catagory.Add(i.ToString());

                    datavalue.Add(Convert.ToDouble(userAttendence.AttendanceNum[i] == "" ? "0" : userAttendence.AttendanceNum[i].ToString()));
                }
               
                chart.catagory = catagory;
                chart.datavalue = datavalue;
                context.Response.Write(jsc.Serialize(chart));
            }
            #endregion
            #region //人员产能
            if (Action == "PersonCapacityReport")
            {
                PersonCapacityEntity personCapacity = new PersonCapacityEntity();
                personCapacity = GetPersonCapaticyData(personCapacity);
                string strJson = "";
                strJson = "{\"page\":1,\"total\": 3 ,\"records\":4,\"rows\":[";
                for (int j = 0; j < 3; j++)
                {
                    strJson += "{";
                    strJson += "\"id\":\"" + (j + 1).ToString() + "\",";
                    strJson += "\"cell\":";
                    strJson += "[";
                  
                    if (j == 0)
                    {
                        for (int i = 0; i < personCapacity.Yield.Count() - 1; i++)
                        {
                            strJson += "\"" + personCapacity.Yield[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + personCapacity.Yield[personCapacity.Yield.Count() - 1].ToString() + "\"";
                    }
                    if (j == 1)
                    {
                        for (int i = 0; i < personCapacity.PersonNum.Count() - 1; i++)
                        {
                            strJson += "\"" + personCapacity.PersonNum[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + personCapacity.PersonNum[personCapacity.PersonNum.Count() - 1].ToString().Trim() + "\"";
                    }
                    if (j == 2)
                    {
                        for (int i = 0; i < personCapacity.PerCapacity.Count() - 1; i++)
                        {
                            strJson += "\"" + personCapacity.PerCapacity[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + personCapacity.PerCapacity[personCapacity.PerCapacity.Count() - 1].ToString() + "\"";
                    }
                  
                    strJson += "]";
                    strJson += "}";
                    strJson += ",";

                }
                strJson = strJson.Trim().TrimEnd(new char[] { ',' });
                strJson += "]}";
                context.Response.Write(strJson);
            }
            #endregion
            #region//人员产能报表
            if (Action == "GetPersonCapacityChart")
            {
                PersonCapacityEntity personCapacity = new PersonCapacityEntity();
                personCapacity = GetPersonCapaticyData(personCapacity);
                DoubleChart chart = new DoubleChart();

                List<string> catagory = new List<string>();
                List<double> datavalue = new List<double>();
                List<double> datavalue1 = new List<double>();
                for (int i = 1; i < personCapacity.Yield.Count(); i++)
                {
                    catagory.Add(i.ToString());

                    datavalue.Add(Convert.ToDouble(personCapacity.Yield[i] == "" ? "0" : personCapacity.Yield[i].ToString()));
                }
                for (int i = 1; i < personCapacity.PerCapacity.Count(); i++)
                {
                    //catagory.Add(i.ToString());
                    datavalue1.Add(Convert.ToDouble(personCapacity.PerCapacity[i] == "" ? "0" : personCapacity.PerCapacity[i].ToString()));
                }
                chart.catagory = catagory;
                chart.datavalueFirst = datavalue;
                chart.datavalueSecond= datavalue1;
                context.Response.Write(jsc.Serialize(chart));
            }
            #endregion

            #region//每日生产完成率
            if (Action == "DailyCompletionRateReport")
            {
                DailyCompletionRateEntity dailyCompletionRate = new DailyCompletionRateEntity();

                dailyCompletionRate = GetDailyCompletionRate(dailyCompletionRate);

                string strJson = "";
                strJson = "{\"page\":1,\"total\": 11 ,\"records\":11,\"rows\":[";
                for (int j = 0; j < 11; j++)
                {
                    strJson += "{";
                    strJson += "\"id\":\"" + (j + 1).ToString() + "\",";
                    strJson += "\"cell\":";
                    strJson += "[";
                    
                    if (j == 0)
                    {
                        for (int i = 0; i < dailyCompletionRate.DispatchNum.Count()-1; i++)
                        {
                            strJson += "\"" + dailyCompletionRate.DispatchNum[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + dailyCompletionRate.DispatchNum[dailyCompletionRate.DispatchNum.Count()-1].ToString() + "\"";
                    }
                    if (j == 1)
                    {
                        for (int i = 0; i < dailyCompletionRate.SAPPostNum.Count()-1; i++)
                        {
                            strJson += "\"" + dailyCompletionRate.SAPPostNum[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + dailyCompletionRate.SAPPostNum[dailyCompletionRate.SAPPostNum.Count()-1].ToString().Trim() + "\"";
                    }
                    if (j == 2)
                    {
                        for (int i = 0; i < dailyCompletionRate.PostNum.Count()-1; i++)
                        {
                            strJson += "\"" + dailyCompletionRate.PostNum[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + dailyCompletionRate.PostNum[dailyCompletionRate.PostNum.Count()-1].ToString() + "\"";
                    }
                    if (j == 3)
                    {
                        for (int i = 0; i < dailyCompletionRate.OrderAccuracy.Count() - 1; i++)
                        {
                            strJson += "\"" + dailyCompletionRate.OrderAccuracy[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + dailyCompletionRate.OrderAccuracy[dailyCompletionRate.OrderAccuracy.Count() - 1].ToString() + "\"";
                    }
                    if (j == 4)
                    {
                        for (int i = 0; i < dailyCompletionRate.TimelyRate.Count() - 1; i++)
                        {
                            strJson += "\"" + dailyCompletionRate.TimelyRate[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + dailyCompletionRate.TimelyRate[dailyCompletionRate.TimelyRate.Count() - 1].ToString() + "\"";
                    }
                    if (j == 5)
                    {
                        for (int i = 0; i < dailyCompletionRate.AttendanceNum.Count() - 1; i++)
                        {
                            strJson += "\"" + dailyCompletionRate.AttendanceNum[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + dailyCompletionRate.AttendanceNum[dailyCompletionRate.AttendanceNum.Count() - 1].ToString() + "\"";
                    }
                    if (j == 6)
                    {
                        for (int i = 0; i < dailyCompletionRate.WorkHour.Count() - 1; i++)
                        {
                            strJson += "\"" + dailyCompletionRate.WorkHour[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + dailyCompletionRate.WorkHour[dailyCompletionRate.WorkHour.Count() - 1].ToString() + "\"";
                    }
                    if (j == 7)
                    {
                        for (int i = 0; i < dailyCompletionRate.AttendanceTime.Count() - 1; i++)
                        {
                            strJson += "\"" + dailyCompletionRate.AttendanceTime[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + dailyCompletionRate.AttendanceTime[dailyCompletionRate.AttendanceTime.Count() - 1].ToString() + "\"";
                    }
                    if (j == 8)
                    {
                        for (int i = 0; i < dailyCompletionRate.EffectiveTime.Count() - 1; i++)
                        {
                            strJson += "\"" + dailyCompletionRate.EffectiveTime[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + dailyCompletionRate.EffectiveTime[dailyCompletionRate.EffectiveTime.Count() - 1].ToString() + "\"";
                    }
                    if (j == 9)
                    {
                        for (int i = 0; i < dailyCompletionRate.EffectiveRate.Count() - 1; i++)
                        {
                            strJson += "\"" + dailyCompletionRate.EffectiveRate[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + dailyCompletionRate.EffectiveRate[dailyCompletionRate.EffectiveRate.Count() - 1].ToString() + "\"";
                    }
                    if (j == 10)
                    {
                        for (int i = 0; i < dailyCompletionRate.MonthCompleteRate.Count() - 1; i++)
                        {
                            strJson += "\"" + dailyCompletionRate.MonthCompleteRate[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + dailyCompletionRate.MonthCompleteRate[dailyCompletionRate.MonthCompleteRate.Count() - 1].ToString() + "\"";
                    }
                    strJson += "]";
                    strJson += "}";
                    strJson += ",";

                }
                strJson = strJson.Trim().TrimEnd(new char[] { ',' });
                strJson += "]}";
                context.Response.Write(strJson);
            }
            #endregion
            #region//月度生产完成率
            if (Action == "MonthCompletionRateReport")
            {
                MonthCompletionRateEntity monthCompletionRate = new MonthCompletionRateEntity();
                monthCompletionRate = GetMonthlyCompletionRate(monthCompletionRate);
                string strJson = "";
                strJson = "{\"page\":1,\"total\": 7 ,\"records\":7,\"rows\":[";
                for (int j = 0; j < 7; j++)
                {
                    strJson += "{";
                    strJson += "\"id\":\"" + (j + 1).ToString() + "\",";
                    strJson += "\"cell\":";
                    strJson += "[";

                    if (j == 0)
                    {
                        for (int i = 0; i < monthCompletionRate.BudgetedQty.Count() - 1; i++)
                        {
                            strJson += "\"" + monthCompletionRate.BudgetedQty[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + monthCompletionRate.BudgetedQty[monthCompletionRate.BudgetedQty.Count() - 1].ToString() + "\"";
                    }
                    if (j == 1)
                    {
                        for (int i = 0; i < monthCompletionRate.FinishQty.Count() - 1; i++)
                        {
                            strJson += "\"" + monthCompletionRate.FinishQty[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + monthCompletionRate.FinishQty[monthCompletionRate.FinishQty.Count() - 1].ToString().Trim() + "\"";
                    }
                    if (j == 2)
                    {
                        for (int i = 0; i < monthCompletionRate.BudgetedCompletionRate.Count() - 1; i++)
                        {
                            strJson += "\"" + monthCompletionRate.BudgetedCompletionRate[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + monthCompletionRate.BudgetedCompletionRate[monthCompletionRate.BudgetedCompletionRate.Count() - 1].ToString() + "\"";
                    }
                    if (j == 3)
                    {
                        for (int i = 0; i < monthCompletionRate.DesignYield.Count() - 1; i++)
                        {
                            strJson += "\"" + monthCompletionRate.DesignYield[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + monthCompletionRate.DesignYield[monthCompletionRate.DesignYield.Count() - 1].ToString() + "\"";
                    }
                    if (j == 4)
                    {
                        for (int i = 0; i < monthCompletionRate.CapacityRate.Count() - 1; i++)
                        {
                            strJson += "\"" + monthCompletionRate.CapacityRate[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + monthCompletionRate.CapacityRate[monthCompletionRate.CapacityRate.Count() - 1].ToString() + "\"";
                    }
                    if (j == 5)
                    {
                        for (int i = 0; i < monthCompletionRate.ERPPlanYield.Count() - 1; i++)
                        {
                            strJson += "\"" + monthCompletionRate.ERPPlanYield[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + monthCompletionRate.ERPPlanYield[monthCompletionRate.ERPPlanYield.Count() - 1].ToString() + "\"";
                    }
                    if (j == 6)
                    {
                        for (int i = 0; i < monthCompletionRate.ERPCompleteRate.Count() - 1; i++)
                        {
                            strJson += "\"" + monthCompletionRate.ERPCompleteRate[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + monthCompletionRate.ERPCompleteRate[monthCompletionRate.ERPCompleteRate.Count() - 1].ToString() + "\"";
                    }
                  
                    strJson += "]";
                    strJson += "}";
                    strJson += ",";

                }
                strJson = strJson.Trim().TrimEnd(new char[] { ',' });
                strJson += "]}";
                context.Response.Write(strJson);

            }
            #endregion
            #region //月度生产完成率柱状图
            if (Action == "MonthCompletionRateChart")
            {
                MonthCompletionRateEntity monthCompletionRate = new MonthCompletionRateEntity();
                monthCompletionRate = GetMonthlyCompletionRate(monthCompletionRate);
                List<ChartWithName> chart = new List<ChartWithName>();
                
                List<string> catagory= new List<string>();

                List<double> datavalue1 = new List<double>();
                List<double> datavalue2 = new List<double>();
                List<double> datavalue3 = new List<double>();
                
                for (int i = 1; i < monthCompletionRate.BudgetedQty.Count()-1; i++)
                {
                    catagory.Add(i.ToString()+'月');

                    datavalue1.Add(Convert.ToDouble(monthCompletionRate.BudgetedQty[i] == "" ? "0" : monthCompletionRate.BudgetedQty[i].ToString()));
                }

                for (int i = 1; i < monthCompletionRate.FinishQty.Count()-1; i++)
                {

                    datavalue2.Add(Convert.ToDouble(monthCompletionRate.FinishQty[i] == "" ? "0" : monthCompletionRate.FinishQty[i].ToString()));
                }


                for (int i = 1; i < monthCompletionRate.ERPPlanYield.Count()-1; i++)
                {

                    datavalue3.Add(Convert.ToDouble(monthCompletionRate.ERPPlanYield[i] == "" ? "0" : monthCompletionRate.ERPPlanYield[i].ToString()));
                }

                chart.Add(new ChartWithName() 
                { 
                    name = monthCompletionRate.BudgetedQty[0].ToString(),  
                    catagory = catagory, 
                    datavalue = datavalue1 
                });
                chart.Add(new ChartWithName()
                {
                    name = monthCompletionRate.FinishQty[0].ToString(),  
                    catagory = catagory, 
                    datavalue = datavalue2 
                });
                chart.Add(new ChartWithName()
                {
                    name = monthCompletionRate.DesignYield[0].ToString(),  
                    catagory = catagory, 
                    datavalue = datavalue3 
                });
                context.Response.Write(jsc.Serialize(chart));
            }
            #endregion

            #region//获取每月预算产量
            if (Action == "GetMonthBudget")
            {
                MonthBudget mb = new MonthBudget();
                mb.CurrentMonth=RequstString("CurrentMonth");
                mb=GetMonthBudget(mb);
                context.Response.Write(jsc.Serialize(mb));
            }
            #endregion
            #region //新增每月预算产量
            if (Action == "MonthBudget_Add")
            {
                MonthBudget mb = new MonthBudget();
                mb.CurrentMonth = RequstString("CurrentMonth");
                mb.BudgetedQty = RequstString("MonthBudget");
                ResultMsg_MonthBudget result = new ResultMsg_MonthBudget();
                result = MonthBudgetMan(mb, result);
                context.Response.Write(jsc.Serialize(result));
            }
            #endregion
            #region //更新每月预算产量
            if (Action == "MonthBudget_Edit")
            {
                MonthBudget mb = new MonthBudget();
                mb.CurrentMonth = RequstString("CurrentMonth");
                mb.BudgetedQty = RequstString("MonthBudget");
                ResultMsg_MonthBudget result = new ResultMsg_MonthBudget();
                result = MonthBudgetEdit(mb, result);
                context.Response.Write(jsc.Serialize(result));
            }
            #endregion
            #region //产品直通率报表
            if (Action == "ProductThroughRateReport")
            {
                List<ProductThroughRateEntity> productThroughRate = new List<ProductThroughRateEntity>();
                productThroughRate = GetProductThroughInfoList(productThroughRate);
                context.Response.Write(jsc.Serialize(productThroughRate));
            }
            #endregion

            #region //产品直通率折线图
            if (Action == "ProductThroughRateChart")
            {
                List<ProductThroughRateEntity> productThroughRate = new List<ProductThroughRateEntity>();
                productThroughRate = GetProductThroughInfoList(productThroughRate);
                
                List<ChartWithName> chart = new List<ChartWithName>();
                List<string> catagory = new List<string>();
                List<double> datavalue1 = new List<double>();
                List<double> datavalue2 = new List<double>();
                List<double> datavalue3 = new List<double>();
                List<double> datavalue4 = new List<double>();

                for (int i = 0; i < productThroughRate.Count; i+=4 )
                {
                    catagory.Add(productThroughRate[i].Date);
                    datavalue1.Add(Convert.ToDouble(productThroughRate[i].ProcessQty == "" ? "0" : productThroughRate[i].ProcessQty.ToString()));
                    datavalue2.Add(Convert.ToDouble(productThroughRate[i+1].ProcessQty == "" ? "0" : productThroughRate[i+1].ProcessQty.ToString()));
                    datavalue3.Add(Convert.ToDouble(productThroughRate[i+2].ProcessQty == "" ? "0" : productThroughRate[i+2].ProcessQty.ToString()));
                    datavalue4.Add(Convert.ToDouble(productThroughRate[i+3].ProcessQty == "" ? "0" : productThroughRate[i+3].ProcessQty.ToString()));
                    if (i == productThroughRate.Count - 4)
                    {
                        break;
                    }
                }
                chart.Add(new ChartWithName()
                {
                    name = productThroughRate[0].ProcessName.ToString(),
                    catagory = catagory,
                    datavalue = datavalue1
                });
                chart.Add(new ChartWithName()
                {
                    name = productThroughRate[1].ProcessName.ToString(),
                    catagory = catagory,
                    datavalue = datavalue2
                });
                chart.Add(new ChartWithName()
                {
                    name = productThroughRate[2].ProcessName.ToString(),
                    catagory = catagory,
                    datavalue = datavalue3
                });
                chart.Add(new ChartWithName()
                {
                    name = productThroughRate[3].ProcessName.ToString(),
                    catagory = catagory,
                    datavalue = datavalue4
                });
                context.Response.Write(jsc.Serialize(chart));
            }
            #endregion
            #region //年度产量对比
            if (Action == "ProductionCompareReport")
            {
                ProductionCompareEntity productCompare = new ProductionCompareEntity();
                productCompare = GetProductCompare(productCompare);
                string strJson = "";
                double sumYiled = 0;
                double sumYiledSecond = 0;

                strJson = "{\"page\":1,\"total\": 3 ,\"records\":4,\"rows\":[";
                for (int j = 0; j < 3; j++)
                {
                    strJson += "{";
                    strJson += "\"id\":\"" + (j + 1).ToString() + "\",";
                    strJson += "\"cell\":";
                    strJson += "[";

                    if (j == 0)
                    {
                        for (int i = 0; i < productCompare.Yiled.Count() - 1; i++)
                        {
                            strJson += "\"" + productCompare.Yiled[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + productCompare.Yiled[productCompare.Yiled.Count() - 1].ToString() + "\"";
                    }
                    if (j == 1)
                    {
                        for (int i = 0; i < productCompare.YiledSecond.Count() - 1; i++)
                        {
                            strJson += "\"" + productCompare.YiledSecond[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + productCompare.YiledSecond[productCompare.YiledSecond.Count() - 1].ToString() + "\"";
                    }
                    if (j == 2)
                    {
                        for (int i = 0; i < productCompare.YiledCompare.Count() - 1; i++)
                        {
                            strJson += "\"" + productCompare.YiledCompare[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + productCompare.YiledCompare[productCompare.YiledCompare.Count() - 1].ToString() + "\"";
                    }
                    strJson += "]";
                    strJson += "}";
                    strJson += ",";

                }
                strJson = strJson.Trim().TrimEnd(new char[] { ',' });
                strJson += "]}";
                context.Response.Write(strJson);

            }
            #endregion

            #region//年度产量对比柱状图
            if (Action == "ProductionCompareChart")
            {
                ProductionCompareEntity personCapacity = new ProductionCompareEntity();
                personCapacity = GetProductCompare(personCapacity);
                DoubleChart chart = new DoubleChart();

                List<string> catagory = new List<string>();
                List<double> datavalueFirst = new List<double>();
                List<double> datavalueSecond = new List<double>();

                for (int i = 1; i < personCapacity.Yiled.Count()-1; i++)
                {
                    catagory.Add(i.ToString());

                    datavalueFirst.Add(Convert.ToDouble(personCapacity.Yiled[i] == "" ? "0" : personCapacity.Yiled[i].ToString()));
                }

                for (int i = 1; i < personCapacity.YiledSecond.Count()-1; i++)
                {
                    catagory.Add(i.ToString());

                    datavalueSecond.Add(Convert.ToDouble(personCapacity.YiledSecond[i] == "" ? "0" : personCapacity.YiledSecond[i].ToString()));
                }

                chart.catagory = catagory;
                chart.datavalueFirst = datavalueFirst;
                chart.datavalueSecond = datavalueSecond;
                context.Response.Write(jsc.Serialize(chart));
            }
            #endregion

            //生产溯源


            #region//订单生产情况
            if (Action == "OrderProductInfo")
            {
                List<ProductionStatisticEntity> productionStatistic = new List<ProductionStatisticEntity>();
                productionStatistic = GetOrderProductInfoList(productionStatistic);
                context.Response.Write(jsc.Serialize(productionStatistic));
            }
            #endregion
            #region//下线情况
            if (Action == "AbnormalInfo")
            {
                List<AbnormalInfo> abnormal = new List<AbnormalInfo>();
                abnormal = GetAbnormalInfoList(abnormal);
                context.Response.Write(jsc.Serialize(abnormal));
            }
            #endregion
            #region//设备报警情况
            if (Action == "EquAlarmInfo")
            {
                List<EquAlarmInfo> equAlarm = new List<EquAlarmInfo>();
                equAlarm = GetEquAlarmInfoList(equAlarm);
                context.Response.Write(jsc.Serialize(equAlarm));
            }
            #endregion
            #region//物料拉动情况
            if (Action == "MaterialPullInfo")
            {
                List<MaterialPullInfo> materialPull = new List<MaterialPullInfo>();
                materialPull = GetMaterialPullInfoList(materialPull);
                context.Response.Write(jsc.Serialize(materialPull));
            }
            #endregion

            #region  //一级保养点检表
            if (Action == "FirstLevelInspectionReport")
            {
                FirstLevelMaintence firstLevelMaintence = new FirstLevelMaintence();
                firstLevelMaintence = GetFirstLevelMaintence(firstLevelMaintence);
                string strJson = "";
                strJson = "{\"page\":1,\"total\": 7 ,\"records\":7,\"rows\":[";
                for (int j = 0; j < 7; j++)
                {
                    strJson += "{";
                    strJson += "\"id\":\"" + (j + 1).ToString() + "\",";
                    strJson += "\"cell\":";
                    strJson += "[";

                    if (j == 0)
                    {
                        for (int i = 0; i < firstLevelMaintence.InspectionStandrad1.Count() - 1; i++)
                        {
                            strJson += "\"" + firstLevelMaintence.InspectionStandrad1[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + firstLevelMaintence.InspectionStandrad1[firstLevelMaintence.InspectionStandrad1.Count() - 1].ToString() + "\"";
                    }
                    if (j == 1)
                    {
                        for (int i = 0; i < firstLevelMaintence.InspectionStandrad2.Count() - 1; i++)
                        {
                            strJson += "\"" + firstLevelMaintence.InspectionStandrad2[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + firstLevelMaintence.InspectionStandrad2[firstLevelMaintence.InspectionStandrad2.Count() - 1].ToString().Trim() + "\"";
                    }
                    if (j == 2)
                    {
                        for (int i = 0; i < firstLevelMaintence.InspectionStandrad3.Count() - 1; i++)
                        {
                            strJson += "\"" + firstLevelMaintence.InspectionStandrad3[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + firstLevelMaintence.InspectionStandrad3[firstLevelMaintence.InspectionStandrad3.Count() - 1].ToString() + "\"";
                    }
                    if (j == 3)
                    {
                        for (int i = 0; i < firstLevelMaintence.InspectionStandrad4.Count() - 1; i++)
                        {
                            strJson += "\"" + firstLevelMaintence.InspectionStandrad4[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + firstLevelMaintence.InspectionStandrad4[firstLevelMaintence.InspectionStandrad4.Count() - 1].ToString() + "\"";
                    }
                    if (j == 4)
                    {
                        for (int i = 0; i < firstLevelMaintence.InspectionStandrad5.Count() - 1; i++)
                        {
                            strJson += "\"" + firstLevelMaintence.InspectionStandrad5[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + firstLevelMaintence.InspectionStandrad5[firstLevelMaintence.InspectionStandrad5.Count() - 1].ToString() + "\"";
                    }
                    if (j == 5)
                    {
                        for (int i = 0; i < firstLevelMaintence.InspectionStandrad6.Count() - 1; i++)
                        {
                            strJson += "\"" + firstLevelMaintence.InspectionStandrad6[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + firstLevelMaintence.InspectionStandrad6[firstLevelMaintence.InspectionStandrad6.Count() - 1].ToString() + "\"";
                    }
                    if (j == 6)
                    {
                        for (int i = 0; i < firstLevelMaintence.InspectionStandrad7.Count() - 1; i++)
                        {
                            strJson += "\"" + firstLevelMaintence.InspectionStandrad7[i].ToString().Trim() + "\",";
                        }
                        strJson += "\"" + firstLevelMaintence.InspectionStandrad7[firstLevelMaintence.InspectionStandrad7.Count() - 1].ToString() + "\"";
                    }
                    
                    strJson += "]";
                    strJson += "}";
                    strJson += ",";

                }
                strJson = strJson.Trim().TrimEnd(new char[] { ',' });
                strJson += "]}";
                context.Response.Write(strJson);
            }
            #endregion

            #region  一级点检问题记录
            if (Action == "FirstLevelInspectionProblemReport")
            {
                List<FirstLevelMaintenceProblem> problem = new List<FirstLevelMaintenceProblem>();
                problem = GetFirstLevelMaintenceProblem(problem);
                if(problem.Count==0)
                {
                    string strJson = "";
                    strJson = "{\"page\":1,\"total\": 1 ,\"records\":1,\"rows\":[";
                    for (int j = 0; j < 3; j++)
                    {
                        strJson += "{";
                        strJson += "\"id\":\"" + (j + 1).ToString() + "\",";
                        strJson += "\"cell\":";
                        strJson += "[";
                        strJson += "{";
                        strJson += "\"id\":\"1\",";
                        strJson += "\"cell\":";
                        strJson += "[";

                        for (int i = 0; i < 4; i++)
                        {
                            strJson += "\"\",";
                        }
                        strJson += "\"\"";

                        strJson += "]";
                        strJson += "}";
                        strJson += ",";
                    }
                    strJson = strJson.Trim().TrimEnd(new char[] { ',' });
                    strJson += "]}";
                    context.Response.Write(strJson);
                }
                else
                {
                    context.Response.Write(jsc.Serialize(problem));
                }
            }
            #endregion

            #region 二级点检设备明细
            if (Action == "SecondLevelInspectionReport")
            {
                List<SecondLevelMaintence> problem = new List<SecondLevelMaintence>();
                problem = GetSecondLevelMaintence(problem);
                if (problem.Count == 0)
                {
                    string strJson = "";
                    strJson = "{\"page\":1,\"total\": 1 ,\"records\":1,\"rows\":[";

                    strJson += "{";
                    strJson += "\"id\":\"1\",";
                    strJson += "\"cell\":";
                    strJson += "[";

                    for (int i = 0; i < 4; i++)
                    {
                        strJson += "\"\",";
                    }
                    strJson += "\"\"";

                    strJson += "]";
                    strJson += "}";
                    strJson += ",";
                    strJson = strJson.Trim().TrimEnd(new char[] { ',' });
                    strJson += "]}";
                    context.Response.Write(strJson);
                }
                else
                {
                    context.Response.Write(jsc.Serialize(problem));
                }
            }
            #endregion

            #region 二级点检内容
            if (Action == "SecondLevelInspectionContent")
            {
                List<SecondLevelMaintenceContent> problem = new List<SecondLevelMaintenceContent>();
                problem = GetSecondLevelMaintenceContent(problem);
                context.Response.Write(jsc.Serialize(problem));
            }
            #endregion

            #region 二级点检更换配件明细
            if (Action == "SecondLevelInspectionReplace")
            {
                List<SecondLevelMaintenceReplace> problem = new List<SecondLevelMaintenceReplace>();
                problem = GetSecondLevelMaintenceReplace(problem);
                if (problem.Count == 0)
                {
                    string strJson = "";
                    strJson = "{\"page\":1,\"total\": 3 ,\"records\":3,\"rows\":[";
                    for (int j = 0; j < 3; j++)
                    {
                        strJson += "{";
                        strJson += "\"id\":\"" + (j + 1).ToString() + "\",";
                        strJson += "\"cell\":";
                        strJson += "[";

                        for (int i = 0; i < 6; i++)
                        {
                            strJson += "\"\",";
                        }
                        strJson += "\"\"";
                        
                        strJson += "]";
                        strJson += "}";
                        strJson += ",";

                    }
                    strJson = strJson.Trim().TrimEnd(new char[] { ',' });
                    strJson += "]}";
                    context.Response.Write(strJson);
                }
                else
                {
                    context.Response.Write(jsc.Serialize(problem));
                }
            }
            #endregion


            #region  //节拍统计表
            if (Action == "ProcessBeatReport")
            {
                List<ProcessBeat> processBeat = new List<ProcessBeat>();
                processBeat = GetProcessBeat(processBeat);
                context.Response.Write(jsc.Serialize(processBeat));
            }
            #endregion

            #region  //节拍统计图
            if (Action == "ProcessBeatChart")
            {
                List<ProcessBeat> processBeat = new List<ProcessBeat>();
                processBeat = GetProcessBeat(processBeat);
                //List<string> list = new List<string>();
                //list = processBeat.Select(p => p.Process).Distinct().ToList();
                List<Chart> chart = new List<Chart>();
                List<string> catagory = new List<string>();
                List<double> datavalueMin = new List<double>();
                List<double> datavalueMax = new List<double>();
                List<double> datavalueDefalut = new List<double>();
                List<double> datavalueAvg = new List<double>();
                processBeat=  processBeat.Where((x, i) => processBeat.FindIndex(z => z.Process == x.Process) == i).ToList();  
                //catagory = list;
                for (int i = 0; i < processBeat.Count() ; i++)
                {
                    catagory.Add( processBeat[i].Process.ToString());
                    datavalueMin.Add(Convert.ToDouble(processBeat[i].BeatMin == "" ? "0" : processBeat[i].BeatMin.ToString()));
                    datavalueMax.Add(Convert.ToDouble(processBeat[i].BeatMax == "" ? "0" : processBeat[i].BeatMax.ToString()));
                    datavalueDefalut.Add(Convert.ToDouble(processBeat[i].Number == "" ? "0" : processBeat[i].Number.ToString()));
                    datavalueAvg.Add(Convert.ToDouble(processBeat[i].BeatPer == "" ? "0" : processBeat[i].BeatPer.ToString()));
                }

                chart.Add(new Chart()
                {
                    catagory = catagory,
                    datavalue = datavalueMin
                });
                chart.Add(new Chart()
                {
                    catagory = catagory,
                    datavalue = datavalueMax
                });
                chart.Add(new Chart()
                {
                    catagory = catagory,
                    datavalue = datavalueDefalut
                });
                chart.Add(new Chart()
                {
                    catagory = catagory,
                    datavalue = datavalueAvg
                });

                context.Response.Write(jsc.Serialize(chart));
            }
            #endregion
        }
           

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }

        public static string RequstString(string sParam)
        {
            String ret = String.Empty;
            try
            {
                ret = (HttpContext.Current.Request[sParam] == null ? string.Empty
                      : HttpContext.Current.Request[sParam].ToString().Trim());
            }
            catch (Exception)
            {
                ret = "";
            }
            return ret;
        }


        /// <summary>
        /// 设别报警
        /// </summary>
        /// <param name="dataEntity"></param>
        /// <returns></returns>
        public List<EquAlarmEntity> GetEquAlarmList(List<EquAlarmEntity> dataEntity)
        {
            DataTable dt = new DataTable();
            string processName = RequstString("ProcessName");
            string deviceName = RequstString("DeviceName");
            string DealWithResult = RequstString("DealWithResult");
            string AlarmStartTime = RequstString("AlarmStartTime");
            string AlarmEndTime = RequstString("AlarmEndTime");
            string DealWithStartTime = RequstString("DealWithStartTime");
            string DealWithEndTime = RequstString("DealWithEndTime");
            string AlarmItem = RequstString("AlarmItem");

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Report_EquAlarm";
                SqlParameter[] sqlPara = new SqlParameter[8];
                sqlPara[0] = new SqlParameter("@processName", processName);
                sqlPara[1] = new SqlParameter("@deviceName", deviceName);
                sqlPara[2] = new SqlParameter("@DealWithResult", DealWithResult);
                sqlPara[3] = new SqlParameter("@AlarmStartTime", AlarmStartTime);
                sqlPara[4] = new SqlParameter("@AlarmEndTime", AlarmEndTime);
                sqlPara[5] = new SqlParameter("@DealWithStartTime", DealWithStartTime);
                sqlPara[6] = new SqlParameter("@DealWithEndTime", DealWithEndTime);
                sqlPara[7] = new SqlParameter("@AlarmItem", AlarmItem);
                
                foreach (SqlParameter para in sqlPara)
                {
                    cmd.Parameters.Add(para);
                }
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
               
                Datapter.Fill(dt);
                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        EquAlarmEntity itemList = new EquAlarmEntity();
                        itemList.ID = dt.Rows[i]["ID"].ToString();
                        itemList.Number = (i + 1).ToString();
                        itemList.ProcessName = dt.Rows[i]["ProcessName"].ToString();
                        itemList.DeviceName = dt.Rows[i]["DeviceName"].ToString();
                        itemList.AlarmTime = dt.Rows[i]["AlarmTime"].ToString();
                        itemList.AlarmItem = dt.Rows[i]["AlarmItem"].ToString();
                        itemList.DealWithResult = dt.Rows[i]["DealWithResult"].ToString();
                        itemList.DealWithTime = dt.Rows[i]["DealWithTime"].ToString();
                        itemList.DealWithOper = dt.Rows[i]["DealWithOper"].ToString();
                        itemList.DealWithComment = dt.Rows[i]["DealWithComment"].ToString();
                        itemList.StopTime = dt.Rows[i]["StopTime"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        /// <summary>
        /// 设备报警柱状图
        /// </summary>
        /// <param name="dataEntity"></param>
        /// <returns></returns>
        public EquAlarm GetEquAlarmReport(EquAlarm dataEntity)
        {

            DataTable dt = new DataTable();
            string processName = RequstString("ProcessName");
            string deviceName = RequstString("DeviceName");
            string DealWithResult = RequstString("DealWithResult");
            string AlarmStartTime = RequstString("AlarmStartTime");
            string AlarmEndTime = RequstString("AlarmEndTime");
            string DealWithStartTime = RequstString("DealWithStartTime");
            string DealWithEndTime = RequstString("DealWithEndTime");
            string AlarmItem = RequstString("AlarmItem");
            EquAlarm itemList = new EquAlarm();

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Report_EquAlarmChart";
                SqlParameter[] sqlPara = new SqlParameter[8];
                sqlPara[0] = new SqlParameter("@processName", processName);
                sqlPara[1] = new SqlParameter("@deviceName", deviceName);
                sqlPara[2] = new SqlParameter("@DealWithResult", DealWithResult);
                sqlPara[3] = new SqlParameter("@AlarmStartTime", AlarmStartTime);
                sqlPara[4] = new SqlParameter("@AlarmEndTime", AlarmEndTime);
                sqlPara[5] = new SqlParameter("@DealWithStartTime", DealWithStartTime);
                sqlPara[6] = new SqlParameter("@DealWithEndTime", DealWithEndTime);
                sqlPara[7] = new SqlParameter("@AlarmItem", AlarmItem);

                foreach (SqlParameter para in sqlPara)
                {
                    cmd.Parameters.Add(para);
                }
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                List<string> Device = new List<string>();
                List<string> AlarmCount = new List<string>();
                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        Device.Add(dt.Rows[i]["DeviceName"].ToString());
                        AlarmCount.Add(dt.Rows[i]["AlarmCount"].ToString());
                    }
                }
                itemList.Device = Device;
                itemList.AlarmCount = AlarmCount;
            }
            return itemList;
        }

        /// <summary>
        /// 设备报警明细
        /// </summary>
        /// <param name="dataEntity"></param>
        /// <returns></returns>
        public List<EquAlarmEntity> GetEquAlarmDetail(List<EquAlarmEntity> dataEntity)
        {
            DataTable dt = new DataTable();
            string plcName = RequstString("PlcName");
            string processName = RequstString("ProcessName");
            string deviceName = RequstString("DeviceName");
            string DealWithResult = RequstString("DealWithResult");
            string AlarmStartTime = RequstString("AlarmStartTime");
            string AlarmEndTime = RequstString("AlarmEndTime");
            string DealWithStartTime = RequstString("DealWithStartTime");
            string DealWithEndTime = RequstString("DealWithEndTime");
            string AlarmItem = RequstString("AlarmItem");

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Report_EquAlarmDetail";
                SqlParameter[] sqlPara = new SqlParameter[9];

                sqlPara[0] = new SqlParameter("@plcName", plcName);
                sqlPara[1] = new SqlParameter("@processName", processName);
                sqlPara[2] = new SqlParameter("@deviceName", deviceName);
                sqlPara[3] = new SqlParameter("@DealWithResult", DealWithResult);
                sqlPara[4] = new SqlParameter("@AlarmStartTime", AlarmStartTime);
                sqlPara[5] = new SqlParameter("@AlarmEndTime", AlarmEndTime);
                sqlPara[6] = new SqlParameter("@DealWithStartTime", DealWithStartTime);
                sqlPara[7] = new SqlParameter("@DealWithEndTime", DealWithEndTime);
                sqlPara[8] = new SqlParameter("@AlarmItem", AlarmItem);

                foreach (SqlParameter para in sqlPara)
                {
                    cmd.Parameters.Add(para);
                }
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);

                Datapter.Fill(dt);
                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        EquAlarmEntity itemList = new EquAlarmEntity();
                        
                        itemList.DeviceName = dt.Rows[i]["DeviceName"].ToString();
                        itemList.AlarmTime = dt.Rows[i]["AlarmTime"].ToString();
                        itemList.AlarmItem = dt.Rows[i]["AlarmItem"].ToString();
                        
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        /// <summary>
        /// 物料拉动
        /// </summary>
        /// <param name="dataEntity"></param>
        /// <returns></returns>
        public List<MaterialPullEntity> GetMaterialPullList(List<MaterialPullEntity> dataEntity)
        {
            DataTable dt = new DataTable();
            string orderno = RequstString("Orderno");
            string materialCode = RequstString("MaterialCode");
            string produce = RequstString("Produce");
            string Status = RequstString("Status");
            string PullTimeStart = RequstString("PullTimeStart");
            string PullTimeEnd = RequstString("PullTimeEnd");
            string OTFlag = RequstString("OTFlag");
            string ActionTimeStart = RequstString("ActionTimeStart");
            string ActionTimeEnd = RequstString("ActionTimeEnd");
            string ActionUser = RequstString("ActionUser");
            string ConfirmTimeStart = RequstString("ConfirmTimeStart");
            string ConfirmTimeEnd = RequstString("ConfirmTimeEnd");
            string ConfirmUser = RequstString("ConfirmUser");

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Report_MaterialPull";
                SqlParameter[] sqlPara = new SqlParameter[13];
                sqlPara[0] = new SqlParameter("@orderno", orderno);
                sqlPara[1] = new SqlParameter("@materialCode", materialCode);
                sqlPara[2] = new SqlParameter("@produce", produce);
                sqlPara[3] = new SqlParameter("@Status", Status);
                sqlPara[4] = new SqlParameter("@PullTimeStart", PullTimeStart);
                sqlPara[5] = new SqlParameter("@PullTimeEnd", PullTimeEnd);
                sqlPara[6] = new SqlParameter("@OTFlag", OTFlag);
                sqlPara[7] = new SqlParameter("@ActionTimeStart", ActionTimeStart);
                sqlPara[8] = new SqlParameter("@ActionTimeEnd", ActionTimeEnd);
                sqlPara[9] = new SqlParameter("@ActionUser", ActionUser);
                sqlPara[10] = new SqlParameter("@ConfirmTimeStart", ConfirmTimeStart);
                sqlPara[11] = new SqlParameter("@ConfirmTimeEnd", ConfirmTimeEnd);
                sqlPara[12] = new SqlParameter("@ConfirmUser", ConfirmUser);

                foreach (SqlParameter para in sqlPara)
                {
                    cmd.Parameters.Add(para);
                }
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);

                Datapter.Fill(dt);
                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                       
                        MaterialPullEntity itemList = new MaterialPullEntity();
                        itemList.ID = dt.Rows[i]["ID"].ToString();
                        itemList.Number = (i + 1).ToString();
                        itemList.WorkOrderNumber = dt.Rows[i]["WorkOrderNumber"].ToString();
                        itemList.WorkOrderVersion = dt.Rows[i]["WorkOrderVersion"].ToString();
                        itemList.Procedure_Name = dt.Rows[i]["Procedure_Name"].ToString();
                        itemList.ItemNumber = dt.Rows[i]["ItemNumber"].ToString();
                        itemList.ItemDsca = dt.Rows[i]["ItemDsca"].ToString();
                        itemList.Qty = dt.Rows[i]["Qty"].ToString();
                        itemList.PullTime = dt.Rows[i]["PullTime"].ToString();
                        itemList.Status = dt.Rows[i]["Status"].ToString();
                        itemList.ActionTime = dt.Rows[i]["ActionTime"].ToString();
                        itemList.ActionUser = dt.Rows[i]["ActionUser"].ToString();
                        itemList.ConfirmTime = dt.Rows[i]["ConfirmTime"].ToString();
                        itemList.ConfirmUser = dt.Rows[i]["ConfirmUser"].ToString();
                        itemList.OTFlag = dt.Rows[i]["OTFlag"].ToString();
                       
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        /// <summary>
        /// 能源统计
        /// </summary>
        /// <param name="dataEntity"></param>
        /// <returns></returns>
        public List<EnergyConsumpEntity> GetEnergyList(List<EnergyConsumpEntity> dataEntity)
        {
            DataTable dt = new DataTable();

            string selecttype = RequstString("selecttype");
            string selectdate = RequstString("selectdate");
            string selectdate1 = RequstString("selectdate1");

            //if(selecttype == "1")
            //{
            //    selectdate += "-01";
            //}
            if (selecttype == "2")
            {
               selectdate += "-01";
               selectdate1 += "-01";
            }

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_EnergyReport";
                SqlParameter[] sqlPara = new SqlParameter[3];
                sqlPara[0] = new SqlParameter("@selectdate", selectdate);
                sqlPara[1] = new SqlParameter("@selectdate1", selectdate1);
                sqlPara[2] = new SqlParameter("@selecttype", selecttype);

                foreach (SqlParameter para in sqlPara)
                {
                    cmd.Parameters.Add(para);
                }
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);

                Datapter.Fill(dt);
               
               
                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        EnergyConsumpEntity itemList = new EnergyConsumpEntity();
                        itemList.Number = (i + 1).ToString();
                        itemList.Date = dt.Rows[i]["TPoint1"].ToString();
                        itemList.CostValue = dt.Rows[i]["CostV"].ToString();
                        itemList.DisplayValue = dt.Rows[i]["DisplayValue"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        /// <summary>
        /// 每月出勤
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public UserAttendence GetAttendenceData(UserAttendence user)
        {
            string date = RequstString("DATE");
            string str = "";
            string selectstr = "";
            string selectlinestr = "";
            DataTable dt = new DataTable();
            DataTable selectdt = new DataTable();
            DataTable selectline = new DataTable();

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                str = "select day(dateadd(mm,1,'" + date + "-01')-day('" + date + "-01')) as daynum";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                selectstr = "select DATEPART(day,Date) as DATE,AttendenceNum,WorkHours,TotalAttendenceHours,ActiveWorkHours from UserM_AttendeceMan where convert(char(7),Date,120)='" + date.Trim() + "'";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = selectstr;
                SqlDataAdapter Datapter1 = new SqlDataAdapter(cmd);
                Datapter1.Fill(selectdt);

                selectlinestr = "select LineHeadCount,ShiftHours from  Mes_Line_List";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = selectlinestr;
                SqlDataAdapter Datapter2 = new SqlDataAdapter(cmd);
                Datapter.Fill(selectline);

                int totalperson = 0;
                int workhour = 0;
                for (int j = 0; j < selectline.Rows.Count; j++)
                {
                    totalperson += Convert.ToInt32(selectline.Rows[j]["LineHeadCount"].ToString());
                    workhour = Convert.ToInt32(selectline.Rows[j]["ShiftHours"].ToString());
                }

                if (dt != null && dt.Rows.Count > 0)
                {
                    dt.Columns.Add("DATE", typeof(System.String));
                    dt.Columns.Add("AttendenceNum", typeof(System.String));
                    dt.Columns.Add("WorkHours", typeof(System.String));
                    dt.Columns.Add("TotalAttendenceHours", typeof(System.String));
                    dt.Columns.Add("ActiveWorkHours", typeof(System.String));
                    if (Convert.ToInt32(dt.Rows[0]["daynum"]) > 0)
                    {
                        int daynum = Convert.ToInt16(dt.Rows[0]["daynum"].ToString());

                        for (int i = 1; i <= daynum; i++)
                        {
                            dt.Rows.Add(daynum, i.ToString(), totalperson.ToString(), workhour.ToString(), totalperson * workhour, "");
                        }
                        for (int j = 1; j < dt.Rows.Count; j++)
                        {
                            if (selectdt.Rows.Count > 0)
                            {
                                string filter = "convert(DATE,'System.String') ='" + dt.Rows[j]["DATE"] + "'";
                                int count = selectdt.Select(filter).Count();
                                if (count > 0)
                                {
                                    DataRow dr = selectdt.Select("DATE='" + dt.Rows[j]["DATE"].ToString() + "'")[0];
                                    dt.Rows[j]["AttendenceNum"] = dr["AttendenceNum"].ToString().Trim();
                                    dt.Rows[j]["WorkHours"] = dr["WorkHours"].ToString().Trim();
                                    dt.Rows[j]["TotalAttendenceHours"] = dr["TotalAttendenceHours"].ToString().Trim();
                                    dt.Rows[j]["ActiveWorkHours"] = dr["ActiveWorkHours"].ToString().Trim();
                                }
                            }
                        }
                    }
                }
                dt.Rows.RemoveAt(0);
                List<string> AttendenceNum = new List<string>();
                List<string> WorkHours = new List<string>();
                List<string> TotalAttendenceHours = new List<string>();
                List<string> ActiveWorkHours = new List<string>();

                AttendenceNum.Add("出勤人数");
                WorkHours.Add("当日工作时间");
                TotalAttendenceHours.Add("出勤时间");
                ActiveWorkHours.Add("有效生产时间");

                for (int j = 0; j < dt.Rows.Count; j++)
                {
                    AttendenceNum.Add(dt.Rows[j]["AttendenceNum"].ToString());
                    WorkHours.Add(dt.Rows[j]["WorkHours"].ToString());
                    TotalAttendenceHours.Add(dt.Rows[j]["TotalAttendenceHours"].ToString());
                    ActiveWorkHours.Add(dt.Rows[j]["ActiveWorkHours"].ToString());
                }


                user.AttendanceNum = AttendenceNum;
                user.WorkHours = WorkHours;
                user.TotalAttendenceHours = TotalAttendenceHours;
                user.ActiveWorkHours = ActiveWorkHours;
            }
            return user;
        }

        /// <summary>
        /// 设备保养总统计
        /// </summary>
        /// <param name="dataEntity"></param>
        /// <returns></returns>
        public List<EquManCountEntity> GetTotalMaintenceList(List<EquManCountEntity> dataEntity)
        {
            DataTable dt = new DataTable();

            string currentdate = RequstString("currentdate");
            string endDate = RequstString("endDate");
            
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_EquMaintenceTotalReport";
                SqlParameter[] sqlPara = new SqlParameter[2];
                sqlPara[0] = new SqlParameter("@currentdate", currentdate);
                sqlPara[1] = new SqlParameter("@endDate", endDate);
               
                foreach (SqlParameter para in sqlPara)
                {
                    cmd.Parameters.Add(para);
                }
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);

                Datapter.Fill(dt);


                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        EquManCountEntity itemList = new EquManCountEntity();
                        //itemList.Number = (i + 1).ToString();
                        itemList.DeviceName = dt.Rows[i]["DeviceName"].ToString();
                        itemList.FirstLevelCount = dt.Rows[i]["FirstLevelCount"].ToString();
                        itemList.SecondLevelCount = dt.Rows[i]["SecondLevelCount"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        /// <summary>
        /// 人员产能
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public PersonCapacityEntity GetPersonCapaticyData(PersonCapacityEntity user)
        {
            string date = RequstString("DATE");
            string str = "";
            string selectstr = "";
            DataTable dt = new DataTable();
            DataTable selectdt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                str = "select day(dateadd(mm,1,'" + date + "-01')-day('" + date + "-01')) as daynum";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);


                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Report_PersonCapaticy";
                SqlParameter[] sqlPara = new SqlParameter[1];
                sqlPara[0] = new SqlParameter("@date", date);
               
                foreach (SqlParameter para in sqlPara)
                {
                    cmd.Parameters.Add(para);
                }
                SqlDataAdapter Datapter1 = new SqlDataAdapter(cmd);

                Datapter1.Fill(selectdt);


                if (dt != null && dt.Rows.Count > 0)
                {
                    dt.Columns.Add("DateValue", typeof(System.String));
                    dt.Columns.Add("Yield", typeof(System.String));
                    dt.Columns.Add("PersonNum", typeof(System.String));
                    dt.Columns.Add("PerCapacity", typeof(System.String));
                    
                    if (Convert.ToInt32(dt.Rows[0]["daynum"]) > 0)
                    {
                        int daynum = Convert.ToInt16(dt.Rows[0]["daynum"].ToString());

                        for (int i = 1; i <= daynum; i++)
                        {
                            dt.Rows.Add(daynum, i.ToString(), "", "", "");
                        }
                        for (int j = 1; j < dt.Rows.Count; j++)
                        {
                            if (selectdt.Rows.Count > 0)
                            {
                                string filter = "convert(DateValue,'System.String') ='" + dt.Rows[j]["DateValue"] + "'";
                                int count = selectdt.Select(filter).Count();
                                if (count > 0)
                                {
                                    DataRow dr = selectdt.Select("DateValue='" + dt.Rows[j]["DateValue"].ToString() + "'")[0];
                                    dt.Rows[j]["Yield"] = dr["Yield"].ToString();
                                    dt.Rows[j]["PersonNum"] = dr["PersonNum"].ToString();
                                    dt.Rows[j]["PerCapacity"] = dr["PerCapacity"].ToString();
                                    
                                }
                            }
                        }
                    }
                    dt.Rows.RemoveAt(0);
                    List<string> Yield = new List<string>();
                    List<string> PersonNum = new List<string>();
                    List<string> PerCapacity = new List<string>();

                    Yield.Add("产量");
                    PersonNum.Add("人员数量");
                    PerCapacity.Add("人均产能");
                    
                    for (int j = 0; j < dt.Rows.Count; j++)
                    {
                        Yield.Add(dt.Rows[j]["Yield"].ToString());
                        PersonNum.Add(dt.Rows[j]["PersonNum"].ToString());
                        PerCapacity.Add(dt.Rows[j]["PerCapacity"].ToString());                      
                    }

                    user.Yield = Yield;
                    user.PersonNum = PersonNum;
                    user.PerCapacity = PerCapacity;             
                }
            }
            return user;
        }

        /// <summary>
        /// 年度产量对比
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public ProductionCompareEntity GetProductCompare(ProductionCompareEntity user)
        {
            string StartYear = RequstString("StartYear");
            string EndYear = RequstString("EndYear");

            DataTable dt = new DataTable();
           
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Report_ProductionCompare";
                SqlParameter[] sqlPara = new SqlParameter[2];
                sqlPara[0] = new SqlParameter("@date1", StartYear);
                sqlPara[1] = new SqlParameter("@date2", EndYear);
                foreach (SqlParameter para in sqlPara)
                {
                    cmd.Parameters.Add(para);
                }
                SqlDataAdapter Datapter1 = new SqlDataAdapter(cmd);

                Datapter1.Fill(dt);

                
                List<string> Yiled = new List<string>();
                List<string> YiledSecond = new List<string>();
                List<string> YiledCompare = new List<string>();

                int sumYiled = 0;
                int sumYiledSecond = 0;
                double sumYiledCompare = 0.0;

                Yiled.Add(StartYear);
                YiledSecond.Add(EndYear);
                YiledCompare.Add("同期产量对比");


                for (int j = 0; j < dt.Rows.Count; j++)
                {
                    Yiled.Add(dt.Rows[j]["Yiled"].ToString());
                    YiledSecond.Add(dt.Rows[j]["YiledSecond"].ToString());
                    YiledCompare.Add(dt.Rows[j]["YiledCompare"].ToString());
                    sumYiled += Convert.ToInt16(string.IsNullOrEmpty(dt.Rows[j]["Yiled"].ToString()) ? 0 : dt.Rows[j]["Yiled"]);
                    sumYiledSecond += Convert.ToInt16(string.IsNullOrEmpty(dt.Rows[j]["YiledSecond"].ToString()) ? 0 : dt.Rows[j]["YiledSecond"]);
                    sumYiledCompare += Convert.ToDouble(string.IsNullOrEmpty(dt.Rows[j]["YiledCompare"].ToString()) ? 0.0 : Convert.ToDouble(dt.Rows[j]["YiledCompare"].ToString().Substring(0, dt.Rows[j]["YiledCompare"].ToString().Length - 1)));
                }

                Yiled.Add(sumYiled.ToString());
                YiledSecond.Add(sumYiledSecond.ToString());
                YiledCompare.Add(sumYiledCompare.ToString() + '%');
               
                user.Yiled = Yiled;
                user.YiledSecond = YiledSecond;
                user.YiledCompare = YiledCompare;
            }
            return user;
        }

        /// <summary>
        /// 获取当月预算产量
        /// </summary>
        /// <param name="monthbudget"></param>
        /// <returns></returns>
        public MonthBudget GetMonthBudget(MonthBudget monthbudget)
        {
            DataTable dt = new DataTable();
            string ReturnValue = string.Empty;

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = "select BudgetProduction from Report_MonthBudget";
                if (monthbudget.CurrentMonth != "")
                {
                    str1 += "  WHERE CurrentMonth ='" + monthbudget.CurrentMonth + "' ";
                }

                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null && dt.Rows.Count > 0)
                {
                    monthbudget.BudgetedQty = dt.Rows[0]["BudgetProduction"].ToString();
                }
                return monthbudget;
            }
        }

        /// <summary>
        /// 新增当月预算产量
        /// </summary>
        /// <param name="dataEntity"></param>
        /// <param name="result"></param>
        /// <returns></returns>
        public ResultMsg_MonthBudget MonthBudgetMan(MonthBudget dataEntity, ResultMsg_MonthBudget result)
        {

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                SqlTransaction transaction = null;
                try
                {
                    conn.Open();
                    cmd.Connection = conn;
                    transaction = conn.BeginTransaction();
                    cmd.Transaction = transaction;
                    string strSql = string.Format(
                         @" INSERT INTO Report_MonthBudget  
                        (CurrentMonth,BudgetProduction, UpdateUser, UpdateTime) VALUES ( '{0}','{1}','{2}',getdate()) ",
                             dataEntity.CurrentMonth,
                             dataEntity.BudgetedQty,
                             UserName
                         );
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = strSql;
                    cmd.ExecuteNonQuery();
                    transaction.Commit();
                    result.result = "success";
                    result.msg = "保存数据成功!";
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    result.result = "failed";
                    result.msg = "保存失败! \n" + ex.Message;
                }
            }
            return result;
        }


        /// <summary>
        /// 编辑当月预算产量
        /// </summary>
        /// <param name="dataEntity"></param>
        /// <param name="result"></param>
        /// <returns></returns>
        public ResultMsg_MonthBudget MonthBudgetEdit(MonthBudget dataEntity, ResultMsg_MonthBudget result)
        {

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                SqlTransaction transaction = null;
                try
                {
                    conn.Open();
                    cmd.Connection = conn;
                    transaction = conn.BeginTransaction();
                    cmd.Transaction = transaction;
                    string strSql = string.Format(
                        @" UPDATE Report_MonthBudget SET 
                                                  BudgetProduction  = '{0}' 
                                                , UpdateUser   = '{1}'
                                                , UpdateTime   = getdate()
                                                  WHERE CurrentMonth = '{2}'
                                            ",
                                                    dataEntity.BudgetedQty,
                                                    UserName,
                                                    dataEntity.CurrentMonth
                         );
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = strSql;
                    cmd.ExecuteNonQuery();
                    transaction.Commit();
                    result.result = "success";
                    result.msg = "保存数据成功!";
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    result.result = "failed";
                    result.msg = "保存失败! \n" + ex.Message;
                }
            }
            return result;
        }

        /// <summary>
        /// 每日生产完成率
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public DailyCompletionRateEntity GetDailyCompletionRate(DailyCompletionRateEntity user)
        {
            string date = RequstString("YEAR");

            DataTable dt = new DataTable();
            DataTable selectdt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Report_DailyCompletionRate";
                SqlParameter[] sqlPara = new SqlParameter[1];
                sqlPara[0] = new SqlParameter("@date", date);
               
                foreach (SqlParameter para in sqlPara)
                {
                    cmd.Parameters.Add(para);
                }
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);

                Datapter.Fill(dt);

                List<string> DispatchNum = new List<string>();
                List<string> SAPPostNum = new List<string>();
                List<string> PostNum = new List<string>();
                List<string> OrderAccuracy = new List<string>();
                List<string> TimelyRate = new List<string>();
                List<string> AttendanceNum = new List<string>();
                List<string> WorkHour = new List<string>();
                List<string> AttendanceTime = new List<string>();
                List<string> EffectiveTime = new List<string>();
                List<string> EffectiveRate = new List<string>();
                List<string> MonthCompleteRate = new List<string>();
                int sumDispatchNum = 0;
                int sumSAPPostNum = 0;
                int sumPostNum = 0;
                int sumAttendanceNum =0;
                int sumWorkHour = 0;
                int sumAttendanceTime = 0;
                int sumEffectiveTime = 0;
                double sumEffectiveRate = 0.0;
                double sumOrderAccuracy = 0.0;
                double sumTimelyRate = 0.0;
   
                DispatchNum.Add("当日ERP派工数量");
                SAPPostNum.Add("当日ERP派工过账数量");
                PostNum.Add("当日过账数量");
                OrderAccuracy.Add("订单准确率");
                TimelyRate.Add("订单及时率");
                AttendanceNum.Add("出勤人数");
                WorkHour.Add("当日工作时间");
                AttendanceTime.Add("出勤时间");
                EffectiveTime.Add("有效生产时间");
                EffectiveRate.Add("有效生产时间效率");
                MonthCompleteRate.Add("月度完成率");

                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        DispatchNum.Add(dt.Rows[i]["DispatchNum"].ToString());
                        SAPPostNum.Add(dt.Rows[i]["SAPPostNum"].ToString());
                        PostNum.Add(dt.Rows[i]["PostNum"].ToString());
                        OrderAccuracy.Add(dt.Rows[i]["OrderAccuracy"].ToString());
                        TimelyRate.Add(dt.Rows[i]["TimelyRate"].ToString());
                        AttendanceNum.Add(dt.Rows[i]["AttendanceNum"].ToString());
                        WorkHour.Add(dt.Rows[i]["WorkHour"].ToString());
                        AttendanceTime.Add(dt.Rows[i]["AttendanceTime"].ToString());
                        EffectiveTime.Add(dt.Rows[i]["EffectiveTime"].ToString());
                        EffectiveRate.Add(dt.Rows[i]["EffectiveRate"].ToString());
                        MonthCompleteRate.Add(dt.Rows[i]["MonthCompleteRate"].ToString());

                        sumDispatchNum += Convert.ToInt16(string.IsNullOrEmpty(dt.Rows[i]["DispatchNum"].ToString()) ? 0 : dt.Rows[i]["DispatchNum"]);
                        sumSAPPostNum += Convert.ToInt16(string.IsNullOrEmpty(dt.Rows[i]["SAPPostNum"].ToString())? 0 : dt.Rows[i]["SAPPostNum"]);
                        sumPostNum += Convert.ToInt16(string.IsNullOrEmpty(dt.Rows[i]["PostNum"].ToString()) ? 0 : dt.Rows[i]["PostNum"]);
                        sumAttendanceNum += Convert.ToInt16(string.IsNullOrEmpty(dt.Rows[i]["AttendanceNum"].ToString()) ? 0 : dt.Rows[i]["AttendanceNum"]);
                        sumWorkHour += Convert.ToInt16(string.IsNullOrEmpty(dt.Rows[i]["WorkHour"].ToString()) ? 0 : dt.Rows[i]["WorkHour"]);
                        sumAttendanceTime += Convert.ToInt16(string.IsNullOrEmpty(dt.Rows[i]["AttendanceTime"].ToString()) ? 0 : dt.Rows[i]["AttendanceTime"]);
                        sumEffectiveTime += Convert.ToInt16(string.IsNullOrEmpty(dt.Rows[i]["EffectiveTime"].ToString()) ? 0 : dt.Rows[i]["EffectiveTime"]);
                        sumEffectiveRate += Convert.ToDouble(string.IsNullOrEmpty(dt.Rows[i]["EffectiveRate"].ToString()) ? 0 : dt.Rows[i]["EffectiveRate"]);
                        sumOrderAccuracy += Convert.ToDouble(string.IsNullOrEmpty(dt.Rows[i]["OrderAccuracy"].ToString()) ? 0.0 : Convert.ToDouble(dt.Rows[i]["OrderAccuracy"].ToString().Substring(0, dt.Rows[i]["OrderAccuracy"].ToString().Length - 1)));
                        sumTimelyRate += Convert.ToDouble(string.IsNullOrEmpty(dt.Rows[i]["TimelyRate"].ToString()) ? 0.0 : Convert.ToDouble(dt.Rows[i]["TimelyRate"].ToString().Substring(0, dt.Rows[i]["TimelyRate"].ToString().Length - 1)));

                    }
                }

                sumOrderAccuracy = Math.Round(sumOrderAccuracy / dt.Rows.Count, 2);
                sumTimelyRate = Math.Round(sumTimelyRate / dt.Rows.Count, 2); 

                DispatchNum.Add(sumDispatchNum.ToString());
                SAPPostNum.Add(sumSAPPostNum.ToString());
                PostNum.Add(sumPostNum.ToString());
                WorkHour.Add(sumWorkHour.ToString());
                AttendanceNum.Add(sumAttendanceNum.ToString());
                AttendanceTime.Add(sumAttendanceTime.ToString());
                EffectiveTime.Add(sumEffectiveTime.ToString());
                EffectiveRate.Add(sumEffectiveRate.ToString());
                OrderAccuracy.Add(sumOrderAccuracy.ToString() + '%');
                TimelyRate.Add(sumTimelyRate.ToString() + '%');

                user.DispatchNum = DispatchNum;
                user.SAPPostNum = SAPPostNum;
                user.PostNum = PostNum;
                user.OrderAccuracy = OrderAccuracy;
                user.TimelyRate = TimelyRate;
                user.AttendanceNum = AttendanceNum;
                user.WorkHour = WorkHour;
                user.AttendanceTime = AttendanceTime;
                user.EffectiveTime = EffectiveTime;
                user.EffectiveRate = EffectiveRate;
                user.MonthCompleteRate = MonthCompleteRate;
            }
            return user;
        }


        /// <summary>
        /// 月度生产完成率
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public MonthCompletionRateEntity GetMonthlyCompletionRate(MonthCompletionRateEntity user)
        {
            string date = RequstString("YEAR");

            DataTable dt = new DataTable();
            DataTable selectdt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Report_MonthCompletionRate";
                SqlParameter[] sqlPara = new SqlParameter[1];
                sqlPara[0] = new SqlParameter("@date", date);

                foreach (SqlParameter para in sqlPara)
                {
                    cmd.Parameters.Add(para);
                }
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);

                Datapter.Fill(dt);

                List<string> BudgetedQty = new List<string>();
                List<string> FinishQty = new List<string>();
                List<string> BudgetedCompletionRate = new List<string>();
                List<string> DesignYield = new List<string>();
                List<string> CapacityRate = new List<string>();
                List<string> ERPPlanYield = new List<string>();
                List<string> ERPCompleteRate = new List<string>();

                int sumBudgetedQty = 0;
                int sumFinishQty = 0;
                int sumDesignYield = 0;
                int sumERPPlanYield = 0;
                double sumBudgetedCompletionRate = 0.0;
                double sumCapacityRate = 0.0;
                double sumERPCompleteRate = 0.0;

                BudgetedQty.Add("预算产量");
                FinishQty.Add("完成产量");
                BudgetedCompletionRate.Add("预算完成率");
                DesignYield.Add("设计产能");
                CapacityRate.Add("产能发挥率");
                ERPPlanYield.Add("ERP计划产量");
                ERPCompleteRate.Add("ERP完成率");

                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        BudgetedQty.Add(dt.Rows[i]["BudgetedQty"].ToString());
                        FinishQty.Add(dt.Rows[i]["FinishQty"].ToString());
                        BudgetedCompletionRate.Add(dt.Rows[i]["BudgetedCompletionRate"].ToString());
                        DesignYield.Add(dt.Rows[i]["DesignYield"].ToString());
                        CapacityRate.Add(dt.Rows[i]["CapacityRate"].ToString());
                        ERPPlanYield.Add(dt.Rows[i]["ERPPlanYield"].ToString());
                        ERPCompleteRate.Add(dt.Rows[i]["ERPCompleteRate"].ToString());

                        sumBudgetedQty += Convert.ToInt16(string.IsNullOrEmpty(dt.Rows[i]["BudgetedQty"].ToString()) ? 0 : dt.Rows[i]["BudgetedQty"]);
                        sumFinishQty += Convert.ToInt16(string.IsNullOrEmpty(dt.Rows[i]["FinishQty"].ToString()) ? 0 : dt.Rows[i]["FinishQty"]);
                        sumDesignYield += Convert.ToInt16(string.IsNullOrEmpty(dt.Rows[i]["DesignYield"].ToString()) ? 0 : dt.Rows[i]["DesignYield"]);
                        sumERPPlanYield += Convert.ToInt16(string.IsNullOrEmpty(dt.Rows[i]["ERPPlanYield"].ToString()) ? 0 : dt.Rows[i]["ERPPlanYield"]);
                        sumBudgetedCompletionRate += Convert.ToDouble(string.IsNullOrEmpty(dt.Rows[i]["BudgetedCompletionRate"].ToString()) ? 0.0 : Convert.ToDouble( dt.Rows[i]["BudgetedCompletionRate"].ToString().Substring(0, dt.Rows[i]["BudgetedCompletionRate"].ToString().Length - 1)));
                        sumCapacityRate += Convert.ToDouble(string.IsNullOrEmpty(dt.Rows[i]["CapacityRate"].ToString()) ? 0.0 : Convert.ToDouble(dt.Rows[i]["CapacityRate"].ToString().Substring(0, dt.Rows[i]["CapacityRate"].ToString().Length - 1)));
                        sumERPCompleteRate += Convert.ToDouble(string.IsNullOrEmpty(dt.Rows[i]["ERPCompleteRate"].ToString()) ? 0.0 : Convert.ToDouble(dt.Rows[i]["ERPCompleteRate"].ToString().Substring(0, dt.Rows[i]["ERPCompleteRate"].ToString().Length - 1)));
                    }
                }
                sumBudgetedCompletionRate = Math.Round(sumBudgetedCompletionRate / dt.Rows.Count, 2);
                sumCapacityRate = Math.Round(sumCapacityRate / dt.Rows.Count, 2);
                sumERPCompleteRate = Math.Round(sumERPCompleteRate / dt.Rows.Count, 2); 

                BudgetedQty.Add(sumBudgetedQty == 0 ? "" : sumBudgetedQty.ToString());
                FinishQty.Add(sumFinishQty == 0 ? "" : sumFinishQty.ToString());
                BudgetedCompletionRate.Add(sumBudgetedCompletionRate == 0 ? "" : sumBudgetedCompletionRate.ToString() + '%');
                DesignYield.Add(sumDesignYield == 0 ? "" : sumDesignYield.ToString());
                CapacityRate.Add(sumCapacityRate == 0 ? "" : sumCapacityRate.ToString() + '%');
                ERPPlanYield.Add(sumERPPlanYield == 0 ? "" : sumERPPlanYield.ToString());
                ERPCompleteRate.Add(sumERPCompleteRate == 0 ? "" : sumERPCompleteRate.ToString() + '%');

                user.BudgetedQty = BudgetedQty;
                user.FinishQty = FinishQty;
                user.BudgetedCompletionRate = BudgetedCompletionRate;
                user.DesignYield = DesignYield;
                user.CapacityRate = CapacityRate;
                user.ERPPlanYield = ERPPlanYield;
                user.ERPCompleteRate = ERPCompleteRate;
            }
            return user;
        }

        /// <summary>
        /// 订单生产情况
        /// </summary>
        /// <param name="dataEntity"></param>
        /// <returns></returns>
        public List<ProductionStatisticEntity> GetOrderProductInfoList(List<ProductionStatisticEntity> dataEntity)
        {
            DataTable dt = new DataTable();
            string StartTime = RequstString("StartTime");
            string EndTime = RequstString("EndTime");
            StartTime += " 00:00:00";
            EndTime +=" 23:59:59";
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Report_OrderProductInfo";
                SqlParameter[] sqlPara = new SqlParameter[2];
                sqlPara[0] = new SqlParameter("@date1", StartTime);
                sqlPara[1] = new SqlParameter("@date2", EndTime);
                foreach (SqlParameter para in sqlPara)
                {
                    cmd.Parameters.Add(para);
                }

                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        ProductionStatisticEntity itemList = new ProductionStatisticEntity();
                        itemList.Number = (i + 1).ToString();
                        itemList.WorkOrderNumber = dt.Rows[i]["ErpWorkOrderNumber"].ToString();
                        itemList.WorkOrderVersion = dt.Rows[i]["MesWorkOrderVersion"].ToString();
                        itemList.StartTime = dt.Rows[i]["MesPlanStartTime"].ToString();
                        itemList.FinishTime = dt.Rows[i]["MesPlanFinishTime"].ToString();
                        itemList.ItemNumber = dt.Rows[i]["ErpGoodsCode"].ToString();
                        itemList.ItemDsca = dt.Rows[i]["ErpGoodsDsca"].ToString();
                        itemList.UOM = dt.Rows[i]["UOM"].ToString();
                        itemList.ErpPlanQty = dt.Rows[i]["MesPlanQty"].ToString();
                        itemList.MesFinishQty = dt.Rows[i]["Mes2ErpCfmQty"].ToString();
                        itemList.UnFinishQty = dt.Rows[i]["UnFinishNum"].ToString();
                        itemList.BackQty = dt.Rows[i]["BackQty"].ToString();
                        itemList.FinishRate = dt.Rows[i]["FinishRate"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        /// <summary>
        /// 设备报警情况(生产统计报表)
        /// </summary>
        /// <param name="dataEntity"></param>
        /// <returns></returns>
        public List<EquAlarmInfo> GetEquAlarmInfoList(List<EquAlarmInfo> dataEntity)
        {
            DataTable dt = new DataTable();
            string StartTime = RequstString("StartTime");
            string EndTime = RequstString("EndTime");
            StartTime += " 00:00:00";
            EndTime += " 23:59:59";
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Report_EquAlarmStatistic";
                SqlParameter[] sqlPara = new SqlParameter[2];
                sqlPara[0] = new SqlParameter("@date1", StartTime);
                sqlPara[1] = new SqlParameter("@date2", EndTime);
                foreach (SqlParameter para in sqlPara)
                {
                    cmd.Parameters.Add(para);
                }

                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        EquAlarmInfo itemList = new EquAlarmInfo();
                        itemList.ProcessName = dt.Rows[i]["ProcessName"].ToString();
                        itemList.DeviceName = dt.Rows[i]["DeviceName"].ToString();
                        itemList.AlarmItem = dt.Rows[i]["Info"].ToString();
                        itemList.AlarmTimes = dt.Rows[i]["AlarmTimes"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }


        /// <summary>
        /// 设备报警情况(生产统计报表)
        /// </summary>
        /// <param name="dataEntity"></param>
        /// <returns></returns>
        public List<MaterialPullInfo> GetMaterialPullInfoList(List<MaterialPullInfo> dataEntity)
        {
            DataTable dt = new DataTable();
            string StartTime = RequstString("StartTime");
            string EndTime = RequstString("EndTime");
            StartTime += " 00:00:00";
            EndTime += " 23:59:59";
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Report_MaterialPullStatistic";
                SqlParameter[] sqlPara = new SqlParameter[2];
                sqlPara[0] = new SqlParameter("@date1", StartTime);
                sqlPara[1] = new SqlParameter("@date2", EndTime);
                foreach (SqlParameter para in sqlPara)
                {
                    cmd.Parameters.Add(para);
                }

                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        MaterialPullInfo itemList = new MaterialPullInfo();
                        itemList.ProcessName = dt.Rows[i]["ProcessName"].ToString();
                        itemList.ItemName = dt.Rows[i]["ItemNumber"].ToString();
                        itemList.PullTimes = dt.Rows[i]["PullCount"].ToString();
                        itemList.OverTimes = dt.Rows[i]["OverTimes"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        /// <summary>
        /// 下线情况(生产统计报表)
        /// </summary>
        /// <param name="dataEntity"></param>
        /// <returns></returns>
        public List<AbnormalInfo> GetAbnormalInfoList(List<AbnormalInfo> dataEntity)
        {
            DataTable dt = new DataTable();
            string StartTime = RequstString("StartTime");
            string EndTime = RequstString("EndTime");
            StartTime += " 00:00:00";
            EndTime += " 23:59:59";
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Report_AbnormalInfoStatistic";
                SqlParameter[] sqlPara = new SqlParameter[2];
                sqlPara[0] = new SqlParameter("@date1", StartTime);
                sqlPara[1] = new SqlParameter("@date2", EndTime);
                foreach (SqlParameter para in sqlPara)
                {
                    cmd.Parameters.Add(para);
                }

                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        AbnormalInfo itemList = new AbnormalInfo();
                        itemList.ProcessName = dt.Rows[i]["DisplayValue"].ToString();
                        itemList.RejectQty = dt.Rows[i]["BaoFeiNum"].ToString();
                        itemList.UnFinishQty = dt.Rows[i]["UnFinishNum"].ToString();
                        itemList.RepairQty = dt.Rows[i]["BuXiuQty"].ToString();
                        itemList.SumAbnormalQty = dt.Rows[i]["SumAbnormalQty"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }


        /// <summary>
        /// 一级保养点检表
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public FirstLevelMaintence GetFirstLevelMaintence(FirstLevelMaintence user)
        {
            string date = RequstString("YEAR");
            string processcode = RequstString("ProcessCode");
            string DeviceName = RequstString("DeviceName");

            DataTable dt = new DataTable();
            DataTable selectdt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Report_FirstLevelInspectionReport";
                SqlParameter[] sqlPara = new SqlParameter[3];
                sqlPara[0] = new SqlParameter("@date", date);
                sqlPara[1] = new SqlParameter("@processcode", processcode);
                sqlPara[2] = new SqlParameter("@devicename", DeviceName);

                foreach (SqlParameter para in sqlPara)
                {
                    cmd.Parameters.Add(para);
                }
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                List<string> InspectionStandrad1 = new List<string>();
                List<string> InspectionStandrad2 = new List<string>();
                List<string> InspectionStandrad3 = new List<string>();
                List<string> InspectionStandrad4 = new List<string>();
                List<string> InspectionStandrad5 = new List<string>();
                List<string> InspectionStandrad6 = new List<string>();
                List<string> InspectionStandrad7 = new List<string>();
                InspectionStandrad1.Add("1");
                InspectionStandrad2.Add("2");
                InspectionStandrad3.Add("3");
                InspectionStandrad4.Add("4");
                InspectionStandrad5.Add("5");
                InspectionStandrad6.Add("6");
                InspectionStandrad7.Add("7");

                InspectionStandrad1.Add("设备操作机构灵活可靠");
                InspectionStandrad2.Add("配合间隙传动正常");
                InspectionStandrad3.Add("工装夹具安装及使用良好");
                InspectionStandrad4.Add("安全装置、照明设施良好");
                InspectionStandrad5.Add("润滑系统清洁畅通、润滑良好");
                InspectionStandrad6.Add("电器装置绝缘良好安全可靠");
                InspectionStandrad7.Add("电器箱内外清洁无灰尘");

                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        InspectionStandrad1.Add(dt.Rows[i]["InspectionStandrad1"].ToString());
                        InspectionStandrad2.Add(dt.Rows[i]["InspectionStandrad2"].ToString());
                        InspectionStandrad3.Add(dt.Rows[i]["InspectionStandrad3"].ToString());
                        InspectionStandrad4.Add(dt.Rows[i]["InspectionStandrad4"].ToString());
                        InspectionStandrad5.Add(dt.Rows[i]["InspectionStandrad5"].ToString());
                        InspectionStandrad6.Add(dt.Rows[i]["InspectionStandrad6"].ToString());
                        InspectionStandrad7.Add(dt.Rows[i]["InspectionStandrad7"].ToString());
                       
                    }
                }
                user.InspectionStandrad1 = InspectionStandrad1;
                user.InspectionStandrad2 = InspectionStandrad2;
                user.InspectionStandrad3 = InspectionStandrad3;
                user.InspectionStandrad4 = InspectionStandrad4;
                user.InspectionStandrad5 = InspectionStandrad5;
                user.InspectionStandrad6 = InspectionStandrad6;
                user.InspectionStandrad7 = InspectionStandrad7;
            }
            return user;
        }

        /// <summary>
        /// 一级保养点检问题记录表
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public List<FirstLevelMaintenceProblem> GetFirstLevelMaintenceProblem(List<FirstLevelMaintenceProblem> user)
        {
            string date = RequstString("YEAR");
            string DeviceName = RequstString("DeviceName");
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = string.Empty;
                str1 = "select InspectionProblem,FORMAT(InspectionDate,'yyyy-MM-dd') as InspectionDate,FindProblem,RepairProblem,ReaminProblem from Equ_FirstLevelInspectionProblem where FORMAT(InspectionDate,'yyyy-MM')='" + date + "' and DeviceCode='" + DeviceName.Trim() + "' and InspectionProblem!='' or FindProblem!='0' or RepairProblem!='0' or ReaminProblem!='0'";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                
                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        FirstLevelMaintenceProblem problem = new 
                            FirstLevelMaintenceProblem();
                        problem.ProblemID = (i + 1).ToString();
                        problem.InspectionDate = dt.Rows[i]["InspectionDate"].ToString();
                        problem.InspectionProblem = dt.Rows[i]["InspectionProblem"].ToString();
                        problem.FindProblem = dt.Rows[i]["FindProblem"].ToString();
                        problem.RepairProblem = dt.Rows[i]["RepairProblem"].ToString();
                        problem.ReaminProblem = dt.Rows[i]["ReaminProblem"].ToString();
                        user.Add(problem);
                    }
                }
                
            }
            return user;
        }

        /// <summary>
        /// 二级点检设备明细表
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public List<SecondLevelMaintence> GetSecondLevelMaintence(List<SecondLevelMaintence> user)
        {
            string StartTime = RequstString("StartTime");
            string EndTime = RequstString("EndTime");
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = string.Empty;
                str1 = "select FORMAT(a.UpdateTime,'yyyy-MM-dd') as PmDate,b.DeviceCode,a.DeviceName,'' as DeviceKind,c.PowerLine,c.GroundLead,c.MaintenceTime,c.InspectionProblem,a.PmOper,'' as ConfirmPerson from Equ_PmRecordList  a left join Equ_DeviceInfoList b on a.ProcessCode=b.ProcessCode and a.DeviceName=b.DeviceName left join Equ_SecondLevelInspectionProblem c on c.PmRecordID=a.ID where FORMAT(a.UpdateTime,'yyyy-MM-dd') between '" + StartTime.Trim() + "' and '" + EndTime.Trim() + "' and PmLevel='二级保养'  order by a.UpdateTime,b.DeviceCode";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        SecondLevelMaintence problem = new
                            SecondLevelMaintence();
                        problem.PmDate = dt.Rows[i]["PmDate"].ToString();
                        problem.DeviceCode = dt.Rows[i]["DeviceCode"].ToString();
                        problem.DeviceName = dt.Rows[i]["DeviceName"].ToString();
                        problem.DeviceKind = dt.Rows[i]["DeviceKind"].ToString();
                        problem.PowerLine = dt.Rows[i]["PowerLine"].ToString();
                        problem.GroundLead = dt.Rows[i]["GroundLead"].ToString();
                        problem.MaintenceTime = dt.Rows[i]["MaintenceTime"].ToString();
                        problem.InspectionProblem = dt.Rows[i]["InspectionProblem"].ToString();
                        problem.PmOper = dt.Rows[i]["PmOper"].ToString();
                        problem.ConfirmPerson = dt.Rows[i]["ConfirmPerson"].ToString();
                        user.Add(problem);
                    }
                }

            }
            return user;
        }

        /// <summary>
        /// 二级点检内容明细
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public List<SecondLevelMaintenceContent> GetSecondLevelMaintenceContent(List<SecondLevelMaintenceContent> user)
        {
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = string.Empty;
                str1 = "select CONVERT(varchar(10),ID)+'、'+InspectionContent as MaintenceContent from Equ_SecondLevelTestContent ";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        SecondLevelMaintenceContent problem = new
                            SecondLevelMaintenceContent();
                        problem.MaintenceContent = dt.Rows[i]["MaintenceContent"].ToString();
                        problem.IsActive = "1";
                        user.Add(problem);
                    }
                }

            }
            return user;
        }

        /// <summary>
        /// 二级点检更换配件
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public List<SecondLevelMaintenceReplace> GetSecondLevelMaintenceReplace(List<SecondLevelMaintenceReplace> user)
        {
            string StartTime = RequstString("StartTime");
            string EndTime = RequstString("EndTime");
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = string.Empty;
                str1 = "select FORMAT(InspectionDate,'yyyy-MM-dd') as PmDate,a.DeviceCode,b.DeviceName,a.ReplacePart,a.ReplaceName,a.ReplaceCount from Equ_SecondLevelInspectionProblem a left join Equ_DeviceInfoList b on a.DeviceCode=b.DeviceCode where FORMAT(InspectionDate,'yyyy-MM-dd')  between '" + StartTime.Trim() + "' and '" + EndTime.Trim() + "' and PmRecordID is not null order by InspectionDate,a.DeviceCode";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        SecondLevelMaintenceReplace problem = new
                            SecondLevelMaintenceReplace();
                        problem.PmDate = dt.Rows[i]["PmDate"].ToString();
                        problem.DeviceCode = dt.Rows[i]["DeviceCode"].ToString();
                        problem.DeviceName = dt.Rows[i]["DeviceName"].ToString();
                        problem.ReplacePart = dt.Rows[i]["ReplacePart"].ToString();
                        problem.ReplaceName = dt.Rows[i]["ReplaceName"].ToString();
                        problem.ReplaceCount = dt.Rows[i]["ReplaceCount"].ToString();
                        user.Add(problem);
                    }
                }

            }
            return user;
        }

        /// <summary>
        /// 节拍统计报表
        /// </summary>
        /// <param name="user"></param>
        /// <returns></returns>
        public List<ProcessBeat> GetProcessBeat(List<ProcessBeat> user)
        {
            string date = RequstString("SelectDate");
            string processcode = RequstString("ProcessCode");
            string DeviceName = RequstString("DeviceName");

            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_ReportProcessBeat";
                SqlParameter[] sqlPara = new SqlParameter[3];
                sqlPara[0] = new SqlParameter("@SelectDate", date);
                sqlPara[1] = new SqlParameter("@ProcessCode", processcode);
                sqlPara[2] = new SqlParameter("@DeviceName", DeviceName);
                foreach (SqlParameter para in sqlPara)
                {
                    cmd.Parameters.Add(para);
                }
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        ProcessBeat pro = new ProcessBeat();
                        pro.Date = dt.Rows[i]["datevalue"].ToString();
                        pro.Process = dt.Rows[i]["ProcessName"].ToString();
                        pro.DeviceName = dt.Rows[i]["DeviceName"].ToString();
                        pro.BeatMin = dt.Rows[i]["BeatMin"].ToString();
                        pro.BeatMax = dt.Rows[i]["BeatMax"].ToString();
                        pro.BeatPer = dt.Rows[i]["BeatPer"].ToString();
                        pro.Number = dt.Rows[i]["ProcessBeat"].ToString();
                        user.Add(pro);
                    }
                }
            }
            return user;
        }


        /// <summary>
        /// 产品直通率报表
        /// </summary>
        /// <param name="dataEntity"></param>
        /// <returns></returns>
        public List<ProductThroughRateEntity> GetProductThroughInfoList(List<ProductThroughRateEntity> dataEntity)
        {
            DataTable dt = new DataTable();
            string StartTime = RequstString("StartTime");
            string EndTime = RequstString("EndTime");
            StartTime += " 00:00:00";
            EndTime += " 23:59:59";
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Report_ProductThroughRate";
                SqlParameter[] sqlPara = new SqlParameter[2];
                sqlPara[0] = new SqlParameter("@StartTime", StartTime);
                sqlPara[1] = new SqlParameter("@EndTime", EndTime);
                foreach (SqlParameter para in sqlPara)
                {
                    cmd.Parameters.Add(para);
                }

                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null)
                {
                    for (int k = 0; k < dt.Rows.Count ; k=k+4)
                    {
                       
                        string result1 = string.IsNullOrEmpty(dt.Rows[k]["PassRateValue"].ToString()) ? "" : dt.Rows[k]["PassRateValue"].ToString();
                        string result2 = string.IsNullOrEmpty(dt.Rows[k]["PassRateValue"].ToString()) ? "" : dt.Rows[k+1]["PassRateValue"].ToString();
                        string result3 = string.IsNullOrEmpty(dt.Rows[k]["PassRateValue"].ToString()) ? "" : dt.Rows[k+2]["PassRateValue"].ToString();
                        string result4 = string.IsNullOrEmpty(dt.Rows[k]["PassRateValue"].ToString()) ? "" : dt.Rows[k+3]["PassRateValue"].ToString();
                        if (string.IsNullOrEmpty(result1) || string.IsNullOrEmpty(result2) || string.IsNullOrEmpty(result3)||string.IsNullOrEmpty(result4))
                        {
                            dt.Rows[k]["DailyThroughRate"] = DBNull.Value;
                            dt.Rows[k + 1]["DailyThroughRate"] = DBNull.Value;
                            dt.Rows[k + 2]["DailyThroughRate"] = DBNull.Value;
                            dt.Rows[k + 3]["DailyThroughRate"] = DBNull.Value;
                        }
                        else
                        {
                            dt.Rows[k]["DailyThroughRate"] =(Convert.ToDouble(result1) * Convert.ToDouble(result2) * Convert.ToDouble(result3) * Convert.ToDouble(result4));
                            dt.Rows[k+1]["DailyThroughRate"] = (Convert.ToDouble(result1) * Convert.ToDouble(result2) * Convert.ToDouble(result3) * Convert.ToDouble(result4));
                            dt.Rows[k+2]["DailyThroughRate"] = (Convert.ToDouble(result1) * Convert.ToDouble(result2) * Convert.ToDouble(result3) * Convert.ToDouble(result4));
                            dt.Rows[k+3]["DailyThroughRate"] = (Convert.ToDouble(result1) * Convert.ToDouble(result2) * Convert.ToDouble(result3) * Convert.ToDouble(result4));
                        }
                        if (k == dt.Rows.Count - 4)
                        {
                            break;
                        }
                    }

                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        ProductThroughRateEntity itemList = new ProductThroughRateEntity();
                        itemList.Date = dt.Rows[i]["TPoint1"].ToString();
                        itemList.ProcessName = dt.Rows[i]["ProcessName"].ToString();
                        itemList.ProcessQty = dt.Rows[i]["totalcount"].ToString();
                        itemList.ScrapQty = dt.Rows[i]["BaoFeiNum"].ToString();
                        itemList.UnFinishQty = dt.Rows[i]["UnFinishNum"].ToString();
                        itemList.RepairQty = dt.Rows[i]["BuXiuQty"].ToString();
                        itemList.PassRate = dt.Rows[i]["PassRate"].ToString();
                        if (string.IsNullOrEmpty(dt.Rows[i]["DailyThroughRate"].ToString()) )
                        {
                            itemList.DailyThroughRate = "";
                        }
                        else
                        {
                            itemList.DailyThroughRate = Convert.ToDecimal(dt.Rows[i]["DailyThroughRate"].ToString()).ToString("p2"); 
                        }
                       
                        dataEntity.Add(itemList);
                    }

                }
            }
            return dataEntity;
        }
    }
}