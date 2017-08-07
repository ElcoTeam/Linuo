using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace LiNuoMes.Login
{
    public partial class fMenu : System.Web.UI.Page
    {
        static clsSql.Sql mySql = new clsSql.Sql();

        public interface IGetData
        {
            void GetData(DataRow row);
        }
        public class result : IGetData
        {
            public string menuno;
            public string parentno;
            public string img;
            public string menuname;
            public string url;
            public void GetData(DataRow row)
            {
                this.menuno = row["MenuNo"].ToString().Trim() + "";
                this.parentno = row["ParentNo"].ToString().Trim() + "";
                this.img = row["Image1"] + "";
                this.menuname = row["MenuName"] + "";
                this.url = row["MenuAddr"] + ""; 
            }
        }

        public class roletree : IGetData
        {
            public string id;
            public string pId;
            public string img;
            public string name;
            public bool open;
            public void GetData(DataRow row)
            {
                this.id = row["MenuNo"].ToString().Trim() + "";
                this.pId = row["ParentNo"].ToString().Trim() + "";
                this.img = row["Image1"] + "";
                this.name = row["MenuName"] + "";
                this.open = true;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            
        }

        /// <summary>
        /// 生成list
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="dt"></param>
        /// <returns></returns>
        public static List<T> getList<T>(DataTable dt) where T : IGetData, new()
        {
            //dt = GenerateDT();//生成虚拟datatable
            List<T> list = new List<T>();
            foreach (DataRow row in dt.Rows)
            {
                T item = ToEntity<T>(row); ;
                list.Add(item);
            }
            return list;
        }


        private static T ToEntity<T>(DataRow row) where T : IGetData, new()
        {
            T result = new T();
            result.GetData(row);
            return result;
        }

        public static string GetJsonResult<t>(List<t> ARG)
        {
            JavaScriptSerializer Tojson = new JavaScriptSerializer();

            return Tojson.Serialize(ARG);
        }

        [WebMethod]
        public static List<result> GetMenuList()
        {
            DataTable dt = new DataTable("result");
            DataTable dt1 = new DataTable("result");
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;

                string sql = "select distinct MenuNo,ParentNo,Image1,MenuName,MenuAddr from UserM_Menu order by MenuNo";

                string sql1 = "select distinct MenuNo,ParentNo,Image1,MenuName,MenuAddr from View_UserMenuLimit where UserID='" + HttpContext.Current.Session["UserID"].ToString().Trim() + "' order by MenuNo ";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = sql;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = sql1;
                SqlDataAdapter Datapter1 = new SqlDataAdapter(cmd);
                Datapter1.Fill(dt1); 

                if(dt1.Rows.Count>0)
                {
                    if(dt.Rows.Count>0)
                    {
                        for (int i = 0; i < dt.Rows.Count; i++)
                        {
                            int count1 = dt1.Select("MenuNo='" + dt.Rows[i]["MenuNo"].ToString().Trim() + "'").Count();
                            if(count1<=0)
                            {
                                dt.Rows[i]["MenuAddr"] = "#";
                            }
                        }
                    }
                }
                else
                {
                    for (int i = 0; i < dt.Rows.Count;i++ )
                    {
                        dt.Rows[i]["MenuAddr"] = "#";
                    }
                }
                List<result> list = getList<result>(dt);       
                return list;
            }

        }

        [WebMethod]
        public static string GetRoleTree()
        {
            DataTable dt = new DataTable("roletree");
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["ELCO_ConnectionString"].ToString()))
            {
                SqlCommand cmd = new SqlCommand();
                conn.Open();
                cmd.Connection = conn;

                string sql = "select distinct MenuNo,ParentNo,Image1,MenuName,MenuAddr from UserM_Menu order by MenuNo";
                cmd.CommandType = CommandType.Text;
                cmd.CommandText = sql;
                SqlDataAdapter Datapter = new SqlDataAdapter(cmd);
                Datapter.Fill(dt);
                List<roletree> list = getList<roletree>(dt);
                string s = GetJsonResult<roletree>(list);
                //Response.Write(GetJsonResult<result>(list));//这个方法获得json  把这个json传到前台就行了
                return s;
            }

        }
    }
}