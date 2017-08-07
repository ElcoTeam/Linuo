using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;

namespace LiNuoMes.Login
{
    /// <summary>
    /// EditPassword 的摘要说明
    /// </summary>
    public class EditPassword : IHttpHandler
    {
        JavaScriptSerializer jsc = new JavaScriptSerializer();
        string Action = "";
      
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            Action = RequstString("Action");

            if (Action.Length == 0) Action = "";


            if (Action == "EditPsw")
            {
                UserInfo userinfo = new UserInfo();
                userinfo.UserID =  RequstString("UserID");
                userinfo.OldPassword = RequstString("OldPsw");
                userinfo.NewPassword = RequstString("NewPsw");
                ResultMsg_User result = new ResultMsg_User();
                result = EditPsw(userinfo, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "DownFlash")
            {
                FlashInfo flashInfo = new FlashInfo();
                flashInfo.FlashVersion = RequstString("CurrentAgent");

                DownLoadFlash(flashInfo, context.Response);
               
            }
        }

        public ResultMsg_User EditPsw(UserInfo dataEntity, ResultMsg_User result)
        {
            
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                SqlTransaction transaction = null;
                try
                {
                    conn.Open();
                    cmd.Connection = conn;
                    string strSql = " SELECT COUNT(1) AS SM FROM UserM_UserInfo WHERE UserID = '" + dataEntity.UserID.Trim() + "' and Password='"+dataEntity.OldPassword.Trim()+"'";
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = strSql;
                    SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    Datapter.Fill(dt);

                    if (dt != null && dt.Rows.Count > 0)
                    {  
                        result.result = "";
                        result.msg = "";
                    }
                    else
                    {
                        result.result = "failed";
                        result.msg = "原密码不正确!";
                    }

                    if (result.result == "")
                    {
                        transaction = conn.BeginTransaction();
                        cmd.Transaction = transaction;
                        strSql = "update UserM_UserInfo set Password='" + dataEntity.NewPassword + "' where UserID='"+dataEntity.UserID.Trim()+"'";
                        cmd.CommandType = CommandType.Text;
                        cmd.CommandText = strSql;
                        cmd.ExecuteNonQuery();
                        transaction.Commit();
                        result.result = "success";
                        result.msg = "修改密码成功!";
                        
                    }
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    result.result = "failed";
                    result.msg = "保存失败! \n" + ex.Message;
                }
            }
            return result;
        }


        public void DownLoadFlash(FlashInfo flashInfo,  System.Web.HttpResponse Response)
        {
            var basePath = VirtualPathUtility.AppendTrailingSlash(HttpContext.Current.Request.ApplicationPath);

            string fileURL ="";
            if (flashInfo.FlashVersion == "Chrome")
            {
                fileURL = HttpContext.Current.Server.MapPath((basePath + "Login/Temp/flashplayerPPAPI_25.0.0.127.exe"));//文件路径，可用相对路径
            }
            else
            {
                fileURL = HttpContext.Current.Server.MapPath((basePath + "Login/Temp/flashplayerNPAPI_26.0.0.131.exe"));//文件路径，可用相对路径
            }     
                
            try
            {
                FileInfo fileInfo = new FileInfo(fileURL);
                Response.Clear();
                Response.AddHeader("content-disposition", "attachment;filename=" + HttpContext.Current.Server.UrlEncode(fileInfo.Name.ToString()));//文件名
                Response.AddHeader("content-length", fileInfo.Length.ToString());//文件大小
                Response.ContentType = "application/octet-stream";
                Response.ContentEncoding = System.Text.Encoding.Default;
                Response.WriteFile(fileURL);

            }
            catch (Exception ex)
            {

                flashInfo.result = "failed";
                flashInfo.msg = "下载失败! \n" + ex.Message;
            }
            
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
        public static string RequstString(string sParam)
        {
            return (HttpContext.Current.Request[sParam] == null ? string.Empty
                  : HttpContext.Current.Request[sParam].ToString().Trim());
        }
    }

    public class UserInfo
    {
        
        public string UserID { set; get; }
     
        public string UserName { set; get; }
        public string OldPassword { set; get; }
        public string NewPassword { set; get; }
    }

    public class ResultMsg_User
    {
        public string result { set; get; }
        public string msg { set; get; }
        public UserInfo data { set; get; }
    }

    public class FlashInfo
    {
        public string FlashVersion { set; get; }
        public string result { set; get; }
        public string msg { set; get; }
    }
}