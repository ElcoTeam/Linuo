using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace LiNuoMes.LineMonitor.hs
{
    /// <summary>
    /// GetMaterialpullforline 的摘要说明
    /// </summary>
    public class GetMaterialpullforline : IHttpHandler
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
            string orderno = RequstString("Orderno");
            string materialCode = RequstString("MaterialCode");
            string produce = RequstString("Produce");
            //string station = RequstString("Station");
            DataTable dt = new DataTable();
            dt = GetUserData(orderno, materialCode, produce);
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
                    strJson += "\"" + dt.Rows[j]["No"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["OrderNo"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["Procedure_Name"].ToString() + "\",";
                    //strJson += "\"" + dt.Rows[j]["Station_Name"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["MaterialCode"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["Pull_Qty"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["PullTime"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["ResponseTime"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["ConfirmTime"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["ResponseOP"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["ConfirmOP"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["PullState"].ToString() + "\"";
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


        /// <summary>
        /// 获取IQC出库数据集
        /// </summary>
        /// <returns></returns>
        public DataTable GetUserData(string orderno,string materialCode,string produce)
        {
            string str = "";
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                str = "select * from AIO_Materialpullforline where OrderNo like '%" + orderno.Trim() + "%' and MaterialCode like '%" + materialCode.Trim() + "%' and Procedure_Name like '%" + produce.Trim() + "%'";
                str += "order by OrderNo,PullState";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                return dt;
            }

        }
    }
}