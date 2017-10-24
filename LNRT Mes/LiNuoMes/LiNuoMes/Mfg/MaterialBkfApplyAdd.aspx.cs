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


namespace LiNuoMes.Mfg
{
    public partial class MaterialBkfApplyAdd : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        public class Material
        {
            public string ItemNumber { get; set; }
            public string ItemDsca { get; set; }
            public string UOM { get; set; } 
            public string IsActive { get; set; }

        }

        [WebMethod]
        public static List<Material> GetMaterialList()
        {
            DataTable tb = new DataTable();
            List<Material> list = new List<Material>();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = "select ItemNumber,ItemDsca,UOM from MFG_WIP_BKF_Item_List order by ItemNumber";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(tb);
                tb.Columns.Add("IsActive", typeof(string));
                if (tb.Rows.Count > 0)
                {
                    for (int i = 0; i < tb.Rows.Count; i++)
                    {
                        tb.Rows[i]["IsActive"] = 0;
                    }
                    ReturnValue = DataTableJson(tb);
                    list = JsonToList<Material>(ReturnValue);
                    return list;
                }
                return list;
            }
        }


        [WebMethod]
        public static string SaveApply(string ApplyUser, List<string> arr)
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
                    SqlParameter[] sqlPara = new SqlParameter[3];
                    for (int i = 0; i < arr.Count; i++)
                    {
                        if (i == 0)
                        {
                            sqlPara[0] = new SqlParameter("@ApplyUser", ApplyUser);
                            sqlPara[0].Direction = System.Data.ParameterDirection.Input;

                            sqlPara[1] = new SqlParameter("@ItemNumber", arr[i].Split(new string[] { "|" }, StringSplitOptions.None)[0]);
                            sqlPara[1].Direction = System.Data.ParameterDirection.Input;

                            sqlPara[2] = new SqlParameter("@ApplyQty", arr[i].Split(new string[] { "|" }, StringSplitOptions.None)[1]);
                            sqlPara[2].Direction = System.Data.ParameterDirection.Input;
                            foreach (SqlParameter para in sqlPara)
                            {
                                cmd.Parameters.Add(para);
                            }
                        }
                        else
                        {
                            cmd.Parameters[1].Value = arr[i].Split(new string[] { "|" }, StringSplitOptions.None)[0];
                            cmd.Parameters[2].Value = arr[i].Split(new string[] { "|" }, StringSplitOptions.None)[1];
                        }
                        cmd.CommandText = "[usp_Mfg_Wip_Bkf_Apply_Add]";
                        cmd.ExecuteNonQuery();

                    }
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