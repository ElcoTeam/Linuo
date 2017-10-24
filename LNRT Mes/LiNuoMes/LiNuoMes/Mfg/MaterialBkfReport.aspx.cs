using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LiNuoMes.Mfg
{
    public partial class MaterialBkfReport : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }


        [WebMethod]
        public static string UpdateExportBkf(List<string> arr)
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
                    string str1 = string.Empty;
                    for (int i = 0; i < arr.Count; i++)
                    {
                          str1 = "update  MFG_WIP_BKF_MTL_Record set Status='3',ConfirmTime=GETDATE(),ConfirmUser='" + HttpContext.Current.Session["UserName"].ToString().ToUpper().Trim() + "' where ID='" + arr[i].ToString().Trim() + "'";
                    }
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

    }
}