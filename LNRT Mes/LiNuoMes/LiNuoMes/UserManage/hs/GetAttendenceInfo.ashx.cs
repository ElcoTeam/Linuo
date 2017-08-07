using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;


namespace LiNuoMes.UserManage.hs
{
    /// <summary>
    /// GetAttendenceInfo 的摘要说明
    /// </summary>
    public class GetAttendenceInfo : IHttpHandler
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
            string date = RequstString("DATE");
           
            DataTable dt = new DataTable();
            dt = GetAttendenceData(date);
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
                    strJson += "\"" + dt.Rows[j]["DATE"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["AttendenceNum"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["WorkHours"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["TotalAttendenceHours"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["ActiveWorkHours"].ToString() + "\"";
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

        public DataTable GetAttendenceData(string date)
        {
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

                selectstr = "select DATEPART(day,Date) as DATE,AttendenceNum,WorkHours,TotalAttendenceHours,ActiveWorkHours from UserM_AttendeceMan where convert(char(7),Date,120)='"+date.Trim()+"'";

                cmd.CommandType = CommandType.Text;
                cmd.CommandText = selectstr;
                SqlDataAdapter Datapter1 = new SqlDataAdapter(cmd);
                Datapter.Fill(selectdt);

                if (dt != null && dt.Rows.Count > 0 )
                {
                    dt.Columns.Add("DATE", typeof(System.String));
                    dt.Columns.Add("AttendenceNum", typeof(System.String));
                    dt.Columns.Add("WorkHours", typeof(System.String));
                    dt.Columns.Add("TotalAttendenceHours", typeof(System.String));
                    dt.Columns.Add("ActiveWorkHours", typeof(System.String));
                    if (Convert.ToInt32(dt.Rows[0]["daynum"]) > 0)
                    {
                        int daynum=Convert.ToInt16( dt.Rows[0]["daynum"].ToString());

                        for (int i = 1; i <= daynum; i++)
                        {                           
                            dt.Rows.Add(daynum,i.ToString(), "", "", "", "");
                        }
                        for (int j = 1; j < dt.Rows.Count; j++)
                        {
                            if(selectdt.Rows.Count>0)
                            {
                                string filter = "convert(DATE,'System.String') ='" + dt.Rows[j]["DATE"] + "'";
                                int count = selectdt.Select(filter).Count();
                                if(count>0)
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
                return dt;
            }
        }
    }
}