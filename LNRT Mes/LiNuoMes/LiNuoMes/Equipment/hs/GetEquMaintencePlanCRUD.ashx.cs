using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;

namespace LiNuoMes.Equipment.hs
{
    /// <summary>
    /// GetEquMaintencePlanCRUD 的摘要说明
    /// </summary>
    public class GetEquMaintencePlanCRUD :  IHttpHandler, IReadOnlySessionState
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

            if (Action == "EquMaintencePlan_Detail")
            {
                Equ_PmPlanInfo equinfo = new Equ_PmPlanInfo();
                equinfo.ID = RequstString("EquID");
                Equ_PmPlanInfo result = new Equ_PmPlanInfo();
                result = GetEquDetailObj(equinfo, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "EquMaintencePlan_Add")
            {
                Equ_PmPlanInfo dataEntity = new Equ_PmPlanInfo();
                //dataEntity.ID = RequstString("ProcId");
                dataEntity.ProcessCode = RequstString("ProcessName");
                dataEntity.PmLevel = RequstString("PmLevel");
                dataEntity.DeviceName = RequstString("DeviceName");
                dataEntity.PmSpecName = RequstString("PmSpecName");
                dataEntity.PmPlanCode = RequstString("PmPlanCode");
                dataEntity.PmPlanName = RequstString("PmPlanName");
                dataEntity.PmFirstDate = RequstString("PmFirstDate");

                if (RequstString("PmCycleTime").Length != 0)
                {
                    dataEntity.PmCycleTime = Convert.ToInt16(RequstString("PmCycleTime"));
                }
                else
                {
                    dataEntity.PmCycleTime = 0;
                }

                if (RequstString("PmTimeUsage").Length != 0)
                {
                    dataEntity.PmTimeUsage = Convert.ToInt16(RequstString("PmTimeUsage"));
                }
                else
                {
                    dataEntity.PmTimeUsage = 0;
                }

                if (RequstString("PmContinueTimes").Length!=0)
                {
                    dataEntity.PmContinueTimes = Convert.ToInt16(RequstString("PmContinueTimes"));
                }
                else
                {
                    dataEntity.PmContinueTimes = 0;
                }


                if (RequstString("PmPreAlarmDates").Length != 0)
                {
                    dataEntity.PmPreAlarmDates = Convert.ToInt16(RequstString("PmPreAlarmDates"));
                }
                else
                {
                    dataEntity.PmPreAlarmDates = 0;
                }

                //dataEntity.PmPreAlarmDates =Convert.ToInt16( RequstString("PmPreAlarmDates"));
                dataEntity.PmPlanComment = RequstString("PmPlanComment");
                ResultMsg_Equ_PmPlan result = new ResultMsg_Equ_PmPlan();
                result = addEquMaintencePlanDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "EquMaintencePlan_Edit")
            {
                Equ_PmPlanInfo dataEntity = new Equ_PmPlanInfo();
                dataEntity.ID = RequstString("EquID");
                dataEntity.ProcessCode = RequstString("ProcessName");
                dataEntity.PmLevel = RequstString("PmLevel");
                dataEntity.DeviceName = RequstString("DeviceName");
                dataEntity.PmSpecName = RequstString("PmSpecName");
                dataEntity.PmPlanCode = RequstString("PmPlanCode");
                dataEntity.PmSpecName = RequstString("PmSpecName");
                dataEntity.PmFirstDate = RequstString("PmFirstDate");
                dataEntity.PmPlanName = RequstString("PmPlanName");
                if (RequstString("PmCycleTime").Length != 0)
                {
                    dataEntity.PmCycleTime = Convert.ToInt16(RequstString("PmCycleTime"));
                }
                else
                {
                    dataEntity.PmCycleTime = 0;
                }

                if (RequstString("PmTimeUsage").Length != 0)
                {
                    dataEntity.PmTimeUsage = Convert.ToInt16(RequstString("PmTimeUsage"));
                }
                else
                {
                    dataEntity.PmTimeUsage = 0;
                }

                if (RequstString("PmContinueTimes").Length != 0)
                {
                    dataEntity.PmContinueTimes = Convert.ToInt16(RequstString("PmContinueTimes"));
                }
                else
                {
                    dataEntity.PmContinueTimes = 0;
                }

                if (RequstString("PmPreAlarmDates").Length != 0)
                {
                    dataEntity.PmPreAlarmDates = Convert.ToInt16(RequstString("PmPreAlarmDates"));
                }
                else
                {
                    dataEntity.PmPreAlarmDates = 0;
                }
                dataEntity.PmPlanComment = RequstString("PmPlanComment");

                ResultMsg_Equ_PmPlan result = new ResultMsg_Equ_PmPlan();
                result = editEquMaintencePlanDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }
           
        }


        public ResultMsg_Equ_PmPlan addEquMaintencePlanDataInDB(Equ_PmPlanInfo dataEntity, ResultMsg_Equ_PmPlan result)
        {
            if (dataEntity.ProcessCode.Length == 0) dataEntity.ProcessCode = "";
            if (dataEntity.DeviceName.Length == 0) dataEntity.DeviceName = "";
            if (dataEntity.PmPlanCode.Length == 0) dataEntity.PmPlanCode = "";
            if (dataEntity.PmSpecName.Length == 0) dataEntity.PmSpecName = "";
            if (dataEntity.PmPlanName.Length == 0) dataEntity.PmPlanName = "";
            //if (dataEntity.PmCycleTime. == 0) dataEntity.PmCycleTime = "";
            //if (dataEntity.PmTimeUsage.Length == 0) dataEntity.PmTimeUsage = "";
            if (dataEntity.PmFirstDate.Length == 0) dataEntity.PmFirstDate = "";
           // if (dataEntity.PmContinueTimes.Length == 0) dataEntity.PmContinueTimes = "";
            //if (dataEntity.PmPreAlarmDates.Length == 0) dataEntity.PmPreAlarmDates = "";
            if (dataEntity.PmPlanComment.Length == 0) dataEntity.PmPlanComment = "";

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                SqlTransaction transaction = null;
                try
                {
                    conn.Open();
                    cmd.Connection = conn;
                    string strSql = " SELECT COUNT(1) AS SM FROM Equ_PmPlanList WHERE PmPlanCode = '" + dataEntity.PmPlanCode + "' OR PmPlanName= '"+dataEntity.PmPlanName+"' ";
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = strSql;
                    SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    Datapter.Fill(dt);

                    if (dt != null && dt.Rows.Count > 0)
                    {
                        if (Convert.ToInt32(dt.Rows[0]["SM"]) > 0)
                        {
                            result.result = "failed";
                            result.msg = "此保养计划编号,名称已经存在, 请核对!";
                        }
                        else
                        {
                            result.result = "";
                            result.msg = "";
                        }
                    }
                    else
                    {
                        result.result = "failed";
                        result.msg = "数据重复性检查失败!";
                    }

                    if (result.result == "")
                    {
                        transaction = conn.BeginTransaction();
                        cmd.Transaction = transaction;
                        strSql = string.Format(
                             @" INSERT INTO Equ_PmPlanList  
                        (ProcessCode,PmLevel, DeviceName, PmSpecCode, PmPlanCode,PmPlanName,PmCycleTime,PmTimeUsage,PmFirstDate,PmContinueTimes,PmPreAlarmDates,PmPlanComment, UpdateUser, UpdateTime) VALUES ( '{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}','{9}','{10}','{11}','{12}',getdate()) ",
                                 dataEntity.ProcessCode,
                                 dataEntity.PmLevel,
                                 dataEntity.DeviceName,
                                 dataEntity.PmSpecName,
                                 dataEntity.PmPlanCode,
                                 dataEntity.PmPlanName,
                                 dataEntity.PmCycleTime,
                                 dataEntity.PmTimeUsage,
                                 dataEntity.PmFirstDate,
                                 dataEntity.PmContinueTimes,
                                 dataEntity.PmPreAlarmDates,
                                 dataEntity.PmPlanComment,
                                 UserName
                             );
                        cmd.CommandType = CommandType.Text;
                        cmd.CommandText = strSql;
                        cmd.ExecuteNonQuery();
                        transaction.Commit();
                        result.result = "success";
                        result.msg = "保存数据成功!";
                      
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

        public ResultMsg_Equ_PmPlan editEquMaintencePlanDataInDB(Equ_PmPlanInfo dataEntity, ResultMsg_Equ_PmPlan result)
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

                    string strSql = " SELECT COUNT(1) AS SM FROM Equ_PmPlanList WHERE PmPlanCode = '" + dataEntity.PmPlanCode + "' and ID <> " + dataEntity.ID;
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = strSql;
                    SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    Datapter.Fill(dt);

                    if (dt != null && dt.Rows.Count > 0)
                    {
                        if (Convert.ToInt32(dt.Rows[0]["SM"]) > 0)
                        {
                            result.result = "failed";
                            result.msg = "此保养计划编号已经存在, 请核对!";
                        }
                        else
                        {
                            result.result = "";
                            result.msg = "";
                        }
                    }
                    else
                    {
                        result.result = "failed";
                        result.msg = "数据重复性检查失败!";
                    }

                    if (result.result == "")
                    {
                        transaction = conn.BeginTransaction();
                        cmd.Transaction = transaction;
                        strSql = string.Format(
                                                @" UPDATE Equ_PmPlanList SET 
                                                  ProcessCode  = '{0}' 
                                                , PmLevel ='{1}'
                                                , DeviceName  = '{2}'
                                                , PmSpecCode = '{3}'
                                                , PmPlanCode= '{4}'
                                                , PmPlanName= '{5}'
                                                , PmCycleTime= '{6}'
                                                , PmTimeUsage= '{7}'
                                                , PmFirstDate= '{8}'
                                                , PmContinueTimes= '{9}'
                                                , PmPreAlarmDates= '{10}'
                                                , PmPlanComment= '{11}'
                                                , UpdateUser   = '{12}'
                                                , UpdateTime   = getdate()
                                                WHERE id = {13}
                                            ",
                                                    dataEntity.ProcessCode,
                                                    dataEntity.PmLevel,
                                                    dataEntity.DeviceName,
                                                    dataEntity.PmSpecName,
                                                    dataEntity.PmPlanCode,
                                                    dataEntity.PmPlanName,
                                                    dataEntity.PmCycleTime,
                                                    dataEntity.PmTimeUsage,
                                                    dataEntity.PmFirstDate,
                                                    dataEntity.PmContinueTimes,
                                                    dataEntity.PmPreAlarmDates,
                                                    dataEntity.PmPlanComment,
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

        public Equ_PmPlanInfo GetEquDetailObj(Equ_PmPlanInfo equinfo, Equ_PmPlanInfo result)
        {

            DataTable dt = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = "select ID,ProcessCode,PmLevel,DeviceName,PmSpecCode,PmPlanCode,PmPlanName,PmCycleTime,PmTimeUsage,FORMAT(PmFirstDate,'yyyy-MM-dd') as PmFirstDate,PmContinueTimes,PmPreAlarmDates,PmPlanComment from Equ_PmPlanList";
                if (equinfo.ID != "")
                {
                    str1 += " WHERE ID = " + equinfo.ID + " ";
                }
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null && dt.Rows.Count > 0)
                {
                    result.ID = dt.Rows[0]["ID"].ToString();
                    result.ProcessCode = dt.Rows[0]["ProcessCode"].ToString();
                    result.PmLevel = dt.Rows[0]["PmLevel"].ToString();
                    result.DeviceName = dt.Rows[0]["DeviceName"].ToString();
                    result.PmSpecName = dt.Rows[0]["PmSpecCode"].ToString();
                    result.PmPlanCode = dt.Rows[0]["PmPlanCode"].ToString();
                    result.PmPlanName = dt.Rows[0]["PmPlanName"].ToString();
                    result.PmCycleTime =Convert.ToInt16(dt.Rows[0]["PmCycleTime"].ToString());
                    result.PmTimeUsage =Convert.ToInt16(dt.Rows[0]["PmTimeUsage"].ToString());
                    result.PmFirstDate = dt.Rows[0]["PmFirstDate"].ToString();
                    result.PmContinueTimes =Convert.ToInt16(dt.Rows[0]["PmContinueTimes"].ToString());
                    result.PmPreAlarmDates =Convert.ToInt16(dt.Rows[0]["PmPreAlarmDates"].ToString());
                    result.PmPlanComment = dt.Rows[0]["PmPlanComment"].ToString();
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

    public class Equ_PmPlanInfo
    {
        public string ID { get; set; }
        public string ProcessCode { set; get; }
        public string PmLevel { set; get; }
        public string DeviceName { set; get; }
        public string PmSpecName { set; get; }
        public string PmPlanCode { set; get; }
        public string PmPlanName { set; get; }
        public int PmCycleTime { set; get; }
        public int PmTimeUsage { set; get; }
        public string PmFirstDate { set; get; }
        public int PmContinueTimes { set; get; }
        public int PmPreAlarmDates { set; get; }
        public string PmPlanComment { set; get; }
    }

    public class ResultMsg_Equ_PmPlan
    {
        public string result { set; get; }
        public string msg { set; get; }
        public Equ_PmPlanInfo data { set; get; }
    }

}