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
    /// GetEquMaintencePlan 的摘要说明
    /// </summary>
    public class GetEquMaintencePlan : IHttpHandler
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
            string pmSpecName = RequstString("PmSpecName");
            string pmPlanCode = RequstString("PmPlanCode");
            string pmPlanName = RequstString("PmPlanName");

            DataTable dt = new DataTable();
            dt = GetUserData(processName, deviceName, pmSpecName, pmPlanCode, pmPlanName);
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
                    strJson += "\"" + dt.Rows[j]["PmSpecCode"].ToString().Replace(@"\", @"\\") + "\",";
                    strJson += "\"" + dt.Rows[j]["ProcessName"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["DeviceName"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["PmSpecName"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["PmLevel"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["PmSpecFile"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["PmPlanCode"].ToString().Replace(@"\", @"\\") + "\",";
                    strJson += "\"" + dt.Rows[j]["PmPlanName"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["PmFirstDate"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["PmFinishDate"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["PmRecord"].ToString() + "\"";

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

        public DataTable GetUserData(string processName, string deviceName, string pmSpecName, string pmPlanCode,string pmPlanName)
        {
            string str = "";
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                str = "select a.ID,d.ID as PmSpecCode,c.ProcessName,a.DeviceName,d.PmSpecName,a.PmLevel,d.PmSpecFile,a.PmPlanCode,a.PmPlanName,FORMAT( a.PmFirstDate,'yyyy-MM-dd') as PmFirstDate,FORMAT(max(b.UpdateTime),'yyyy-MM-dd') as PmFinishDate,COUNT(b.PmDoTimes) as PmRecord from Equ_PmPlanList a left join Equ_PmRecordList b on a.ProcessCode=b.ProcessCode and a.DeviceName=b.DeviceName left join Mes_Process_List c on a.ProcessCode=c.ProcessCode left join Equ_PmSpecList d on a.PmSpecCode=d.PmSpecCode where a.DeviceName like '%" + deviceName.Trim() + "%' and a.PmPlanName like '%" + pmPlanName.Trim() + "%'";
                if (processName != "")
                {
                    str += " and a.ProcessCode='" + processName.Trim() + "'";
                }
                if (pmSpecName != "")
                {
                    str += " and d.PmSpecName='" + pmSpecName.Trim() + "'";
                }
                if (pmPlanCode != "")
                {
                    str += " and a.PmPlanCode='" + pmPlanCode.Trim() + "'";
                }
                str += " group by a.ID,d.ID,c.ProcessName,a.DeviceName,d.PmSpecName,a.PmLevel,d.PmSpecFile,a.PmPlanCode,a.PmPlanName,a.PmFirstDate ";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                return dt;
            }
        }
    }
}