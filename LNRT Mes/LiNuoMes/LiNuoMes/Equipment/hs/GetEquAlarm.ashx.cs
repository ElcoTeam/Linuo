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
    /// GetEquAlarm 的摘要说明
    /// </summary>
    public class GetEquAlarm : IHttpHandler
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
            string DealWithResult = RequstString("DealWithResult");
            string AlarmStartTime = RequstString("AlarmStartTime");
            string AlarmEndTime = RequstString("AlarmEndTime");
            string DealWithStartTime= RequstString("DealWithStartTime");
            string DealWithEndTime= RequstString("DealWithEndTime");
            string DealWithOper= RequstString("DealWithOper");

            if(DealWithResult=="未处理")
            {
                DealWithResult = "N";
            }
            else if(DealWithResult == "已处理")
            {
                DealWithResult = "R";
            }
            DataTable dt = new DataTable();
            dt = GetUserData(processName, deviceName, DealWithResult, AlarmStartTime, AlarmEndTime, DealWithStartTime,DealWithEndTime,DealWithOper);
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
                    strJson += "\"" + dt.Rows[j]["ProcessName"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["DeviceName"].ToString().Trim()+ "\",";
                    strJson += "\"" + dt.Rows[j]["AlarmTime"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["AlarmItem"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["DealWithResult"].ToString().Trim() + "\",";
                    strJson += "\"" + dt.Rows[j]["DealWithTime"].ToString().Trim()+ "\",";
                    strJson += "\"" + dt.Rows[j]["DealWithOper"].ToString().Trim() + "\"";
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

        public DataTable GetUserData(string processName, string deviceName,string DealWithResult, string AlarmStartTime,string AlarmEndTime,string DealWithStartTime,string DealWithEndTime,string DealWithOper)
        {
           
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_EquAlarm";
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
            }
            return dt;
        }
    }
}