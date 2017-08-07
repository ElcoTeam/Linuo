using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using clsSql;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Security.Policy;

namespace LiNuoMes.BaseConfig
{
    public partial class LineConfig : System.Web.UI.Page
    {
        static clsSql.Sql mySql = new clsSql.Sql();

     //   static String UserID;
        protected void Page_Load(object sender, EventArgs e)
        {
     //       UserID = Session["NewUserID"].ToString();
        }

    }
}