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
    public class GetReportInfo : IHttpHandler
    {
        JavaScriptSerializer jsc = new JavaScriptSerializer();
        string Action = "";

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            Action = RequstString("Action");

            if (Action.Length == 0) Action = "";

            //设备报警报表
            if (Action == "EquAlarmReport")
            {
                List<EquAlarmEntity> equAlarm= new List<EquAlarmEntity>();
                equAlarm = GetEquAlarmList(equAlarm);
                context.Response.Write(jsc.Serialize(equAlarm));
            }

            //关键设备OEE
            if (Action == "KeyEquOEEReport")
            {
                List<KeyEquOEEEntity> equOEE = new List<KeyEquOEEEntity>();
                //equOEE = GetEquAlarmList(equOEE);
                //context.Response.Write(jsc.Serialize(equOEE));
            }

            //设备生产工艺
            if (Action == "ProductArtReport")
            {
                List<ProductArtEntity> productArt = new List<ProductArtEntity>();
                //equOEE = GetEquAlarmList(equOEE);
                //context.Response.Write(jsc.Serialize(equOEE));
            }

            //物料拉动
            if (Action == "MaterialPullReport")
            {
                List<MaterialPullEntity> materialPull = new List<MaterialPullEntity>();
                materialPull = GetMaterialPullList(materialPull);
                context.Response.Write(jsc.Serialize(materialPull));
            }

            //能耗统计
            if (Action == "EnergyConsumpReport")
            {
                List<EnergyConsumpEntity> energyConsump = new List<EnergyConsumpEntity>();
                energyConsump = GetEnergyList(energyConsump);
                context.Response.Write(jsc.Serialize(energyConsump));
            }

            //能耗统计
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

            //设备保养总统计表
            if (Action == "GetEquTotalReport")
            {
                List<EquManCountEntity> equmancount = new List<EquManCountEntity>();
                equmancount = GetTotalMaintenceList(equmancount);
                context.Response.Write(jsc.Serialize(equmancount));

            }

            //每日出勤统计
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
                    //strJson += "\"" + dt.Rows[j]["KindName"].ToString().Trim() + "\",";
                    //strJson += "\"" + dt.Rows[j]["DeviceCode"].ToString().Trim() + "\",";
                    //strJson += "\"" + dt.Rows[j]["CheckItem"].ToString().Trim() + "\",";
                    //strJson += "\"" + dt.Rows[j]["ItemSpec"].ToString().Trim() + "\",";
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

            //每月出勤人数报表
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

            //人员产能
            if (Action == "PersonCapacityReport")
            {
                PersonCapacityEntity personCapacity = new PersonCapacityEntity();
                personCapacity = GetPersonCapaticyData(personCapacity);
                context.Response.Write(jsc.Serialize(personCapacity));
            }

            //每日生产完成率
            if (Action == "DailyCompletionRateReport")
            {
                List<DailyCompletionRateEntity> dailyCompletionRate = new List<DailyCompletionRateEntity>();
                //materialPull = GetMaterialPullList(materialPull);
                //context.Response.Write(jsc.Serialize(materialPull));
            }

            //月度生产完成率
            if (Action == "MonthCompletionRateReport")
            {
                List<MonthCompletionRateEntity> monthCompletionRate = new List<MonthCompletionRateEntity>();
                //materialPull = GetMaterialPullList(materialPull);
                //context.Response.Write(jsc.Serialize(materialPull));
            }

            //产品直通率
            if (Action == "ProductThroughRateReport")
            {
                List<ProductThroughRateEntity> productThroughRate = new List<ProductThroughRateEntity>();
                //materialPull = GetMaterialPullList(materialPull);
                //context.Response.Write(jsc.Serialize(materialPull));
            }

            //年度产量对比
            if (Action == "ProductionCompareReport")
            {
                List<ProductionCompareEntity> productCompare = new List<ProductionCompareEntity>();
                //materialPull = GetMaterialPullList(materialPull);
                //context.Response.Write(jsc.Serialize(materialPull));
            }

            //生产溯源
            if (Action == "ProductionCompareReport")
            {
                List<ProductionSourceEntity> productionSource = new List<ProductionSourceEntity>();
                //materialPull = GetMaterialPullList(materialPull);
                //context.Response.Write(jsc.Serialize(materialPull));
            }

            //订单生产情况
            if (Action == "OrderProductInfo")
            {
                List<ProductionStatisticEntity> productionStatistic = new List<ProductionStatisticEntity>();
                //materialPull = GetMaterialPullList(materialPull);
                //context.Response.Write(jsc.Serialize(materialPull));
            }

            //下线情况
            if (Action == "AbnormalInfo")
            {
                List<AbnormalInfo> abnormal = new List<AbnormalInfo>();
                //materialPull = GetMaterialPullList(materialPull);
                //context.Response.Write(jsc.Serialize(materialPull));
            }

            //设备报警情况
            if (Action == "EquAlarmInfo")
            {
                List<EquAlarmInfo> equAlarm = new List<EquAlarmInfo>();
                //materialPull = GetMaterialPullList(materialPull);
                //context.Response.Write(jsc.Serialize(materialPull));
            }

            //物料拉动情况
            if (Action == "MaterialPullInfo")
            {
                List<MaterialPullInfo> materialPull = new List<MaterialPullInfo>();
                //materialPull = GetMaterialPullList(materialPull);
                //context.Response.Write(jsc.Serialize(materialPull));
            }

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
            string DealWithOper = RequstString("DealWithOper");

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
                sqlPara[7] = new SqlParameter("@DealWithOper", DealWithOper);
                
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
                cmd.CommandText = "usp_Report_EquAlarm";
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
            //else if (selecttype == "2")
            //{
            //    selectdate += "-01-01";
            //}

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

                selectstr = "select DATEPART(day,Date) as DATE,AttendenceNum,WorkHours,TotalAttendenceHours,ActiveWorkHours from UserM_AttendeceMan where convert(char(7),Date,120)='" + date.Trim() + "'";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = selectstr;
                SqlDataAdapter Datapter1 = new SqlDataAdapter(cmd);
                Datapter.Fill(selectdt);
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
                            dt.Rows.Add(daynum, i.ToString(), "", "", "", "");
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
                                    dt.Rows[j]["AttendenceNum"] = dr["AttendenceNum"].ToString();
                                    dt.Rows[j]["WorkHours"] = dr["WorkHours"].ToString();
                                    dt.Rows[j]["TotalAttendenceHours"] = dr["TotalAttendenceHours"].ToString();
                                    dt.Rows[j]["ActiveWorkHours"] = dr["ActiveWorkHours"].ToString();
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
                
            }
            return user;
        }
    }
}