using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Runtime.Serialization.Json;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using clsSql;

namespace LiNuoMes.Equipment
{
    public partial class EquSecondLevelMaintence : System.Web.UI.Page
    {
        static clsSql.Sql mySql = new Sql();
        public class SecondLevelMaintence
        {
            public string ProcessName { get; set; }
            public string PmPlanCode { get; set; }
            public string PmSpecCode { get; set; }
            public string DeviceName { get; set; }
            public string PmPlanName { get; set; }
            public string IsActive { get; set; }

        }

        protected void Page_Load(object sender, EventArgs e)
        {

        }


        [WebMethod]
        public static List<SecondLevelMaintence> GetSecondLevelList()
        {
            DataTable tb = new DataTable();
            List<SecondLevelMaintence> list = new List<SecondLevelMaintence>();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = "select  COUNT(distinct PmPlanCode) from Equ_PmRecordList where PmLevel='二级保养'";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                Datapter.Fill(dt);


                string str2 = "select  COUNT(distinct PmPlanCode) from Equ_PmPlanList where PmLevel='二级保养' and PmPlanCode not in (select PmPlanCode from Equ_PmRecordList where PmLevel='二级保养')";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str2;
                SqlDataAdapter Datapter3 = new SqlDataAdapter(cmd);
                DataTable dt1 = new DataTable();
                Datapter.Fill(dt1);
                if (dt != null && dt.Rows.Count > 0)
                {
                    if (Convert.ToInt32(dt1.Rows[0][0]) != 0)
                    {
                        string str3 = "select PmPlanCode,PmSpecCode,b.ProcessName,a.PmPlanName,a.DeviceName from Equ_PmPlanList a  left join Mes_Process_List b on a.ProcessCode=b.ProcessCode where a.PmLevel='二级保养'  and  CONVERT(varchar(100), GETDATE(), 23) between  DATEADD(DAY,-7, a.PmFirstDate) and  DATEADD(DAY,7, a.PmFirstDate) and PmPlanCode not in (select PmPlanCode from Equ_PmRecordList where PmLevel='二级保养')";
                        cmd.CommandType = CommandType.Text;
                        cmd.CommandText = str3;
                        SqlDataAdapter Datapter1 = new SqlDataAdapter(cmd);
                        Datapter1.Fill(tb); 
                    }
                    else
                    {
                        if (Convert.ToInt32(dt.Rows[0][0]) != 0)
                        {
                            string str4 = "select b.PmPlanCode,b.PmSpecCode,c.ProcessName,b.PmPlanName,a.DeviceName from Equ_PmRecordList a left join Equ_PmPlanList b on a.PmPlanCode=b.PmPlanCode left join Mes_Process_List c on a.ProcessCode=c.ProcessCode where a.PmLevel='二级保养' and  b.PmPlanCode not in (select PmPlanCode from Equ_PmRecordList where PmLevel='二级保养') and  CONVERT(varchar(100), GETDATE(), 23) between  DATEADD(DAY,-7, DATEADD(MONTH,b.PmCycleTime,(select top 1 a.PmPlanDate from Equ_PmRecordList a where PmLevel='二级保养' group by a.PmPlanCode,a.PmPlanDate order by PmPlanDate desc))) and DATEADD(DAY,7, DATEADD(MONTH,b.PmCycleTime,(select top 1 a.PmPlanDate from Equ_PmRecordList a where PmLevel='二级保养' group by a.PmPlanCode,a.PmPlanDate order by PmPlanDate desc))) ";

                            cmd.CommandType = CommandType.Text;
                            cmd.CommandText = str4;
                            SqlDataAdapter Datapter2 = new SqlDataAdapter(cmd);
                            Datapter2.Fill(tb);
                        }
                       
                    }
                }

                tb.Columns.Add("IsActive", typeof(string));
                if (tb.Rows.Count > 0)
                {
                    for (int i = 0; i < tb.Rows.Count; i++)
                    {
                        tb.Rows[i]["IsActive"] = 0;
                    }
                    ReturnValue = DataTableJson(tb);
                    list = JsonToList<SecondLevelMaintence>(ReturnValue);
                    return list;
                }
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