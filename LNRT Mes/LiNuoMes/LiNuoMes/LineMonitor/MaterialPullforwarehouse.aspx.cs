﻿using System;
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
    public partial class MaterialPullforwarehouse : System.Web.UI.Page
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
        public static string GetProduceInfo()
        {
            DataTable tb = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = "select * from AIO_Materialpullforwarehouse";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(tb);
                ReturnValue = DataTableJson(tb);
                return ReturnValue;
            }
        }

        [WebMethod]
        public static string DeletePullInfo(string no)
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
                    string str1 = "delete  from AIO_Materialpullforwarehouse where No='" + no.ToString().Trim() + "'";
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = str1;
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


        [WebMethod]
        public static string ConfirmPullInfo(string no)
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
                    string str1 = "update  from AIO_Materialpullforwarehouse set ResponseState='1' where No='" + no.ToString().Trim() + "'";
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = str1;
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
    }
}