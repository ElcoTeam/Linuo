using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;

namespace LiNuoMes.Equipment.hs
{
    /// <summary>
    /// GetAlarmCRUD 的摘要说明
    /// </summary>
    public class GetAlarmCRUD :  IHttpHandler, IReadOnlySessionState
    {
        JavaScriptSerializer jsc = new JavaScriptSerializer();
        string Action = "";

        string UserName = "";

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            if (context.Session["UserName"] != null)
                UserName = context.Session["UserName"].ToString().ToUpper().Trim();
            else
                UserName = "";
            Action = RequstString("Action");

            if (Action.Length == 0) Action = "";

            if (Action == "EquAlarm_Detail")
            {
                Equ_AlarmInfo equinfo = new Equ_AlarmInfo();
                equinfo.ID = RequstString("EquID");
                Equ_AlarmInfo result = new Equ_AlarmInfo();
                result = GetEquAlarmDetailObj(equinfo, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "EquAlarm_Edit")
            {
                Equ_AlarmInfo dataEntity = new Equ_AlarmInfo();
                dataEntity.ID = RequstString("EquID");
                dataEntity.ProcessCode = RequstString("ProcessName");
                dataEntity.DeviceName = RequstString("DeviceName");
                dataEntity.AlarmItem = RequstString("AlarmItem");
                dataEntity.AlarmTime = RequstString("AlarmTime");
                dataEntity.DealWithResult = RequstString("DealWithResult");
                dataEntity.DealWithTime = RequstString("DealWithTime");
                dataEntity.DealWithOper = RequstString("DealWithOper");
                dataEntity.DealWithComment = RequstString("DealWithComment");
               
                ResultMsg_Equ_Alarm result = new ResultMsg_Equ_Alarm();
                result = editEquAlarmDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "EquAlarm_Handle")
            {
                Equ_AlarmInfo dataEntity = new Equ_AlarmInfo();
                dataEntity.ID = RequstString("EquID");
                //dataEntity.DealWithResult = "已处理";
                dataEntity.DealWithTime = RequstString("DealWithTime");
                dataEntity.DealWithOper = RequstString("DealWithOper");
                dataEntity.DealWithComment = RequstString("DealWithComment");

                ResultMsg_Equ_Alarm result = new ResultMsg_Equ_Alarm();
                result = handleEquAlarmDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }
        }

        public Equ_AlarmInfo GetEquAlarmDetailObj(Equ_AlarmInfo equinfo, Equ_AlarmInfo result)
        {

            DataTable dt = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = @"select 
                                a.ID,b.ProcessCode,DeviceName,d.Info  as AlarmItem,
                                CONVERT(varchar(100), AlarmTime, 120) as AlarmTime,
                                a.AlarmStatus as  DealWithResult,
                                CONVERT(varchar(16),DealWithTime, 120) as DealWithTime,
                                DealWithOper,DealWithComment 
                                from Mes_PLC_AlarmFiles a  
                                left join Equ_DeviceInfoList c on a.DeviceCode=c.DeviceCode  
                                left join Mes_Process_List b on c.ProcessCode=b.ProcessCode 
                                left join TagsInfo1 d on a.Tag=d.Tag ";
                if (equinfo.ID != "")
                {
                    str1 += " WHERE a.ID = " + equinfo.ID + " ";
                }
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null && dt.Rows.Count > 0)
                {
                    result.ID = dt.Rows[0]["ID"].ToString();
                    result.ProcessCode = dt.Rows[0]["ProcessCode"].ToString();
                    result.DeviceName = dt.Rows[0]["DeviceName"].ToString();
                    result.AlarmItem = dt.Rows[0]["AlarmItem"].ToString();
                    result.AlarmTime = dt.Rows[0]["AlarmTime"].ToString();
                    result.DealWithResult = dt.Rows[0]["DealWithResult"].ToString();
                    result.DealWithTime = dt.Rows[0]["DealWithTime"].ToString();
                    result.DealWithOper = dt.Rows[0]["DealWithOper"].ToString();
                    result.DealWithComment = dt.Rows[0]["DealWithComment"].ToString();
                }
            }
            return result;
        }

        public ResultMsg_Equ_Alarm editEquAlarmDataInDB(Equ_AlarmInfo dataEntity, ResultMsg_Equ_Alarm result)
        {
            if (dataEntity.ID.Length == 0) dataEntity.ID = "0";
            dataEntity.DealWithResult = "1";
            //if (dataEntity.ProcessCode.Length == 0) dataEntity.ProcessCode = "";
            //if (dataEntity.ProcessName.Length == 0) dataEntity.ProcessName = "";
            //if (dataEntity.ProcessBeat.Length == 0) dataEntity.ProcessBeat = "";
            //if (dataEntity.ProcessDsca.Length == 0) dataEntity.ProcessDsca = "";
            //if (dataEntity.InturnNumber.Length == 0) dataEntity.InturnNumber = "0";
            //if (dataEntity.ProcessManual.Length == 0) dataEntity.ProcessManual = "";
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                SqlTransaction transaction = null;
                try
                {
                    conn.Open();
                    cmd.Connection = conn;
                    string strSql = "";
                    transaction = conn.BeginTransaction();
                    cmd.Transaction = transaction;
                    strSql = string.Format(
                                            @" UPDATE Equ_DeviceAlarm SET 
                                              ProcessCode  = '{0}' 
                                            , DeviceName  = '{1}'
                                            , AlarmItem = '{2}'
                                            , AlarmTime= '{3}'
                                            , DealWithResult= '{4}'
                                            , DealWithTime= '{5}'
                                            , DealWithOper= '{6}'
                                            , DealWithComment= '{7}'
                                            , UpdateUser   = '{8}'
                                            , UpdateTime   = getdate()
                                            WHERE id = {9}
                                        ",
                                                dataEntity.ProcessCode,
                                                dataEntity.DeviceName,
                                                dataEntity.AlarmItem,
                                                dataEntity.AlarmTime,
                                                dataEntity.DealWithResult,
                                                dataEntity.DealWithTime,
                                                dataEntity.DealWithOper,
                                                dataEntity.DealWithComment,
                                                UserName,
                                                dataEntity.ID
                                );
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = strSql;
                    cmd.ExecuteNonQuery();
                    transaction.Commit();
                    result.result = "success";
                    result.msg = "保存数据成功!";

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

        public ResultMsg_Equ_Alarm handleEquAlarmDataInDB(Equ_AlarmInfo dataEntity, ResultMsg_Equ_Alarm result)
        {
            if (dataEntity.ID.Length == 0) dataEntity.ID = "0";
            //if (dataEntity.ProcessCode.Length == 0) dataEntity.ProcessCode = "";
            //if (dataEntity.ProcessName.Length == 0) dataEntity.ProcessName = "";
            //if (dataEntity.ProcessBeat.Length == 0) dataEntity.ProcessBeat = "";
            //if (dataEntity.ProcessDsca.Length == 0) dataEntity.ProcessDsca = "";
            //if (dataEntity.InturnNumber.Length == 0) dataEntity.InturnNumber = "0";
            //if (dataEntity.ProcessManual.Length == 0) dataEntity.ProcessManual = "";
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                SqlTransaction transaction = null;
                try
                {
                    conn.Open();
                    cmd.Connection = conn;
                    string strSql = "";
                    transaction = conn.BeginTransaction();
                    cmd.Transaction = transaction;
                    strSql = string.Format(
                                            @" UPDATE Mes_PLC_AlarmFiles SET 
                                              DealWithTime= '{0}'
                                            , DealWithOper= '{1}'
                                            , DealWithComment= '{2}'                                 
                                            WHERE id = {3}
                                        ",
                                                
                                                dataEntity.DealWithTime,
                                                dataEntity.DealWithOper,
                                                dataEntity.DealWithComment,
                                                dataEntity.ID
                                );
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = strSql;
                    cmd.ExecuteNonQuery();
                    transaction.Commit();
                    result.result = "success";
                    result.msg = "保存数据成功!";

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

    public class Equ_AlarmInfo
    {
        public string ID { get; set; }
        public string ProcessCode { set; get; }
        public string DeviceName { set; get; }
        public string AlarmItem { set; get; }
        public string AlarmTime { set; get; }
        public string DealWithResult { set; get; }
        public string DealWithTime { set; get; }
        public string DealWithOper { set; get; }
        public string DealWithComment { set; get; }
       
    }

    public class ResultMsg_Equ_Alarm
    {
        public string result { set; get; }
        public string msg { set; get; }
        public Equ_AlarmInfo data { set; get; }
    }
}