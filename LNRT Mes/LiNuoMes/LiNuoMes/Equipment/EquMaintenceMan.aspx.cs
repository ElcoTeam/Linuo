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

namespace LiNuoMes.Equipment
{
    public partial class EquMaintenceMan : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string DeleteMaintenceExtraMan(string EquID)
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
                    string str1 = "delete  from Equ_PmRecordList where ID='" + EquID.ToString().Trim() + "'";
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
        public static string GetSecondMaintenceInfo()
        {
            DataTable tb = new DataTable();
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
                    //if (Convert.ToInt32(dt.Rows[0][0]) != Convert.ToInt32(dt1.Rows[0][0]))
                    if (Convert.ToInt32(dt1.Rows[0][0])!=0)
                    {
                        string str3 = "select PmPlanCode,PmPlanName from Equ_PmPlanList where PmLevel='二级保养' and CONVERT(varchar(100), GETDATE(), 23) between  DATEADD(DAY,-PmPreAlarmDates, PmFirstDate) and  DATEADD(MONTH,PmCycleTime,PmFirstDate) and PmPlanCode not in (select PmPlanCode from Equ_PmRecordList where PmLevel='二级保养')";
                        cmd.CommandType = CommandType.Text;
                        cmd.CommandText = str3;
                        SqlDataAdapter Datapter1 = new SqlDataAdapter(cmd);
                        Datapter1.Fill(tb);
                        ReturnValue = DataTableJson(tb);
                        return ReturnValue;
                    }
                    else
                    {
                        string str4 = "select b.PmPlanCode from Equ_PmRecordList a left join Equ_PmPlanList b on a.PmPlanCode=b.PmPlanCode where a.PmLevel='二级保养' and  CONVERT(varchar(100), GETDATE(), 23) between  DATEADD(DAY,-b.PmPreAlarmDates, DATEADD(MONTH,b.PmCycleTime,(select top 1 a.PmPlanDate from Equ_PmRecordList a where PmLevel='二级保养' group by a.PmPlanCode,a.PmPlanDate order by PmPlanDate desc))) and  DATEADD(MONTH,b.PmCycleTime,(select top 1 a.PmPlanDate from Equ_PmRecordList a where PmLevel='二级保养' group by a.PmPlanCode,a.PmPlanDate order by PmPlanDate desc))";

                        cmd.CommandType = CommandType.Text;
                        cmd.CommandText = str4;
                        SqlDataAdapter Datapter2 = new SqlDataAdapter(cmd);
                        Datapter2.Fill(tb);
                        ReturnValue = DataTableJson(tb);
                        return ReturnValue;
                    }
                }
                else
                {
                    return "";
                }
            }
        }

        [WebMethod]
        public static string FirstLevelList()
        {
            DataTable tb = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = "select COUNT(1) from Equ_PmPlanList where PmLevel='一级保养'";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                Datapter.Fill(dt);
                ReturnValue = DataTableJson(tb);
                return ReturnValue;
               
            }
        }

        [WebMethod]
        public static string GetFirstMaintenceInfo()
        {
            DataTable tb = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = "select COUNT(1) as PmCount from Equ_PmPlanList where PmLevel='一级保养'";
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