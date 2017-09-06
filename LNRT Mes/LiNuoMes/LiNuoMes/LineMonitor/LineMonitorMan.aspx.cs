using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LiNuoMes.LineMonitor
{
    public partial class LineMonitorMan : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
           
        }

        /// <summary>
        /// 取得所有工位
        /// </summary>
        /// <param name="deviceid"></param>
        /// <returns></returns>
        [WebMethod]
        public static string GetLineInfo()
        {
            DataTable tb = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = "select ProcessCode,ProcessName from Mes_Process_List where ParamName!=''";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(tb);
                ReturnValue = DataTableJson(tb);
                return ReturnValue;
            }
        }

        /// <summary>
        /// 当前订单
        /// </summary>
        /// <param name="lineno"></param>
        /// <returns></returns>
        [WebMethod]
        public static string SetLineInfo(string lineno)
        {
            DataTable tb = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_LineMonitor";
                SqlParameter[] sqlPara = new SqlParameter[1];
                sqlPara[0] = new SqlParameter("@devicecode", lineno);
                foreach (SqlParameter para in sqlPara)
                {
                    cmd.Parameters.Add(para);
                }

                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(tb);
                ReturnValue = DataTableJson(tb);
                return ReturnValue;
               
            }
        }

        /// <summary>
        /// 下一订单
        /// </summary>
        /// <param name="lineno"></param>
        /// <returns></returns>
        [WebMethod]
        public static string SetNextLineInfo(string lineno, string orderversion)
        {
            DataTable tb = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_LineNextMonitor";
                SqlParameter[] sqlPara = new SqlParameter[2];
                sqlPara[0] = new SqlParameter("@lineno", lineno);
                sqlPara[1] = new SqlParameter("@orderversion", orderversion);
                foreach (SqlParameter para in sqlPara)
                {
                    cmd.Parameters.Add(para);
                }

                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(tb);
                ReturnValue = DataTableJson(tb);
                return ReturnValue;
            }
        }
        /// <summary>       
        /// dataTable转换成Json格式       
        /// </summary>       
        /// <param name="dt"></param>       
        /// <returns></returns>       
        public static string DataTableJson(DataTable dt)
        {
            StringBuilder jsonBuilder = new StringBuilder();
            if (dt.Rows.Count > 0)
            {
                //jsonBuilder.Append("{");
                //jsonBuilder.Append(dt.TableName.ToString());\"\":
                jsonBuilder.Append("[");
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    jsonBuilder.Append("{");
                    for (int j = 0; j < dt.Columns.Count; j++)
                    {
                        jsonBuilder.Append("\"");
                        jsonBuilder.Append(dt.Columns[j].ColumnName);
                        jsonBuilder.Append("\":\"");
                        jsonBuilder.Append(dt.Rows[i][j].ToString().Trim());
                        jsonBuilder.Append("\",");
                    }
                    jsonBuilder.Remove(jsonBuilder.Length - 1, 1);
                    jsonBuilder.Append("},");
                }
                jsonBuilder.Remove(jsonBuilder.Length - 1, 1);
                jsonBuilder.Append("]");
                //jsonBuilder.Append("}");

            }

            return jsonBuilder.ToString();
        }  
    }
}