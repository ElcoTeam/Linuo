using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Runtime.Serialization.Json;

namespace LiNuoMes.UserManage
{
    public partial class UserProcessCodeEdit : System.Web.UI.Page
    {
        public class UserInfo
        {
            public string ID { get; set; }
            public string UserID { get; set; }
            public string UserName { get; set; }

            public string RoleID { get; set; }
            public string ProcessCode { get; set; }
            public string Description { get; set; }
            
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            
        }

        [WebMethod]
        public static List<UserInfo> GetUserInfo(string UserID)
        {
            DataTable tb = new DataTable();
            List<UserInfo> list = new List<UserInfo>();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = string.Empty;
                str1 = "select a.ID,a.UserID,a.UserName,a.RoleID,a.Description,c.ProcessCode from UserM_UserInfo a left join UserM_RoleInfo b on a.RoleID=b.RoleID left join Mes_Process_List c on a.ProcessCode=c.ProcessCode where a.UserID='" + UserID.Trim() + "' ";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(tb);
                ReturnValue = DataTableJson(tb);
                list = JsonToList<UserInfo>(ReturnValue);
                return list;
              
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
                        jsonBuilder.Append(dt.Rows[i][j].ToString().Replace("\n"," ").Replace("\t"," ").Trim());
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

        [WebMethod]
        public static string SaveUserInfo(string UserID, string UserName, string Description, string ProcessCode, string UserOldID)
        {

           
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                SqlTransaction transaction = null;
                try
                {
                    conn.Open();
                    transaction = conn.BeginTransaction();
                    cmd.Transaction = transaction;
                    cmd.Connection = conn;
                    cmd.CommandType = System.Data.CommandType.StoredProcedure;
                    SqlParameter[] sqlPara = new SqlParameter[5];
                    sqlPara[0] = new SqlParameter("@UserID", UserID);
                    sqlPara[0].Direction = System.Data.ParameterDirection.Input;
                    sqlPara[1] = new SqlParameter("@UserName", UserName);
                    sqlPara[1].Direction = System.Data.ParameterDirection.Input;
                   
                   
                   
                    sqlPara[2] = new SqlParameter("@Description", Description);
                    sqlPara[2].Direction = System.Data.ParameterDirection.Input;

                    sqlPara[3] = new SqlParameter("@ProcessCode", ProcessCode);
                    sqlPara[3].Direction = System.Data.ParameterDirection.Input;
                    sqlPara[4] = new SqlParameter("@UserOldID", UserOldID);
                    sqlPara[4].Direction = System.Data.ParameterDirection.Input;

                    foreach (SqlParameter para in sqlPara)
                    {
                        cmd.Parameters.Add(para);
                    }

                    cmd.CommandText = "[usp_UserM_EditUserPCInfo]";
                    cmd.ExecuteNonQuery();
                    transaction.Commit();
                    return "success";
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    return "falut";
                }
            }
        }


        /// <summary>
        /// Json转换成实体类，返回对象
        /// </summary>
        /// <typeparam name="T">反序列化类型</typeparam>
        /// <param name="jsonString">反序列化字符串</param>
        /// <returns>反序列化后的值</returns>
        public static T JsonToModel<T>(string jsonString)
        {
            using (MemoryStream ms = new MemoryStream(Encoding.UTF8.GetBytes(jsonString)))
            {
                try
                {
                    DataContractJsonSerializer serializer = new DataContractJsonSerializer(typeof(T));
                    T returnOjbect = (T)serializer.ReadObject(ms);
                    return returnOjbect;
                }
                catch (Exception ex)
                {
                    throw ex;
                }
                finally
                {
                    ms.Close();
                    ms.Dispose();
                }
            }
        }

        /// <summary>
        /// Json转换成List集合，返回对象List
        /// </summary>
        /// <typeparam name="T">反序列化类型</typeparam>
        /// <param name="jsonString">反序列化字符串</param>
        /// <returns>反序列化后的值</returns>
        public static List<T> JsonToList<T>(string jsonString)
        {
            return JsonToModel<List<T>>(jsonString);
        }
    }
}