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

namespace LiNuoMes.Equipment
{
    public partial class EquDeviceInfo : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string DeleteEquInfo(string EquID)
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
                    string str1 = "delete  from Equ_DeviceInfoList where ID='" + EquID.ToString().Trim() + "'";
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
        public static string GetProcessInfo()
        {
            DataTable tb = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = "select ProcessCode,ProcessName from Mes_Process_List";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(tb);
                ReturnValue = DataTableJson(tb);
                return ReturnValue;
            }
        }

        [WebMethod]
        public static string GetPmSpecName()
        {
            DataTable tb = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = "select PmSpecCode, PmSpecName from Equ_PmSpecList";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(tb);
                ReturnValue = DataTableJson(tb);
                return ReturnValue;
            }
        }

        [WebMethod]
        public static string GetDeviceName()
        {
            DataTable tb = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = "select DeviceCode,DeviceName from Equ_DeviceInfoList";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
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

            }

            return jsonBuilder.ToString();
        }  
    }
}