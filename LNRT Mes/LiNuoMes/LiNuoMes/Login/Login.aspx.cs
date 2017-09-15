using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LiNuoMes.Login
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            
        }

        [WebMethod]
        public static string CheckLogin(string UserID, string Password)
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
                    SqlParameter[] sqlPara = new SqlParameter[4];
                    sqlPara[0] = new SqlParameter("@UserID", UserID);
                    sqlPara[0].Direction = System.Data.ParameterDirection.Input;
                   
                    sqlPara[1] = new SqlParameter("@Password", Password);
                    sqlPara[1].Direction = System.Data.ParameterDirection.Input;
                    sqlPara[2] = new SqlParameter("@CatchFlag", 0);
                    sqlPara[2].Size = 10;
                    sqlPara[2].Direction = System.Data.ParameterDirection.Output;
                    sqlPara[3] = new SqlParameter("@ReturnName", "");
                    sqlPara[3].Size = 50;
                    sqlPara[3].Direction = System.Data.ParameterDirection.Output;

                    foreach (SqlParameter para in sqlPara)
                    {
                        cmd.Parameters.Add(para);
                    }

                    cmd.CommandText = "[usp_UserM_CheckLogin]";
                    cmd.ExecuteNonQuery();
                    transaction.Commit();
                    if (int.Parse(sqlPara[2].Value.ToString()) == 1)
                    {
                        return "nouser";
                    }
                    else if (int.Parse(sqlPara[2].Value.ToString()) == 2)
                    {
                        return "errorpsw";
                    }

                    HttpContext.Current.Session["UserID"] = UserID;
                    HttpContext.Current.Session["UserName"] = sqlPara[3].Value.ToString();
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
        public static string GetSession()
        {
            if (HttpContext.Current.Session["UserName"]!=null)
            {
                
                return HttpContext.Current.Session["UserName"].ToString();
            }
            else
            {
                return "";
            }
        }
    }
}