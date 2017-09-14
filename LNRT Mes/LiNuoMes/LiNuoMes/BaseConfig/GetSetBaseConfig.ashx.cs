using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Data.SqlClient;
using clsSql;
using System.IO;
using System.Configuration;
using System.Web;
using System.Web.Services;
using System.Web.SessionState;
using System.Web.Script.Serialization;


namespace LiNuoMes.BaseConfig
{
    /// <summary>
    /// GetSetBaseConfig 的摘要说明
    /// </summary>
    public class GetSetBaseConfig : IHttpHandler, IReadOnlySessionState
    {
        JavaScriptSerializer jsc = new JavaScriptSerializer();
        string UserName = "";
        string Action   = "";
        string uploadFilePath = HttpContext.Current.Server.MapPath("\\BaseConfig\\TemporaryFile\\");
        string browseFilePath = HttpContext.Current.Server.MapPath("\\BaseConfig\\ProcessManual\\");
        string logoFilePath   = HttpContext.Current.Server.MapPath("\\BaseConfig\\CustomerLogo\\");

        public void ProcessRequest(HttpContext context)
        {
            jsc.MaxJsonLength = Int32.MaxValue;
            context.Response.ContentType = "text/plain";
            if (context.Session["UserName"] != null)
                UserName = context.Session["UserName"].ToString().ToUpper().Trim();
            else
                UserName = "";

            Action = RequstString("Action");

            if (Action.Length == 0 ) Action = "";

            if (Action == "MES_CONFIG")
            {
                MesConfig dataEntity;
                dataEntity = new MesConfig();
                dataEntity = ReadWriteMesConfig(dataEntity);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "MES_CUSTOMER_LIST")
            {
                List<CustomerEntity> dataEntity = new List<CustomerEntity>();
                ResultMsg result = new ResultMsg();
                dataEntity = GetCustomerListObj(dataEntity);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "MES_CUSTOMER_CONFIG_DETAIL")
            {
                CustomerEntity findItem = new CustomerEntity();
                findItem.CustomerID = RequstString("CustID");
                CustomerEntity dataEntity = new CustomerEntity();
                dataEntity = GetCustomerDetailObj(dataEntity, findItem);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "MES_CUSTOMER_CONFIG_EDIT" || Action == "MES_CUSTOMER_CONFIG_ADD")
            {
                CustomerEntity dataEntity = new CustomerEntity();
                ResultMsg_Customer result = new ResultMsg_Customer();

                dataEntity.CustomerID   = RequstString("CustId");
                dataEntity.CustomerName = RequstString("CustomerName");
                dataEntity.CustomerLogo = RequstString("CustomerLogo");
                dataEntity.UploadedFile = RequstString("UploadedFile");
                browseFilePath = logoFilePath; //默认browseFilePath是为工序指导书路径, 因此这里临时指定一下.
                if (Action == "MES_CUSTOMER_CONFIG_EDIT")
                {
                    result = editCustomerDataInDB(dataEntity, result);
                }
                else if (Action == "MES_CUSTOMER_CONFIG_ADD")
                {
                    result = addCustomerDataInDB(dataEntity, result);
                }
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "MES_LINE_CONFIG_READ")
            {
                LineEntity dataEntity;
                dataEntity = new LineEntity();
                ResultMsg_Line result = new ResultMsg_Line();
                result = readLineEntityDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "MES_LINE_CONFIG_SAVE")
            {
                LineEntity dataEntity;
                dataEntity = new LineEntity();
                dataEntity.LineCode = RequstString("LineCode");
                dataEntity.LineName = RequstString("LineName");
                dataEntity.ShiftHours = RequstString("ShiftHours");
                dataEntity.LineCapacity = RequstString("LineCapacity");
                dataEntity.LineHeadCount = RequstString("LineHeadCount");
                dataEntity.LineDsca = RequstString("LineDsca");

                ResultMsg_Line result = new ResultMsg_Line();
                result = saveLineEntityDataInDB(dataEntity, result);
                result.data = dataEntity;
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "MES_PROC_CONFIG_FILE_UPLOAD")
            {
                HttpPostedFile file = System.Web.HttpContext.Current.Request.Files["Filedata"];
                ResultMsg_FileUPload result = new ResultMsg_FileUPload();
                result = doUploadFile(result, file);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "MFG_WO_LIST_FILE_UPLOAD")
            {
                HttpPostedFile file = System.Web.HttpContext.Current.Request.Files["Filedata"];
                ResultMsg_FileUPload result = new ResultMsg_FileUPload();
                result = doUploadFile(result, file);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "MES_PROC_CONFIG_DETAIL")
            {
                ProcessEntity findItem;
                findItem = new ProcessEntity();
                findItem.ID = RequstString("ProcID");
                ProcessEntity dataEntity;
                dataEntity = new ProcessEntity();
                dataEntity = GetProcessDetailObj(dataEntity, findItem);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "MES_PROC_CONFIG_CHECK" || Action == "MES_PROC_CONFIG_DOWNLOAD")
            {
                string objID = RequstString("ObjID");
                string fileName = GetProcessManualFileNameFromDB(objID);
                string fileType = Path.GetExtension(fileName).ToLower();
                
                
                context.Response.ClearContent( );
                context.Response.ClearHeaders( );

                if (Action == "MES_PROC_CONFIG_CHECK")
                {
                    context.Response.AppendHeader("Content-Disposition", string.Format("inline; filename={0}", fileName));
                }
                else
                {
                    context.Response.AppendHeader("Content-Disposition", string.Format("attached; filename={0}", fileName));
                }

                //content-type: application/pdf （PDF文件） ||  application/msword（WORD文件） || application/x-msexcel（EXCEL文件） || text/plain （文本文件）
                if (fileType == ".docx" || fileType == ".doc")
                {
                    context.Response.AppendHeader("content-type", "application/msword");
                }
                else if (fileType == ".xlsx" || fileType == ".xls")
                {
                    context.Response.AppendHeader("content-type", "application/x-msexcel");
                }
                else if (fileType == ".pdf")
                {
                    context.Response.AppendHeader("content-type", "application/pdf");
                }
                try
                {
                    FileInfo objFile = new FileInfo(browseFilePath + fileName);
                    context.Response.AppendHeader("content-length", objFile.Length.ToString());
                    context.Response.WriteFile(browseFilePath + fileName);
                }
                catch (Exception ex)
                {
                    context.Response.Write(ex.Message);
                }
                context.Response.Flush( );
                context.Response.Close( );
            }
            else if (Action == "MES_PROC_CONFIG_LIST")
            {
                ProcessEntity findItem;
                findItem = new ProcessEntity();
                findItem.ProcessCode = RequstString("ProcessCode");
                findItem.ProcessName = RequstString("ProcessName");
                List<ProcessEntity> dataEntity;
                dataEntity = new List<ProcessEntity>();
                dataEntity = GetProcessListObj(dataEntity, findItem);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "MES_PROC_CONFIG_DEL")
            {
                ProcessEntity dataEntity = new ProcessEntity();
                dataEntity.ID            = RequstString("ProcId");
                ResultMsg_Process result = new ResultMsg_Process();
                result = delProcessDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "MES_PROC_CONFIG_EDIT" || Action == "MES_PROC_CONFIG_ADD")
            {
                ProcessEntity dataEntity = new ProcessEntity();
                dataEntity.ID            = RequstString("ProcId");
                dataEntity.ProcessCode   = RequstString("ProcessCode");
                dataEntity.ProcessName   = RequstString("ProcessName");
                dataEntity.ProcessBeat   = RequstString("ProcessBeat");
                dataEntity.ProcessDsca   = RequstString("ProcessDsca");
                dataEntity.InturnNumber  = RequstString("InturnNumber");
                dataEntity.ProcessManual = RequstString("ProcessManual");
                dataEntity.UploadedFile  = RequstString("UploadedFile");

                ResultMsg_Process result = new ResultMsg_Process();
                {
                    if (Action == "MES_PROC_CONFIG_EDIT")
                    {
                        result = editProcessDataInDB(dataEntity, result);
                    }
                    else if (Action == "MES_PROC_CONFIG_ADD")
                    {
                        result = addProcessDataInDB(dataEntity, result);
                    }
                }

                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "MES_GOODS_CONFIG_DETAIL")
            {
                GoodsEntity findItem;
                findItem = new GoodsEntity();
                findItem.ID = RequstString("GoodsId");
                GoodsEntity dataEntity;
                dataEntity = new GoodsEntity();
                dataEntity = GetGoodsDetailObj(dataEntity, findItem);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "MES_GOODS_CONFIG_LIST")
            {
                GoodsEntity findItem;
                findItem = new GoodsEntity();
                findItem.GoodsCode = RequstString("GoodsCode");
                findItem.DimLength = RequstString("DimLength");
                findItem.DimHeight = RequstString("DimHeight");
                findItem.DimWidth  = RequstString("DimWidth");
                List<GoodsEntity> dataEntity;
                dataEntity = new List<GoodsEntity>();
                dataEntity = GetGoodsListObj(dataEntity, findItem);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "MES_GOODS_CONFIG_DEL")
            {
                GoodsEntity dataEntity = new GoodsEntity();
                dataEntity.ID = RequstString("GoodsId");
                ResultMsg_Goods result = new ResultMsg_Goods();
                result = delGoodsDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "MES_GOODS_CONFIG_EDIT" || Action == "MES_GOODS_CONFIG_ADD")
            {
                GoodsEntity dataEntity = new GoodsEntity();
                dataEntity.ID           = RequstString("GoodsId");
                dataEntity.GoodsCode    = RequstString("GoodsCode");
                dataEntity.GoodsDsca    = RequstString("GoodsDsca");
                dataEntity.DimLength    = RequstString("DimLength");
                dataEntity.DimHeight    = RequstString("DimHeight");
                dataEntity.DimWidth     = RequstString("DimWidth");
                dataEntity.UnitCostTime = RequstString("UnitCostTime");

                ResultMsg_Goods result = new ResultMsg_Goods();
                {
                    if (Action == "MES_GOODS_CONFIG_EDIT")
                    {
                        result = editGoodsDataInDB(dataEntity, result);
                    }
                    else if (Action == "MES_GOODS_CONFIG_ADD")
                    {
                        result = addGoodsDataInDB(dataEntity, result);
                    }
                }

                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "MES_THRESHOLD_CONFIG_LIST")
            {
                ThresholdEntity findItem;
                findItem = new ThresholdEntity();
                findItem.ProcessCode = RequstString("ProcessCode");
                findItem.ItemNumber  = RequstString("ItemNumber");
                List<ThresholdEntity> dataEntity;
                dataEntity = new List<ThresholdEntity>();
                dataEntity = GetThresholdListObj(dataEntity, findItem);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "MES_THRESHOLD_CONFIG_EDIT" )
            {
                ThresholdEntity dataEntity = new ThresholdEntity();
                dataEntity.THID       = RequstString("THID");
                dataEntity.MaxPullQty = RequstString("MaxPullQty");
                dataEntity.MinTrigQty = RequstString("MinTrigQty");
                dataEntity.UOM        = RequstString("UOM");

                ResultMsg_Threshold result = new ResultMsg_Threshold();
                result = editThresholdDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "MES_PLC_PULL_CONFIG_LIST")
            {
                List<PLCEntity> dataEntity;
                dataEntity = new List<PLCEntity>();
                dataEntity = GetPlcPullObjList(dataEntity);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "MES_PLC_PULL_CONFIG_EDIT")
            {
                List<PLCParameUPD> paramlist = new List<PLCParameUPD>();

                PLCParameUPD[] dataEntity;
                dataEntity = jsc.Deserialize<PLCParameUPD[]>(RequstString("ListJson"));
                ResultMsg result = new ResultMsg();
                result = editPlcPullParameDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "MES_PLC_CONFIG_LIST")
            {
                List<PLCEntity> dataEntity;
                dataEntity = new List<PLCEntity>();
                dataEntity = GetPLCObjList(dataEntity);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "MES_PLC_CONFIG_EDIT")
            {
                PLCParameUPD[] dataEntity;
                dataEntity = jsc.Deserialize<PLCParameUPD[]>(RequstString("ListJson"));
                ResultMsg result = new ResultMsg();
                result = editPlcParameDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "MES_PLC_PARAMETERS_SEND")
            {
                List<PLCParame> paramlist = new List<PLCParame>();
                PLCParame[] dataEntity;
                dataEntity = jsc.Deserialize<PLCParame[]>(RequstString("ListJson"));
                ResultMsg_PLCSend result = new ResultMsg_PLCSend();
                result = sendPlcParameDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "MES_PLC_PARAMETERS_SEND_STATUS")
            {
                ResultMsg_PLCStatus result = new ResultMsg_PLCStatus();
                result.PlcList = new List<PLCEntity>();
                result = GetPLCSendStatusList(result.PlcList, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else
            {
                ResultMsg_Line result = new ResultMsg_Line();
                result.result = "error";
                result.msg = "系统暂时无法处理您的操作请求！";
                context.Response.Write(jsc.Serialize(result));
            }
            context.Response.End();
        }

        public List<CustomerEntity> GetCustomerListObj(List<CustomerEntity> dataEntity)
        {
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = "select * from Mes_Customer_List Order by CustomerID";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                for (int i = 0; i < dt.Rows.Count; i++ )
                {
                    CustomerEntity dataItem = new CustomerEntity();
                    dataItem.CustomerID = dt.Rows[i]["CustomerID"].ToString();
                    dataItem.CustomerName = dt.Rows[i]["CustomerName"].ToString();
                    dataItem.CustomerLogo = dt.Rows[i]["CustomerLogo"].ToString();
                    dataEntity.Add(dataItem);
                }
            }
            return dataEntity;
        }

        public CustomerEntity GetCustomerDetailObj(CustomerEntity dataEntity, CustomerEntity findItem)
        {

            DataTable dt = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                string strSql = string.Format("SELECT * FROM Mes_Customer_List WHERE CustomerID = {0}", findItem.CustomerID);
                cmd.Connection = conn;                
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = strSql;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null && dt.Rows.Count > 0)
                {
                    dataEntity.CustomerName = dt.Rows[0]["CustomerName"].ToString();
                    dataEntity.CustomerLogo = dt.Rows[0]["CustomerLogo"].ToString();
                }
            }
            return dataEntity;
        }

        public ResultMsg_Customer editCustomerDataInDB(CustomerEntity dataEntity, ResultMsg_Customer result)
        {
            if(dataEntity.CustomerID.Length   == 0) dataEntity.CustomerID   = "0";
            if(dataEntity.CustomerName.Length == 0) dataEntity.CustomerName = "";
            if(dataEntity.CustomerLogo.Length == 0) dataEntity.CustomerLogo = "";
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
                    strSql = string.Format(@"UPDATE Mes_Customer_List SET CustomerName = '{0}', CustomerLogo = N'{1}' WHERE CustomerID = {2}",
                                           dataEntity.CustomerName,
                                           dataEntity.CustomerLogo,
                                           dataEntity.CustomerID );
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = strSql;
                    cmd.ExecuteNonQuery();

                    string strFileMoveResult = "";
                    
                    strFileMoveResult = doFileMove(dataEntity.UploadedFile, dataEntity.CustomerID);
                    if (strFileMoveResult.Length == 0)
                    {
                        transaction.Commit();
                        result.result = "success";
                        result.msg = "保存数据成功!";
                    }
                    else
                    {
                        transaction.Rollback();
                        result.result = "failed";
                        result.msg = "服务器端文件处理发生错误.\n" + strFileMoveResult;
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

        public ResultMsg_Customer addCustomerDataInDB(CustomerEntity dataEntity, ResultMsg_Customer result)
        {
            if (dataEntity.CustomerID.Length   == 0) dataEntity.CustomerID   = "0";
            if (dataEntity.CustomerName.Length == 0) dataEntity.CustomerName = "";
            if (dataEntity.CustomerLogo.Length == 0) dataEntity.CustomerLogo = "";

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                SqlTransaction transaction = null;
                try
                {
                    conn.Open();
                    cmd.Connection = conn;
                    string strSql = " ";


                    transaction = conn.BeginTransaction();
                    cmd.Transaction = transaction;
                    strSql = string.Format(
                        @" INSERT INTO Mes_Customer_List  
                    (  CustomerName, CustomerLogo) VALUES (
                        N'{0}',N'{1}') ", dataEntity.CustomerName, dataEntity.CustomerLogo );
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = strSql;
                    cmd.ExecuteNonQuery();

                    cmd.CommandText = "select SCOPE_IDENTITY() AS CustomerID";
                    SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    Datapter.Fill(dt);

                    dataEntity.CustomerID = dt.Rows[0]["CustomerID"].ToString();

                    string strFileMoveResult = "";
                    strFileMoveResult = doFileMove(dataEntity.UploadedFile, dataEntity.CustomerID);
                    if (strFileMoveResult.Length == 0)
                    {
                        transaction.Commit();
                        result.result = "success";
                        result.msg = "保存数据成功!";
                    }
                    else
                    {
                        transaction.Rollback();
                        result.result = "failed";
                        result.msg = "服务器端文件处理发生错误.\n" + strFileMoveResult;
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

        public ResultMsg_Line readLineEntityDataInDB(LineEntity dataEntity, ResultMsg_Line result)
        {

            DataTable dt = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = "select * from Mes_Line_List";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null && dt.Rows.Count > 0)
                {
                    dataEntity.LineCode = dt.Rows[0]["LineCode"].ToString();
                    dataEntity.LineName = dt.Rows[0]["LineName"].ToString();
                    dataEntity.ShiftHours = dt.Rows[0]["ShiftHours"].ToString();
                    dataEntity.LineCapacity = dt.Rows[0]["LineCapacity"].ToString();
                    dataEntity.LineHeadCount = dt.Rows[0]["LineHeadCount"].ToString();
                    dataEntity.LineDsca = dt.Rows[0]["LineDsca"].ToString();
                    result.result = "success";
                    result.msg = "获取数据成功!";
                    result.data = dataEntity;
                }
                else
                {
                    result.result = "failed";
                    result.msg = "获取数据失败!";
                }
            } 
            return result;
        }

        public ResultMsg_Line saveLineEntityDataInDB(LineEntity dataEntity, ResultMsg_Line result)
        {
            if (dataEntity.LineCode.Length == 0) dataEntity.LineCode = "";
            if (dataEntity.LineName.Length == 0) dataEntity.LineName = "";
            if (dataEntity.ShiftHours.Length == 0) dataEntity.ShiftHours = "";
            if (dataEntity.LineCapacity.Length == 0) dataEntity.LineCapacity = "";
            if (dataEntity.LineHeadCount.Length == 0) dataEntity.LineHeadCount = "";
            if (dataEntity.LineDsca.Length == 0) dataEntity.LineDsca = "";

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
                    string strSql = string.Format(" update Mes_Line_List set LineCode='{0}', LineName=N'{1}', ShiftHours={2}, LineCapacity={3}, LineHeadCount={4}, LineDsca=N'{5}', UpdateUser=N'{6}', UpdateTime=getdate()  ",
                        dataEntity.LineCode ,
                        dataEntity.LineName ,
                        dataEntity.ShiftHours , 
                        dataEntity.LineCapacity, 
                        dataEntity.LineHeadCount,
                        dataEntity.LineDsca,
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

        public ResultMsg_Process editProcessDataInDB(ProcessEntity dataEntity, ResultMsg_Process result)
        {
            if(dataEntity.ID.Length           == 0 ) dataEntity.ID            = "0";           
            if(dataEntity.ProcessCode.Length  == 0 ) dataEntity.ProcessCode   = "";
            if(dataEntity.ProcessName.Length  == 0 ) dataEntity.ProcessName   = "";
            if(dataEntity.ProcessBeat.Length  == 0 ) dataEntity.ProcessBeat   = "";
            if(dataEntity.ProcessDsca.Length  == 0 ) dataEntity.ProcessDsca   = "";
            if (dataEntity.InturnNumber.Length== 0 ) dataEntity.InturnNumber  = "0";
            if(dataEntity.ProcessManual.Length== 0 ) dataEntity.ProcessManual = "";
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                SqlTransaction transaction = null;
                try
                {
                    conn.Open();
                    cmd.Connection = conn;

                    string strSql = " SELECT COUNT(1) AS SM FROM Mes_Process_List WHERE ProcessCode = '" + dataEntity.ProcessCode + "' and ID <> " + dataEntity.ID;
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
                            result.msg = "此工序编号已经存在, 请核对!";
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
                                              @"UPDATE Mes_Process_List 
                                                SET 
                                                     ProcessCode   =  '{0}' 
                                                    ,ProcessName   = N'{1}'
                                                    ,ProcessBeat   =   {2}
                                                    ,ProcessDsca   = N'{3}'
                                                    ,InturnNumber  =   {4}
                                                    ,ProcessManual = N'{5}'
                                                    ,UpdateUser    = N'{6}'
                                                    ,UpdateTime    = GETDATE()
                                                WHERE id = {7}
                                            ",
                                                    dataEntity.ProcessCode,
                                                    dataEntity.ProcessName,
                                                    dataEntity.ProcessBeat,
                                                    dataEntity.ProcessDsca,
                                                    dataEntity.InturnNumber,
                                                    dataEntity.ProcessManual,
                                                    UserName,
                                                    dataEntity.ID
                                    );
                        cmd.CommandType = CommandType.Text;
                        cmd.CommandText = strSql;
                        cmd.ExecuteNonQuery();

                        string strFileMoveResult = "";
                        strFileMoveResult = doFileMove(dataEntity.UploadedFile, dataEntity.ProcessCode);
                        if (strFileMoveResult.Length == 0)
                        {
                            transaction.Commit();
                            result.result = "success";
                            result.msg = "保存数据成功!";
                        }
                        else
                        {
                            transaction.Rollback();
                            result.result = "failed";
                            result.msg = "服务器端文件处理发生错误.\n" + strFileMoveResult;
                        }
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

        public ResultMsg_Process addProcessDataInDB(ProcessEntity dataEntity, ResultMsg_Process result)
        {
            if (dataEntity.ProcessCode.Length == 0)   dataEntity.ProcessCode   = "";
            if (dataEntity.ProcessName.Length == 0)   dataEntity.ProcessName   = "";
            if (dataEntity.ProcessBeat.Length == 0)   dataEntity.ProcessBeat   = "";
            if (dataEntity.ProcessDsca.Length == 0)   dataEntity.ProcessDsca   = "";
            if (dataEntity.InturnNumber.Length == 0)  dataEntity.InturnNumber  = "0";
            if (dataEntity.ProcessManual.Length == 0) dataEntity.ProcessManual = "";
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                SqlTransaction transaction = null;
                try
                {
                    conn.Open();
                    cmd.Connection = conn;
                    string strSql = " SELECT COUNT(1) AS SM FROM Mes_Process_List WHERE ProcessCode = '" + dataEntity.ProcessCode + "' ";
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
                            result.msg    = "此工序编号已经存在, 请核对!";
                        }
                        else
                        {
                            result.result = "";
                            result.msg    = "";
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
                            @" INSERT INTO Mes_Process_List  
                        (  ProcessCode, ProcessName, ProcessBeat, ProcessDsca, InturnNumber, ProcessManual, UpdateUser, UpdateTime) VALUES (
                          '{0}',N'{1}',{2},N'{3}',{4},N'{5}',N'{6}',getdate()) ",
                                dataEntity.ProcessCode,
                                dataEntity.ProcessName,
                                dataEntity.ProcessBeat,
                                dataEntity.ProcessDsca,
                                dataEntity.InturnNumber,
                                dataEntity.ProcessManual,
                                UserName
                            );
                        cmd.CommandType = CommandType.Text;
                        cmd.CommandText = strSql;
                        cmd.ExecuteNonQuery();

                        string strFileMoveResult = "";
                        strFileMoveResult = doFileMove(dataEntity.UploadedFile, dataEntity.ProcessCode);
                        if (strFileMoveResult.Length == 0)
                        {
                            transaction.Commit();
                            result.result = "success";
                            result.msg    = "保存数据成功!";
                        }
                        else
                        {
                            transaction.Rollback();
                            result.result = "failed";
                            result.msg    = "服务器端文件处理发生错误.\n" + strFileMoveResult;
                        }
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

        public ResultMsg_Process delProcessDataInDB(ProcessEntity dataEntity, ResultMsg_Process result)
        {
            if (dataEntity.ID.Length == 0) dataEntity.ID = "0";
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
                    string strSql = string.Format(" DELETE FROM Mes_Process_List WHERE ReservedFlag=0 and ID = {0}", dataEntity.ID);
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

        public List<ProcessEntity> GetProcessListObj(List<ProcessEntity> dataEntity, ProcessEntity findItem)
        {
            DataTable dt = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = " select * from Mes_Process_List ";
                string strWhere = "";
                if (findItem.ProcessCode != "" || findItem.ProcessName != "")
                {
                    if (findItem.ProcessCode != "")
                    {
                        strWhere = " ProcessCode = '" + findItem.ProcessCode + "' ";
                    }

                    if (findItem.ProcessName != "")
                    {
                        if (strWhere != "")
                        {
                            strWhere += " AND ";
                        }
                        strWhere += " ProcessName = N'" + findItem.ProcessName + "' ";
                    }

                    strWhere = " WHERE " + strWhere ;
                }

                str1 += strWhere + "  order by InturnNumber, ProcessCode ";                
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        ProcessEntity itemList = new ProcessEntity();
                        itemList.ID            = dt.Rows[i]["ID"].ToString();
                        itemList.InturnNumber  = dt.Rows[i]["InturnNumber"].ToString();
                        itemList.ProcessCode   = dt.Rows[i]["ProcessCode"].ToString();
                        itemList.ProcessName   = dt.Rows[i]["ProcessName"].ToString();
                        itemList.ProcessDsca   = dt.Rows[i]["ProcessDsca"].ToString();
                        itemList.ProcessBeat   = dt.Rows[i]["ProcessBeat"].ToString();
                        itemList.ProcessManual = dt.Rows[i]["ProcessManual"].ToString();
                        itemList.ReservedFlag  = dt.Rows[i]["ReservedFlag"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        public ProcessEntity GetProcessDetailObj(ProcessEntity dataEntity, ProcessEntity findItem)
        {
            DataTable dt = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string strSql = " select * from Mes_Process_List ";
                string strWhere = "";

                if (findItem.ID != "")
                {
                    strWhere = " WHERE ID = " + findItem.ID + " ";
                }

                strSql += strWhere + " order by InturnNumber, ProcessCode ";                
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = strSql;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null && dt.Rows.Count > 0)
                {
                    dataEntity.ID            = dt.Rows[0]["ID"].ToString();
                    dataEntity.InturnNumber  = dt.Rows[0]["InturnNumber"].ToString();
                    dataEntity.ProcessCode   = dt.Rows[0]["ProcessCode"].ToString();
                    dataEntity.ProcessName   = dt.Rows[0]["ProcessName"].ToString();
                    dataEntity.ProcessDsca   = dt.Rows[0]["ProcessDsca"].ToString();
                    dataEntity.ProcessBeat   = dt.Rows[0]["ProcessBeat"].ToString();
                    dataEntity.ProcessManual = dt.Rows[0]["ProcessManual"].ToString();
                    dataEntity.ReservedFlag  = dt.Rows[0]["ReservedFlag"].ToString();
                }
            }
            return dataEntity;
        }

        public List<GoodsEntity> GetGoodsListObj(List<GoodsEntity> dataEntity, GoodsEntity findItem)
        {
            DataTable dt = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = " select * from Mes_Goods_List ";
                string strWhere = "";
                if (   findItem.GoodsCode != ""
                    || findItem.DimLength != ""
                    || findItem.DimHeight != ""
                    || findItem.DimWidth  != ""
                    )
                {
                    if (findItem.GoodsCode != "")
                    {
                        strWhere = " GoodsCode = '" + findItem.GoodsCode + "' ";
                    }

                    if (findItem.DimLength != "")
                    {
                        if (strWhere != "")
                        {
                            strWhere += " AND ";
                        }
                        strWhere += " DimLength = " + findItem.DimLength + " ";
                    }

                    if (findItem.DimHeight != "")
                    {
                        if (strWhere != "")
                        {
                            strWhere += " AND ";
                        }
                        strWhere += " DimHeight = " + findItem.DimHeight + " ";
                    }

                    if (findItem.DimWidth != "")
                    {
                        if (strWhere != "")
                        {
                            strWhere += " AND ";
                        }
                        strWhere += " DimWidth = " + findItem.DimWidth + " ";
                    }
                    strWhere = " WHERE " + strWhere ;
                }

                str1 += strWhere + "  order by GoodsCode ";                
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        GoodsEntity itemList = new GoodsEntity();
                        itemList.ID            = dt.Rows[i]["ID"].ToString();
                        itemList.InturnNumber  = (i + 1).ToString();
                        itemList.GoodsCode     = dt.Rows[i]["GoodsCode"].ToString();
                        itemList.GoodsDsca     = dt.Rows[i]["GoodsDsca"].ToString();
                        itemList.DimLength     = dt.Rows[i]["DimLength"].ToString();
                        itemList.DimHeight     = dt.Rows[i]["DimHeight"].ToString();
                        itemList.DimWidth      = dt.Rows[i]["DimWidth"].ToString();
                        itemList.UnitCostTime  = dt.Rows[i]["UnitCostTime"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        public GoodsEntity GetGoodsDetailObj(GoodsEntity dataEntity, GoodsEntity findItem)
        {
            DataTable dt = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string strSql = " select * from Mes_Goods_List ";
                string strWhere = "";

                if (findItem.ID != "")
                {
                    strWhere = " WHERE ID = " + findItem.ID + " ";
                }

                strSql += strWhere + " order by GoodsCode ";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = strSql;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null && dt.Rows.Count > 0)
                {
                    dataEntity.ID           = dt.Rows[0]["ID"].ToString();
                    dataEntity.GoodsCode    = dt.Rows[0]["GoodsCode"].ToString();
                    dataEntity.GoodsDsca    = dt.Rows[0]["GoodsDsca"].ToString();
                    dataEntity.DimLength    = dt.Rows[0]["DimLength"].ToString();
                    dataEntity.DimHeight    = dt.Rows[0]["DimHeight"].ToString();
                    dataEntity.DimWidth     = dt.Rows[0]["DimWidth"].ToString();
                    dataEntity.UnitCostTime = dt.Rows[0]["UnitCostTime"].ToString();
                }
            }
            return dataEntity;
        }

        public ResultMsg_Goods editGoodsDataInDB(GoodsEntity dataEntity, ResultMsg_Goods result)
        {
            if (dataEntity.ID.Length == 0) dataEntity.ID = "0";
            if (dataEntity.GoodsCode.Length    == 0) dataEntity.GoodsCode    = "";
            if (dataEntity.GoodsDsca.Length    == 0) dataEntity.GoodsDsca    = "";
            if (dataEntity.DimLength.Length    == 0) dataEntity.DimLength    = "0";
            if (dataEntity.DimHeight.Length    == 0) dataEntity.DimHeight    = "0";
            if (dataEntity.DimWidth.Length     == 0) dataEntity.DimWidth     = "0";
            if (dataEntity.UnitCostTime.Length == 0) dataEntity.UnitCostTime = "2";
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

                    SqlParameter[] sqlPara = new SqlParameter[10];

                    sqlPara[0] = new SqlParameter("@GoodsCode", dataEntity.GoodsCode);
                    sqlPara[1] = new SqlParameter("@GoodsDsca", dataEntity.GoodsDsca);
                    sqlPara[2] = new SqlParameter("@DimLength", dataEntity.DimLength);
                    sqlPara[3] = new SqlParameter("@DimHeight", dataEntity.DimHeight);
                    sqlPara[4] = new SqlParameter("@DimWidth",  dataEntity.DimWidth);
                    sqlPara[5] = new SqlParameter("@UnitCostTime", dataEntity.UnitCostTime);
                    sqlPara[6] = new SqlParameter("@UpdateUser", UserName);
                    sqlPara[7] = new SqlParameter("@GoodsID",    dataEntity.ID);

                    sqlPara[8] = new SqlParameter("@CatchError", 0);
                    sqlPara[9] = new SqlParameter("@RtnMsg", "");

                    sqlPara[8].Direction = ParameterDirection.Output;
                    sqlPara[9].Direction = ParameterDirection.Output;
                    sqlPara[9].Size = 100;

                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandText = "usp_Mes_Goods_List_Edit";

                    foreach (SqlParameter para in sqlPara)
                    {
                        cmd.Parameters.Add(para);
                    }
                    cmd.ExecuteNonQuery();

                    if (sqlPara[8].Value.ToString() != "0")
                    {
                        transaction.Rollback();
                        result.result = "failed";
                        result.msg = sqlPara[9].Value.ToString();
                        cmd.Dispose();
                        return result;
                    }
                    else
                    {
                        transaction.Commit();
                        cmd.Dispose();
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

        public ResultMsg_Goods addGoodsDataInDB(GoodsEntity dataEntity, ResultMsg_Goods result)
        {
            if (dataEntity.GoodsCode.Length    == 0) dataEntity.GoodsCode = "";
            if (dataEntity.GoodsDsca.Length    == 0) dataEntity.GoodsDsca = "";
            if (dataEntity.DimLength.Length    == 0) dataEntity.DimLength = "0";
            if (dataEntity.DimHeight.Length    == 0) dataEntity.DimHeight = "0";
            if (dataEntity.DimWidth.Length     == 0) dataEntity.DimWidth  = "0";
            if (dataEntity.UnitCostTime.Length == 0) dataEntity.UnitCostTime = "2";
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

                    SqlParameter[] sqlPara = new SqlParameter[9];

                    sqlPara[0] = new SqlParameter("@GoodsCode",   dataEntity.GoodsCode);
                    sqlPara[1] = new SqlParameter("@GoodsDsca",   dataEntity.GoodsDsca);
                    sqlPara[2] = new SqlParameter("@DimLength",   dataEntity.DimLength);
                    sqlPara[3] = new SqlParameter("@DimHeight",   dataEntity.DimHeight);
                    sqlPara[4] = new SqlParameter("@DimWidth",    dataEntity.DimWidth);
                    sqlPara[5] = new SqlParameter("@UnitCostTime",dataEntity.UnitCostTime);
                    sqlPara[6] = new SqlParameter("@UpdateUser",  UserName);
                    sqlPara[7] = new SqlParameter("@CatchError",  0);
                    sqlPara[8] = new SqlParameter("@RtnMsg", "");

                    sqlPara[7].Direction = ParameterDirection.Output;
                    sqlPara[8].Direction = ParameterDirection.Output;
                    sqlPara[8].Size = 100;

                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandText = "usp_Mes_Goods_List_Add";

                    foreach (SqlParameter para in sqlPara)
                    {
                        cmd.Parameters.Add(para);
                    }
                    cmd.ExecuteNonQuery();

                    if (sqlPara[7].Value.ToString() != "0")
                    {
                        transaction.Rollback();
                        result.result = "failed";
                        result.msg = sqlPara[8].Value.ToString();
                        cmd.Dispose();
                        return result;
                    }
                    else
                    {
                        transaction.Commit();
                        cmd.Dispose();
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

        public ResultMsg_Goods delGoodsDataInDB(GoodsEntity dataEntity, ResultMsg_Goods result)
        {
            if (dataEntity.ID.Length == 0) dataEntity.ID = "0";
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

                    SqlParameter[] sqlPara = new SqlParameter[3];

                    sqlPara[0] = new SqlParameter("@GoodsID", dataEntity.ID);
                    sqlPara[1] = new SqlParameter("@CatchError", 0);
                    sqlPara[2] = new SqlParameter("@RtnMsg", "");

                    sqlPara[1].Direction = ParameterDirection.Output;
                    sqlPara[2].Direction = ParameterDirection.Output;
                    sqlPara[2].Size = 100;

                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandText = "usp_Mes_Goods_List_Delete";

                    foreach (SqlParameter para in sqlPara)
                    {
                        cmd.Parameters.Add(para);
                    }
                    cmd.ExecuteNonQuery();

                    if (sqlPara[1].Value.ToString() != "0")
                    {
                        transaction.Rollback();
                        result.result = "failed";
                        result.msg = sqlPara[2].Value.ToString();
                        cmd.Dispose();
                        return result;
                    }
                    else
                    {
                        transaction.Commit();
                        cmd.Dispose();
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

        public List<ThresholdEntity> GetThresholdListObj(List<ThresholdEntity> dataEntity, ThresholdEntity findItem)
        {
            DataTable dt = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;

                SqlParameter[] sqlPara = new SqlParameter[2];
                sqlPara[0] = new SqlParameter("@ItemNumber", findItem.ItemNumber);
                sqlPara[1] = new SqlParameter("@ProcessCode", findItem.ProcessCode);

                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Mes_Threshold_List";

                foreach (SqlParameter para in sqlPara)
                {
                    cmd.Parameters.Add(para);
                }
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        ThresholdEntity itemList = new ThresholdEntity();
                        itemList.ID           = (i + 1).ToString();
                        itemList.THID         = dt.Rows[i]["ID"].ToString();
                        itemList.ProcessCode  = dt.Rows[i]["ProcessCode"].ToString();
                        itemList.ProcessName  = dt.Rows[i]["ProcessName"].ToString();
                        itemList.ItemNumber   = dt.Rows[i]["ItemNumber"].ToString();
                        itemList.ItemName     = dt.Rows[i]["ItemName"].ToString();
                        itemList.MaxPullQty   = dt.Rows[i]["MaxPullQty"].ToString();
                        itemList.MinTrigQty   = dt.Rows[i]["MinTrigQty"].ToString();
                        itemList.UOM          = dt.Rows[i]["UOM"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        public ResultMsg_Threshold editThresholdDataInDB(ThresholdEntity dataEntity, ResultMsg_Threshold result)
        {
            if (dataEntity.THID.Length       == 0) dataEntity.THID       = "0";
            if (dataEntity.MaxPullQty.Length == 0) dataEntity.MaxPullQty = "0";
            if (dataEntity.MinTrigQty.Length == 0) dataEntity.MinTrigQty = "0";
            if (dataEntity.UOM.Length        == 0) dataEntity.UOM        = "个";
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                SqlTransaction transaction = null;
                try
                {
                    conn.Open();
                    cmd.Connection = conn;

                    string strSql = string.Empty;

                    transaction = conn.BeginTransaction();
                    cmd.Transaction = transaction;
                    strSql = string.Format(
                                @" UPDATE Mes_Threshold_List SET 
                                    MaxPullQty =   {0} 
                                , MinTrigQty   =   {1}
                                , UOM          = N'{2}'
                                , UpdateUser   = N'{3}'
                                , UpdateTime   = getdate()
                                WHERE id = {4} ",
                                    dataEntity.MaxPullQty,
                                    dataEntity.MinTrigQty,
                                    dataEntity.UOM,
                                    UserName,
                                    dataEntity.THID
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

        public List<PLCEntity> GetPLCObjList(List<PLCEntity> dataEntity)
        {
            string findGoodsCode  = RequstString("GoodsCode");
            string findSenderType = RequstString("SenderType");
            string ReturnValue = string.Empty;
            if (findSenderType == "") findSenderType = "VS";

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                //此处语句, 没有考虑新产品的情况, 需要设定PLC无产品设定情况下的模板数据.
                string strSql0 = string.Format("usp_Mes_Plc_List '{0}', '{1}' ", findGoodsCode, findSenderType);
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = strSql0;
                SqlDataAdapter Datapter0 = new SqlDataAdapter(cmd);
                DataTable dt0 = new DataTable();
                Datapter0.Fill(dt0);

                if (dt0 != null)
                {
                    for (int i = 0; i < dt0.Rows.Count; i++)
                    {
                        PLCEntity plc_entity   = new PLCEntity();
                        plc_entity.ID          = dt0.Rows[i]["ID"].ToString();
                        plc_entity.GoodsCode   = dt0.Rows[i]["GoodsCode"].ToString();
                        plc_entity.ProcessCode = dt0.Rows[i]["ProcessCode"].ToString();
                        plc_entity.ProcessName = dt0.Rows[i]["ProcessName"].ToString();
                        plc_entity.PLCCode     = dt0.Rows[i]["PLCCode"].ToString();
                        plc_entity.PLCName     = dt0.Rows[i]["PLCName"].ToString();
                        plc_entity.PLCType     = dt0.Rows[i]["PLCType"].ToString();
                        plc_entity.PLCCabinet  = dt0.Rows[i]["PLCCabinet"].ToString();
                        plc_entity.Parames     = new List<PLCParame>();

                        //如果是发送变更产品请求, 则就不需要获取PLC的详细参数清单了.
                        if (findSenderType == "VS")
                        {
                            string strSql1 = string.Format("usp_Mes_Plc_Parameters_List {0}", plc_entity.ID);
                            cmd.CommandType = CommandType.Text;
                            cmd.CommandText = strSql1;
                            SqlDataAdapter Datapter1 = new SqlDataAdapter(cmd);
                            DataTable dt1 = new DataTable();
                            Datapter1.Fill(dt1);
                            for (int j = 0; j < dt1.Rows.Count; j++)
                            {
                                PLCParame plc_parame   = new PLCParame();
                                plc_parame.ID          = dt1.Rows[j]["ID"].ToString();
                                plc_parame.PLCID       = dt1.Rows[j]["PLCID"].ToString();
                                plc_parame.ParamName   = dt1.Rows[j]["ParamName"].ToString();
                                plc_parame.ParamDsca   = dt1.Rows[j]["ParamDsca"].ToString();
                                plc_parame.ParamValue  = dt1.Rows[j]["ParamValue"].ToString();
                                plc_parame.ParamType   = dt1.Rows[j]["ParamType"].ToString();
                                plc_parame.OperateType = dt1.Rows[j]["OperateType"].ToString();
                                plc_parame.ItemNumber  = dt1.Rows[j]["ItemNumber"].ToString();
                                plc_entity.Parames.Add(plc_parame);
                            }
                            dt1.Clear();
                        }
                        dataEntity.Add(plc_entity);
                        //如下语句: 如果有连续调用datable的情况发生, 需要使用此语句进行清空, 否则会叠加.
                    }
                }
                dt0.Clear();
            }
            return dataEntity;
        }

        public List<PLCEntity> GetPlcPullObjList(List<PLCEntity> dataEntity)
        {
            string findGoodsCode   = RequstString("GoodsCode");
            string findProcessCode = RequstString("ProcessCode");
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                //此处语句, 没有考虑新产品的情况, 需要设定PLC无产品设定情况下的模板数据.
                string strSql0 = string.Format("usp_Mes_Plc_Pull_List '{0}', '{1}' ", findGoodsCode, findProcessCode);
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = strSql0;
                SqlDataAdapter Datapter0 = new SqlDataAdapter(cmd);
                DataTable dt0 = new DataTable();
                Datapter0.Fill(dt0);

                if (dt0 != null)
                {
                    for (int i = 0; i < dt0.Rows.Count; i++)
                    {
                        PLCEntity plc_entity = new PLCEntity();
                        plc_entity.ID          = dt0.Rows[i]["ID"].ToString();
                        plc_entity.GoodsCode   = dt0.Rows[i]["GoodsCode"].ToString();
                        plc_entity.ProcessCode = dt0.Rows[i]["ProcessCode"].ToString();
                        plc_entity.ProcessName = dt0.Rows[i]["ProcessName"].ToString();
                        plc_entity.PLCCode     = dt0.Rows[i]["PLCCode"].ToString();
                        plc_entity.PLCName     = dt0.Rows[i]["PLCName"].ToString();
                        plc_entity.PLCType     = dt0.Rows[i]["PLCType"].ToString();
                        plc_entity.PLCCabinet  = dt0.Rows[i]["PLCCabinet"].ToString();
                        plc_entity.Parames     = new List<PLCParame>();

                        string strSql1 = string.Format("usp_Mes_Plc_Pull_Parameters_List {0}", plc_entity.ID);
                        cmd.CommandType = CommandType.Text;
                        cmd.CommandText = strSql1;
                        SqlDataAdapter Datapter1 = new SqlDataAdapter(cmd);
                        DataTable dt1 = new DataTable();
                        Datapter1.Fill(dt1);
                        for (int j = 0; j < dt1.Rows.Count; j++)
                        {
                            PLCParame plc_parame = new PLCParame();
                            plc_parame.ID          = dt1.Rows[j]["ID"].ToString();
                            plc_parame.PLCID       = dt1.Rows[j]["PLCID"].ToString();
                            plc_parame.ParamName   = dt1.Rows[j]["ParamName"].ToString();
                            plc_parame.ParamDsca   = dt1.Rows[j]["ParamDsca"].ToString();
                            plc_parame.ParamValue  = dt1.Rows[j]["ParamValue"].ToString();
                            plc_parame.ParamType   = dt1.Rows[j]["ParamType"].ToString();
                            plc_parame.OperateType = dt1.Rows[j]["OperateType"].ToString();
                            plc_parame.ItemNumber  = dt1.Rows[j]["ItemNumber"].ToString();
                            plc_entity.Parames.Add(plc_parame);
                        }
                        dataEntity.Add(plc_entity);
                        //如下语句: 如果有连续调用datable的情况发生, 需要使用此语句进行清空, 否则会叠加.
                        dt1.Clear();
                    }
                }
            }
            return dataEntity;
        }

        public ResultMsg_PLCStatus GetPLCSendStatusList(List<PLCEntity> dataEntity, ResultMsg_PLCStatus result)
        {
            string BatchNo = RequstString("BatchNo");
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                try
                {
                    conn.Open();
                    cmd.Connection = conn;
                    string strSql0 = string.Format("usp_Mes_Plc_Send_Status '{0}'", BatchNo);
                    cmd.CommandType = CommandType.Text;
                    cmd.CommandText = strSql0;
                    SqlDataAdapter Datapter0 = new SqlDataAdapter(cmd);
                    DataTable dt0 = new DataTable();
                    Datapter0.Fill(dt0);
                    if (dt0 != null)
                    {
                        for (int i = 0; i < dt0.Rows.Count; i++)
                        {
                            PLCEntity plc_entity = new PLCEntity();
                            plc_entity.ID = dt0.Rows[i]["PLCID"].ToString();
                            plc_entity.StatusValue = dt0.Rows[i]["StatusValue"].ToString();
                            plc_entity.StatusTip = dt0.Rows[i]["StatusTip"].ToString();
                            plc_entity.Parames = new List<PLCParame>();

                            string strSql1 = string.Format("usp_Mes_Plc_Parameters_Send_Status {0}", plc_entity.ID);
                            cmd.CommandType = CommandType.Text;
                            cmd.CommandText = strSql1;
                            SqlDataAdapter Datapter1 = new SqlDataAdapter(cmd);
                            DataTable dt1 = new DataTable();
                            Datapter1.Fill(dt1);
                            for (int j = 0; j < dt1.Rows.Count; j++)
                            {
                                PLCParame plc_param   = new PLCParame();
                                plc_param.ID          = dt1.Rows[j]["ParamID"].ToString();
                                plc_param.ParamValue  = dt1.Rows[j]["ParamValue"].ToString();
                                plc_param.StatusValue = dt1.Rows[j]["StatusValue"].ToString();
                                plc_param.StatusTip   = dt1.Rows[j]["StatusTip"].ToString();
                                plc_entity.Parames.Add(plc_param);
                            }
                            dataEntity.Add(plc_entity);
                            //如下语句: 如果有连续调用datable的情况发生, 需要使用此语句进行清空, 否则会叠加.
                            dt1.Clear();
                        }
                        result.result = "success";
                        result.msg = "读取数据成功!";
                    }
                    else
                    {
                        result.result = "failed";
                        result.msg = "没有发现此批次的派发数据! \n";
                    }
                }
                catch (Exception ex)
                {
                    result.result = "failed";
                    result.msg = "读取数据失败! \n" + ex.Message;
                }
            }
            return result;
        }

        public ResultMsg editPlcParameDataInDB(PLCParameUPD[] dataEntity, ResultMsg result)
        {
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                SqlTransaction transaction = null;
                try
                {

                    string strSql = string.Empty;

                    for (int i = 0; i < dataEntity.Length; i++)
                    {
                        strSql += string.Format(
                                    @" UPDATE Mes_PLC_Parameters SET ParamValue = '{0}', UpdateUser = N'{1}', UpdateTime = getdate() where ID={2} ",
                                        dataEntity[i].PARAM_VALUE,                                        
                                        UserName,
                                        dataEntity[i].PARAM_ID
                                    );
                    }
                    conn.Open();
                    cmd.Connection = conn;
                    transaction = conn.BeginTransaction();
                    cmd.Transaction = transaction;
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

        public ResultMsg editPlcPullParameDataInDB(PLCParameUPD[] dataEntity, ResultMsg result)
        {
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                SqlTransaction transaction = null;
                try
                {

                    string strSql = string.Empty;

                    for (int i = 0; i < dataEntity.Length; i++)
                    {
                        strSql += string.Format(
                                    @" UPDATE Mes_PLC_Parameters SET ItemNumber = '{0}', UpdateUser = N'{1}', UpdateTime = getdate() where ID={2} ",
                                        dataEntity[i].PARAM_VALUE,                                        
                                        UserName,
                                        dataEntity[i].PARAM_ID
                                    );
                    }
                    conn.Open();
                    cmd.Connection = conn;
                    transaction = conn.BeginTransaction();
                    cmd.Transaction = transaction;
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

        public ResultMsg_PLCSend sendPlcParameDataInDB(PLCParame[] dataEntity, ResultMsg_PLCSend result)
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
                    string strPLCIDList = "";
                    string strSpliter = "";
                    string WorkOrderNumber = RequstString("WorkOrderNumber");
                    string WorkOrderVersion = RequstString("WorkOrderVersion");
                    string SenderType = RequstString("SenderType");
                    if (WorkOrderNumber.Length == 0) WorkOrderNumber = "";
                    if (WorkOrderVersion.Length == 0) WorkOrderVersion = "0";
                    if (SenderType.Length == 0) SenderType = "VS";
                    for (int i = 0; i < dataEntity.Length; i++)
                    {
                        strPLCIDList += strSpliter + dataEntity[i].PLCID;
                        strSpliter = ",";
                    }

                    SqlParameter[] sqlPara = new SqlParameter[9];
                    sqlPara[0] = new SqlParameter("@IDLIST",      strPLCIDList);
                    sqlPara[1] = new SqlParameter("@OperateUser", UserName);
                    sqlPara[2] = new SqlParameter("@WorkOrderNumber",  WorkOrderNumber);
                    sqlPara[3] = new SqlParameter("@WorkOrderVersion", Convert.ToInt32(WorkOrderVersion));
                    sqlPara[4] = new SqlParameter("@SenderType", SenderType);
                    sqlPara[5] = new SqlParameter("@BatchNo",    "");
                    sqlPara[6] = new SqlParameter("@ParamsCount", 0);
                    sqlPara[7] = new SqlParameter("@CatchError",  0);
                    sqlPara[8] = new SqlParameter("@RtnMsg",     "");

                    sqlPara[5].Direction = ParameterDirection.Output;
                    sqlPara[6].Direction = ParameterDirection.Output;
                    sqlPara[7].Direction = ParameterDirection.Output;
                    sqlPara[8].Direction = ParameterDirection.Output;
                    sqlPara[5].Size = 20;
                    sqlPara[8].Size = 100;

                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandText = "usp_Mes_Plc_Parameters_Send";

                    foreach (SqlParameter para in sqlPara)
                    {
                        cmd.Parameters.Add(para);
                    }
                    cmd.ExecuteNonQuery();

                    if (sqlPara[7].Value.ToString() != "0")
                    {
                        transaction.Rollback();
                        result.result = "failed";
                        result.msg    = sqlPara[8].Value.ToString();
                        cmd.Dispose();
                    }
                    else
                    {
                        result.BatchNo      = sqlPara[5].Value.ToString();
                        result.ParamesCount = sqlPara[6].Value.ToString();
                        result.result       = "success";
                        result.msg          = "读取(保存)数据成功!";
                        transaction.Commit();
                        cmd.Dispose();
                    }
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    cmd.Dispose();
                    result.result = "failed";
                    result.msg = "读取(保存)失败! \n" + ex.Message;
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

        public MesConfig ReadWriteMesConfig(MesConfig dataEntity)  
        {
            dataEntity.ID = RequstString("ID");
            dataEntity.ReadWriteFlag = RequstString("ReadWriteFlag");
            dataEntity.ParamName = RequstString("ParamName");
            dataEntity.ParamValue = RequstString("ParamValue");            
            if (dataEntity.ID.Length == 0) dataEntity.ID = "1";
            if (dataEntity.ReadWriteFlag.Length == 0) dataEntity.ReadWriteFlag = "READ"; //readwriteflag: READ; WRITE
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

                    SqlParameter[] sqlPara = new SqlParameter[7];

                    sqlPara[0] = new SqlParameter("@ReadWriteFlag", dataEntity.ReadWriteFlag);
                    sqlPara[1] = new SqlParameter("@ID", dataEntity.ID);
                    sqlPara[2] = new SqlParameter("@ParamName", dataEntity.ParamName);
                    sqlPara[3] = new SqlParameter("@InValue", dataEntity.ParamValue);
                    sqlPara[4] = new SqlParameter("@OutValue", dataEntity.ParamValue);
                    sqlPara[5] = new SqlParameter("@CatchError", 0);
                    sqlPara[6] = new SqlParameter("@RtnMsg", "");

                    sqlPara[4].Direction = ParameterDirection.Output;
                    sqlPara[4].Size = 20;

                    sqlPara[5].Direction = ParameterDirection.Output;
                    sqlPara[6].Direction = ParameterDirection.Output;
                    sqlPara[6].Size = 100;

                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandText = "usp_Mes_Config";

                    foreach (SqlParameter para in sqlPara)
                    {
                        cmd.Parameters.Add(para);
                    }
                    cmd.ExecuteNonQuery();

                    if (sqlPara[5].Value.ToString() != "0")
                    {
                        transaction.Rollback();
                        dataEntity.result = "failed";
                        dataEntity.msg    = sqlPara[6].Value.ToString();
                        cmd.Dispose();
                    }
                    else
                    {
                        dataEntity.ParamValue = sqlPara[4].Value.ToString();
                        dataEntity.result = "success";
                        dataEntity.msg = "读取(保存)数据成功!";
                        transaction.Commit();
                        cmd.Dispose();
                    }
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    cmd.Dispose();
                    dataEntity.result = "failed";
                    dataEntity.msg = "读取(保存)失败! \n" + ex.Message;
                }
            }
            return dataEntity;
        }

        public string GetProcessManualFileNameFromDB(string objID)
        {
            DataTable dt = new DataTable();
            string ReturnValue = string.Empty;

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str = " select top 1 ProcessCode, ProcessManual from Mes_Process_List ";
                string strWhere = "";
                if (objID.Length>0)
                {
                    strWhere = " WHERE ID = " + objID ;
                }
                str += strWhere;                
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null && dt.Rows.Count>0)
                {
                    ReturnValue = dt.Rows[0]["ProcessCode"].ToString() + Path.GetExtension(dt.Rows[0]["ProcessManual"].ToString());
                }
            }

        //    ReturnValue = "./ProcessManual/" + ReturnValue + Path.GetExtension(dt.Rows[0]["ProcessManual"].ToString());
            return ReturnValue;
        }

        public bool setFilePath(string filePath, bool isBrowsePath = true)
        {
            string tmpPath;
            tmpPath = filePath.Trim();
            if (tmpPath.Length == 0)
            {
                return false;
            }
            if (tmpPath.Substring(tmpPath.Length - 1) != "\\" && tmpPath.Substring(tmpPath.Length - 1) != "/")
            {
                tmpPath += "\\";
            }
            if (isBrowsePath)
                browseFilePath = tmpPath;
            else
                uploadFilePath = tmpPath;

            return true;
        }

        public string doFileMove(string sourceFileName, string destinationFileName)
        {
            string strReturn = "";
            try
            {
                string fileType = Path.GetExtension(sourceFileName).ToLower();
                string targetFileName = destinationFileName + fileType;
                if (sourceFileName.Length > 0)
                {
                    if (!Directory.Exists(browseFilePath))
                    {
                        Directory.CreateDirectory(browseFilePath);
                    }
                    if (File.Exists(browseFilePath + targetFileName))
                    {
                        File.Delete(browseFilePath + targetFileName);
                    }
                    File.Move(uploadFilePath + sourceFileName, browseFilePath + targetFileName);
                }
            }
            catch (Exception e)
            {
                strReturn = e.Message;
            }
            return strReturn;
        }

        public ResultMsg_FileUPload doUploadFile(ResultMsg_FileUPload result, HttpPostedFile file)
        {
            //判断文件是否为空               
            if (file != null)
            {
                string fileName = file.FileName;
                string fileType = Path.GetExtension(fileName).ToLower();

                //由于不同浏览器取出的FileName不同（有的是文件绝对路径，有的是只有文件名），故要进行处理
                if (fileName.IndexOf(' ') > -1)
                {
                    fileName = fileName.Substring(fileName.LastIndexOf(' ') + 1);
                }
                else if (fileName.IndexOf('/') > -1)
                {
                    fileName = fileName.Substring(fileName.LastIndexOf('/') + 1);
                }
                               
                if (!Directory.Exists(uploadFilePath))
                {
                    Directory.CreateDirectory(uploadFilePath);
                }
                result.sourceFileName = fileName;
                result.targetFileName = getTemporaryFileName(fileType);

                file.SaveAs(uploadFilePath + result.targetFileName);
                result.result = "success";
                result.msg    = "上传成功";
            }
            else
            {
                result.result = "failed";
                result.msg    = "上传失败";
                result.sourceFileName = "";
                result.targetFileName = "";
            }
            return result;
        }

        public string getTemporaryFileName(string fileType)
        {
            const int RANDOM_MAX_VALUE = 100000;
            string strTemp, strYear, strMonth, strDay, strHour, strMinute, strSecond, strMillisecond;
          
            Random rnd = new Random(); //获取一个随机数
            DateTime dt = DateTime.Now;

            int rndNumber = rnd.Next(RANDOM_MAX_VALUE);

            strYear = dt.Year.ToString();
            strMonth = (dt.Month > 9) ? dt.Month.ToString() : "0" + dt.Month.ToString();
            strDay = (dt.Day > 9) ? dt.Day.ToString() : "0" + dt.Day.ToString();
            strHour = (dt.Hour > 9) ? dt.Hour.ToString() : "0" + dt.Hour.ToString();
            strMinute = (dt.Minute > 9) ? dt.Minute.ToString() : "0" + dt.Minute.ToString();
            strSecond = (dt.Second > 9) ? dt.Second.ToString() : "0" + dt.Second.ToString();
            strMillisecond = dt.Millisecond.ToString();

            strTemp = strYear 
                + strMonth + "_"
                + strDay + "_" 
                + strHour + "_"
                + strMinute + "_"
                + strSecond + "_" 
                + strMillisecond + "_" 
                + rndNumber.ToString();

            return strTemp + fileType;
        }
    }

    public class CustomerEntity
    {
        public string CustomerID      { set; get; }
        public string CustomerName    { set; get; }
        public string CustomerLogo    { set; get; }
        public string UploadedFile    { set; get; }
    }

    public class LineEntity
    {
        public string LineCode      { set; get; }
        public string LineName      { set; get; }
        public string ShiftHours    { set; get; }
        public string LineCapacity  { set; get; }
        public string LineHeadCount { set; get; }
        public string LineDsca      { set; get; }
    }

    public class ProcessEntity
    {
        public string ID              { set; get; }
        public string InturnNumber    { set; get; }
        public string ProcessCode     { set; get; }
        public string ProcessName     { set; get; }
        public string ProcessDsca     { set; get; }
        public string ProcessBeat     { set; get; }
        public string ProcessManual   { set; get; }
        public string UploadedFile    { set; get; }
        public string ReservedFlag    { set; get; }
        public string WorkOrderNumber { set; get; }
        public string WorkOrderVersion{ set; get; }
    }

    public class GoodsEntity
    {
        public string ID            { set; get; }
        public string InturnNumber  { set; get; }
        public string GoodsCode     { set; get; }
        public string GoodsDsca     { set; get; }
        public string DimLength     { set; get; }
        public string DimHeight     { set; get; }
        public string DimWidth      { set; get; }
        public string UnitCostTime  { set; get; }
    }

    public class ThresholdEntity
    {
        public string ID           { set; get; }
        public string THID         { set; get; }
        public string ProcessCode  { set; get; }
        public string ProcessName  { set; get; }
        public string ItemNumber   { set; get; }
        public string ItemName     { set; get; }
        public string MaxPullQty   { set; get; }
        public string MinTrigQty   { set; get; }
        public string UOM          { set; get; }
    }

    public class PLCEntity
    {
        public string ID               { set; get; }              
        public string GoodsCode        { set; get; }
        public string ProcessCode      { set; get; }
        public string ProcessName      { set; get; }       
        public string PLCCode          { set; get; }       
        public string PLCName          { set; get; }       
        public string PLCType          { set; get; }
        public string PLCModel         { set; get; }
        public string PLCCabinet       { set; get; }       
        public string UpdateUser       { set; get; }          
        public string UpdateTime       { set; get; }         
        public string DownloadTime     { set; get; }       
        public string FeedBackTime     { set; get; }
        public string DownloadFlag     { set; get; }
        public string StatusValue      { set; get; } 
        public string StatusTip        { set; get; } 
        public List<PLCParame> Parames { set; get; }
    }

    public class PLCParame
    {
        public string ID          { set; get; } 
        public string PLCID       { set; get; }    
        public string ParamName   { set; get; }
        public string ParamDsca   { set; get; }
        public string ParamValue  { set; get; }
        public string ParamType   { set; get; }
        public string OperateType { set; get; }
        public string ItemNumber  { set; get; }
        public string StatusValue { set; get; }
        public string StatusTip { set; get; }
    }

    public class PLCParameUPD
    {
        public string PARAM_ID    { set; get; }
        public string PARAM_VALUE { set; get; }
    }

    public class ResultMsg_Customer
    {
        public string result { set; get; }
        public string msg    { set; get; }
        public CustomerEntity data { set; get; } 
    }

    public class ResultMsg_Line
    {
        public string result { set; get; }
        public string msg    { set; get; }
        public LineEntity data { set; get; } 
    }

    public class ResultMsg_Process
    {
        public string result { set; get; }
        public string msg { set; get; }
        public ProcessEntity data { set; get; }
    }

    public class ResultMsg_Goods
    {
        public string result { set; get; }
        public string msg { set; get; }
        public GoodsEntity data { set; get; }
    }       

    public class ResultMsg_Threshold
    {
        public string result { set; get; }
        public string msg { set; get; }
        public ThresholdEntity data { set; get; }
    }
       
    public class ResultMsg_FileUPload
    {
        public string result { set; get; }
        public string msg { set; get; }
        public string sourceFileName { set; get; }
        public string targetFileName { set; get; }
    }

    public class ResultMsg_PLCSend
    {
        public string result { set; get; }
        public string msg { set; get; }
        public string BatchNo { set; get; }
        public string ParamesCount { set; get; }
    }

    public class ResultMsg_PLCStatus
    {
        public string result { set; get; }
        public string msg { set; get; }
        public List<PLCEntity> PlcList { set; get; }
    }

    public class ResultMsg
    {
        public string result { set; get; }
        public string msg { set; get; }
    }

    public class MesConfig
    {
        public string ID { set; get; }
        public string ReadWriteFlag { set; get; }
        public string ParamName { set; get; }
        public string ParamValue { set; get; }
        public string result { set; get; }  //保存或读取结果的状态标志
        public string msg { set; get; }     //保存或读取结果的消息文字提示
    }

}