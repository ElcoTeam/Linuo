using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace LiNuoMes.Equipment.hs
{
    /// <summary>
    /// GetEquMaintenceMan 的摘要说明
    /// </summary>
    public class GetEquMaintenceMan : IHttpHandler
    {

        clsSql.Sql cSql = new clsSql.Sql();
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            context.Response.Write(GetDataJson());
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
            return (HttpContext.Current.Request[sParam] == null ? string.Empty
                : HttpContext.Current.Request[sParam].ToString().Trim());
        }
        public string GetDataJson()
        {
            string strJson = "";
            string processName = RequstString("ProcessName");
            string deviceName = RequstString("DeviceName");
            string PmType = RequstString("PmType");
            string PmLevel = RequstString("PmLevel");
            string Status = RequstString("Status");
            string PmSpecName= RequstString("PmSpecName");
            string PmPlanName= RequstString("PmPlanName");
            string PmStartDate= RequstString("PmStartDate");
            string PmFinishDate= RequstString("PmFinishDate");
            //string PmFinishDateStart= RequstString("PmFinishDateStart");
            //string PmFinishDateEnd = RequstString("PmFinishDateEnd");

            DataTable dt = new DataTable();
            dt = GetUserData(processName, deviceName, PmType, PmLevel, Status, PmSpecName, PmPlanName, PmStartDate, PmFinishDate);
            //int i = 0;
            if (dt != null)
            {
                string page = RequstString("page");
                //String page =Re .getParameter("page"); // 取得当前页数,注意这是jqgrid自身的参数 
                string rows = RequstString("rows");  // 取得每页显示行数，,注意这是jqgrid自身的参数 
                int totalRecord = dt.Rows.Count; // 总记录数(应根据数据库取得，在此只是模拟) 
                int totalPage = totalRecord % Convert.ToInt16(rows) == 0 ? totalRecord
                / Convert.ToInt16(rows) : totalRecord / Convert.ToInt16(rows)
                + 1; // 计算总页数 
                int index = (Convert.ToInt16(page) - 1) * Convert.ToInt16(rows); // 开始记录数 
                int pageSize = Convert.ToInt16(rows);
                strJson = "{\"page\":" + page + ",\"total\": " + totalPage + "  ,\"records\":" + dt.Rows.Count.ToString() + ",\"rows\":[";
                for (int j = index; j < pageSize + index && j < totalRecord; j++)
                {
                    strJson += "{";
                    strJson += "\"id\":\"" + (j + 1).ToString() + "\",";
                    strJson += "\"cell\":";
                    strJson += "[";
                    strJson += "\"" + dt.Rows[j]["ID"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["PmSpecCode"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["ProcessName"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["PmType"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["PmLevel"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["DeviceName"].ToString().Trim() + "\",";
                    //strJson += "\"" + dt.Rows[j]["PmSpecName"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["PmSpecFile"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["PmPlanName"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["PmPlanCount"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["PmStatus"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["PmPlanDate"].ToString().Trim() + "\",";
                    //strJson += "\"" + dt.Rows[j]["PmStartDate"].ToString().Trim() + "\",";
                    //strJson += "\"" + dt.Rows[j]["PmFinishDate"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["PmOper"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["UpdateTime"].ToString().Trim() + "\"";
                    strJson += "]";
                    strJson += "}";
                    if (j != pageSize + index - 1 && j != totalRecord - 1)
                    {
                        strJson += ",";
                    }
                }
            }
            else
            {
                strJson = "{\"page\":1,\"total\":0,\"records\":0,\"rows\":[";
            }
            strJson = strJson.Trim().TrimEnd(new char[] { ',' });
            strJson += "]}";
            return strJson;
        }
        
        public DataTable GetUserData(string processName,string deviceName,string  PmType,string  PmLevel,string  Status,string  PmSpecName,string  PmPlanName,string  PmStartDate,string  PmFinishDate)
        {
            #region    以前部分
            //string str = "";
            //string str1 = "";
            //string str2 = "";
            //string selectrecord = "";
            //DataTable dt = new DataTable();
            //using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            //{
            //    SqlCommand cmd = new SqlCommand();
            //    conn.Open();
            //    cmd.Connection = conn;
            //    selectrecord = "select count(1) as SM from Equ_PmRecordList where PmType!='计划外保养'";
            //    cmd.CommandType = CommandType.Text;
            //    cmd.CommandText = selectrecord;
            //    SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
            //    DataTable dt1 = new DataTable();
            //    Datapter.Fill(dt1);

            //    if (dt1 != null && dt1.Rows.Count > 0)
            //    {
            //        if (Convert.ToInt32(dt1.Rows[0]["SM"]) > 0)
            //        {
            //            str1 = "select a.ID,c.ProcessName,'计划内保养' as PmType,d.PmLevel,a.DeviceName,a.PmSpecName,d.PmSpecFile,a.PmPlanName,(select count(1)+1 from Equ_PmRecordList b where a.PmSpecName=b.PmSpecName and b.PmType!='计划外保养') PmPlanCount,'未完成' as PmStatus,convert(varchar(10),dateadd(day,a.PmCycleTime,(select max(b.PmFinishDate)  from Equ_PmRecordList b where a.PmSpecName=b.PmSpecName and b.PmType!='计划外保养')),120)  PmPlanDate,'' as PmStartDate,'' as PmFinishDate,'' as PmOper from Equ_PmPlanList a  left join Mes_Process_List c on a.ProcessCode=c.ProcessCode left join Equ_PmSpecList d on a.PmSpecName=d.PmSpecName where  a.DeviceName like '%" + deviceName.Trim() + "%' and  a.PmSpecName like '%" + PmSpecName.Trim() + "%' and a.PmPlanName like '%" + PmPlanName.Trim() + "%' and DATEADD(DAY,-a.PmPreAlarmDates,dateadd(day,a.PmCycleTime,(select max(b.PmFinishDate)  from Equ_PmRecordList b where a.PmSpecName=b.PmSpecName and b.PmType!='计划外保养')))<=GETDATE()";
            //        }
            //        else
            //        {
            //            str1 = "select a.ID,c.ProcessName,'计划内保养' as PmType,d.PmLevel,a.DeviceName,a.PmSpecName,d.PmSpecFile,a.PmPlanName,(select count(1)+1 from Equ_PmRecordList b where a.PmSpecName=b.PmSpecName and b.PmType!='计划外保养') PmPlanCount,'未完成' as PmStatus,convert(varchar(10),dateadd(day,a.PmCycleTime,a.PmFirstDate),120) as PmPlanDate,'' as PmStartDate,'' as PmFinishDate,'' as PmOper from Equ_PmPlanList a  left join Mes_Process_List c on a.ProcessCode=c.ProcessCode left join Equ_PmSpecList d on a.PmSpecName=d.PmSpecName where  a.DeviceName like '%" + deviceName.Trim() + "%' and  a.PmSpecName like '%" + PmSpecName.Trim() + "%' and a.PmPlanName like '%" + PmPlanName.Trim() + "%' and DATEADD(DAY,-a.PmPreAlarmDates,dateadd(day,a.PmCycleTime,a.PmFirstDate))<=GETDATE()";
            //        }
            //    }
               
            //    str2 = "select a.ID,c.ProcessName,a.PmType,d.PmLevel,a.DeviceName,a.PmSpecName,d.PmSpecFile,a.PmPlanName,a.PmDoTimes as PmPlanCount,'已完成' as PmStatus,FORMAT(a.PmPlanDate,'yyyy-MM-dd') as PmPlanDate,FORMAT(a.PmStartDate,'yyyy-MM-dd') as PmStartDate, FORMAT( a.PmFinishDate,'yyyy-MM-dd') as PmFinishDate,a.PmOper from Equ_PmRecordList a left join Equ_PmPlanList b on a.PmPlanName=b.PmPlanName left join Mes_Process_List c on a.ProcessCode=c.ProcessCode left join Equ_PmSpecList d on a.PmSpecName=d.PmSpecName where  a.DeviceName like '%" + deviceName.Trim() + "%' and  a.PmSpecName like '%" + PmSpecName.Trim() + "%' and a.PmPlanName like '%" + PmPlanName.Trim() + "%'";

            //    if (processName != "")
            //    {
            //        str1 += " and c.ProcessName='" + processName.Trim() + "'";
            //        str2 += " and c.ProcessName='" + processName.Trim() + "'";
            //    }
               
            //    if (PmLevel != "")
            //    {
            //        str1 += " and d.PmLevel='" + PmLevel.Trim() + "'";
            //        str2 += " and d.PmLevel='" + PmLevel.Trim() + "'";
            //    }
               
            //    //计划开始时间
            //    if (PmStartDate != "" || PmFinishDate != "")
            //    {
            //        str1 += " and dateadd(day,a.PmCycleTime,a.PmFirstDate) between '" + PmStartDate.Trim() + "' and '" + PmFinishDate.Trim() + "'";
            //        str2 += " and a.PmPlanDate between '" + PmStartDate.Trim() + "' and '" + PmFinishDate.Trim() + "'";
            //    }

            //    str = str1 + " union all " + str2;

            //    //实际完成时间
            //    if (PmFinishDateStart != "" || PmFinishDateEnd != "")
            //    {
            //        str2 += " and a.PmFinishDate between '" + PmFinishDateStart.Trim() + "' and '" + PmFinishDateEnd.Trim() + "'";
            //        str = str2;
            //    }
            //    if (PmType != "")
            //    {
            //        str2 += " and a.PmType='" + PmType.Trim() + "'";
            //        if (PmType=="计划外保养")
            //        {
            //            str = str2;
            //        }
            //    }
            //    str = str + "  order by PmType , PmPlanDate desc";
            //    cmd.CommandType = CommandType.Text;
            //    cmd.CommandText = str;
            //    SqlDataAdapter Datapter1 = new SqlDataAdapter(cmd);
            //    Datapter1.Fill(dt);
            //    return dt;
            //}
            #endregion

             DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_EquMaintenceRecordMan";
                SqlParameter[] sqlPara = new SqlParameter[9];
                sqlPara[0] = new SqlParameter("@processName", processName);
                sqlPara[1] = new SqlParameter("@deviceName", deviceName);
                sqlPara[2] = new SqlParameter("@PmType", PmType);
                sqlPara[3] = new SqlParameter("@PmLevel", PmLevel);
                sqlPara[4] = new SqlParameter("@Status", Status);
                sqlPara[5] = new SqlParameter("@PmSpecName", PmSpecName);
                sqlPara[6] = new SqlParameter("@PmPlanName", PmPlanName);
                sqlPara[7] = new SqlParameter("@PmStartDate", PmStartDate);
                sqlPara[8] = new SqlParameter("@PmFinishDate", PmFinishDate);
                //sqlPara[9] = new SqlParameter("@PmFinishDateStart", PmFinishDateStart);
                //sqlPara[10] = new SqlParameter("@PmFinishDateEnd", PmFinishDateEnd);
               
                foreach (SqlParameter para in sqlPara)
                {
                    cmd.Parameters.Add(para);
                }
                cmd.ExecuteNonQuery();
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
               
                Datapter.Fill(dt);
            }
            return dt;
        }
    }
}