using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.SessionState;
using LiNuoMes.Model;
namespace LiNuoMes.Equipment.hs
{
    /// <summary>
    /// GetEquMaintenceManCRUD 的摘要说明
    /// </summary>
    public class GetEquMaintenceManCRUD : IHttpHandler, IReadOnlySessionState
    {
        JavaScriptSerializer jsc = new JavaScriptSerializer();
        string Action = "";
        string uploadFilePath = HttpContext.Current.Server.MapPath("\\Equipment\\TemporaryFile\\");
        string browsePmSpecFilePath = HttpContext.Current.Server.MapPath("\\Equipment\\PmSpecFile\\");

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

            if (Action == "EquMaintenceExtraMan_Detail" || Action == "EquMaintenceMan_DetailFinish")
            {
                Equ_PmRecordInfo equinfo = new Equ_PmRecordInfo();
                equinfo.ID = RequstString("EquID");
                Equ_PmRecordInfo result = new Equ_PmRecordInfo();
                result = GetEquPmRecordDetailObj(equinfo, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "EquMaintenceExtraMan_Edit")
            {
                Equ_PmRecordInfo dataEntity = new Equ_PmRecordInfo();
                dataEntity.ID = RequstString("EquID");
                dataEntity.ProcessCode = RequstString("ProcessName");
                dataEntity.DeviceName = RequstString("DeviceName");
                dataEntity.PmSpecName = RequstString("PmSpecName");
                dataEntity.PmStartDate = RequstString("PmStartDate");
                dataEntity.PmFinishDate = RequstString("PmFinishDate");
                dataEntity.PmOper = RequstString("PmOper");
                dataEntity.PmComment = RequstString("PmComment");

                ResultMsg_Equ_PmRecord result = new ResultMsg_Equ_PmRecord();
                result = editEquMaintenceExtraManDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "EquMaintenceExtraMan_Add")
            {
                Equ_PmRecordInfo dataEntity = new Equ_PmRecordInfo();
                //dataEntity.ID = RequstString("ProcId");
                dataEntity.ProcessCode = RequstString("ProcessName");
                dataEntity.DeviceName = RequstString("DeviceName");
                dataEntity.PmType = RequstString("PmType");
                dataEntity.PmSpecName = RequstString("PmSpecName");
                dataEntity.PmStartDate = RequstString("PmStartDate");
                dataEntity.PmFinishDate = RequstString("PmFinishDate");
                dataEntity.PmComment = RequstString("PmComment");
                dataEntity.PmOper = RequstString("PmOper");

                ResultMsg_Equ_PmRecord result = new ResultMsg_Equ_PmRecord();
                result = addEquMaintenceExtraManDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }

            else if (Action == "EquMaintenceMan_DetailUnFinish")
            {
                Equ_PmRecordInfo equinfo = new Equ_PmRecordInfo();
                equinfo.ID = RequstString("EquID");
                Equ_PmRecordInfo result = new Equ_PmRecordInfo();
                result = GetEquPmUnFinishRecordDetailObj(equinfo, result);
                context.Response.Write(jsc.Serialize(result));
            }

            else if (Action == "ExcuteEquMaintenceMan")
            {
                Equ_PmRecordInfo dataEntity = new Equ_PmRecordInfo();
                //dataEntity.ID = RequstString("EquID");
                dataEntity.ProcessCode = RequstString("ProcessName");
                dataEntity.DeviceName = RequstString("DeviceName");
                dataEntity.PmSpecName = RequstString("PmSpecName");
                dataEntity.PmPlanName = RequstString("PmPlanName");
                dataEntity.PmType = "计划内保养";
                dataEntity.PmSpecName = RequstString("PmSpecName");
                dataEntity.PmStartDate = RequstString("PmStartDate");
                dataEntity.PmFinishDate = RequstString("PmFinishDate");
                dataEntity.PmComment = RequstString("PmComment");
                dataEntity.PmOper = RequstString("PmOper");

                ResultMsg_Equ_PmRecord result = new ResultMsg_Equ_PmRecord();
                result = ExcuteEquMaintenceManDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }

            else if (Action == "EquMaintenceManEdit")
            {
                Equ_PmRecordInfo dataEntity = new Equ_PmRecordInfo();
                dataEntity.ID = RequstString("EquID");
                //dataEntity.ProcessCode = RequstString("ProcessName");
                //dataEntity.DeviceName = RequstString("DeviceName");
                //dataEntity.PmSpecName = RequstString("PmSpecName");
                //dataEntity.PmPlanName = RequstString("PmPlanName");
                //dataEntity.PmType = "计划内保养";
                //dataEntity.PmSpecName = RequstString("PmSpecName");
                dataEntity.PmStartDate = RequstString("PmStartDate");
                dataEntity.PmFinishDate = RequstString("PmFinishDate");
                dataEntity.PmComment = RequstString("PmComment");
                dataEntity.PmOper = RequstString("PmOper");

                ResultMsg_Equ_PmRecord result = new ResultMsg_Equ_PmRecord();
                result = editEquMaintenceManDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }

            else if (Action == "ExcuteFirstLevelEquMaintenceMan")
            {
                List<Equ_PmFisrtLevelRecordInfo> dataEntity = new List<Equ_PmFisrtLevelRecordInfo>();
                string[] PmList = RequstString("PmList").Split(',');
               
                for (int i = 0; i < PmList.Length; i++ )
                {
                    Equ_PmFisrtLevelRecordInfo ep = new Equ_PmFisrtLevelRecordInfo();
                    ep.PmPlanCode = PmList[i].ToString();

                    ep.PmComment = RequstString("PmComment");
                    ep.PmOper = RequstString("PmOper");

                    ep.FindProblem = RequstString("FindProblem") == "" ? 0 : Convert.ToInt16(RequstString("FindProblem"));
                    ep.RepairProblem = RequstString("RepairProblem") == "" ? 0 : Convert.ToInt16(RequstString("RepairProblem"));
                    ep.ReaminProblem = RequstString("ReaminProblem") == "" ? 0 : Convert.ToInt16(RequstString("ReaminProblem"));
                    dataEntity.Add(ep);
                }

                ResultMsg_Equ_PmFirstLevelRecord result = new ResultMsg_Equ_PmFirstLevelRecord();
                result = ExcuteFirstLevelEquMaintenceMan(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }

            else if (Action == "ExcuteSecondLevelEquMaintenceMan")
            {
                List<Equ_PmFisrtLevelRecordInfo> dataEntity = new List<Equ_PmFisrtLevelRecordInfo>();
                string[] PmList = RequstString("PmList").Split(',');
                
                for (int i = 0; i < PmList.Length; i++)
                {
                    Equ_PmFisrtLevelRecordInfo ep = new Equ_PmFisrtLevelRecordInfo();
                    ep.PmPlanCode = PmList[i].ToString();
                    ep.PmOper = RequstString("PmOper");
                    dataEntity.Add(ep);
                    
                }

                ResultMsg_Equ_PmFirstLevelRecord result = new ResultMsg_Equ_PmFirstLevelRecord();
                result = ExcuteSecondLevelEquMaintenceMan(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }

            else if (Action == "CheckFirstLevelMaintence")
            {
                ResultMsg_Equ_PmFirstLevelRecord result = new ResultMsg_Equ_PmFirstLevelRecord();
                result = CheckFirstLevelMaintence(result);
                context.Response.Write(jsc.Serialize(result));
            }

            else if (Action == "EquFirstLevelMaintenceMan_Detail")
            {
                Equ_PmFisrtLevelRecordDetail result = new Equ_PmFisrtLevelRecordDetail();
                result.ID= RequstString("EquID");
                result = GetFirstLevelDetail(result);
                context.Response.Write(jsc.Serialize(result));
            }

            else if (Action == "AddSecondLevelProblem")
            {
                Equ_PmSecondLevelProblem dataEntity = new Equ_PmSecondLevelProblem();
                //dataEntity.ID = RequstString("EquID");
                dataEntity.PmOper = RequstString("PmOper");
                dataEntity.PmDate = RequstString("PmDate");
                dataEntity.DeviceCode = RequstString("DeviceCode");
                dataEntity.MaintenceTime = RequstString("MaintenceTime");
                dataEntity.PowerLine = RequstString("PowerLine");
                dataEntity.GroundLead = RequstString("GroundLead");
                dataEntity.ReplacePart = RequstString("ReplacePart");
                dataEntity.ReplaceName = RequstString("ReplaceName");
                dataEntity.ReplaceCount = RequstString("ReplaceCount");
                dataEntity.InspectionProblem = RequstString("InspectionProblem");

                ResultMsg_Equ_PmFirstLevelRecord result = new ResultMsg_Equ_PmFirstLevelRecord();
                result = AddSecondLevelProblem(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }

            #region//获取每日保养用时
            if (Action == "GetDailyMaintenceTime")
            {
                Model.DailyMaintenceTime mb = new Model.DailyMaintenceTime();
                mb.MaintenceDate = RequstString("CurrentMonth");
                mb = GetDailyMaintenceTime(mb);
                context.Response.Write(jsc.Serialize(mb));
            }
            #endregion
            #region //新增每日保养用时
            if (Action == "DailyMaintenceTime_Add")
            {
                Model.DailyMaintenceTime mb = new Model.DailyMaintenceTime();
                mb.MaintenceDate = RequstString("CurrentTime");
                mb.TotalTime = RequstString("TotalTime");
                Model.ResultMsg_DailyMaintenceTime result = new ResultMsg_DailyMaintenceTime();
                result = DailyMaintenceTimeAdd(mb, result);
                context.Response.Write(jsc.Serialize(result));
            }
            #endregion
            #region //更新每日保养用时
            if (Action == "DailyMaintenceTime_Edit")
            {
                Model.DailyMaintenceTime mb = new Model.DailyMaintenceTime();
                mb.MaintenceDate = RequstString("CurrentMonth");
                mb.TotalTime = RequstString("TotalTime");
                Model.ResultMsg_DailyMaintenceTime result = new Model.ResultMsg_DailyMaintenceTime();
                result = DailyMaintenceTimeEdit(mb, result);
                context.Response.Write(jsc.Serialize(result));
            }
            #endregion
        }

        public Equ_PmRecordInfo GetEquPmRecordDetailObj(Equ_PmRecordInfo equinfo, Equ_PmRecordInfo result)
        {

            DataTable dt = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = "select a.ID,b.ProcessName as ProcessCode,a.DeviceName,a.PmPlanName,a.PmSpecName,convert(varchar(10),a.PmStartDate,120) as PmStartDate,convert(varchar(10),a.PmFinishDate,120) as PmFinishDate,a.PmOper, a.PmComment from Equ_PmRecordList a  left join Mes_Process_List b on a.ProcessCode=b.ProcessCode";
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
                    result.PmPlanName = dt.Rows[0]["PmPlanName"].ToString();
                    result.PmSpecName = dt.Rows[0]["PmSpecName"].ToString();
                    result.PmStartDate = dt.Rows[0]["PmStartDate"].ToString();
                    result.PmFinishDate = dt.Rows[0]["PmFinishDate"].ToString();
                    result.PmOper = dt.Rows[0]["PmOper"].ToString();
                    result.PmComment = dt.Rows[0]["PmComment"].ToString();
                }
            }
            return result;
        }

        public Equ_PmRecordInfo GetEquPmUnFinishRecordDetailObj(Equ_PmRecordInfo equinfo, Equ_PmRecordInfo result)
        {

            DataTable dt = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = "select a.ID,b.ProcessName as ProcessCode,a.DeviceName,a.PmPlanName,a.PmSpecName from Equ_PmPlanList a  left join Mes_Process_List b on a.ProcessCode=b.ProcessCode";
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
                    result.PmPlanName = dt.Rows[0]["PmPlanName"].ToString();
                    result.PmSpecName = dt.Rows[0]["PmSpecName"].ToString();
                    result.PmStartDate = "";
                    result.PmFinishDate = "";
                    result.PmComment ="";
                    result.PmOper = "";
                }
            }
            return result;
        }
      

        public ResultMsg_Equ_PmRecord addEquMaintenceExtraManDataInDB(Equ_PmRecordInfo dataEntity, ResultMsg_Equ_PmRecord result)
        {
            if (dataEntity.ProcessCode.Length == 0) dataEntity.ProcessCode = "";
            if (dataEntity.DeviceName.Length == 0) dataEntity.DeviceName = "";
            if (dataEntity.PmOper.Length == 0) dataEntity.PmOper = "";
            if (dataEntity.PmSpecName.Length == 0) dataEntity.PmSpecName = "";
            if (dataEntity.PmStartDate.Length == 0) dataEntity.PmStartDate = "";
            if (dataEntity.PmFinishDate.Length == 0) dataEntity.PmFinishDate = "";
            if (dataEntity.PmComment.Length == 0) dataEntity.PmComment = "";
            if (dataEntity.PmType.Length == 0) dataEntity.PmType = "计划外保养";
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
                         @" INSERT INTO Equ_PmRecordList  
                    (  ProcessCode, DeviceName,PmSpecName,PmType,PmStartDate,PmFinishDate,PmOper,PmComment,UpdateUser,UpdateTime,PmPlanName)VALUES (
                      '{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}',getdate(),'') ",
                             dataEntity.ProcessCode,
                             dataEntity.DeviceName,
                             dataEntity.PmSpecName,
                             dataEntity.PmType,
                             dataEntity.PmStartDate,
                             dataEntity.PmFinishDate,
                             dataEntity.PmOper,
                             dataEntity.PmComment,
                             UserName
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

        public ResultMsg_Equ_PmRecord editEquMaintenceExtraManDataInDB(Equ_PmRecordInfo dataEntity, ResultMsg_Equ_PmRecord result)
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
                                            @" UPDATE Equ_PmRecordList SET 
                                              ProcessCode  = '{0}' 
                                            , DeviceName  = {1}
                                            , PmSpecName = {2}
                                            , PmStartDate= '{3}'
                                            , PmFinishDate= '{4}'
                                            , PmOper= '{5}'
                                            , PmComment= '{6}'
                                            , UpdateUser   = '{7}'
                                            , UpdateTime   = getdate()
                                            WHERE id = {8}
                                        ",
                                                dataEntity.ProcessCode,
                                                dataEntity.DeviceName,
                                                dataEntity.PmSpecName,
                                                dataEntity.PmStartDate,
                                                dataEntity.PmFinishDate,
                                                dataEntity.PmOper,
                                                dataEntity.PmComment,
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


        public ResultMsg_Equ_PmRecord ExcuteEquMaintenceManDataInDB(Equ_PmRecordInfo dataEntity, ResultMsg_Equ_PmRecord result)
        {
            if (dataEntity.ProcessCode.Length == 0) dataEntity.ProcessCode = "";
            if (dataEntity.DeviceName.Length == 0) dataEntity.DeviceName = "";
            if (dataEntity.PmOper.Length == 0) dataEntity.PmOper = "";
            if (dataEntity.PmSpecName.Length == 0) dataEntity.PmSpecName = "";
            if (dataEntity.PmStartDate.Length == 0) dataEntity.PmStartDate = "";
            if (dataEntity.PmFinishDate.Length == 0) dataEntity.PmFinishDate = "";
            if (dataEntity.PmComment.Length == 0) dataEntity.PmComment = "";
            //if (dataEntity.PmType.Length == 0) dataEntity.PmType = "计划外保养";
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
                         @" INSERT INTO Equ_PmRecordList  
                    (  ProcessCode, DeviceName,PmSpecName,PmType,PmStartDate,PmFinishDate,PmOper,PmComment,UpdateUser,UpdateTime,PmPlanName,PmLevel,PmPlanDate,PmDoTimes)VALUES (
                      (select ProcessCode from Mes_Process_List where ProcessName='"+dataEntity.ProcessCode+"'),'{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}',getdate(),'{8}',(select PmLevel from Equ_PmSpecList where PmSpecName='" + dataEntity.PmSpecName + "'),'" + RequstString("PmFirstDate") + "','" + RequstString("PmDoTimes") + "') ",
                             dataEntity.DeviceName,
                             dataEntity.PmSpecName,
                             dataEntity.PmType,
                             dataEntity.PmStartDate,
                             dataEntity.PmFinishDate,
                             dataEntity.PmOper,
                             dataEntity.PmComment,
                             UserName,
                             dataEntity.PmPlanName
                             
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

        public ResultMsg_Equ_PmRecord editEquMaintenceManDataInDB(Equ_PmRecordInfo dataEntity, ResultMsg_Equ_PmRecord result)
        {
            if (dataEntity.ID.Length == 0) dataEntity.ID = "0";         
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
                                            @" UPDATE Equ_PmRecordList SET 
                                              PmStartDate= '{1}'
                                            , PmFinishDate= '{2}'
                                            , PmOper= '{3}'
                                            , PmComment= '{4}'
                                            , UpdateUser   = '{5}'
                                            , UpdateTime   = getdate()
                                            WHERE id = {6}
                                        ",
                                                dataEntity.PmStartDate,
                                                dataEntity.PmFinishDate,
                                                dataEntity.PmOper,
                                                dataEntity.PmComment,
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


        public ResultMsg_Equ_PmFirstLevelRecord ExcuteFirstLevelEquMaintenceMan(List<Equ_PmFisrtLevelRecordInfo> dataEntity, ResultMsg_Equ_PmFirstLevelRecord result)
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
                    SqlParameter[] sqlPara = new SqlParameter[6];
                    for (int i = 0; i < dataEntity.Count; i++ )
                    {
                        if (i == 0)
                        {
                            sqlPara[0] = new SqlParameter("@PmPlanCode", dataEntity[i].PmPlanCode);
                            sqlPara[0].Direction = System.Data.ParameterDirection.Input;
                            
                            sqlPara[1] = new SqlParameter("@PmOper", dataEntity[i].PmOper);
                            sqlPara[1].Direction = System.Data.ParameterDirection.Input;
                            sqlPara[2] = new SqlParameter("@PmComment", dataEntity[i].PmComment);
                            sqlPara[2].Direction = System.Data.ParameterDirection.Input;
                            sqlPara[3] = new SqlParameter("@FindProblem", dataEntity[i].FindProblem);
                            sqlPara[3].Direction = System.Data.ParameterDirection.Input;
                            sqlPara[4] = new SqlParameter("@RepairProblem", dataEntity[i].RepairProblem);
                            sqlPara[4].Direction = System.Data.ParameterDirection.Input;
                            sqlPara[5] = new SqlParameter("@ReaminProblem", dataEntity[i].ReaminProblem);
                            sqlPara[5].Direction = System.Data.ParameterDirection.Input;
                            foreach (SqlParameter para in sqlPara)
                            {
                                cmd.Parameters.Add(para);
                            }
                        }
                        else
                        {
                            cmd.Parameters[0].Value = dataEntity[i].PmPlanCode;
                            
                        }
                        cmd.CommandText = "[usp_EquExcuteFirstMaintence]";
                        cmd.ExecuteNonQuery();
                    }
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



        public ResultMsg_Equ_PmFirstLevelRecord ExcuteSecondLevelEquMaintenceMan(List<Equ_PmFisrtLevelRecordInfo> dataEntity, ResultMsg_Equ_PmFirstLevelRecord result)
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
                    SqlParameter[] sqlPara = new SqlParameter[2];
                    for (int i = 0; i < dataEntity.Count; i++)
                    {
                        if (i == 0)
                        {
                            sqlPara[0] = new SqlParameter("@PmPlanCode", dataEntity[i].PmPlanCode);
                            sqlPara[0].Direction = System.Data.ParameterDirection.Input;
                            //sqlPara[1] = new SqlParameter("@PmStartDate", dataEntity[i].PmStartDate);
                            //sqlPara[1].Direction = System.Data.ParameterDirection.Input;
                            //sqlPara[2] = new SqlParameter("@PmFinishDate", dataEntity[i].PmFinishDate);
                            //sqlPara[2].Direction = System.Data.ParameterDirection.Input;
                            sqlPara[1] = new SqlParameter("@PmOper", dataEntity[i].PmOper);
                            sqlPara[1].Direction = System.Data.ParameterDirection.Input;
                            foreach (SqlParameter para in sqlPara)
                            {
                                cmd.Parameters.Add(para);
                            }
                        }
                        else
                        {
                            cmd.Parameters[0].Value = dataEntity[i].PmPlanCode;

                        }
                        cmd.CommandText = "[usp_EquExcuteSecondMaintence]";
                        cmd.ExecuteNonQuery();
                    }
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

        public ResultMsg_Equ_PmFirstLevelRecord CheckFirstLevelMaintence(ResultMsg_Equ_PmFirstLevelRecord result)
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
                    SqlParameter[] sqlPara = new SqlParameter[1];
                    sqlPara[0] = new SqlParameter("@CatchFlag", 0);
                    sqlPara[0].Size = 10;
                    sqlPara[0].Direction = System.Data.ParameterDirection.Output;
                    foreach (SqlParameter para in sqlPara)
                    {
                        cmd.Parameters.Add(para);
                    }
                    cmd.CommandText = "[usp_Equ_CheckFirstLevelMaintence]";
                    cmd.ExecuteNonQuery();
                    transaction.Commit();

                    if (sqlPara[0].Value.ToString()=="1")
                    {
                        result.result = "1";
                        result.msg = "当日已完成两次维护，不需要再次维护";

                    }
                    else if (sqlPara[0].Value.ToString() == "0")
                    {
                        result.result = "0";
                        result.msg = "需要维护!";
                    }
                    
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    result.result = "failed";
                    result.msg = "数据异常! \n" + ex.Message;
                }
            }
            return result;
        }


        public Equ_PmFisrtLevelRecordDetail GetFirstLevelDetail(Equ_PmFisrtLevelRecordDetail result)
        {
            DataTable dt = new DataTable();

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = "select c.ProcessName,a.DeviceName,a.PmOper,b.InspectionProblem,b.FindProblem,b.RepairProblem,b.ReaminProblem from Equ_PmRecordList a left join Equ_FirstLevelInspectionProblem b on a.ID=b.PmRecordID left join Mes_Process_List c on a.ProcessCode =c.ProcessCode";
                if (result.ID != "")
                {
                    str1 += " WHERE a.ID = " + result.ID + " ";
                }
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null && dt.Rows.Count > 0)
                {
                    
                    result.ProcessCode = dt.Rows[0]["ProcessName"].ToString();
                    result.DeviceName = dt.Rows[0]["DeviceName"].ToString();
                    result.PmOper = dt.Rows[0]["PmOper"].ToString();
                    result.PmComment = dt.Rows[0]["InspectionProblem"].ToString();

                    result.FindProblem = dt.Rows[0]["FindProblem"].ToString() == "" ? 0 : Convert.ToInt16(dt.Rows[0]["FindProblem"].ToString());
                    result.RepairProblem = dt.Rows[0]["RepairProblem"].ToString() == "" ? 0 : Convert.ToInt16(dt.Rows[0]["RepairProblem"].ToString());
                    result.ReaminProblem = dt.Rows[0]["ReaminProblem"].ToString() == "" ? 0 : Convert.ToInt16(dt.Rows[0]["ReaminProblem"].ToString());
                }
            }
            return result;
        }


        public ResultMsg_Equ_PmFirstLevelRecord AddSecondLevelProblem(Equ_PmSecondLevelProblem dataEntity, ResultMsg_Equ_PmFirstLevelRecord result)
        {
            
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
                         @" INSERT INTO Equ_SecondLevelInspectionProblem  
                    (  InspectionProblem, InspectionDate,DeviceCode,MaintenceTime,PowerLine,GroundLead,ReplacePart,ReplaceName,ReplaceCount)VALUES (
                      '{0}','{1}','{2}','{3}','{4}','{5}','{6}','{7}','{8}')",
                             dataEntity.InspectionProblem,
                             dataEntity.PmDate,
                             dataEntity.DeviceCode,
                             dataEntity.MaintenceTime,
                             dataEntity.PowerLine,
                             dataEntity.GroundLead,
                             dataEntity.ReplacePart,
                             dataEntity.ReplaceName,
                             dataEntity.ReplaceCount
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




        /// <summary>
        /// 获取当日保养用时
        /// </summary>
        /// <param name="monthbudget"></param>
        /// <returns></returns>
        public Model.DailyMaintenceTime GetDailyMaintenceTime(Model.DailyMaintenceTime usetime)
        {
            DataTable dt = new DataTable();
            string ReturnValue = string.Empty;

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = "select TotalTime from Equ_MaintenceUseTime";
                if (usetime.MaintenceDate != "")
                {
                    str1 += "  WHERE MaintenceDate ='" + usetime.MaintenceDate + "' ";
                }

                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null && dt.Rows.Count > 0)
                {
                    usetime.TotalTime = dt.Rows[0]["TotalTime"].ToString();
                }
                return usetime;
            }
        }

        /// <summary>
        /// 新增当月预算产量
        /// </summary>
        /// <param name="dataEntity"></param>
        /// <param name="result"></param>
        /// <returns></returns>
        public Model.ResultMsg_DailyMaintenceTime DailyMaintenceTimeAdd(Model.DailyMaintenceTime dataEntity, Model.ResultMsg_DailyMaintenceTime result)
        {

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                SqlTransaction transaction = null;
                try
                {
                    conn.Open();
                    cmd.Connection = conn;
                    transaction = conn.BeginTransaction();
                    cmd.Transaction = transaction;
                    string strSql = string.Format(
                         @" INSERT INTO Equ_MaintenceUseTime  
                        (MaintenceDate,TotalTime, UpdateUser, UpdateTime) VALUES ( '{0}','{1}','{2}',getdate()) ",
                             dataEntity.MaintenceDate,
                             dataEntity.TotalTime,
                             UserName
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


        /// <summary>
        /// 编辑当月预算产量
        /// </summary>
        /// <param name="dataEntity"></param>
        /// <param name="result"></param>
        /// <returns></returns>
        public Model.ResultMsg_DailyMaintenceTime DailyMaintenceTimeEdit(Model.DailyMaintenceTime dataEntity, Model.ResultMsg_DailyMaintenceTime result)
        {

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                SqlTransaction transaction = null;
                try
                {
                    conn.Open();
                    cmd.Connection = conn;
                    transaction = conn.BeginTransaction();
                    cmd.Transaction = transaction;
                    string strSql = string.Format(
                        @" UPDATE Equ_MaintenceUseTime SET 
                                                  TotalTime  = '{0}' 
                                                , UpdateUser   = '{1}'
                                                , UpdateTime   = getdate()
                                                  WHERE MaintenceDate = '{2}'
                                            ",
                                                    dataEntity.TotalTime,
                                                    UserName,
                                                    dataEntity.MaintenceDate
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

    public class Equ_PmRecordInfo
    {
        public string ID { get; set; }
        public string ProcessCode { set; get; }
        public string DeviceName { set; get; }
        public string PmSpecName { set; get; }
        public string PmPlanName { get; set; }
        public string PmType { set; get; }
        public string PmStartDate { set; get; }
        public string PmFinishDate { set; get; }
        public string PmOper { set; get; }
        public string PmComment { set; get; }

    }

    public class Equ_PmFisrtLevelRecordInfo
    {
        public string PmPlanCode { get; set; }
        public string PmStartDate { set; get; }
        public string PmFinishDate { set; get; }
        public string PmOper { set; get; }
        public string PmComment { set; get; }
        public int FindProblem { set; get; }
        public int RepairProblem { set; get; }
        public int ReaminProblem { set; get; }

    }

    public class Equ_PmFisrtLevelRecordDetail
    {
        public string ID { get; set; }
        public string ProcessCode { set; get; }
        public string DeviceName { set; get; }
      
        public string PmOper { set; get; }
        public string PmComment { set; get; }
        public int FindProblem { set; get; }
        public int RepairProblem { set; get; }
        public int ReaminProblem { set; get; }

    }

    public class Equ_PmSecondLevelProblem
    {
        public string PmOper { get; set; }
        public string PmDate { set; get; }
        public string DeviceCode { set; get; }
        public string MaintenceTime { set; get; }
        public string PowerLine { set; get; }
        public string GroundLead { set; get; }
        public string ReplacePart { set; get; }
        public string ReplaceName { set; get; }
        public string ReplaceCount { set; get; }
        public string InspectionProblem { set; get; }

    }


    public class ResultMsg_Equ_PmRecord
    {
        public string result { set; get; }
        public string msg { set; get; }
        public Equ_PmRecordInfo data { set; get; }
    }

    public class ResultMsg_Equ_PmFirstLevelRecord
    {
        public string result { set; get; }
        public string msg { set; get; }

    }

}