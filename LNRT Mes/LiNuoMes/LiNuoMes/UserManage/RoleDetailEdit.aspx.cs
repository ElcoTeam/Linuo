using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LiNuoMes.UserManage
{
    public partial class RoleDetailEdit : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string SaveRoleInfo(string RoleID,string RoleName, string Description, List<string> arr)
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
                    string limitno = string.Join(",", arr.ToArray());

                    sqlPara[0] = new SqlParameter("@RoleID", RoleID);
                    sqlPara[0].Direction = System.Data.ParameterDirection.Input;
                    sqlPara[1] = new SqlParameter("@RoleName", RoleName);
                    sqlPara[1].Direction = System.Data.ParameterDirection.Input;
                    sqlPara[2] = new SqlParameter("@Description", Description);
                    sqlPara[2].Direction = System.Data.ParameterDirection.Input;
                    sqlPara[3] = new SqlParameter("@Limitno ", limitno);
                    sqlPara[3].Size = -1;
                    sqlPara[3].Direction = System.Data.ParameterDirection.Input;
                    sqlPara[4] = new SqlParameter("@CatchFlag", 0);
                    sqlPara[4].Size = 10;
                    sqlPara[4].Direction = System.Data.ParameterDirection.Output;

                    foreach (SqlParameter para in sqlPara)
                    {
                        cmd.Parameters.Add(para);
                    }
                    cmd.CommandText = "[usp_UserM_AddRoleInfo]";
                    cmd.ExecuteNonQuery();
                    transaction.Commit();
                    if (int.Parse(sqlPara[4].Value.ToString()) == 1)
                    {
                        return "hasexit";
                    }
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