using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using LiNuoMes.Model;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.SessionState;

namespace LiNuoMes.Mfg
{
    /// <summary>
    /// GetMaterialBkfInfo 的摘要说明
    /// </summary>
    public class GetMaterialBkfInfo : IHttpHandler, IReadOnlySessionState
    {
        JavaScriptSerializer jsc = new JavaScriptSerializer();
        string UserName = "";
        string Action = "";
       
        public void ProcessRequest(HttpContext context)
        {
           
            context.Response.ContentType = "text/plain";
            if (context.Session["UserName"] != null)
                UserName = context.Session["UserName"].ToString().ToUpper().Trim();
            else
                UserName = "";

            Action = RequstString("Action");

            if (Action.Length == 0) Action = "";

            //反冲料申请
            if (Action == "MFG_WIP_BKF_APPLY_LIST")
            {
                List<MaterialBfkApply> dataEntity;
                dataEntity = new List<MaterialBfkApply>();
                dataEntity = getMaterialApplyList(dataEntity);
                context.Response.Write(jsc.Serialize(dataEntity));
            }

            //反冲料响应
            if (Action == "MFG_WIP_BKF_RESPONSE_LIST")
            {
                List<MaterialBfkResponse> dataEntity;
                dataEntity = new List<MaterialBfkResponse>();
                dataEntity = getMaterialResponseList(dataEntity);
                context.Response.Write(jsc.Serialize(dataEntity));
            }

            //反冲料确认
            if (Action == "MFG_WIP_BKF_CONFIRM_LIST")
            {
                List<MaterialBfkConfirm> dataEntity;
                dataEntity = new List<MaterialBfkConfirm>();
                dataEntity = getMaterialConfirmList(dataEntity);
                context.Response.Write(jsc.Serialize(dataEntity));
            }

            //反冲料 领料单
            if (Action == "MaterialBfkReport")
            {
                List<MaterialBfkReport> dataEntity;
                dataEntity = new List<MaterialBfkReport>();
                dataEntity = getMaterialReportList(dataEntity);
                context.Response.Write(jsc.Serialize(dataEntity));
            }

            context.Response.End();
        }

        /// <summary>
        /// 反冲料申请列表
        /// </summary>
        /// <param name="dataEntity"></param>
        /// <returns></returns>
        public List<MaterialBfkApply> getMaterialApplyList(List<MaterialBfkApply> dataEntity)
        {
            string StartDate = RequstString("StartDate");
            string FinishDate = RequstString("FinishDate");
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Mfg_Wip_Bkf_Apply_List";
                SqlParameter[] sqlPara = new SqlParameter[2];
                sqlPara[0] = new SqlParameter("@StartTime", StartDate+" 00:00:00");
                sqlPara[1] = new SqlParameter("@EndTime", FinishDate+" 23:59:59");
                cmd.Parameters.Add(sqlPara[0]);
                cmd.Parameters.Add(sqlPara[1]);
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        MaterialBfkApply itemList = new MaterialBfkApply();
                        itemList.ID = dt.Rows[i]["ID"].ToString();
                        itemList.InturnNumber = (i + 1).ToString();
                        itemList.ItemNumber = dt.Rows[i]["ItemNumber"].ToString();
                        itemList.ItemDsca = dt.Rows[i]["ItemDsca"].ToString();
                        itemList.UOM = dt.Rows[i]["UOM"].ToString();
                        itemList.ApplyQty = dt.Rows[i]["ApplyQty"].ToString();
                        itemList.ApplyUser = dt.Rows[i]["ApplyUser"].ToString();
                        itemList.ApplyTime = dt.Rows[i]["ApplyTime"].ToString();
                        itemList.Status = dt.Rows[i]["Status"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }



        /// <summary>
        /// 反冲料响应列表
        /// </summary>
        /// <param name="dataEntity"></param>
        /// <returns></returns>
        public List<MaterialBfkResponse> getMaterialResponseList(List<MaterialBfkResponse> dataEntity)
        {
            string materialcode = RequstString("materialcode");
            string StartDate = RequstString("PullTimeStart");
            string FinishDate = RequstString("PullTimeEnd");
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Mfg_Wip_Bkf_Response_List";
                SqlParameter[] sqlPara = new SqlParameter[3];
                sqlPara[0] = new SqlParameter("@materialcode",materialcode );
                sqlPara[1] = new SqlParameter("@StartTime", StartDate + " 00:00:00");
                sqlPara[2] = new SqlParameter("@EndTime", FinishDate + " 23:59:59");
                cmd.Parameters.Add(sqlPara[0]);
                cmd.Parameters.Add(sqlPara[1]);
                cmd.Parameters.Add(sqlPara[2]);
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        MaterialBfkResponse itemList = new MaterialBfkResponse();
                        itemList.ID = dt.Rows[i]["ID"].ToString();
                        //itemList.InturnNumber = (i + 1).ToString();
                        itemList.ItemNumber = dt.Rows[i]["ItemNumber"].ToString();
                        itemList.ItemDsca = dt.Rows[i]["ItemDsca"].ToString();
                        itemList.UOM = dt.Rows[i]["UOM"].ToString();
                        itemList.ApplyQty = dt.Rows[i]["ApplyQty"].ToString();
                        itemList.ApplyUser = dt.Rows[i]["ApplyUser"].ToString();
                        itemList.ApplyTime = dt.Rows[i]["ApplyTime"].ToString();
                        itemList.Status = dt.Rows[i]["Status"].ToString();
                        itemList.ActionQty = dt.Rows[i]["ActionQty"].ToString();
                        itemList.ActionTime = dt.Rows[i]["ActionTime"].ToString();
                        itemList.ActionUser = dt.Rows[i]["ActionUser"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        /// <summary>
        /// 反冲料确认列表
        /// </summary>
        /// <param name="dataEntity"></param>
        /// <returns></returns>
        public List<MaterialBfkConfirm> getMaterialConfirmList(List<MaterialBfkConfirm> dataEntity)
        {
            string materialcode = RequstString("materialcode");
            string StartDate = RequstString("PullTimeStart");
            string FinishDate = RequstString("PullTimeEnd");
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Mfg_Wip_Bkf_Confirm_List";
                SqlParameter[] sqlPara = new SqlParameter[3];
                sqlPara[0] = new SqlParameter("@materialcode", materialcode);
                sqlPara[1] = new SqlParameter("@StartTime", StartDate + " 00:00:00");
                sqlPara[2] = new SqlParameter("@EndTime", FinishDate + " 23:59:59");
                cmd.Parameters.Add(sqlPara[0]);
                cmd.Parameters.Add(sqlPara[1]);
                cmd.Parameters.Add(sqlPara[2]);
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                if (dt != null)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        MaterialBfkConfirm itemList = new MaterialBfkConfirm();
                        itemList.ID = dt.Rows[i]["ID"].ToString();
                        //itemList.InturnNumber = (i + 1).ToString();
                        itemList.ItemNumber = dt.Rows[i]["ItemNumber"].ToString();
                        itemList.ItemDsca = dt.Rows[i]["ItemDsca"].ToString();
                        itemList.UOM = dt.Rows[i]["UOM"].ToString();
                        itemList.ApplyQty = dt.Rows[i]["ApplyQty"].ToString();
                        itemList.ApplyUser = dt.Rows[i]["ApplyUser"].ToString();
                        itemList.ApplyTime = dt.Rows[i]["ApplyTime"].ToString();
                        itemList.Status = dt.Rows[i]["Status"].ToString();
                        itemList.ActionQty = dt.Rows[i]["ActionQty"].ToString();
                        itemList.ActionTime = dt.Rows[i]["ActionTime"].ToString();
                        itemList.ActionUser = dt.Rows[i]["ActionUser"].ToString();
                        itemList.ConfirmTime = dt.Rows[i]["ConfirmTime"].ToString();
                        itemList.ConfirmUser = dt.Rows[i]["ConfirmUser"].ToString();
                        itemList.ConfirmQty = dt.Rows[i]["ConfirmQty"].ToString();
                        dataEntity.Add(itemList);
                    }
                }
            }
            return dataEntity;
        }

        /// <summary>
        /// 反冲料补货单
        /// </summary>
        /// <param name="dataEntity"></param>
        /// <returns></returns>
        public List<MaterialBfkReport> getMaterialReportList(List<MaterialBfkReport> dataEntity)
        {
            
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandText = "usp_Mfg_Wip_Bkf_Report_List";
                //SqlParameter[] sqlPara = new SqlParameter[3];
                //sqlPara[0] = new SqlParameter("@materialcode", materialcode);
                //sqlPara[1] = new SqlParameter("@StartTime", StartDate + " 00:00:00");
                //sqlPara[2] = new SqlParameter("@EndTime", FinishDate + " 23:59:59");
                //cmd.Parameters.Add(sqlPara[0]);
                //cmd.Parameters.Add(sqlPara[1]);
                //cmd.Parameters.Add(sqlPara[2]);
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                if (dt != null)
                {
                   
                     for (int i = 0; i < dt.Rows.Count; i++)
                     {
                         MaterialBfkReport itemList = new MaterialBfkReport();
                         itemList.ID = (i + 1).ToString();
                         itemList.InturnNumber = dt.Rows[i]["ID"].ToString();
                         itemList.ItemNumber = dt.Rows[i]["ItemNumber"].ToString();
                         itemList.ItemDsca = dt.Rows[i]["ItemDsca"].ToString();
                         itemList.UOM = dt.Rows[i]["UOM"].ToString();
                         itemList.ApplyQty = dt.Rows[i]["ApplyQty"].ToString();
                         itemList.ConfirmQty = dt.Rows[i]["ConfirmQty"].ToString();
                         itemList.Remark = "";
                         dataEntity.Add(itemList);
                     } 
                    
                }

                if (dt.Rows.Count<8)
                {
                    for (int i = dt.Rows.Count; i < 8; i++)
                    {
                        MaterialBfkReport itemList = new MaterialBfkReport();
                        itemList.ID = "";
                        //itemList.InturnNumber = (i + 1).ToString();
                        itemList.ItemNumber = "";
                        itemList.ItemDsca = "";
                        itemList.UOM = "";
                        itemList.ApplyQty = "";
                        itemList.ConfirmQty ="";
                        itemList.Remark = "";
                        dataEntity.Add(itemList);
                    } 

                }
            }
            return dataEntity;
        }

        public static string RequstString(string sParam)
        {
            String ret = String.Empty;
            try
            {
                ret = (HttpContext.Current.Request[sParam] == null ? string.Empty
                      : HttpContext.Current.Request[sParam].ToString().Trim());
            }
            catch (Exception)
            {
                ret = "";
            }
            return ret;
        }

        public bool IsReusable
        {
            get
            {
                return false;
            }
        }
    }
}