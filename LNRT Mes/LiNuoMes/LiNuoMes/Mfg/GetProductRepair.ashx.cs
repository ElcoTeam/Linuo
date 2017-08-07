using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;

namespace LiNuoMes.Mfg
{
    /// <summary>
    /// GetProductRepair 的摘要说明
    /// </summary>
    public class GetProductRepair : IHttpHandler
    {
        string Action = "";
        JavaScriptSerializer jsc = new JavaScriptSerializer();
        clsSql.Sql cSql = new clsSql.Sql();

        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            context.Response.ContentType = "text/plain";
            Action = RequstString("Action");

            if (Action.Length == 0) Action = "";

            if (Action == "MFG_ProductRepairInfo")
            {
                List<ProductRepairInfo> dataEntity;
                dataEntity = new List<ProductRepairInfo>();
                dataEntity = GetProductRepairList(dataEntity);
                context.Response.Write(jsc.Serialize(dataEntity));
            }
            else if (Action == "ProductRepair_Detail")
            {
                ProductRepairInfo dataEntity = new ProductRepairInfo();
                dataEntity.ID = RequstString("EquID");
                ProductRepairInfo result = new ProductRepairInfo();
                result = GetProductRepairDetail(dataEntity,result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "ProductRepair_Repair" || Action == "ProductRepair_Edit")
            {
                ProductRepairInfo dataEntity = new ProductRepairInfo();
                //dataEntity.ID = RequstString("EquID");
                ResultMsg result = new ResultMsg();
                result = RepairProduct(dataEntity, result);
                context.Response.Write(jsc.Serialize(result));
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


        public List<ProductRepairInfo> GetProductRepairList(List<ProductRepairInfo> dataEntity)
        {
            DataTable dt = new DataTable();
            string str = "";
            string RFID = RequstString("RFID");
            string WorkOrderNumber = RequstString("WorkOrderNumber");
            string GoodsCode = RequstString("GoodsCode");
            string AbnormalPoint = RequstString("AbnormalPoint");
            string AbnormalType = RequstString("AbnormalType");
            string RepairStatus = RequstString("RepairStatus");
            string FromTime = RequstString("FromTime");
            string ToTime = RequstString("ToTime");
            string RepairFromTime = RequstString("RepairFromTime");
            string RepairToTime = RequstString("RepairToTime");

            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                str = " SELECT  AB.ID,AB.RFID,AB.AbnormalPoint,AB.AbnormalType,AB.RepairStatus, CONVERT(varchar(100), AB.AbnormalTime, 120)  as AbnormalTime,AB.AbnormalUser,CONVERT(varchar(100), AB.RepairTime, 120)  as RepairTime,AB.RepairUser,WO.ErpGoodsCode as GoodsCode,WO.ErpWorkOrderNumber WorkOrderNumber FROM MFG_WIP_Data_Abnormal AB left join  MFG_WO_List WO   on AB.WorkOrderNumber= WO.ErpWorkOrderNumber AND AB.WorkOrderVersion= WO.MesWorkOrderVersion where WO.ErpWorkOrderNumber like '%" + WorkOrderNumber.Trim() + "%' and WO.ErpGoodsCode like '%" + GoodsCode.Trim() + "%' and AB.RFID like '%" + RFID.Trim() + "%'";

                if (AbnormalPoint != "")
                {
                    str += " and AB.AbnormalPoint='" + AbnormalPoint.Trim() + "'";
                }
                if (AbnormalType != "")
                {
                    str += " and AB.AbnormalType='" + AbnormalType.Trim() + "'";
                }
                if (RepairStatus != "")
                {
                    str += " and AB.RepairStatus='" + RepairStatus.Trim() + "'";
                }
                if (FromTime != "" && ToTime != "")
                {
                    str += " and AB.AbnormalTime between '" + FromTime + " 00:00:00' and '" + ToTime + " 23:59:59'";
                }
                if (RepairFromTime != "" && RepairToTime != "")
                {
                    str += " and AB.RepairTime between '" + RepairFromTime + " 00:00:00' and '" + RepairToTime + " 23:59:59'";
                }
                str += " order by AB.RepairStatus";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        ProductRepairInfo itemList = new ProductRepairInfo();
                        itemList.ID = dt.Rows[i]["ID"].ToString();
                        itemList.InturnNumber = (i + 1).ToString();
                        itemList.WorkOrderNumber = dt.Rows[i]["WorkOrderNumber"].ToString();
                        itemList.RFID = dt.Rows[i]["RFID"].ToString();
                        itemList.GoodsCode = dt.Rows[i]["GoodsCode"].ToString();
                        itemList.AbnormalPoint = dt.Rows[i]["AbnormalPoint"].ToString();
                        itemList.AbnormalType = dt.Rows[i]["AbnormalType"].ToString();
                        itemList.RepairStatus = dt.Rows[i]["RepairStatus"].ToString();
                        itemList.AbnormalUser = dt.Rows[i]["AbnormalUser"].ToString();
                        itemList.AbnormalTime = dt.Rows[i]["AbnormalTime"].ToString();
                        itemList.RepairTime = dt.Rows[i]["RepairTime"].ToString();
                        itemList.RepairUser = dt.Rows[i]["RepairUser"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        public ProductRepairInfo GetProductRepairDetail(ProductRepairInfo equinfo, ProductRepairInfo result)
        {

            DataTable dt = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = "SELECT  AB.ID,AB.RFID,AB.AbnormalPoint,AB.AbnormalType,AB.RepairStatus, CONVERT(varchar(100), AB.AbnormalTime, 120)  as AbnormalTime,AB.AbnormalUser,CONVERT(varchar(100), AB.RepairTime, 120)  as RepairTime,AB.RepairUser,WO.ErpGoodsCode as GoodsCode,WO.ErpWorkOrderNumber WorkOrderNumber,AB.RepairComment FROM MFG_WIP_Data_Abnormal AB left join  MFG_WO_List WO   on AB.WorkOrderNumber= WO.ErpWorkOrderNumber AND AB.WorkOrderVersion= WO.MesWorkOrderVersion";

                if (equinfo.ID != "")
                {
                    str1 += " WHERE AB.ID = " + equinfo.ID + " ";
                }
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null && dt.Rows.Count > 0)
                {
                    result.ID = dt.Rows[0]["ID"].ToString();
                    result.WorkOrderNumber = dt.Rows[0]["WorkOrderNumber"].ToString();
                    result.RFID = dt.Rows[0]["RFID"].ToString();
                    result.GoodsCode = dt.Rows[0]["GoodsCode"].ToString();
                    result.AbnormalPoint = dt.Rows[0]["AbnormalPoint"].ToString();
                    result.AbnormalType = dt.Rows[0]["AbnormalType"].ToString();
                    result.RepairStatus = dt.Rows[0]["RepairStatus"].ToString();
                    result.AbnormalUser = dt.Rows[0]["AbnormalUser"].ToString();
                    result.AbnormalTime = dt.Rows[0]["AbnormalTime"].ToString();
                    result.RepairTime = dt.Rows[0]["RepairTime"].ToString();
                    result.RepairUser = dt.Rows[0]["RepairUser"].ToString();
                    result.RepairUser = dt.Rows[0]["RepairComment"].ToString();
                }
            }
            return result;
        }

        public ResultMsg RepairProduct(ProductRepairInfo dataEntity, ResultMsg result)
        {
            dataEntity.ID = RequstString("EquID");
            dataEntity.RepairTime = RequstString("RepairTime");
            dataEntity.RepairUser = RequstString("RepairUser");
            dataEntity.RepairComment = RequstString("RepairComment");
     
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

                    sqlPara[0] = new SqlParameter("@ID", Convert.ToInt32(dataEntity.ID));
                    sqlPara[1] = new SqlParameter("@RepairTime", dataEntity.RepairTime);
                    sqlPara[2] = new SqlParameter("@RepairUser", dataEntity.RepairUser);
                    sqlPara[3] = new SqlParameter("@RepairComment", dataEntity.RepairComment);
                    sqlPara[4] = new SqlParameter("@CatchFlag", 0);
                    sqlPara[4].Direction = ParameterDirection.Output;
                    cmd.CommandType = CommandType.StoredProcedure;

                    if (Action == "ProductRepair_Edit")
                    {
                        cmd.CommandText = "usp_Mfg_Product_RepairEdit";
                    }
                    else if (Action == "ProductRepair_Repair")
                    {
                        cmd.CommandText = "usp_Mfg_Product_RepairAdd";
                    }

                    foreach (SqlParameter para in sqlPara)
                    {
                        cmd.Parameters.Add(para);
                    }

                    cmd.ExecuteNonQuery();

                    if (sqlPara[4].Value.ToString() == "1")
                    {
                        transaction.Rollback();
                        result.result = "failed";
                        result.msg = "补修信息已经超过三天无法编辑";
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
    }

    public class ProductRepairInfo
    {
        public string ID { set; get; }
        public string InturnNumber { set; get; }
        public string RFID { set; get; }
        public string WorkOrderNumber { set; get; }
        public string WorkOrderVersion { set; get; }
        public string GoodsCode { set; get; }
        public string AbnormalPoint { set; get; }
        public string AbnormalType { set; get; }
        public string AbnormalTime { set; get; }
        public string RepairTime { set; get; }
        public string RepairStatus { set; get; }
        public string RepairUser { set; get; }
        public string AbnormalUser { set; get; }
        public string AbnormalReason { set; get; }
        public string RepairComment { set; get; }
    }

   
}