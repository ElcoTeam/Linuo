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
    public partial class MaterialPullConfirm : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string ConfirmPullInfo(string ID)
        {
            string ConfirmUser = HttpContext.Current.Session["UserName"].ToString().Trim();
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
                    SqlParameter[] sqlPara = new SqlParameter[2];
                    sqlPara[0] = new SqlParameter("@ID", ID);
                    sqlPara[1] = new SqlParameter("@ConfirmUser", ConfirmUser);

                    cmd.Parameters.Add(sqlPara[0]);
                    cmd.Parameters.Add(sqlPara[1]);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandText = "usp_Mfg_Material_Pull_Confirm";
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