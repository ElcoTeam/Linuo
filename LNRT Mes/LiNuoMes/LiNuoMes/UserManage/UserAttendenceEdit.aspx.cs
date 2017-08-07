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
    public partial class UserAttendenceEdit : System.Web.UI.Page
    {
        public class AttendenceInfo
        {
            public string Date { get; set; }
            public string AttendenceNum { get; set; }

            public string WorkHours { get; set; }
            public string ActiveWorkHours { get; set; }
            public string TotalAttendenceHours { get; set; }

        }
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static List<AttendenceInfo> GetAttendenceInfo(string DATE)
        {
            DataTable tb = new DataTable();
            List<AttendenceInfo> list = new List<AttendenceInfo>();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = string.Empty;
                str1 = "select * from UserM_AttendeceMan where Date='"+DATE.Trim()+"'";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(tb);
                if(tb.Rows.Count>0){
                    ReturnValue = DataTableJson(tb);
                    list = JsonToList<AttendenceInfo>(ReturnValue);
                    return list;
                }
                else
                {
                    return list;
                }
            }

        }


        [WebMethod]
        public static string SaveAttendenceInfo(string DATE,string  AttendanceNum,string WorkHours,string  TotalAttendenceHours,string  ActiveWorkHours)
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
                    sqlPara[0] = new SqlParameter("@DATE", DATE);
                    sqlPara[0].Direction = System.Data.ParameterDirection.Input;
                    sqlPara[1] = new SqlParameter("@AttendanceNum", AttendanceNum);
                    sqlPara[1].Direction = System.Data.ParameterDirection.Input;

                    sqlPara[2] = new SqlParameter("@WorkHours", WorkHours);
                    sqlPara[2].Direction = System.Data.ParameterDirection.Input;

                    sqlPara[3] = new SqlParameter("@TotalAttendenceHours", TotalAttendenceHours);
                    sqlPara[3].Direction = System.Data.ParameterDirection.Input;

                    sqlPara[4] = new SqlParameter("@ActiveWorkHours", ActiveWorkHours);
                    sqlPara[4].Direction = System.Data.ParameterDirection.Input;

                    foreach (SqlParameter para in sqlPara)
                    {
                        cmd.Parameters.Add(para);
                    }

                    cmd.CommandText = "[usp_UserM_EditAttendenceInfo]";
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