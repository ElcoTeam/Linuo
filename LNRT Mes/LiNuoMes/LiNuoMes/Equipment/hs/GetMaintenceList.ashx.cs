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
    /// GetMaintenceList 的摘要说明
    /// </summary>
    public class GetMaintenceList : IHttpHandler
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
            string processName = RequstString("DeviceCode");

            DataTable dt = new DataTable();
            dt = GetUserData(processName);
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
                    strJson += "\"" + dt.Rows[j]["PmDate"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["DeviceCode"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["DeviceName"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["MaintenceTime"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["InspectionProblem"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["PowerLine"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["GroundLead"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["ReplacePart"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["ReplaceName"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["ReplaceCount"].ToString().Trim() + "\"";
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

        public DataTable GetUserData(string processName)
        {
            string str = "";
            DataTable dt = new DataTable();
            string[] deviceList = processName.Split(',');
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;

                if (deviceList.Count() > 1)
                {
                    str = "select  a.InspectionDate as PmDate ,a.DeviceCode,b.DeviceName,a.MaintenceTime,a.InspectionProblem,a.PowerLine,a.GroundLead,a.ReplacePart,a.ReplaceName,a.ReplaceCount from Equ_SecondLevelInspectionProblem a left join Equ_DeviceInfoList b on a.DeviceCode = b.DeviceCode where a.DeviceCode='" + deviceList[0] + "' and FORMAT(a.InspectionDate,'yyyy-MM-dd')=FORMAT(getdate(),'yyyy-MM-dd') and and a.PmRecordID is null";
                    for (int i = 1; i < deviceList.Count(); i++)
                    {
                        str = str + " union all select  a.InspectionDate as PmDate,a.DeviceCode,b.DeviceName,a.MaintenceTime,a.InspectionProblem,a.PowerLine,a.GroundLead,a.ReplacePart,a.ReplaceName,a.ReplaceCount from Equ_SecondLevelInspectionProblem a left join Equ_DeviceInfoList b on a.DeviceCode = b.DeviceCode where a.DeviceCode='" + deviceList[i] + "' and and a.PmRecordID is null";
                    }
                }
                else
                {
                    str = "select  a.InspectionDate as PmDate,a.DeviceCode,b.DeviceName,a.MaintenceTime,a.InspectionProblem,a.PowerLine,a.GroundLead,a.ReplacePart,a.ReplaceName,a.ReplaceCount from Equ_SecondLevelInspectionProblem a left join Equ_DeviceInfoList b on a.DeviceCode = b.DeviceCode where a.DeviceCode='" + deviceList[0] + "' and FORMAT(a.InspectionDate,'yyyy-MM-dd')=FORMAT(getdate(),'yyyy-MM-dd') and and a.PmRecordID is null";
                }

                str += "order by a.InspectionDate,a.DeviceCode";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                return dt;
            }
        }
    }
}