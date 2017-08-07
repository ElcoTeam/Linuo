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
    /// GetUserInfo 的摘要说明
    /// </summary>
    public class GetUserInfo : IHttpHandler
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
            string userno = RequstString("Userno");
            string username = RequstString("Username");
            string rolename = RequstString("Rolename");
            //string station = RequstString("Station");
            DataTable dt = new DataTable();
            dt = GetUserData(userno,username,rolename);
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
                    strJson += "\"" + dt.Rows[j]["UserID"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["UserName"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["RoleName"].ToString() + "\"";
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

        public DataTable GetUserData(string userno,string username,string rolename)
        {
            string str = "";
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                str = "select a.ID,a.UserID,a.UserName,b.RoleName from UserM_UserInfo a left join UserM_RoleInfo b on a.RoleID=b.RoleID where a.UserID like '%" + userno.Trim() + "%' and a.UserName like '%" + username.Trim() + "%'";
                if(rolename!=""){
                    str += " and b.RoleID='" + rolename.Trim() + "'";
                }
                // str += "order by OrderNo,ResponseState";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                return dt;
            }
        }
    }
}