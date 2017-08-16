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
using LiNuoMes.BaseConfig;


namespace LiNuoMes.Mfg
{
    /// <summary>
    /// GetSetBaseConfig 的摘要说明
    /// </summary>
    public class GetSetMfg : IHttpHandler, IReadOnlySessionState
    {
        JavaScriptSerializer jsc = new JavaScriptSerializer();
        string UserName = "";
        string Action   = "";
        string uploadFilePath = HttpContext.Current.Server.MapPath("\\Mfg\\TemporaryFile\\");
        string browseFilePath = HttpContext.Current.Server.MapPath("\\Mfg\\LogoFile\\");
        GetSetBaseConfig gbs = new GetSetBaseConfig();

        public void ProcessRequest(HttpContext context)
        {
            gbs.setFilePath(uploadFilePath, false);
            gbs.setFilePath(browseFilePath, true);

            context.Response.ContentType = "text/plain";
            if (context.Session["UserName"] != null)
                UserName = context.Session["UserName"].ToString().ToUpper().Trim();
            else
                UserName = "";

            Action = RequstString("Action");

            if (Action.Length == 0 ) Action = "";

            if (Action == "MFG_PM_PLAN_LIST")
            {
                List<PmPlanEntity> dataEntity;
                dataEntity = new List<PmPlanEntity>();
                dataEntity = getPmPlanListObj(dataEntity);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "MFG_WO_MTL_LIST")
            {
                List<WoMtlEntity> dataEntity;
                dataEntity = new List<WoMtlEntity>();
                dataEntity = getWoMtlListObj(dataEntity);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "MFG_WO_LIST")
            {
                List<WoEntity> dataEntity;
                dataEntity = new List<WoEntity>();
                dataEntity = getWoList(dataEntity);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "MFG_WO_LIST_ROC")
            {
                List<WoEntity> dataEntity;
                dataEntity = new List<WoEntity>();
                dataEntity = getWoRocList(dataEntity);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "MFG_WO_LIST_SUBPLAN")
            {
                List<WoEntity> dataEntity;
                dataEntity = new List<WoEntity>();
                dataEntity = getWoSubPlanList(dataEntity);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "MFG_WIP_DATA_ABNORMAL")
            {
                List<WipAbnormalEntity> dataEntity;
                dataEntity = new List<WipAbnormalEntity>();
                dataEntity = getWipAbnormalList(dataEntity);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "MFG_WIP_DATA_ABNORMAL_POINT")
            {
                List<WipAbnormalPoint> dataEntity;
                dataEntity = new List<WipAbnormalPoint>();
                dataEntity = getWipAbnormalPointList(dataEntity);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "MFG_WIP_DATA_ABNORMAL_PRODUCT")
            {
                List<WipAbnormalProduct> dataEntity;
                dataEntity = new List<WipAbnormalProduct>();
                dataEntity = getWipAbnormalProductList(dataEntity);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "MFG_WIP_DATA_ABNORMAL_REASON")
            {
                List<WipAbnormalReason> dataEntity;
                dataEntity = new List<WipAbnormalReason>();
                dataEntity = getWipAbnormalReasonList(dataEntity);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "MFG_WIP_DATA_ABNORMAL_MTL")
            {
                List<WipAbnormalMtlEntity> dataEntity;
                dataEntity = new List<WipAbnormalMtlEntity>();
                dataEntity = getWipAbnormalMtlList(dataEntity);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "WIP_ABNORMAL_MTL_SUMMARY")
            {
                List<WipAbnormalMtlEntity> dataEntity;
                dataEntity = new List<WipAbnormalMtlEntity>();
                dataEntity = getWipAbnormalMtlSummaryList(dataEntity);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "MFG_WO_LIST_DETAIL")
            {
                WoEntity dataEntity;
                dataEntity = new WoEntity();
                dataEntity = getWoObjDetail(dataEntity);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "MFG_WIP_DATA_ABNORMAL_DETAIL")
            {
                WipAbnormalEntity dataEntity;
                dataEntity = new WipAbnormalEntity();
                dataEntity = getWipAbnormalDetail(dataEntity);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "MFG_WO_LIST_MVT")
            {
                ResultMsg result = new ResultMsg();
                result = setWOListMvt(result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "MFG_WO_LIST_INTURN_ADJUST")
            {
                ResultMsg result = new ResultMsg();
                result = setWOListInturn(result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "MFG_WO_LIST_EDIT" || Action == "MFG_WO_LIST_ADD")
            {
                WoEntity dataEntity = new WoEntity();
                ResultMsg result = new ResultMsg();
                result = saveWoDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "MFG_WO_LIST_ROC_EDIT")
            {
                WoEntity dataEntity = new WoEntity();
                ResultMsg result = new ResultMsg();
                result = saveWoRocDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "MFG_WIP_DATA_ABNORMAL_EDIT" || Action == "MFG_WIP_DATA_ABNORMAL_ADD")
            {
                WipAbnormalEntity dataEntity = new WipAbnormalEntity();
                ResultMsg result = new ResultMsg();
                result = saveWipAbnormalDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "MFG_WIP_DATA_ABNORMAL_MTL_EDIT" )
            {
                WipAbnormalMtlEntity[] dataEntity;
                dataEntity = jsc.Deserialize<WipAbnormalMtlEntity[]>(RequstString("ListJason"));
                ResultMsg result = new ResultMsg();
                result = saveWipAbnormalMtlDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "MFG_WO_MTL_LIST_ADD_SUBPLAN")
            {
                WipAbnormalMtlEntity[] dataEntity;
                dataEntity = jsc.Deserialize<WipAbnormalMtlEntity[]>(RequstString("ListJason"));
                ResultMsg result = new ResultMsg();
                result = saveWoMtlSubPlanDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "MFG_WO_LIST_DELETE")
            {
                WoEntity dataEntity = new WoEntity();
                ResultMsg result = new ResultMsg();
                result = deleteWoDataInDB(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else
            {
                ResultMsg result = new ResultMsg();
                result.result = "error";
                result.msg = "系统暂时无法处理您的操作请求！";
                context.Response.Write(jsc.Serialize(result));
            }
            context.Response.End();
        }

        public List<PmPlanEntity> getPmPlanListObj(List<PmPlanEntity> dataEntity)
        {
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_PMPlan_List_get_today";
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        PmPlanEntity itemList = new PmPlanEntity();
                        itemList.InturnNumber = (i + 1).ToString();
                        itemList.ProcessName  = dt.Rows[i]["ProcessName"].ToString(); 
                        itemList.DeviceName   = dt.Rows[i]["DeviceName"].ToString();
                        itemList.PmPlanName   = dt.Rows[i]["PmPlanName"].ToString();
                        itemList.PmFirstDate  = dt.Rows[i]["PmFirstDate"].ToString();
                        itemList.PmFinishDate = dt.Rows[i]["PmFinishDate"].ToString();
                        itemList.PmTimeUsage  = dt.Rows[i]["PmTimeUsage"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        public List<WoMtlEntity> getWoMtlListObj(List<WoMtlEntity> dataEntity)
        {
            String WoId = RequstString("WoId");
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Mfg_Wo_Mtl_List_OneWo";
                SqlParameter[] sqlPara = new SqlParameter[1];
                sqlPara[0] = new SqlParameter("@WOID", WoId);
                cmd.Parameters.Add(sqlPara[0]);
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        WoMtlEntity itemList = new WoMtlEntity();
                        itemList.InturnNumber = (i + 1).ToString();
                        itemList.LineNumber = dt.Rows[i]["LineNumber"].ToString();
                        itemList.ItemNumber = dt.Rows[i]["ItemNumber"].ToString();
                        itemList.ItemDsca = dt.Rows[i]["ItemDsca"].ToString();
                        itemList.Qty = dt.Rows[i]["Qty"].ToString();
                        itemList.UOM = dt.Rows[i]["UOM"].ToString();
                        itemList.ProcessCode = dt.Rows[i]["ProcessCode"].ToString();
                        itemList.WorkCenter = dt.Rows[i]["WorkCenter"].ToString();
                        itemList.WHLocation = dt.Rows[i]["WHLocation"].ToString();
                        itemList.Phantom = dt.Rows[i]["Phantom"].ToString();
                        itemList.Bulk = dt.Rows[i]["Bulk"].ToString();
                        itemList.Backflush = dt.Rows[i]["Backflush"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        public WoEntity getWoObjDetail(WoEntity dataEntity)
        {
            String WOID = RequstString("WoId");
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Mfg_Wo_List_one_detail";
                SqlParameter[] sqlPara = new SqlParameter[1];
                sqlPara[0] = new SqlParameter("@WOID", WOID);
                cmd.Parameters.Add(sqlPara[0]);
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                if (dt != null)
                {
                    dataEntity.WorkOrderNumber = dt.Rows[0]["WorkOrderNumber"].ToString();
                    dataEntity.GoodsCode = dt.Rows[0]["GoodsCode"].ToString();
                    dataEntity.WorkOrderType = dt.Rows[0]["WorkOrderType"].ToString();
                    dataEntity.PlanQty = dt.Rows[0]["PlanQty"].ToString();
                    dataEntity.PlanStartTime = dt.Rows[0]["PlanStartTime"].ToString();
                    dataEntity.DiscardQty = dt.Rows[0]["DiscardQty"].ToString();
                    dataEntity.LeftQty1 = dt.Rows[0]["LeftQty1"].ToString();
                    dataEntity.LeftQty2 = dt.Rows[0]["LeftQty2"].ToString();
                    dataEntity.PlanFinishTime = dt.Rows[0]["PlanFinishTime"].ToString();
                    dataEntity.UnitCostTime = dt.Rows[0]["UnitCostTime"].ToString();
                    dataEntity.CostTime = dt.Rows[0]["CostTime"].ToString();
                    dataEntity.CustomerID = dt.Rows[0]["CustomerID"].ToString();
                    dataEntity.OrderComment = dt.Rows[0]["OrderComment"].ToString();
                }
            }
            return dataEntity;
        }

        public WipAbnormalEntity getWipAbnormalDetail(WipAbnormalEntity dataEntity)
        {
            String AbId = RequstString("AbId");
            String RFID = RequstString("RFID");
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Mfg_Wip_Data_Abnormal_Detail";
                SqlParameter[] sqlPara = new SqlParameter[3];
                sqlPara[0] = new SqlParameter("@AbId", AbId);
                sqlPara[1] = new SqlParameter("@RFID", RFID);
                sqlPara[2] = new SqlParameter("@UserName", UserName);
                cmd.Parameters.Add(sqlPara[0]);
                cmd.Parameters.Add(sqlPara[1]);
                cmd.Parameters.Add(sqlPara[2]);
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                if (dt != null)
                {
                    if (dt.Rows.Count > 0)
                    {
                        dataEntity.WorkOrderNumber = dt.Rows[0]["WorkOrderNumber"].ToString();
                        dataEntity.GoodsCode = dt.Rows[0]["GoodsCode"].ToString();
                        dataEntity.RFID = dt.Rows[0]["RFID"].ToString();
                        dataEntity.AbnormalPoint = dt.Rows[0]["AbnormalPoint"].ToString();
                        dataEntity.AbnormalType = dt.Rows[0]["AbnormalType"].ToString();
                        dataEntity.AbnormalTime = dt.Rows[0]["AbnormalTime"].ToString();
                        dataEntity.AbnormalUser = dt.Rows[0]["AbnormalUser"].ToString();
                        dataEntity.AbnormalReason = dt.Rows[0]["AbnormalReason"].ToString();
                    }
                }
            }
            return dataEntity;
        }

        public List<WoEntity> getWoList(List<WoEntity> dataEntity)
        {
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Mfg_Wo_List_get_today";
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        WoEntity itemList = new WoEntity();
                        itemList.ID = dt.Rows[i]["ID"].ToString();
                        itemList.InturnNumber = ( i + 1 ).ToString(); 
                        itemList.WorkOrderNumber = dt.Rows[i]["WorkOrderNumber"].ToString();
                        itemList.WorkOrderVersion = dt.Rows[i]["WorkOrderVersion"].ToString();
                        itemList.GoodsCode = dt.Rows[i]["GoodsCode"].ToString();
                        itemList.PlanStartTime = dt.Rows[i]["PlanStartTime"].ToString();
                        itemList.PlanFinishTime = dt.Rows[i]["PlanFinishTime"].ToString();
                        itemList.CostTime = dt.Rows[i]["CostTime"].ToString();
                        itemList.PlanQty = dt.Rows[i]["PlanQty"].ToString();
                        itemList.WorkOrderType = dt.Rows[i]["WorkOrderType"].ToString();
                        itemList.FinishQty = dt.Rows[i]["FinishQty"].ToString();
                        itemList.StartPoint = dt.Rows[i]["StartPoint"].ToString();
                        itemList.Status = dt.Rows[i]["Status"].ToString();                      
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        public List<WoEntity> getWoRocList(List<WoEntity> dataEntity)
        {
            String WorkOrderNumber = RequstString("WorkOrderNumber");
            String PlanDate = RequstString("PlanDate");

            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Mfg_Wo_List_Roc";
                SqlParameter[] sqlPara = new SqlParameter[2];
                sqlPara[0] = new SqlParameter("@WorkOrderNumber", WorkOrderNumber);
                sqlPara[1] = new SqlParameter("@PlanDate", PlanDate);
                cmd.Parameters.Add(sqlPara[0]);
                cmd.Parameters.Add(sqlPara[1]);
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        WoEntity itemList = new WoEntity();
                        itemList.ID = dt.Rows[i]["ID"].ToString();
                        itemList.InturnNumber = ( i + 1 ).ToString(); 
                        itemList.WorkOrderNumber = dt.Rows[i]["WorkOrderNumber"].ToString();
                        itemList.PlanStartTime = dt.Rows[i]["PlanStartTime"].ToString();
                        itemList.WorkOrderType = dt.Rows[i]["WorkOrderType"].ToString();
                        itemList.PlanQty = dt.Rows[i]["PlanQty"].ToString();
                        itemList.FinishQty = dt.Rows[i]["FinishQty"].ToString();
                        itemList.EnableROC = dt.Rows[i]["EnableROC"].ToString();
                        itemList.ROCQty = dt.Rows[i]["ROCQty"].ToString();
                        itemList.ROCMsg = dt.Rows[i]["ROCMsg"].ToString();
                        itemList.Mes2ErpCfmQty = dt.Rows[i]["Mes2ErpCfmQty"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        public List<WoEntity> getWoSubPlanList(List<WoEntity> dataEntity)
        {
            DataTable dt = new DataTable();
            string WorkOrderNumber = RequstString("WorkOrderNumber");
            string PlanDate        = RequstString("PlanDate");
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Mfg_Wo_List_SubPlan";

                SqlParameter[] sqlPara = new SqlParameter[2];
                sqlPara[0] = new SqlParameter("@WorkOrderNumber", WorkOrderNumber);
                sqlPara[1] = new SqlParameter("@PlanDate",        PlanDate);
                cmd.Parameters.Add(sqlPara[0]);
                cmd.Parameters.Add(sqlPara[1]);

                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        WoEntity itemList = new WoEntity();
                        itemList.ID = dt.Rows[i]["ID"].ToString();
                        itemList.InturnNumber = ( i + 1 ).ToString(); 
                        itemList.WorkOrderNumber = dt.Rows[i]["WorkOrderNumber"].ToString();
                        itemList.WorkOrderVersion = dt.Rows[i]["WorkOrderVersion"].ToString();
                        itemList.GoodsCode = dt.Rows[i]["GoodsCode"].ToString();
                        itemList.WorkOrderType = dt.Rows[i]["WorkOrderType"].ToString();
                        itemList.PlanStartTime = dt.Rows[i]["PlanStartTime"].ToString();
                        itemList.PlanFinishTime = dt.Rows[i]["PlanFinishTime"].ToString();
                        itemList.PlanQty = dt.Rows[i]["PlanQty"].ToString();
                        itemList.DiscardQty = dt.Rows[i]["DiscardQty"].ToString();
                        itemList.LeftQty1 = dt.Rows[i]["LeftQty1"].ToString();
                        itemList.LeftQty2 = dt.Rows[i]["LeftQty2"].ToString();
                        itemList.Status = dt.Rows[i]["Status"].ToString();
                        itemList.SubPlanFlag = dt.Rows[i]["SubPlanFlag"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        public List<WipAbnormalEntity> getWipAbnormalList(List<WipAbnormalEntity> dataEntity)
        {
            DataTable dt = new DataTable();
            string RFID        = RequstString("RFID");
            string WorkOrderNumber = RequstString("WorkOrderNumber");
            string GoodsCode = RequstString("GoodsCode");
            string AbnormalPoint = RequstString("AbnormalPoint");
            string AbnormalType = RequstString("AbnormalType");
            string FromTime = RequstString("FromTime");
            string ToTime = RequstString("ToTime");

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Mfg_Wip_Data_Abnormal";
                SqlParameter[] sqlPara = new SqlParameter[7];
                sqlPara[0] = new SqlParameter("@RFID",        RFID);
                sqlPara[1] = new SqlParameter("@WorkOrderNumber", WorkOrderNumber);
                sqlPara[2] = new SqlParameter("@GoodsCode", GoodsCode);
                sqlPara[3] = new SqlParameter("@AbnormalPoint", AbnormalPoint);
                sqlPara[4] = new SqlParameter("@AbnormalType", AbnormalType);
                sqlPara[5] = new SqlParameter("@FromTime", FromTime);
                sqlPara[6] = new SqlParameter("@ToTime", ToTime);

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
                        WipAbnormalEntity itemList = new WipAbnormalEntity();
                        itemList.ID = dt.Rows[i]["ID"].ToString();
                        itemList.InturnNumber = ( i + 1 ).ToString(); 
                        itemList.WorkOrderNumber = dt.Rows[i]["WorkOrderNumber"].ToString();
                        itemList.RFID = dt.Rows[i]["RFID"].ToString();
                        itemList.GoodsCode = dt.Rows[i]["GoodsCode"].ToString();
                        itemList.AbnormalPoint = dt.Rows[i]["AbnormalPoint"].ToString();
                        itemList.AbnormalType = dt.Rows[i]["AbnormalType"].ToString();
                        itemList.AbnormalUser = dt.Rows[i]["AbnormalUser"].ToString();
                        itemList.AbnormalTime = dt.Rows[i]["AbnormalTime"].ToString();
                        itemList.SubPlanStatus = dt.Rows[i]["SubPlanStatus"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        public List<WipAbnormalPoint> getWipAbnormalPointList(List<WipAbnormalPoint> dataEntity)
        {
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandText = " SELECT * FROM MFG_WIP_Data_Abnormal_Point ORDER BY ID ";
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        WipAbnormalPoint itemList = new WipAbnormalPoint();
                        itemList.ID = dt.Rows[i]["ID"].ToString();
                        itemList.DisplayValue = dt.Rows[i]["DisplayValue"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        public List<WipAbnormalProduct> getWipAbnormalProductList(List<WipAbnormalProduct> dataEntity)
        {
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                String abPointID = RequstString("ABPOINTID");
                if (abPointID == "") abPointID = "0";
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandText = "exec usp_Mfg_Wip_Data_Abnormal_Product_List " + abPointID;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        WipAbnormalProduct itemList = new WipAbnormalProduct();
                        itemList.ID = dt.Rows[i]["ID"].ToString();
                        itemList.DisplayValue = dt.Rows[i]["DisplayValue"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        public List<WipAbnormalReason> getWipAbnormalReasonList(List<WipAbnormalReason> dataEntity)
        {
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                String abProduct = RequstString("ABPRODUCT");
                String AbId = RequstString("AbId");
                if (AbId == "") AbId = "0";
                if (abProduct == "") abProduct = "0";
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandText = "exec usp_Mfg_Wip_Data_Abnormal_Reason_List " + AbId + ", " + abProduct ;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        WipAbnormalReason itemList = new WipAbnormalReason();
                        itemList.TemplateID = dt.Rows[i]["TemplateID"].ToString();
                        itemList.DisplayValue = dt.Rows[i]["DisplayValue"].ToString();
                        itemList.RecordValue = dt.Rows[i]["RecordValue"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        public List<WipAbnormalMtlEntity> getWipAbnormalMtlList(List<WipAbnormalMtlEntity> dataEntity)
        {
            DataTable dt = new DataTable();
            string AbId = RequstString("AbId");
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Mfg_Wip_Data_Abnormal_Mtl";
                SqlParameter[] sqlPara = new SqlParameter[1];
                sqlPara[0] = new SqlParameter("@AbId", AbId);
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
                        WipAbnormalMtlEntity itemList = new WipAbnormalMtlEntity();
                        itemList.ID = dt.Rows[i]["ID"].ToString();
                        itemList.InturnNumber = ( i + 1 ).ToString(); 
                        itemList.ProcessCode = dt.Rows[i]["ProcessCode"].ToString();
                        itemList.ItemNumber = dt.Rows[i]["ItemNumber"].ToString();
                        itemList.UOM = dt.Rows[i]["UOM"].ToString();
                        itemList.LeftQty = dt.Rows[i]["LeftQty"].ToString();
                        itemList.RequireQty = dt.Rows[i]["RequireQty"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        public List<WipAbnormalMtlEntity> getWipAbnormalMtlSummaryList(List<WipAbnormalMtlEntity> dataEntity)
        {
            String WOID = RequstString("WoId");
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Mfg_Wip_Data_Abnormal_Mtl_List_Summary";

                SqlParameter[] sqlPara = new SqlParameter[1];
                sqlPara[0] = new SqlParameter("@WOID", WOID);
                cmd.Parameters.Add(sqlPara[0]);

                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        WipAbnormalMtlEntity itemList = new WipAbnormalMtlEntity();
                 //       itemList.ID = dt.Rows[i]["ID"].ToString();
                        itemList.InturnNumber = ( i + 1 ).ToString(); 
                        itemList.ProcessCode = dt.Rows[i]["ProcessCode"].ToString();
                        itemList.ItemNumber = dt.Rows[i]["ItemNumber"].ToString();
                        itemList.ItemDsca = dt.Rows[i]["ItemDsca"].ToString();
                        itemList.UOM = dt.Rows[i]["UOM"].ToString();
                        itemList.LeftQty = dt.Rows[i]["LeftQty"].ToString();
                        itemList.RequireQty = dt.Rows[i]["RequireQty"].ToString();
                        itemList.InventoryQty = dt.Rows[i]["InventoryQty"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        public ResultMsg saveWoDataInDB(WoEntity dataEntity, ResultMsg result)
        {
            dataEntity.ID = RequstString("WoId");
            dataEntity.UnitCostTime = RequstString("UnitCostTime");
            dataEntity.CostTime = RequstString("CostTime");
            dataEntity.PlanStartTime = RequstString("PlanStartTime");
            dataEntity.PlanFinishTime = RequstString("PlanFinishTime");
            dataEntity.CustomerID = RequstString("CustomerID");
            dataEntity.OrderComment = RequstString("OrderComment");
            dataEntity.UploadedFile = RequstString("UploadedFile");

            if (dataEntity.ID.Length == 0) dataEntity.ID = "0";
            if (dataEntity.UnitCostTime.Length == 0) dataEntity.UnitCostTime = "2";
            if (dataEntity.CostTime.Length == 0) dataEntity.CostTime = "0";
            if (dataEntity.PlanStartTime.Length == 0) dataEntity.PlanStartTime = "";
            if (dataEntity.PlanFinishTime.Length == 0) dataEntity.PlanFinishTime = "";
            if (dataEntity.CustomerID.Length == 0) dataEntity.CustomerID = "0";
            if (dataEntity.OrderComment.Length == 0) dataEntity.OrderComment = "";
            if (dataEntity.UploadedFile.Length == 0) dataEntity.UploadedFile = "";

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

                    sqlPara[0] = new SqlParameter("@WOID", Convert.ToInt32(dataEntity.ID));
                    sqlPara[1] = new SqlParameter("@UnitCostTime", Convert.ToInt32(dataEntity.UnitCostTime));
                    sqlPara[2] = new SqlParameter("@CostTime", Convert.ToInt32(dataEntity.CostTime));
                    sqlPara[3] = new SqlParameter("@PlanStartTime", Convert.ToDateTime(dataEntity.PlanStartTime));
                    sqlPara[4] = new SqlParameter("@PlanFinishTime", Convert.ToDateTime(dataEntity.PlanFinishTime));
                    sqlPara[5] = new SqlParameter("@CustomerID", Convert.ToInt32(dataEntity.CustomerID));
                    sqlPara[6] = new SqlParameter("@OrderComment", dataEntity.OrderComment);
                    sqlPara[7] = new SqlParameter("@CatchError", 0);
                    sqlPara[8] = new SqlParameter("@RtnMsg", "");

                    sqlPara[7].Direction = ParameterDirection.Output;
                    sqlPara[8].Direction = ParameterDirection.Output;
                    sqlPara[8].Size = 100;

                    cmd.CommandType = CommandType.StoredProcedure;

                    if (Action == "MFG_WO_LIST_EDIT")
                    { 
                        cmd.CommandText = "usp_Mfg_Wo_List_Edit";
                    }
                    else if (Action == "MFG_WO_LIST_ADD")
                    { 
                        //其实, 这种情况是不存在的: 因为,订单都是从ERP导入进来的.
                        cmd.CommandText = "usp_Mfg_Wo_List_Add";
                    }

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
                    //    string strFileMoveResult = "";
                    //    strFileMoveResult = gbs.doFileMove(dataEntity.UploadedFile, dataEntity.ID);
                    //    if (strFileMoveResult.Length == 0)
                    //    {
                            transaction.Commit();
                            result.result = "success";
                            result.msg = "保存数据成功!";
                            cmd.Dispose();
                    //    }
                    //    else
                    //    {
                    //        transaction.Rollback();
                    //        result.result = "failed";
                    //        result.msg = "服务器端文件处理发生错误.\n" + strFileMoveResult;
                    //    }
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

        public ResultMsg saveWoRocDataInDB(WoEntity dataEntity, ResultMsg result)
        {
            dataEntity.ID = RequstString("WoId");
            dataEntity.ROCQty = RequstString("ROCQty");

            if (dataEntity.ID.Length == 0) dataEntity.ID = "0";
            if (dataEntity.ROCQty.Length == 0) dataEntity.ROCQty = "0";

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

                    SqlParameter[] sqlPara = new SqlParameter[5];

                    sqlPara[0] = new SqlParameter("@WOID", Convert.ToInt32(dataEntity.ID));
                    sqlPara[1] = new SqlParameter("@ROCQty",    dataEntity.ROCQty);
                    sqlPara[2] = new SqlParameter("@UserName",  UserName);
                    sqlPara[3] = new SqlParameter("@CatchError", 0);
                    sqlPara[4] = new SqlParameter("@RtnMsg", "");

                    sqlPara[3].Direction = ParameterDirection.Output;
                    sqlPara[4].Direction = ParameterDirection.Output;
                    sqlPara[4].Size = 100;

                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandText = "usp_Mfg_Wo_List_Roc_Edit";

                    foreach (SqlParameter para in sqlPara)
                    {
                        cmd.Parameters.Add(para);
                    }

                    cmd.ExecuteNonQuery();

                    if (sqlPara[3].Value.ToString() != "0")
                    {
                        transaction.Rollback();
                        result.result = "failed";
                        result.msg = sqlPara[4].Value.ToString();
                        cmd.Dispose();
                        return result;
                    }
                    else
                    {
                        transaction.Commit();
                        result.result = "success";
                        result.msg = "保存数据成功!";
                        cmd.Dispose();
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

        public ResultMsg saveWipAbnormalDataInDB(WipAbnormalEntity dataEntity, ResultMsg result)
        {
            dataEntity.ID             = RequstString("AbId");
            dataEntity.RFID           = RequstString("RFID");
            dataEntity.AbnormalType   = RequstString("AbnormalType");
            dataEntity.AbnormalTime   = RequstString("AbnormalTime");
            dataEntity.AbnormalUser   = RequstString("AbnormalUser");
            dataEntity.AbnormalReason = RequstString("AbnormalReason");

            if (dataEntity.ID.Length == 0) dataEntity.ID = "0";
            if (dataEntity.RFID.Length == 0) dataEntity.RFID = "";
            if (dataEntity.AbnormalType.Length == 0) dataEntity.AbnormalType = "1";
            if (dataEntity.AbnormalTime.Length == 0) dataEntity.AbnormalTime = DateTime.Now.ToLocalTime().ToString(); ;
            if (dataEntity.AbnormalUser.Length == 0) dataEntity.AbnormalUser = UserName;
            if (dataEntity.AbnormalReason.Length == 0) dataEntity.AbnormalReason = "";

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

                    sqlPara[0] = new SqlParameter("@AbID", Convert.ToInt32(dataEntity.ID));
                    sqlPara[1] = new SqlParameter("@RFID", dataEntity.RFID);
                    sqlPara[2] = new SqlParameter("@AbnormalType", dataEntity.AbnormalType);
                    sqlPara[3] = new SqlParameter("@AbnormalTime", dataEntity.AbnormalTime);
                    sqlPara[4] = new SqlParameter("@AbnormalUser", dataEntity.AbnormalUser);
                    sqlPara[5] = new SqlParameter("@AbnormalReason", dataEntity.AbnormalReason);
                    sqlPara[6] = new SqlParameter("@UpdateUser", UserName);
                    sqlPara[7] = new SqlParameter("@CatchError", 0);
                    sqlPara[8] = new SqlParameter("@RtnMsg", "");

                    sqlPara[7].Direction = ParameterDirection.Output;
                    sqlPara[8].Direction = ParameterDirection.Output;
                    sqlPara[8].Size = 100;

                    cmd.CommandType = CommandType.StoredProcedure;

                    if (Action == "MFG_WIP_DATA_ABNORMAL_EDIT")
                    {
                        cmd.CommandText = "usp_Mfg_Wip_Data_Abnormal_Edit";
                    }
                    else if (Action == "MFG_WIP_DATA_ABNORMAL_ADD")
                    {
                        cmd.CommandText = "usp_Mfg_Wip_Data_Abnormal_Add";
                    }

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
                        result.result = "success";
                        result.msg = "保存数据成功!";
                        cmd.Dispose();
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

        public ResultMsg saveWipAbnormalMtlDataInDB(WipAbnormalMtlEntity[] dataEntity, ResultMsg result)
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
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandText = "usp_Mfg_Wip_Data_Abnormal_Mtl_Edit";

                    for (int i = 0; i < dataEntity.Length; i++)
                    {
                        SqlParameter[] sqlPara = new SqlParameter[6];

                        sqlPara[0] = new SqlParameter("@ID", Convert.ToInt32(dataEntity[i].ID));
                        sqlPara[1] = new SqlParameter("@LeftQty", dataEntity[i].LeftQty);
                        sqlPara[2] = new SqlParameter("@RequireQty", dataEntity[i].RequireQty);
                        sqlPara[3] = new SqlParameter("@UpdateUser", UserName);
                        sqlPara[4] = new SqlParameter("@CatchError", 0);
                        sqlPara[5] = new SqlParameter("@RtnMsg", "");

                        sqlPara[4].Direction = ParameterDirection.Output;
                        sqlPara[5].Direction = ParameterDirection.Output;
                        sqlPara[5].Size = 100;

                        cmd.Parameters.Clear();
                        foreach (SqlParameter para in sqlPara)
                        {
                            cmd.Parameters.Add(para);
                        }

                        cmd.ExecuteNonQuery();

                        if (sqlPara[4].Value.ToString() != "0")
                        {
                            transaction.Rollback();
                            result.result = "failed";
                            result.msg = sqlPara[5].Value.ToString();
                            cmd.Dispose();
                            return result;
                        }
                    }

                    transaction.Commit();
                    result.result = "success";
                    result.msg = "保存数据成功!";
                    cmd.Dispose();
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

        public ResultMsg saveWoMtlSubPlanDataInDB(WipAbnormalMtlEntity[] dataEntity, ResultMsg result)
        {
            String WoId = RequstString("WoId");
       //     String PlanQty = RequstString("PlanQty");

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
                    cmd.CommandType = CommandType.StoredProcedure;

                    cmd.CommandText = "usp_Mfg_Wo_List_Add_SubPlan";

                    String WorkOrderNumber = String.Empty;
                    int WorkOrderVersion = -1;

         //           sqlParaWo[1] = new SqlParameter("@PlanQty", PlanQty); //此项需要系统在后台自动计算, 无需用户计算得来.

                    SqlParameter[] sqlParaWo = new SqlParameter[6];
                    sqlParaWo[0] = new SqlParameter("@WoId", WoId);
                    sqlParaWo[1] = new SqlParameter("@UserName", UserName);
                    sqlParaWo[2] = new SqlParameter("@WorkOrderNumber", Convert.ToString(""));
                    sqlParaWo[3] = new SqlParameter("@WorkOrderVersion", Convert.ToInt32(-1));
                    sqlParaWo[4] = new SqlParameter("@CatchError", 0);
                    sqlParaWo[5] = new SqlParameter("@RtnMsg", "");

                    sqlParaWo[2].Direction = ParameterDirection.Output;
                    sqlParaWo[3].Direction = ParameterDirection.Output;
                    sqlParaWo[4].Direction = ParameterDirection.Output;
                    sqlParaWo[5].Direction = ParameterDirection.Output;
                    sqlParaWo[2].Size = 50;
                    sqlParaWo[5].Size = 100;

                    cmd.Parameters.Clear();
                    foreach (SqlParameter para in sqlParaWo)
                    {
                        cmd.Parameters.Add(para);
                    }

                    cmd.ExecuteNonQuery();

                    if (sqlParaWo[4].Value.ToString() != "0")
                    {
                        transaction.Rollback();
                        result.result = "failed";
                        result.msg = sqlParaWo[5].Value.ToString();
                        cmd.Dispose();
                        return result;
                    }

                    WorkOrderNumber = sqlParaWo[2].Value.ToString();
                    WorkOrderVersion = Convert.ToInt32(sqlParaWo[3].Value);

                    cmd.CommandText = "usp_Mfg_Wo_Mtl_List_Add_SubPlan";

                    for (int i = 0; i < dataEntity.Length; i++)
                    {
                        SqlParameter[] sqlPara = new SqlParameter[12];

                        sqlPara[ 0] = new SqlParameter("@WorkOrderNumber", WorkOrderNumber);  
                        sqlPara[ 1] = new SqlParameter("@WorkOrderVersion", WorkOrderVersion);
                        sqlPara[ 2] = new SqlParameter("@InturnNumber", Convert.ToInt32(dataEntity[i].InturnNumber));  //我们使用此列作为LineNumber值
                        sqlPara[ 3] = new SqlParameter("@ProcessCode", dataEntity[i].ProcessCode);
                        sqlPara[ 4] = new SqlParameter("@ItemNumber", dataEntity[i].ItemNumber);
                        sqlPara[ 5] = new SqlParameter("@ItemDsca", dataEntity[i].ItemDsca);
                        sqlPara[ 6] = new SqlParameter("@UOM", dataEntity[i].UOM);
                        sqlPara[ 7] = new SqlParameter("@LeftQty", Convert.ToDouble(dataEntity[i].LeftQty));
                        sqlPara[ 8] = new SqlParameter("@RequireQty", Convert.ToDouble(dataEntity[i].RequireQty));
                        sqlPara[ 9] = new SqlParameter("@UpdateUser", UserName);
                        sqlPara[10] = new SqlParameter("@CatchError", 0);
                        sqlPara[11] = new SqlParameter("@RtnMsg", "");

                        sqlPara[10].Direction = ParameterDirection.Output;
                        sqlPara[11].Direction = ParameterDirection.Output;
                        sqlPara[11].Size = 100;

                        cmd.Parameters.Clear();
                        foreach (SqlParameter para in sqlPara)
                        {
                            cmd.Parameters.Add(para);
                        }

                        cmd.ExecuteNonQuery();

                        if (sqlPara[10].Value.ToString() != "0")
                        {
                            transaction.Rollback();
                            result.result = "failed";
                            result.msg = sqlPara[11].Value.ToString();
                            cmd.Dispose();
                            return result;
                        }
                    }

                    transaction.Commit();
                    result.result = "success";
                    result.msg = "保存数据成功!";
                    cmd.Dispose();
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

        public ResultMsg deleteWoDataInDB(WoEntity dataEntity, ResultMsg result)
        {
            dataEntity.ID = RequstString("WoId");
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

                    sqlPara[0] = new SqlParameter("@WOID", Convert.ToInt32(dataEntity.ID));
                    sqlPara[1] = new SqlParameter("@CatchError", 0);
                    sqlPara[2] = new SqlParameter("@RtnMsg", "");

                    sqlPara[1].Direction = ParameterDirection.Output;
                    sqlPara[2].Direction = ParameterDirection.Output;
                    sqlPara[2].Size = 100;

                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandText = "usp_Mfg_Wo_List_Delete";

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

        public ResultMsg setWOListInturn(ResultMsg result)
        {
            String WOID = RequstString("WOID");
            String NBID = RequstString("NBID");
            String ADJDirection = RequstString("ADJDIRECTION");

            if (WOID.Length == 0) WOID = "0";
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

                    SqlParameter[] sqlPara = new SqlParameter[5];

                    sqlPara[0] = new SqlParameter("@WOID", Convert.ToInt32(WOID));
                    sqlPara[1] = new SqlParameter("@NBID", Convert.ToInt32(NBID));
                    sqlPara[2] = new SqlParameter("@ADJDirection", ADJDirection);
                    sqlPara[3] = new SqlParameter("@CatchError", 0);
                    sqlPara[4] = new SqlParameter("@RtnMsg", "");

                    sqlPara[3].Direction = ParameterDirection.Output;
                    sqlPara[4].Direction = ParameterDirection.Output;
                    sqlPara[4].Size = 100;

                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandText = "usp_Mfg_Wo_List_Adjust_inturn";

                    foreach (SqlParameter para in sqlPara)
                    {
                        cmd.Parameters.Add(para);
                    }
                    cmd.ExecuteNonQuery();

                    if (sqlPara[3].Value.ToString() != "0")
                    {
                        transaction.Rollback();
                        result.result = "failed";
                        result.msg = sqlPara[4].Value.ToString();
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

        public ResultMsg setWOListMvt(ResultMsg result)
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

                    SqlParameter[] sqlPara = new SqlParameter[2];

                    sqlPara[0] = new SqlParameter("@CatchError", 0);
                    sqlPara[1] = new SqlParameter("@RtnMsg", "");

                    sqlPara[0].Direction = ParameterDirection.Output;
                    sqlPara[1].Direction = ParameterDirection.Output;
                    sqlPara[1].Size = 100;

                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandText = "usp_Mfg_Wo_List_Mvt_Edit";

                    foreach (SqlParameter para in sqlPara)
                    {
                        cmd.Parameters.Add(para);
                    }

                    cmd.ExecuteNonQuery();

                    if (sqlPara[0].Value.ToString() != "0")
                    {
                        transaction.Rollback();
                        result.result = "failed";
                        result.msg = sqlPara[1].Value.ToString();
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

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }

        public static string RequstString(string sParam)
        {
            String ret = String.Empty;
            try
            {
                ret = (HttpContext.Current.Request[sParam] == null ? string.Empty
                      : HttpContext.Current.Request[sParam].ToString().Trim());
            }
            catch (Exception )
            {
                ret = "";
            }
            return ret;
        }
    }

    public class PmPlanEntity
    {
        public string ID           { set; get; }
        public string InturnNumber { set; get; }
        public string ProcessName  { set; get; }
        public string DeviceName   { set; get; }
        public string PmPlanName   { set; get; }
        public string PmFirstDate  { set; get; }
        public string PmFinishDate { set; get; }
        public string PmTimeUsage  { set; get; }
    }

    public class WoEntity
    {
        public string ID               { set; get; }
        public string InturnNumber     { set; get; }
        public string WorkOrderNumber  { set; get; }
        public string WorkOrderVersion { set; get; }
        public string GoodsCode        { set; get; }
        public string PlanStartTime    { set; get; }
        public string PlanFinishTime   { set; get; }
        public string CostTime         { set; get; }
        public string PlanQty          { set; get; }
        public string DiscardQty       { set; get; }
        public string LeftQty1         { set; get; }
        public string LeftQty2         { set; get; }
        public string WorkOrderType    { set; get; }
        public string FinishQty        { set; get; }
        public string StartPoint       { set; get; }
        public string Status           { set; get; }
        public string UnitCostTime     { set; get; }
        public string CustomerID       { set; get; }
        public string CustomerName     { set; get; }
        public string CustomerLogo     { set; get; }
        public string OrderComment     { set; get; }
        public string UploadedFile     { set; get; }
        public string SubPlanFlag      { set; get; }
        public string EnableROC        { set; get; }
        public string ROCQty           { set; get; }
        public string ROCMsg           { set; get; }
        public string Mes2ErpCfmQty    { set; get; }
    }

    public class WoMtlEntity
    {
        public string ID           { set; get; }
        public string InturnNumber { set; get; }
        public string LineNumber   { set; get; }
        public string ItemNumber   { set; get; }
        public string ItemDsca     { set; get; }
        public string Qty          { set; get; }
        public string UOM          { set; get; }
        public string ProcessCode  { set; get; }
        public string WorkCenter   { set; get; }
        public string WHLocation   { set; get; }
        public string Phantom      { set; get; }
        public string Bulk         { set; get; }
        public string Backflush    { set; get; }
    }

    public class WipAbnormalPoint
    {
        public string ID              { set; get; }
        public string DisplayValue    { set; get; }
    }

    public class WipAbnormalProduct
    {
        public string ID              { set; get; }
        public string DisplayValue    { set; get; }
    }

    public class WipAbnormalReason
    {
        public string TemplateID      { set; get; }
        public string DisplayValue    { set; get; }
        public string RecordValue     { set; get; }
    }

    public class WipAbnormalEntity
    {
        public string ID              { set; get; }
        public string InturnNumber    { set; get; }
        public string RFID            { set; get; }
        public string WorkOrderNumber { set; get; }
        public string WorkOrderVersion{ set; get; }
        public string GoodsCode       { set; get; }
        public string AbnormalPoint   { set; get; }
        public string AbnormalType    { set; get; }
        public string AbnormalTime    { set; get; }
        public string AbnormalUser    { set; get; }
        public string AbnormalReason  { set; get; }
        public string SubPlanStatus   { set; get; }
    }

    public class WipAbnormalMtlEntity
    {
        public string ID           { set; get; }
        public string AbnormalID   { set; get; }
        public string InturnNumber { set; get; }
        public string ProcessCode  { set; get; }
        public string ItemNumber   { set; get; }
        public string ItemDsca     { set; get; }
        public string UOM          { set; get; }
        public string LeftQty      { set; get; }
        public string RequireQty   { set; get; }
        public string InventoryQty { set; get; }
    }

    public class ResultMsg
    {
        public string result { set; get; }
        public string msg    { set; get; }
    }

}