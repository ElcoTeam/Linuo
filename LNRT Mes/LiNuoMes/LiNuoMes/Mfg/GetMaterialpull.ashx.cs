using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace LiNuoMes.Mfg
{
    /// <summary>
    /// GetMaterialpill 的摘要说明
    /// </summary>
    public class GetMaterialpull : IHttpHandler
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

            DataTable dt = new DataTable();
            dt = GetUserData(orderno, materialCode, produce, Status, PullTimeStart, PullTimeEnd,
                        OTFlag, ActionTimeStart, ActionTimeEnd,
                        ActionUser, ConfirmTimeStart, ConfirmTimeEnd,
                        ConfirmUser);
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
                    strJson += "\"" + dt.Rows[j]["WorkOrderNumber"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["WorkOrderVersion"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["Procedure_Name"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["ItemNumber"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["ItemDsca"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["Qty"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["PullTime"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["Status"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["ActionTime"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["ActionUser"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["ConfirmTime"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["ConfirmUser"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["OTFlag"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["Status"].ToString() + "\"";
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

        public DataTable GetUserData(string orderno, string materialCode, string produce, string Status, string PullTimeStart, string PullTimeEnd, string
                        OTFlag, string ActionTimeStart, string ActionTimeEnd, string ActionUser, string ConfirmTimeStart, string ConfirmTimeEnd, string ConfirmUser)
        {

            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Mfg_MaterialPull";
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
                return dt;
            }

        }
    }
}