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
    /// GetUnPlanedMaterial 的摘要说明
    /// </summary>
    public class GetUnPlanedMaterial : IHttpHandler
    {
        string Action = "";
        JavaScriptSerializer jsc = new JavaScriptSerializer();
        clsSql.Sql cSql = new clsSql.Sql();
        public void ProcessRequest(HttpContext context)
        {
            context.Response.ContentType = "text/plain";
            Action = RequstString("Action");

            if (Action.Length == 0) Action = "";

            if (Action == "GetUnPlanedMaterial_Detail")
            {
                MFG_WO_MTL_List mtlinfo = new MFG_WO_MTL_List();
                mtlinfo.WorkOrderNumber = RequstString("WorkOrderNumber");
                mtlinfo.WorkOrderVersion = RequstString("WorkOrderVersion");
                MFG_WO_MTL_List result = new MFG_WO_MTL_List();
                result = GetUnPlanedMaterial_Detail(mtlinfo, result);
                context.Response.Write(jsc.Serialize(result));
            }
            else if (Action == "UnPlanedMaterialPrintInfo")
            {
                context.Response.Write(GetUnPlanedMaterialPrintInfo());
            }
            else if (Action == "UnPlanedMaterialListInfo") 
            {
                context.Response.Write(GetUnPlanedMaterialInfo());
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

        public MFG_WO_MTL_List GetUnPlanedMaterial_Detail(MFG_WO_MTL_List equinfo, MFG_WO_MTL_List result)
        {

            DataTable dt = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = "select a.ID,a.WorkOrderNumber,a.WorkOrderVersion,a.ItemNumber,b.MesPlanQty from MFG_WO_MTL_List a left join MFG_WO_List b on a.WorkOrderNumber=b.ErpWorkOrderNumber and a.WorkOrderVersion=b.MesWorkOrderVersion";
                if (equinfo.WorkOrderNumber != "")
                {
                    str1 += " WHERE a.WorkOrderNumber = " + equinfo.WorkOrderNumber + " and  a.WorkOrderVersion='"+equinfo.WorkOrderVersion+"'";
                }
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                if (dt != null && dt.Rows.Count > 0)
                {
                    result.ID = dt.Rows[0]["ID"].ToString();
                    result.WorkOrderNumber = dt.Rows[0]["WorkOrderNumber"].ToString();
                    result.WorkOrderVersion = dt.Rows[0]["WorkOrderVersion"].ToString();
                    result.ItemNumber = dt.Rows[0]["ItemNumber"].ToString();
                    result.MesPlanQty = dt.Rows[0]["MesPlanQty"].ToString();
                  
                }
            }
            return result;
        }

        public string GetUnPlanedMaterialInfo()
        {
            string strJson = "";
            string WorkOrderNumber = RequstString("WorkOrderNumber");
            string WorkOrderVersion = RequstString("WorkOrderVersion");
            
            DataTable dt = new DataTable();
            dt = GetUserData(WorkOrderNumber, WorkOrderVersion);
            //int i = 0;
            if (dt != null)
            {
                string page = RequstString("page");
                //String page =Re .getParameter("page"); // 取得当前页数,注意这是jqgrid自身的参数 
                string rows = RequstString("rows");  // 取得每页显示行数，,注意这是jqgrid自身的参数 
                int totalRecord = dt.Rows.Count; // 总记录数(应根据数据库取得，在此只是模拟) 
                int totalPage = totalRecord % Convert.ToInt16(rows) == 0 ? totalRecord
                / Convert.ToInt16(rows) : totalRecord / Convert.ToInt16(rows)
                + 1; // 计算总页数 
                int index = (Convert.ToInt16(page) - 1) * Convert.ToInt16(rows); // 开始记录数 
                int pageSize = Convert.ToInt16(rows);
                strJson = "{\"page\":" + page + ",\"total\": " + totalPage + "  ,\"records\":" + dt.Rows.Count.ToString() + ",\"rows\":[";
                for (int j = index; j < pageSize + index && j < totalRecord; j++)
                {
                    strJson += "{";
                    strJson += "\"id\":\"" + (j + 1).ToString() + "\",";
                    strJson += "\"cell\":";
                    strJson += "[";

                    strJson += "\"" + dt.Rows[j]["ProcessName"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["ItemNumber"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["LeftQty"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["Qty"].ToString() + "\"";

                    strJson += "]";
                    strJson += "}";
                    if (j != pageSize + index - 1 && j != totalRecord - 1)
                    {
                        strJson += ",";
                    }
                }
            }
            else
            {
                strJson = "{\"page\":1,\"total\":0,\"records\":0,\"rows\":[";
            }
            strJson = strJson.Trim().TrimEnd(new char[] { ',' });
            strJson += "]}";
            return strJson;
        }


        public string GetUnPlanedMaterialPrintInfo()
        {
            string strJson = "";
            string WorkOrderNumber = RequstString("WorkOrderNumber");
            string WorkOrderVersion = RequstString("WorkOrderVersion");

            DataTable dt = new DataTable();
            dt = GetMaterialPrintData(WorkOrderNumber, WorkOrderVersion);
            //int i = 0;
            if (dt != null)
            {
                string page = RequstString("page");
                //String page =Re .getParameter("page"); // 取得当前页数,注意这是jqgrid自身的参数 
                string rows = RequstString("rows");  // 取得每页显示行数，,注意这是jqgrid自身的参数 
                int totalRecord = dt.Rows.Count; // 总记录数(应根据数据库取得，在此只是模拟) 
                int totalPage = totalRecord % Convert.ToInt16(rows) == 0 ? totalRecord
                / Convert.ToInt16(rows) : totalRecord / Convert.ToInt16(rows)
                + 1; // 计算总页数 
                int index = (Convert.ToInt16(page) - 1) * Convert.ToInt16(rows); // 开始记录数 
                int pageSize = Convert.ToInt16(rows);
                strJson = "{\"page\":" + page + ",\"total\": " + totalPage + "  ,\"records\":" + dt.Rows.Count.ToString() + ",\"rows\":[";
                for (int j = index; j < pageSize + index && j < totalRecord; j++)
                {
                    strJson += "{";
                    strJson += "\"id\":\"" + (j + 1).ToString() + "\",";
                    strJson += "\"cell\":";
                    strJson += "[";
                    //strJson += "\"" + dt.Rows[j]["ID"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["ItemNumber"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["ItemDsca"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["UOM"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["Qty"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["RealNum"].ToString() + "\",";
                    strJson += "\"" + dt.Rows[j]["Sign"].ToString() + "\"";

                    strJson += "]";
                    strJson += "}";
                    if (j != pageSize + index - 1 && j != totalRecord - 1)
                    {
                        strJson += ",";
                    }
                }
            }
            else
            {
                strJson = "{\"page\":1,\"total\":0,\"records\":0,\"rows\":[";
            }
            strJson = strJson.Trim().TrimEnd(new char[] { ',' });
            strJson += "]}";
            return strJson;
        }

        public DataTable GetUserData(string WorkOrderNumber,string WorkOrderVersion)
        {
            string str = "";
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                str = "select b.ProcessName, a.ItemNumber,a.LeftQty,a.Qty from MFG_WO_MTL_List a left join Mes_Process_List b on a.ProcessCode=b.ProcessCode where a.WorkOrderNumber='" + WorkOrderNumber.Trim() + "' and a.WorkOrderVersion='"+WorkOrderVersion.Trim()+"'";
                //str += "order by OrderNo,ResponseState";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);

                return dt;
            }
        }

        public DataTable GetMaterialPrintData(string WorkOrderNumber, string WorkOrderVersion)
        {
            string str = "";
            DataTable dt = new DataTable();
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                str = "select '' as ID, a.ItemNumber,a.ItemDsca,a.UOM,a.Qty,'' as RealNum,'' as Sign from MFG_WO_MTL_List a left join Mes_Process_List b on a.ProcessCode=b.ProcessCode where a.WorkOrderNumber='" + WorkOrderNumber.Trim() + "' and a.WorkOrderVersion='" + WorkOrderVersion.Trim() + "'";
                //str += "order by OrderNo,ResponseState";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                if(dt.Rows.Count>0)
                {
                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        dt.Rows[i]["ID"] = (i + 1).ToString();
                    }
                }
                return dt;
            }
        }
    }

    public class MFG_WO_MTL_List
    {
        public string ID { get; set; }
        public string WorkOrderNumber { set; get; }
        public string WorkOrderVersion { set; get; }
        public string ItemNumber { set; get; }
        public string MesPlanQty { set; get; }

    }
}