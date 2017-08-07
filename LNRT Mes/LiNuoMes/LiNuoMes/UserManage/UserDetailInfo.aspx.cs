using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using clsSql;
namespace LiNuoMes.UserManage
{
    public partial class UserDetailInfo : System.Web.UI.Page
    {
        static clsSql.Sql mySql = new Sql();
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string SaveUserInfo(string UserID, string UserName, string Password, string RoleID, string CreateTime,string ProcessCode, string Description)
        {

            //if (mySql.FoundRec("select * from UserM_UserInfo where UserID='" + UserID.Trim() + "'"))
            //{
            //    return "hasexict";
            //}
          
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
                    SqlParameter[] sqlPara = new SqlParameter[8];
                    sqlPara[0] = new SqlParameter("@UserID", UserID);
                    sqlPara[0].Direction = System.Data.ParameterDirection.Input;
                    sqlPara[1] = new SqlParameter("@UserName", UserName);
                    sqlPara[1].Direction = System.Data.ParameterDirection.Input;
                    sqlPara[2] = new SqlParameter("@Password", Password);
                    sqlPara[2].Direction = System.Data.ParameterDirection.Input;
                    sqlPara[3] = new SqlParameter("@RoleID", RoleID==null?"":RoleID);
                    sqlPara[3].Direction = System.Data.ParameterDirection.Input;
                    sqlPara[4] = new SqlParameter("@CreateTime", CreateTime);
                    sqlPara[4].Direction = System.Data.ParameterDirection.Input;
                    sqlPara[5] = new SqlParameter("@ProcessCode", ProcessCode);
                    sqlPara[5].Direction = System.Data.ParameterDirection.Input;
                    sqlPara[6] = new SqlParameter("@Description", Description);
                    sqlPara[6].Direction = System.Data.ParameterDirection.Input;
                    sqlPara[7] = new SqlParameter("@CatchFlag", 0);
                    sqlPara[7].Size = 10;
                    sqlPara[7].Direction = System.Data.ParameterDirection.Output;

                    foreach (SqlParameter para in sqlPara)
                    {
                        cmd.Parameters.Add(para);
                    }

                    cmd.CommandText = "[usp_UserM_AddUserInfo]";
                    cmd.ExecuteNonQuery();
                    transaction.Commit();
                    if (int.Parse(sqlPara[7].Value.ToString()) == 1)
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