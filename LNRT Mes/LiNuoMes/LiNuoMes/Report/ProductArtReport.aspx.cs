using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using LiNuoMes.Common;

namespace LiNuoMes.Report
{
    public partial class ProductArtReport : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static string GetArtName(string deviceid)
        {
            DataTable tb = new DataTable();
            string ReturnValue = string.Empty;
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;
                string str1 = string.Format(
                    @"select art.ArtName from Equ_DeviceInfoList device
                       left join Mes_ProcessArtList art on device.ProcessCode = art.ProcessCode 
                            where device.DeviceCode='{0}'",
                       deviceid
                    );
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = str1;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(tb);
                ReturnValue = DataToJson.DataTableJson(tb);
                return ReturnValue;
            }
        }
    }
}